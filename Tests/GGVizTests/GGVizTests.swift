import XCTest

import GGViz
import Judo
import MiscKit
import BricBrac

/// A running count of all the contexts that have been created and not destroyed
private final class GGDebugContext : GGVizContext {
    static var liveContexts = 0

    override init(ctx: JXContext = JXContext()) throws {
        try super.init(ctx: ctx)
        Self.liveContexts += 1
    }

    deinit {
        Self.liveContexts -= 1
    }
}

final class GGVizTests: XCTestCase {
    override class func tearDown() {
        XCTAssertEqual(0, GGDebugContext.liveContexts)
    }

    func testGGVizResource() {
        XCTAssertNotNil(GGVizContext.ggvizResource(min: true))
        XCTAssertNotNil(GGVizContext.ggvizResource(min: false))
        XCTAssertNotNil(GGVizContext.ggvizResource(min: nil))
    }

    /// A very simple spec for testing rendering and compiling
    func simpleSampleSpec(mark: Mark = .bar, width: Double = 900, height: Double = 600) -> SimpleVizSpec {
        let dataSet = InlineDataset([
            ["A": "x", "B": 0.1],
            ["A": "y", "B": 0.2],
            ["A": "z", "B": 0.3],
        ])

        var spec = SimpleVizSpec(data: .init(.init(.init(InlineData(values: dataSet)))))
        (spec.width, spec.height) = (.init(width), .init(height))
        spec.mark = .init(mark)

        spec.title = .init(.init("Hello GGViz!"))

        spec.encoding = .init(
            x: .init(FacetedEncoding.X(PositionFieldDef(field: .init(FieldName("A")), title: .init(.init("Alpha"))))),
            y: .init(FacetedEncoding.Y(PositionFieldDef(field: .init(FieldName("B")), title: .init(.init("Bravo")), type: .quantitative))))

        return spec
    }

    @available(macOS 10.13, iOS 13.0, watchOS 6.0, tvOS 12.0, *)
    func testCompileGrammar() throws {
        let spec = simpleSampleSpec()
        let ctx = try GGDebugContext()
        try prf("compile") {
            try checkRenderResults(ctx, spec: spec, compile: true)
        }
    }

    @available(macOS 10.13, iOS 13.0, watchOS 6.0, tvOS 12.0, *)
    func testMeasureCompile() throws {
        let spec = simpleSampleSpec()
        let ctx = try GGDebugContext()
        measure {
            XCTAssertNoThrow(try! checkRenderResults(ctx, spec: spec, compile: true))
        }
    }

    @available(macOS 10.13, iOS 13.0, watchOS 6.0, tvOS 12.0, *)
    func testMeasureData() throws {
        let spec = simpleSampleSpec()
        let ctx = try GGDebugContext()
        measure {
            XCTAssertNoThrow(try! checkRenderResults(ctx, spec: spec, data: true))
        }
    }

    @available(macOS 10.13, iOS 13.0, watchOS 6.0, tvOS 12.0, *)
    func testMeasureSceneGraph() throws {
        let spec = simpleSampleSpec()
        let ctx = try GGDebugContext()
        measure {
            XCTAssertNoThrow(try! checkRenderResults(ctx, spec: spec, sg: true))
        }
    }

    @available(macOS 10.13, iOS 13.0, watchOS 6.0, tvOS 12.0, *)
    func testMeasureSVG() throws {
        let spec = simpleSampleSpec()
        let ctx = try GGDebugContext()
        measure {
            XCTAssertNoThrow(try! checkRenderResults(ctx, spec: spec, svg: true))
        }
    }

    @available(macOS 10.13, iOS 13.0, watchOS 6.0, tvOS 12.0, *)
    func testMeasureCanvas() throws {
        let spec = simpleSampleSpec()
        let ctx = try GGDebugContext()
        measure {
            XCTAssertNoThrow(try! checkRenderResults(ctx, spec: spec, canvas: true))
        }
    }

    @available(macOS 10.13, iOS 13.0, watchOS 6.0, tvOS 12.0, *)
    func testMeasureAllOperations() throws {
        let spec = simpleSampleSpec()
        let ctx = try GGDebugContext()
        measure {
            XCTAssertNoThrow(try! checkRenderResults(ctx, spec: spec, data: true, sg: true, svg: true))
        }
    }

    /// A simple AbstractCanvasAPI subclass that tracks all the text measuring requests it gets
    final class MeasuringCanvasAPI : AbstractCanvasAPI {
        var measures: [String] = []
        override func measureText(value: String) -> TextMetrics? {
            dbg("measure:", value)
            measures.append(value)
            return super.measureText(value: value)
        }
    }

    @available(macOS 10.13, iOS 13.0, watchOS 6.0, tvOS 12.0, *)
    func checkRenderResults<M: VizSpecMeta>(_ ctx: GGVizContext, spec: VizSpec<M>, compile: Bool = false, data checkData: Bool = false, sg checkSceneGraph: Bool = false, canvas checkCanvas: Bool = false, svg checkSVG: Bool = false) throws {
        if compile {
            let compiled = try ctx.compileGrammar(spec: spec, normalize: true)

            // nothing to normalize in this spec (i.e., no row/column/facet encodings or repeats)
            XCTAssertEqual(compiled.normalized, spec, "normalized spec should be identical")

            XCTAssertEqual([], compiled.warn.defaulted)
            XCTAssertEqual([], compiled.debug.defaulted)
            XCTAssertEqual([], compiled.info.defaulted)
        }


        let canvasAPI = MeasuringCanvasAPI()
        let canvas = try checkCanvas ? Canvas(env: ctx.ctx, delegate: canvasAPI) : nil
        let rendered = try ctx.renderViz(spec: spec, returnData: checkData, returnSVG: checkSVG, returnCanvas: checkCanvas, returnScenegraph: checkSceneGraph, canvas: canvas)

        let data = rendered[GGVizContext.RenderResponseKey.data.rawValue]
        if !checkData {
            XCTAssert(data.isUndefined, "data should not have been set")
        } else {
            let rows = try data.toDecodable(ofType: [String: [Bric.ObjType]].self)
            guard let data_0 = rows["data_0"] else { return XCTFail("could not find data_0") }
            XCTAssertEqual(["x", "y", "z"], data_0.map(\.["A"]))
            XCTAssertEqual([0.1, 0.2, 0.3], data_0.map(\.["B"]))
        }

        if !checkCanvas {
            //XCTAssert(data.isUndefined, "canvas should not have been set")
        } else {
            let canvas = try XCTUnwrap(canvas) // our canvas var should be legit

            // check that the canvas was configured for use
            XCTAssertEqual("bold 13px sans-serif", canvasAPI.font)
            XCTAssertEqual(1, canvasAPI.lineWidth)
            XCTAssertEqual("#888", canvasAPI.strokeStyle)
            XCTAssertEqual("#000", canvasAPI.fillStyle)
        }

        let sg = rendered[GGVizContext.RenderResponseKey.scenegraph.rawValue]
        if !checkSceneGraph {
            XCTAssert(sg.isUndefined, "sg should not have been set")
        } else {
            let sceneGraph = try sg.toDecodable(ofType: GGSceneGraph.self) // not yet working…

            //dbg("sceneGraph", sceneGraph, sceneGraph.jsonDebugDescription)

            let sceneMarks = sceneGraph.flattened().map(\.element)
            XCTAssertEqual(16, sceneMarks.count)

            let sceneItems = sceneMarks.compactMap(\.sceneItems).joined()
            XCTAssertEqual(67, sceneItems.count)

            XCTAssertEqual([900.0, 270.0, 270.0, 270.0], sceneItems.compactMap(\.width))
            XCTAssertEqual([600.0, 200.0, 400.00000000000006, 600.0], sceneItems.compactMap(\.height))

            let checkFirst = 21
            XCTAssertEqual([0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 150.0, 450.0], sceneItems.prefix(checkFirst).compactMap(\.x))

            XCTAssertEqual([0.0, 0.5, 600.0, 560.0, 520.0, 480.0, 440.0, 400.0, 360.0, 320.0, 280.0, 240.0, 200.0, 160.0, 120.0, 80.0, 40.0, 0.0, 600.5, 0.0, 0.0], sceneItems.prefix(checkFirst).compactMap(\.y))

        }


        let svg = rendered[GGVizContext.RenderResponseKey.svg.rawValue]
        if !checkSVG {
            XCTAssert(svg.isUndefined, "svg should not have been set")
        } else {
            // dbg("SVG", svg.stringValue)

            // parse the SVG as XML, get the flattened elements, and check for expected values
            let xml = try XMLTree.parse(data: svg.stringValue?.data(using: .utf8) ?? Data())
            let elements = xml.flattenedElements

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
                "Y-axis titled \'Bravo\' for a linear scale with values from 0.00 to 0.30",
                "Alpha: x; Bravo: 0.1",
                "Alpha: y; Bravo: 0.2",
                "Alpha: z; Bravo: 0.3",
                "Title text \'Hello GGViz!\'",
            ])
        }

    }
}
