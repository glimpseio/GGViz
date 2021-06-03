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


        let rendered = try ctx.renderViz([
            .spec: ctx.ctx.encode(spec),
            .returnData: ctx.ctx.boolean(true),
            .returnSVG: ctx.ctx.boolean(true),
            .returnScenegraph: ctx.ctx.boolean(true),
        ])

        let svg = rendered[GGVizContext.RenderResponseKey.svg.rawValue]

        // dbg("SVG", svg.stringValue)

        // parse the SVG as XML, get the flattened elements, and check for expected values
        let xml = try XMLTree.parse(data: svg.stringValue?.data(using: .utf8) ?? Data())
        let elements = treemap(root: xml, children: \.elementChildren) { $0 }

        // index by the role
        let roleValues = Dictionary(grouping: elements, by: \.[attribute: "role"])
        XCTAssertEqual(2, roleValues["graphics-object"]?.count)
        XCTAssertEqual(6, roleValues["graphics-symbol"]?.count)

        /// Index by the given attribute, which is expected to contain space-separated tokens (like "class" or "role")
        func indexBy(attribute: String) -> [String: [XMLTree]] {
            var classValues: [String: [XMLTree]] = [:]
            for element in elements {
                for key in element[attribute: attribute]?.components(separatedBy: .whitespacesAndNewlines) ?? [] {
                    classValues[key, default: []].append(element)
                }
            }
            return classValues
        }

        // check accessibility properties
        let accessibilityRoleValues = indexBy(attribute: "aria-roledescription")
        XCTAssertEqual(2, accessibilityRoleValues["mark"]?.count)
        XCTAssertEqual(1, accessibilityRoleValues["rect"]?.count)
        XCTAssertEqual(2, accessibilityRoleValues["container"]?.count)

        // check CSS properties
        let classValues = indexBy(attribute: "class")
        XCTAssertEqual(5, classValues["background"]?.count)
        XCTAssertEqual(2, classValues["marks"]?.count)
        XCTAssertEqual(5, classValues["mark-group"]?.count)
        XCTAssertEqual(3, classValues["role-axis"]?.count)

        let allContent = elements.map(\.childContent).joined()
        XCTAssertTrue(allContent.contains("Hello GGViz!"))

        // extract all the accessibility labels and verify their values
        let allLabels = elements.compactMap(\.[attribute: "aria-label"])
        XCTAssertEqual(allLabels, [
            "X-axis titled \'Alpha\' for a discrete scale with 3 values: x, y, z",
            "Y-axis titled \'Bravo\' for a linear scale with values from 0.0 to 3.0",
            "Alpha: x; Bravo: 1",
            "Alpha: y; Bravo: 2",
            "Alpha: z; Bravo: 3",
            "Title text \'Hello GGViz!\'",
        ])

        let sg = rendered[GGVizContext.RenderResponseKey.scenegraph.rawValue]
        let sceneGraph = try sg.toDecodable(ofType: GGSceneGraph.self) // not yet working…

        //dbg("sceneGraph", sceneGraph, sceneGraph.jsonDebugDescription)

        let sceneMarks = treemap(root: sceneGraph.root, children: \.children.faulted) { $0 }
        XCTAssertEqual(16, sceneMarks.count)

        let sceneItems = sceneMarks.compactMap(\.sceneItems).joined()
        XCTAssertEqual(40, sceneItems.count)

        XCTAssertEqual([0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 10.0, 30.0, 50.0, 9.5, 29.5, 49.5, 0.0, 30.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -7.0, -7.0, -7.0, -7.0, -7.0, -7.0, -7.0, 0.0, -35.0, 1.0, 21.0, 41.0, 30.0, nil], sceneItems.map(\.x))

        XCTAssertEqual([0.0, 0.5, 200.0, 167.0, 133.0, 100.0, 67.0, 33.0, 0.0, 200.5, 0.0, 0.0, 0.0, 7.0, 7.0, 7.0, 0.0, 19.0, 0.5, 200.0, 167.0, 133.0, 100.0, 67.0, 33.0, 0.0, 200.0, 166.66666666666669, 133.33333333333334, 100.0, 66.66666666666667, 33.33333333333333, 0.0, 200.0, 100.0, 133.33333333333334, 66.66666666666667, 0.0, -22.0, nil], sceneItems.map(\.y))
    }
}
