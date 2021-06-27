import XCTest

import GGViz
import Judo
import MiscKit
import BricBrac
import GGSources
import GGSamples

extension VizEngine {
    /// Creates a `JXContext.DataFetcher` relative to a given `basePath` for loading URL resources in this engine. If the `basePath` is not nil, file loading will be permitted beneath the given base.
    static func fetchHandler(relativeTo basePath: URL?) -> JXContext.DataFetcher {
        { ctx, path, opts in
            // opts e.g.: {"context":"dataflow","response":"text"}
            //dbg("fetching", path, "options", opts?.jsonDebugDescription ?? ".none")

            // load the URL, either relative ("data/stocks.csv") or absolute

            guard let url = URL(string: path) else {
                dbg("invalid URL:", path)
                return (nil, nil)
            }

            // dbg("url:", url, url.isFileURL, "scheme:", url.scheme)
            if url.scheme != nil { // try to load the URL using the built-in mechanisms
                let (data, response, _) = URLSession.shared.syncRequest(with: URLRequest(url: url))
                return (response, data)
            }

            let fileURL = URL(fileURLWithPath: path, relativeTo: basePath)

            if basePath != nil && FileManager.default.isReadableFile(atPath: fileURL.path) {
                return (nil, try Data(contentsOf: fileURL, options: .mappedIfSafe))
            }

            // even if we disallow direct file access, we still permit the sample "data/" URLs to be loaded from the samples bundle; this permits the sample spec to load and render with their respective data files
            let comps = url.pathComponents
            if url.scheme == nil && comps.count == 2 && comps.first == "data", let source = GGSource(rawValue: url.lastPathComponent), let resourceURL = source.resourceURL {
                return (nil, try Data(contentsOf: resourceURL, options: .mappedIfSafe))
            }

            dbg("no URL found for path:", path)
            return (nil, nil)
        }
    }
}

extension URLSession {
    /// Creates a synchronous request
    func syncRequest(with request: URLRequest) -> (Data?, URLResponse?, Error?) {
       var data: Data?
       var response: URLResponse?
       var error: Error?

       let dispatchGroup = DispatchGroup()
       let task = dataTask(with: request) {
          data = $0
          response = $1
          error = $2
          dispatchGroup.leave()
       }
       dispatchGroup.enter()
       task.resume()
       dispatchGroup.wait()

       return (data, response, error)
    }

}

/// A running count of all the contexts that have been created and not destroyed
private final class VizEngineDebug : VizEngine {
    static var liveContexts = 0

    override init(ctx: JXContext = JXContext(), fetcher: JXContext.DataFetcher? = nil) throws {
        try super.init(ctx: ctx, fetcher: fetcher)
        Self.liveContexts += 1
    }

    deinit {
        Self.liveContexts -= 1
    }
}

final class GGVizTests: XCTestCase {
    let speedUp = false

    func measureBlock(file: StaticString = #filePath, line: UInt = #line, _ f: () throws -> ()) rethrows {
        if speedUp {
//            measureMetrics([], automaticallyStartMeasuring: true) {
//                do {
                    try f()
//                } catch {
//                    XCTFail("\(error)", file: file, line: line)
//                }
//            }
        } else {
            measure {
                do {
                    try f()
                } catch {
                    XCTFail("\(error)", file: file, line: line)
                }
            }
        }
    }

    override class func tearDown() {
        XCTAssertEqual(0, VizEngineDebug.liveContexts)
    }

    func testengineScript() {
        XCTAssertNotNil(VizEngine.engineScript(min: true))
        XCTAssertNotNil(VizEngine.engineScript(min: false))
        XCTAssertNotNil(VizEngine.engineScript(min: nil))
    }

    /// A very simple spec for testing rendering and compiling
    func simpleSampleSpec(mark: GG.PrimitiveMarkType = .bar, count: Int, width: Double = 900, height: Double = 600) -> SimpleVizSpec {

        var rows: [Bric] = []
        for i in 0..<count {
            rows.append([
                "A" : Bric.str(i % 3 == 0 ? "x" : i % 3 == 1 ? "y" : "z"),
                "B" : Bric.num(Double(i + 1) / 10.0),
            ])
        }
        let dataSet = GG.InlineDataset(rows)

        var spec = SimpleVizSpec(data: .init(.init(.init(GG.InlineData(values: dataSet)))))
        (spec.width, spec.height) = (.init(width), .init(height))
        spec.mark = .init(mark)

        spec.title = .init(.init("Hello GGViz!"))

        spec.encoding = .init(
            x: .init(GG.EncodingChannelMap.X(GG.PositionFieldDef(field: .init(GG.FieldName("A")), title: .init(.init("Alpha"))))),
            y: .init(GG.EncodingChannelMap.Y(GG.PositionFieldDef(field: .init(GG.FieldName("B")), title: .init(.init("Bravo")), type: .quantitative))))

        return spec
    }

    func testCompileGrammar() throws {
        let count = 0
        let spec = simpleSampleSpec(count: count)
        let gve = try VizEngineDebug()
        try prf("compile") {
            try checkRenderResults(gve, spec: spec, count: count, compile: true)
        }
    }

    func testMeasureCompile() throws {
        let count = 0
        let spec = simpleSampleSpec(count: count)
        let gve = try VizEngineDebug()
        try measureBlock {
            try checkRenderResults(gve, spec: spec, count: count, compile: true)
        }
    }

    func measureData(count: Int) throws {
        let spec = simpleSampleSpec(count: count)
        let gve = try VizEngineDebug()
        try measureBlock {
            try checkRenderResults(gve, spec: spec, count: count, data: true)
        }
    }

    func testMeasureData10() throws {
        try measureData(count: 10)
    }

    func testMeasureData100() throws {
        try measureData(count: 100)
    }

    func testMeasureData1000() throws {
        try measureData(count: 1000)
    }

//    func testMeasureData10000() throws {
//        try measureData(count: 10000)
//    }

    func measureScenegraph(count: Int) throws {
        let spec = simpleSampleSpec(count: count)
        let gve = try VizEngineDebug()
        try measureBlock {
            try checkRenderResults(gve, spec: spec, count: count, sg: true)
        }
    }

    func testMeasureSceneGraph10() throws {
        try measureScenegraph(count: 10)
    }

    func testMeasureSceneGraph100() throws {
        try measureScenegraph(count: 100)
    }

    func testMeasureSceneGraph1000() throws {
        try measureScenegraph(count: 1000)
    }

//    func testMeasureSceneGraph10000() throws {
//        try measureScenegraph(count: 10000)
//    }

//    func testMeasureSceneGraph100000() throws {
//        try measureScenegraph(count: 100000)
//    }

    func measureSVG(count: Int) throws {
        let spec = simpleSampleSpec(count: count)
        let gve = try VizEngineDebug()
        try measureBlock {
            try checkRenderResults(gve, spec: spec, count: count, svg: true)
        }
    }

    func testMeasureSVG10() throws {
        try measureSVG(count: 10)
    }

    func testMeasureSVG100() throws {
        try measureSVG(count: 100)
    }

    func testMeasureSVG1000() throws {
        try measureSVG(count: 1000)
    }

//    func testMeasureSVG10000() throws {
//        try measureSVG(count: 10000)
//    }

//    func testMeasureSVG100000() throws {
//        try measureSVG(count: 100000)
//    }

    func measureCanvas(count: Int) throws {
        let spec = simpleSampleSpec(count: count)
        let gve = try VizEngineDebug()
        try measureBlock {
            try checkRenderResults(gve, spec: spec, count: count, canvas: true)
        }
    }

    func testMeasureCanvas10() throws {
        try measureCanvas(count: 10)
    }

    func testMeasureCanvas100() throws {
        try measureCanvas(count: 100)
    }

    func testMeasureCanvas1000() throws {
        try measureCanvas(count: 1000)
    }

//    func testMeasureCanvas10000() throws {
//        try measureCanvas(count: 10000)
//    }

//    func testMeasureCanvas100000() throws {
//        try measureCanvas(count: 100000)
//    }

    func testMeasureAllOperations() throws {
        let count = 3
        let spec = simpleSampleSpec(count: count)
        let gve = try VizEngineDebug()
        try measureBlock {
            try checkRenderResults(gve, spec: spec, count: count, data: true, sg: true, svg: true, canvas: true)
        }
    }

    func testReadData() throws {
        let gve = try VizEngineDebug()

        do {
            let parsed = try gve.readData("A,B,C\n1,2,3", type: .csv)
            dbg("parsed", parsed, parsed.isArray, parsed.count)
            XCTAssertEqual(true, parsed.isArray)
            XCTAssertEqual(1, parsed.count)
            let bric = try parsed.toDecodable(ofType: Bric.self)
            XCTAssertEqual([["A": 1, "B": 2, "C": 3]], bric)
        }

        do {
            let parsed = try gve.readData("[{ \"A\": 1, \"B\": 2, \"C\": 3 }]", type: .json)
            dbg("parsed", parsed, parsed.isArray, parsed.count)
            XCTAssertEqual(true, parsed.isArray)
            XCTAssertEqual(1, parsed.count)
            let bric = try parsed.toDecodable(ofType: Bric.self)
            XCTAssertEqual([["A": 1, "B": 2, "C": 3]], bric)
        }

    }

    func testFetchLoader() throws {
        try loaderFetch(inline: true)
        try loaderFetch(inline: false)
    }

    func loaderFetch(inline: Bool) throws {
        let gve = try VizEngineDebug(fetcher: VizEngine.fetchHandler(relativeTo: nil))

        let sourceRows: [Bric] = [
            ["group": "1", "person": "Alan"],
            ["group": "1", "person": "George"],
            ["group": "1", "person": "Fred"],
            ["group": "2", "person": "Steve"],
            ["group": "2", "person": "Nick"],
            ["group": "2", "person": "Will"],
            ["group": "3", "person": "Cole"],
            ["group": "3", "person": "Rick"],
            ["group": "3", "person": "Tom"],
        ]

        var spec = SimpleVizSpec()
        spec.mark = .init(.bar)

        if inline {
            spec.data = .init(.init(.init(GG.InlineData(values: .init(sourceRows)))))
        } else {
            spec.data = .init(.init(.init(GG.UrlData(url: "data/lookup_groups.csv")))) // identical data to sourceRows
        }

        let rendered = try gve.renderViz(spec: spec, returnData: true, returnSVG: false, returnScenegraph: false, canvas: nil)

        //dbg("rendered:", rendered.properties)
        let renderedData = rendered[VizEngine.RenderResponseKey.data.rawValue]

        guard renderedData.isObject else {
            return XCTFail("renderedData \(renderedData) not an object")
        }

        //dbg("renderedData:", renderedData)
        //dbg("renderedData.properties:", renderedData.properties)

        let source_0 = renderedData["source_0"]
        //dbg("source_0:", source_0)
        guard source_0.isObject else {
            return XCTFail("source_0 \(source_0) not an object")
        }

        let renderedRows: [Bric] = try source_0.toDecodable(ofType: [Bric].self)
        //dbg("renderedRows:", renderedRows)

        XCTAssertEqual(sourceRows.count, renderedRows.count, "data rows were empty: \(renderedRows)")
        XCTAssertEqual(sourceRows, renderedRows)
    }

    func checkRenderResults<M: VizSpecMeta>(_ gve: VizEngine, spec: VizSpec<M>, count: Int, compile: Bool = false, data checkData: Bool = false, sg checkSceneGraph: Bool = false, svg checkSVG: Bool = false, canvas checkCanvas: Bool = false) throws {
        if compile {
            let compiled = try gve.compileGrammar(spec: spec, normalize: true)

            // nothing to normalize in this spec (i.e., no row/column/facet encodings or repeats)
            // XCTAssertEqual(compiled.normalized, spec, "normalized spec should be identical")

            XCTAssertEqual([], compiled.warn.defaulted.compactMap({ $0 }))
            XCTAssertEqual([], compiled.debug.defaulted.compactMap({ $0 }))
            XCTAssertEqual([], compiled.info.defaulted.compactMap({ $0 }))
        }

        #if canImport(CoreGraphics)
        // use a layer canvas to render to an image
        let canvasAPI = checkCanvas == true ? try LayerCanvas(size: CGSize(width: 500, height: 500)) : nil // avg: 0.052
        #else // non-CoreGraphics systems just use the fake canvas
        let canvasAPI = checkCanvas == true ? AbstractCanvasAPI() : nil // avg: 0.035
        #endif

        let rendered = try gve.renderViz(spec: spec, returnData: checkData, returnSVG: checkSVG, returnScenegraph: checkSceneGraph, canvas: canvasAPI)

        #if canImport(CoreGraphics)
        if checkCanvas {
            dbg("PNG data size", canvasAPI?.createPNGData()?.count)
        }
        #endif

        let data = rendered[VizEngine.RenderResponseKey.data.rawValue]
        if !checkData {
            XCTAssert(data.isUndefined, "data should not have been set")
        } else {
            let rows = try data.toDecodable(ofType: [String: [Bric.ObjType]].self)
            guard let data_0 = rows["data_0"] else { return XCTFail("could not find data_0") }
            XCTAssertEqual(["x", "y", "z"].prefix(data_0.count), data_0.compactMap(\.["A"]?.str).prefix(3))
            XCTAssertEqual([0.1, 0.2, 0.3].prefix(data_0.count), data_0.map(\.["B"]).prefix(3))
        }

        if let canvasAPI = canvasAPI {
            // check that the canvas was configured for use
            //XCTAssertEqual("bold 13px sans-serif", canvasAPI.font)
            XCTAssertEqual(1, canvasAPI.lineWidth)
            //XCTAssertEqual("#888", canvasAPI.strokeStyle)
            XCTAssertEqual("#000", canvasAPI.fillStyle)
        }

        let sg = rendered[VizEngine.RenderResponseKey.scenegraph.rawValue]
        if !checkSceneGraph {
            XCTAssert(sg.isUndefined, "sg should not have been set")
        } else {
//            dbg("sg:", sg)
//            dbg("sg root:", sg["root"].stringValue)
//            dbg("sg marktype:", sg["marktype"].stringValue)
//            dbg("root marktype:", root["marktype"].stringValue)
            let sceneGraph = try sg.toDecodable(ofType: Scenegraph.self) 

            //dbg("sceneGraph", sceneGraph, sceneGraph.jsonDebugDescription)

            let sceneMarks = sceneGraph.flattened().map(\.element)
            XCTAssertEqual(16, sceneMarks.count)

            let sceneItems = sceneMarks.compactMap(\.sceneItems).joined()
            if count == 3 {
                XCTAssertEqual(67, sceneItems.count)

                XCTAssertEqual([900.0, 270.0, 270.0, 270.0].prefix(4), sceneItems.compactMap(\.width).prefix(4))
                XCTAssertEqual([600.0, 200.0, 400.00000000000006, 600.0].prefix(4), sceneItems.compactMap(\.height).prefix(4))

                let checkFirst = 21
                XCTAssertEqual([0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 150.0, 450.0], sceneItems.prefix(checkFirst).compactMap(\.x))

                XCTAssertEqual([0.0, 0.5, 600.0, 560.0, 520.0, 480.0, 440.0, 400.0, 360.0, 320.0, 280.0, 240.0, 200.0, 160.0, 120.0, 80.0, 40.0, 0.0, 600.5, 0.0, 0.0], sceneItems.prefix(checkFirst).compactMap(\.y))
            }
        }


        let svg = rendered[VizEngine.RenderResponseKey.svg.rawValue]
        if !checkSVG {
            XCTAssert(svg.isUndefined, "svg should not have been set")
        } else {
            // dbg("SVG", svg.stringValue)

            // parse the SVG as XML, get the flattened elements, and check for expected values
            let xml = try prf("SVG XMLTree.parse", threshold: 0.5) { try XMLTree.parse(data: svg.stringValue?.data(using: .utf8) ?? Data()) }
            let elements = xml.flattenedElements

            // index by the role
            let roleValues = Dictionary(grouping: elements, by: \.[attribute: "role"])
            XCTAssertEqual(2, roleValues["graphics-object"]?.count)
            XCTAssertEqual(count + 3, roleValues["graphics-symbol"]?.count)

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
            if count == 3 {
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
}
