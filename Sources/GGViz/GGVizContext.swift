import MiscKit
import Judo

/// Uses `JXKit` and `GGSpec`
///
/// Uses: `JXContext.installGGViz`
open class GGVizContext {
    open var ctx: JXContext

    let gv: JXValue

    let glance: JXValue
    let vg: JXValue
    let vge: JXValue
    let vgg: JXValue

    let vgg_compile: JXValue
    let vg_parse: JXValue
    let vg_View: JXValue

    let ggviz_render: JXValue
    let ggviz_compile: JXValue

    public init(ctx: JXContext = JXContext()) throws {
        self.ctx = ctx

        try ctx.installConsole()
        try ctx.installGGViz()


//        try ctx.eval(script: """
//        console.log("ggviz", glimpseviz);
//        console.log("ggviz.vl", Object.keys(glimpseviz));
//        """)

        func check(_ value: JXValue) throws -> JXValue {
            if !value.isObject {
                throw err("Value was not an object")
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

        self.vg_parse = try check(vg["parse"])

        self.vgg_compile = try check(vgg["compile"])

        self.vg_View = try check(vg["View"])

        self.ggviz_render = try check(glance["render"])

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

public extension GGVizContext {

    /// Returns the resource for the script.
    ///
    /// - Parameter min: whether to return the minified (`true`), non-minified (`false`) or module (`nil`) form of the script
    static func ggvizResource(min: Bool?) -> URL? {
        switch min {
        case .none:
            return Bundle.module.url(forResource: "ggviz.module", withExtension: "js")
        case .some(true):
            return Bundle.module.url(forResource: "ggviz.min", withExtension: "js")
        case .some(false):
            return Bundle.module.url(forResource: "ggviz", withExtension: "js")
        }
    }

    /// Compiles a spec
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

    func renderViz<M: VizSpecMeta>(spec: VizSpec<M>, returnData: Bool? = nil, returnSVG: Bool? = nil, returnCanvas: Bool? = nil, returnScenegraph: Bool? = nil, canvas externalCanvas: Judo.Canvas? = nil) throws -> JXValue {
        var opts: [RenderRequestKey: JXValue] = [:]
        opts[.spec] = try ctx.encode(spec)

        if let externalCanvas = externalCanvas {
            // no need to encode: Judo.Canvas is a JXValue reference
            opts[.externalCanvas] = externalCanvas
        }

        if let returnData = returnData {
            opts[.returnData] = try ctx.encode(returnData)
        }

        if let returnSVG = returnSVG {
            opts[.returnSVG] = try ctx.encode(returnSVG)
        }

        if let returnScenegraph = returnScenegraph {
            opts[.returnScenegraph] = try ctx.encode(returnScenegraph)
        }

        if let returnCanvas = returnCanvas {
            opts[.returnCanvas] = try ctx.encode(returnCanvas)
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

    /// The result of compiling a GGSpec
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
    @discardableResult public func installGGViz(min: Bool? = false) throws -> JXValType {
        let propertyName = "ggviz"
        let _ = self.globalObject(property: "global") // ggviz needs "global" (probably for console)
        let exports = self.globalObject(property: "exports")
        let ggviz = exports[propertyName]
        if ggviz.isObject {
            return ggviz
        } else {
            // this will be "ggviz" or "ggviz.min" based on the flag
            let moduleName = GGVizContext.ggvizResource(min: min)?.deletingPathExtension().lastPathComponent ?? "ggviz"
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
