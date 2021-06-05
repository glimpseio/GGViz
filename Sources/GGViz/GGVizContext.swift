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

    let glance_render: JXValue
    let glance_compile: JXValue

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

        self.glance_render = try check(glance["render"])

        // use a custom compile step that captures the logged output and returns it as a `CompileOutput`
        self.glance_compile = try check(ctx.eval("""
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

    /// Compiles a spec
    func compileGrammar<T: VizSpecMeta>(spec: VizSpec<T>, normalize: Bool) throws -> CompileOutput<T> {
        try ctx.trying {
            try glance_compile.call(withArguments: [ctx.encode(spec), ctx.boolean(normalize)])
        }.toDecodable(ofType: CompileOutput.self)
    }

    func parseViz(_ spec: JXValue) throws -> JXValue {
        try ctx.trying {
            vg_parse.call(withArguments: [spec])
        }
    }

    /// Renders the spec with the given options
    /// - Parameter options: the rendering options
    /// - Returns: an object value with keys defined in `RenderResponseKey`
    func renderViz(_ options: [RenderRequestKey: JXValue]) throws -> JXValue {
        let opts = JXValue(newObjectIn: ctx)
        for (key, value) in options {
            opts[key.rawValue] = value
        }

        return try ctx.trying {
            glance_render.call(withArguments: [opts])
        }
    }
    /// The keys that can be used to specify data requests.
    /// - Note: These keys must be kept in sync with the equivalent keys in `ggviz.js`
    enum RenderRequestKey : String {
        case spec = "spec"
        case data = "data"
        case vegaSpec = "vegaSpec"

        case headless = "headless"
        case elementID = "elementID"

        case returnData = "returnData"
        case returnSVG = "returnSVG"
        case returnScenegraph = "returnScenegraph"
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
        public var requestKey: RenderRequestKey {
            switch self {
            case .data: return .returnData
            case .svg: return .returnSVG
            case .scenegraph: return .returnScenegraph
            case .canvas, .canvasNative: return .returnCanvas
            }
        }
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
    @discardableResult public func installGGViz() throws -> JXValType {
        let propertyName = "ggviz"
        let _ = self.globalObject(property: "global") // ggviz needs "global" (probably for console)
        let exports = self.globalObject(property: "exports")
        let ggviz = exports[propertyName]
        if ggviz.isObject {
            return ggviz
        } else {
            exports[propertyName] = try installModule(named: "ggviz", in: .module)
            return exports[propertyName]
        }
    }
}

