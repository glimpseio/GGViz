import Foundation
import MiscKit
import Judo

/// Uses `JXKit` and `GGSchema`
///
/// Uses: `JXContext.installGGViz`
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
open class VizEngine {
    /// The underlying context for the engine
    open var ctx: JXContext

    let gv: JXValue

    let glance: JXValue
    let vg: JXValue
    let vge: JXValue
    let vgg: JXValue

    let vgg_compile: JXValue
    let vg_read: JXValue
    let vg_parse: JXValue
    let vg_loader: JXValue
    let vg_loader_load: JXValue

    let vg_View: JXValue

    let ggviz_render: JXValue
    let ggviz_compile: JXValue

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    public init(ctx: JXContext = JXContext(), fetcher: JXContext.DataFetchHandler? = nil) throws {
        self.ctx = ctx

        try ctx.installConsole()

        // install the data fetcher if a delegate was supplied
        if let fetcher = fetcher {
            ctx.installFetch(fetcher)
        }

        try ctx.installGGViz()

        /// Verifies that the given instance is a function or object
        func check(isFunction: Bool = false, _ value: JXValue) throws -> JXValue {
            if !value.isObject {
                throw err("Value was not an object")
            }
            if isFunction && !value.isFunction {
                throw err("Value was not a function")
            }
            return value
        }

        self.gv = try check(ctx["ggviz"])

        // cache commonly-used functions

        let version = gv["version"]
        dbg("initializing ggviz version", version.stringValue)

        self.glance = try check(gv["glance"])
        self.vg = try check(gv["vg"])
        self.vge = try check(gv["vge"])
        self.vgg = try check(gv["vgg"])

        self.vg_read = try check(isFunction: true, vg["read"])
        self.vg_parse = try check(isFunction: true, vg["parse"])

        self.vg_loader = try check(isFunction: true, vg["loader"])
        self.vg_loader_load = try check(isFunction: true, vg_loader.call()["load"])

        self.vgg_compile = try check(vgg["compile"])

        self.vg_View = try check(vg["View"])

        self.ggviz_render = try check(isFunction: true, glance["render"])

        // use a custom compile step that captures the logged output and returns it as a `CompileOutput`
        self.ggviz_compile = try check(ctx.eval("""
            (function(spec, normalize) {
                var warn = [];
                var info = [];
                var debug = [];
                var logger = {
                    warn: function() { for (let arg of arguments) { warn.push(arg) } },
                    info: function() { for (let arg of arguments) { info.push(arg) } },
                    debug: function() { for (let arg of arguments) { debug.push(arg) } }
                };

                const compiled = ggviz.vgg.compile(spec, { logger: logger });

                const ret = {
                    vega: compiled.spec,
                    normalized: normalize ? compiled.normalized : null,
                    warn: warn,
                    info: info,
                    debug: debug
                };

                return ret;
            })
            """))
    }

    deinit {

    }
}


@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
public extension VizEngine {

    /// Returns the resource for the script with the given mode.
    ///
    /// - Parameter min: whether to return the minified (`true`), non-minified (`false`) or module (`nil`) form of the script
    static func engineScript(min: Bool?) -> URL? {
        switch min {
        case .none:
            return Bundle.moduleResource(named: "ggviz.module", withExtension: "js", in: .module)
        case .some(true):
            return Bundle.moduleResource(named: "ggviz.min", withExtension: "js", in: .module)
        case .some(false):
            return Bundle.moduleResource(named: "ggviz", withExtension: "js", in: .module)
        }
    }

    /// The type of data that is being read
    enum ReadDataType : String, CaseIterable, Hashable { case json, csv, tsv, topojson }

    /// Reads the data source in the given format
    func readData(_ source: String, type: ReadDataType) throws -> JXValue {
        if !vg_read.isFunction { throw err("vg_loader_load was not a function") }
        try ctx.throwException()
        // https://www.npmjs.com/package/vega-loader#read
        let schema: Bric = [
            "type": .str(type.rawValue),
            "parse": "auto",
            //"property": "",
        ]

        let result = vg_read.call(withArguments: [ctx.string(source), try ctx.encode(schema)])

        // doesn't work because vega's parsing doesn't handle ArrayBuffer (only node's Buffer)
        //let result = vg_read.call(withArguments: [ctx.data(source), try ctx.encode(schema)])
        //let result = try ctx.withArrayBuffer(source: source) { arrayBuffer in
        //    vg_read.call(withArguments: [arrayBuffer, try ctx.encode(schema)])
        //}
        
        try ctx.throwException()
        return result
    }

    /// Compiles a spec and returns the compiled result
    func loadData(_ source: Data) throws -> String? {
        #warning("not yet working")
        if !vg_loader_load.isFunction { throw err("vg_loader_load was not a function") }
        try ctx.throwException()
        ctx.installTimer(immediate: true) { duration, item in
            return JXContext.dispatchScheduler(qos: .default)(duration, item)
        }
        let result = vg_loader_load.call(withArguments: [ctx.data(source)])
        try ctx.throwException()

        return result.stringValue
    }

    /// Compiles a spec and returns the compiled result
    func compileGrammar<T: VizSpecMeta>(spec: VizSpec<T>, normalize: Bool) throws -> CompileOutput<T> {
        try ctx.trying {
            try ggviz_compile.call(withArguments: [ctx.encode(spec), ctx.boolean(normalize)])
        }.toDecodable(ofType: CompileOutput.self)
    }

    func parseViz(_ spec: JXValue) throws -> JXValue {
        try ctx.trying {
            vg_parse.call(withArguments: [spec])
        }
    }

    /// Renders the visualization synchronously.
    ///
    /// - Parameters:
    ///   - spec: the GGViz spec to render
    ///   - data: external data to inject
    ///   - returnData: whether `RenderRequestKey.returnData` should be set, resulting in the `RenderResponseKey.data` key
    ///   - returnSVG: whether `RenderRequestKey.returnSVG` should be set, resulting in the `RenderResponseKey.svg` key
    ///   - returnCanvas: whether `RenderRequestKey.returnCanvas` should be set, resulting in the `RenderResponseKey.canvas` key
    ///   - returnScenegraph: whether `RenderRequestKey.returnScenegraph` should be set, resulting in the `RenderResponseKey.scenegraph` key
    ///   - externalCanvas: the canvas implementation to draw into
    ///
    /// - Returns: the response dictionary, which will contain keys based on the parameters.
    func renderViz<M: VizSpecMeta>(spec: VizSpec<M>, data: [String: [Bric]]? = nil, returnData: Bool? = nil, returnSVG: Bool? = nil, returnScenegraph: Bool? = nil, canvas externalCanvas: CanvasAPI? = nil) throws -> JXValue {
        var opts: [RenderRequestKey: JXValue] = [:]
        opts[.spec] = try ctx.encode(spec)

        if let data = data {
            opts[.data] = try ctx.encode(data)
        }

        if let externalCanvas = externalCanvas {
            // Judo.Canvas is a live canvas that interacts with the CanvasAPI
            opts[.externalCanvas] = try Canvas(env: ctx, delegate: externalCanvas)
            opts[.returnCanvas] = ctx.boolean(true)
        }

        if let returnData = returnData {
            opts[.returnData] = ctx.boolean(returnData)
        }

        if let returnSVG = returnSVG {
            opts[.returnSVG] = ctx.boolean(returnSVG)
        }

        if let returnScenegraph = returnScenegraph {
            opts[.returnScenegraph] = ctx.boolean(returnScenegraph)
        }


        return try performRender(opts)
    }

    /// Renders the spec with the given options
    /// - Parameter options: the rendering options
    /// - Returns: an object value with keys defined in `RenderResponseKey`
    internal func performRender(_ options: [RenderRequestKey: JXValue]) throws -> JXValue {
        let opts = JXValue(newObjectIn: ctx)
        for (key, value) in options {
            opts[key.rawValue] = value
        }

        return try ctx.trying {
            ggviz_render.call(withArguments: [opts])
        }
    }
    /// The keys that can be used to specify data requests.
    /// - Note: These keys must be kept in sync with the equivalent keys in `ggviz.js`
    internal enum RenderRequestKey : String {
        /// The specification grammar to render (exclusive with `vegaSpec`)
        case spec = "spec"
        /// The compiler vega spec to render (exclusive with `spec`)
        case vegaSpec = "vegaSpec"
        /// A `Canvas` implementation into which the spec should be rendered
        case externalCanvas = "externalCanvas"
        /// The data to render
        case data = "data"

        /// Whether to force headless mode
        case headless = "headless"
        /// The DOM's element ID to place the rendered output
        case elementID = "elementID"

        /// Whether `RenderResponseKey.data` should be set
        case returnData = "returnData"
        /// Whether `RenderResponseKey.svg` should be set
        case returnSVG = "returnSVG"
        /// Whether `RenderResponseKey.scenegraph` should be set
        case returnScenegraph = "returnScenegraph"
        /// Whether `RenderResponseKey.canvas` should be set
        case returnCanvas = "returnCanvas"
    }

    /// The keys that the `Glance.render()` JS function will contain in the returned JSON `Bric`
    enum RenderResponseKey : String {
        /// The key that contains the JSON data from the rendered spec
        /// - See also: `VegaHeadlessRenderOptions.data`
        case data = "data"

        /// The key that contains the SVG output from the rendered spec
        /// - See also: `VegaHeadlessRenderOptions.svg`
        case svg = "svg"

        /// The key that contains the scenegraph output from the rendered spec
        case scenegraph = "scenegraph"

        /// The key that contains the native canvas – not used because canvas cannot be serialized
        /// - See also: `VegaHeadlessRenderOptions.canvas`
        case canvas = "canvas"

        /// The internal variable that holds the native canvas instance
        case canvasNative = "__NativeCanvas"

        /// The key that indicates that we will be requesting this return value
//        public var requestKey: RenderRequestKey {
//            switch self {
//            case .data: return .returnData
//            case .svg: return .returnSVG
//            case .scenegraph: return .returnScenegraph
//            case .canvas, .canvasNative: return .returnCanvas
//            }
//        }
    }

    /// The result of compiling a GGSchema
    struct CompileOutput<Meta: VizSpecMeta> : Decodable {
        public var vega: Bric
        public var normalized: VizSpec<Meta>?
        public var warn: [String]?
        public var info: [String]?
        public var debug: [String]?

        public init(vega: Bric, normalized: VizSpec<Meta>? = nil, warn: [String]? = nil, info: [String]? = nil, debug: [String]? = nil) {
            self.vega = vega
            self.normalized = normalized
            self.warn = warn
            self.info = info
            self.debug = debug
        }
    }
}

extension JXContext {
    /// Installs the GGViz module into `ggviz`.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    @discardableResult public func installGGViz(min: Bool? = false) throws -> JXValType {
        let propertyName = "ggviz"
        let _ = self.globalObject(property: "global") // ggviz needs "global" (probably for console)
        let exports = self.globalObject(property: "exports")
        let ggviz = exports[propertyName]
        if ggviz.isObject {
            return ggviz
        } else {
            // this will be "ggviz" or "ggviz.min" based on the flag
            let moduleName = VizEngine.engineScript(min: min)?.deletingPathExtension().lastPathComponent ?? "ggviz"
            exports[propertyName] = try installModule(named: moduleName, in: .module)
            return exports[propertyName]
        }
    }
}


//public func getModule(for bundle: Bundle) throws -> Bundle {
//    return bundle
//}
//
///// The bundle for GGViz
//public typealias GGVizBundle = getModule(for: .module)
