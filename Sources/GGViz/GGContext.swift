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

        self.vgg_compile = try check(vgg["compile"])
    }

    deinit {

    }

    /// Compiles a spec
    open func compileGrammar<T: Codable>(spec: T) throws -> JXValue {
        try ctx.trying {
            try vgg_compile.call(withArguments: [ctx.encode(spec)])
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

