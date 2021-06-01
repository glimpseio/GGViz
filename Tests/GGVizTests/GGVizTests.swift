import XCTest

import GGViz
import MiscKit
import BricBrac

/// A running count of all the contexts that have been created and not destroyed
private final class GGDebugContext : GGVizContext {
    static var debugContextCount = 0

    override init(ctx: JXContext = JXContext()) throws {
        try super.init(ctx: ctx)
        Self.debugContextCount += 1
    }

    deinit {
        Self.debugContextCount -= 1
    }
}

final class GGVizTests: XCTestCase {
    override class func tearDown() {
        XCTAssertEqual(0, GGDebugContext.debugContextCount)
    }

    @available(macOS 10.13, iOS 13.0, watchOS 6.0, tvOS 11.0, *)
    func testCompileGrammar() throws {
        let dataSet = InlineDataset([
            ["A": "x", "B": 1.0],
            ["A": "y", "B": 2.0],
            ["A": "z", "B": 3.0],
        ])

        var spec = SimpleVizSpec(data: .init(.init(.init(InlineData(values: dataSet)))))
        spec.mark = .init(Mark.bar)

        spec.title = .init(.init("Hello GGViz!"))

        spec.encoding = .init(
            x: .init(FacetedEncoding.X(PositionFieldDef(field: .init(FieldName("A")), title: .init(.init("Alpha"))))),
            y: .init(FacetedEncoding.Y(PositionFieldDef(field: .init(FieldName("B")), title: .init(.init("Bravo")), type: .quantitative))))

        let ctx = try GGDebugContext()
        let compiled = try ctx.compileGrammar(spec: spec, normalize: true)

        // nothing to normalize in this spec (i.e., no row/column/facet encodings or repeats)
        XCTAssertEqual(compiled.normalized, spec, "normalized spec should be identical")

        XCTAssertEqual([], compiled.warn.defaulted)
        XCTAssertEqual([], compiled.debug.defaulted)
        XCTAssertEqual([], compiled.info.defaulted)

//        XCTAssertEqual(compiled.vega, [:])

        let rendered = try ctx.renderViz([
            .spec: ctx.ctx.encode(spec),
            .returnData: ctx.ctx.boolean(true),
            .returnSVG: ctx.ctx.boolean(true),
            .returnScenegraph: ctx.ctx.boolean(true),
        ])

        let svg = rendered[GGVizContext.RenderResponseKey.svg.rawValue]

        dbg(svg.stringValue)

        // parse the SVG as XML and check for expected values
        let xml = try XMLTree.parse(data: svg.stringValue?.data(using: .utf8) ?? Data())
        let allNodes = treenumerate(root: xml, children: \.elementChildren)
        let allElements = allNodes.map(\.element)

        // index by the role
        let roleValues = Dictionary(grouping: allElements, by: \.[attribute: "role"])
        XCTAssertEqual(2, roleValues["graphics-object"]?.count)
        XCTAssertEqual(6, roleValues["graphics-symbol"]?.count)

        let allContent = allElements.map(\.childContent).joined()
        XCTAssertTrue(allContent.contains("Hello GGViz!"))

        // extract all the accessibility labels and verify their values
        let allLabels = allElements.compactMap(\.[attribute: "aria-label"])
        XCTAssertEqual(allLabels, [
            "X-axis titled \'Alpha\' for a discrete scale with 3 values: x, y, z",
            "Y-axis titled \'Bravo\' for a linear scale with values from 0.0 to 3.0",
            "Alpha: x; Bravo: 1",
            "Alpha: y; Bravo: 2",
            "Alpha: z; Bravo: 3",
            "Title text \'Hello GGViz!\'",
        ])

        // XCTAssertEqual(svg.stringValue, """
        //     """)

        let sg = rendered[GGVizContext.RenderResponseKey.scenegraph.rawValue]
//        dbg("sg", (try? sg.toJSON(indent: 2)) ?? "")

//        let sceneGraph = try sg.toDecodable(ofType: GGSceneGraph.self) // not yet working…

//        let sceneGraph = try sg.toDecodable(ofType: [String: Bric].self)
//        dbg("sceneGraph", sceneGraph)
//
//        XCTAssertEqual("group", sceneGraph["marktype"])
//        XCTAssertEqual("frame", sceneGraph["role"])
//        // XCTAssertEqual(1, sceneGraph["items"]?.arr?.count)

    }
}
