//
//  File.swift
//  
//
//  Created by Marc Prud'hommeaux on 5/26/21.
//

import MiscKit

/// Uses `JXKit` and `GGSpec`
open class GGContext {
    open var ctx: JXContext

    let gv: JXValue

    let glance: JXValue
    let vg: JXValue
    let vge: JXValue
    let vgg: JXValue

    let vgg_compile: JXValue
    let vg_parse: JXValue
    let vg_View: JXValue
    let vg_render: JXValue

    public init(ctx: JXContext = JXContext()) throws {
        self.ctx = ctx

        ctx.installConsole()
        try ctx.installGlimpseViz()

        // cache commonly-used functions

        try ctx.eval(script: """
        console.log("XXX");
        console.log("glimpseviz", glimpseviz);
        console.log("glimpseviz.vl", Object.keys(glimpseviz));
        """)

        func check(_ value: JXValue) throws -> JXValue {
            if !value.isObject {
                throw err("Value was not an object")
            }
            return value
        }

        self.gv = try check(ctx["glimpseviz"])

        let version = gv["version"]
        dbg("initializing glimpseviz version", version.stringValue)

        self.glance = try check(gv["glance"])
        self.vg = try check(gv["vg"])
        self.vge = try check(gv["vge"])
        self.vgg = try check(gv["vgg"])

        self.vg_parse = try check(vg["parse"])

        self.vgg_compile = try check(vgg["compile"])

        self.vg_View = try check(vg["View"])

        self.vg_render = try check(ctx.eval(script: """
            (function(vg, spec) {
                var svg = "";
                var view = new vg.View(vg.parse(spec), {renderer: 'none'});
                view.run();
                view.toSVG() // 
                  .then(function(svgString) {
                    // console.log("SVG", svgString);
                    svg = svgString;
                  })
                  .catch(function(err) { console.error(err); });

                return svg;
            })
            """))
    }

    deinit {

    }

    /// Compiles a spec
    open func compileGrammar<T: VizSpecMeta>(spec: VizSpec<T>) throws -> JXValue {
        try ctx.trying {
            try vgg_compile.call(withArguments: [ctx.encode(spec)])
        }
    }

    open func parseViz(_ spec: JXValue) throws -> JXValue {
        try ctx.trying {
            vg_parse.call(withArguments: [spec])
        }
    }

    open func renderViz(_ spec: JXValue) throws -> JXValue {
        try ctx.trying {
            vg_render.call(withArguments: [vg, spec])
        }
    }


}


public extension JXContext {
    static let glimpseviz = Bundle.module.url(forResource: "glimpseviz", withExtension: "js", subdirectory: "Resources/JavaScript")

    /// Runs `glimpseviz.js`
    func installGlimpseViz() throws {
        guard let glimpsevizURL = Self.glimpseviz else {
            throw err("Could not load glimpseviz.js")
        }
        try self.eval(url: glimpsevizURL)
    }
}

