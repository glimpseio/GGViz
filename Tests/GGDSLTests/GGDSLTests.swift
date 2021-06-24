import XCTest
import GGDSL

typealias SimpleViz = Viz<Bric.ObjType>
typealias Graphiq = SimpleViz

extension XCTestCase {
    /// Checks that the given viz builder matches the JSON spec.
    ///
    /// - Note: Empty specs are skipped by throwing `XCTSkip`
    func check<M: Pure>(viz: Viz<M>, againstJSON json: String, file: StaticString = #file, line: UInt = #line, function: StaticString = #function) throws {
        if viz.rawValue == Viz().rawValue {
            throw XCTSkip("skip empty check for \(function)", file: file, line: line)
        }

        var checkSpec = try VizSpec<M>.loadFromJSON(data: json.data(using: .utf8) ?? Data())
        checkSpec.schema = nil // schema property is optional

        // first check if they both to serialize to the same JSON…
        XCTAssertEqual("\n" + viz.debugDescription + "\n", "\n" + checkSpec.jsonDebugDescription + "\n")
        if viz.debugDescription == checkSpec.jsonDebugDescription {
            // … then check for actual equality of thw structure
            XCTAssertEqual(viz.rawValue, checkSpec)
        }
    }
}

final class GGDSLTests: XCTestCase {


    func testScales() throws {
        let _ = GG.EncodingChannelMap.X(t1: .init()).rawValue.v1?.scale
        let _ = GG.EncodingChannelMap.Y(t1: .init()).rawValue.v1?.scale
        let _ = GG.EncodingChannelMap.Color(t1: .init()).rawValue.v1?.scale
        let _ = GG.EncodingChannelMap.StrokeDash(t1: .init()).rawValue.v1?.scale
        //let _ = GG.EncodingChannelMap.X2(t1: .init()).rawValue.v1?.scale
        //let _ = GG.EncodingChannelMap.Y2(t1: .init()).rawValue.v1?.scale
        //let _ = GG.EncodingChannelMap.Row(t1: .init()).rawValue.v1?.scale
        //let _ = GG.EncodingChannelMap.Text(t1: .init()).rawValue.v1?.scale

        #if os(Linux) || os(Windows) // ugh
        XCTAssertEqual(Scale().range((Double.pi * 0.75)...(Double.pi * 2.75)).rawValue.jsonDebugDescription, """
            {"range":[2.356194490192345,8.63937979737193]}
            """)
        XCTAssertEqual(Scale().range((Float80.pi * 0.75)...(Float80.pi * 2.75)).rawValue.jsonDebugDescription, """
            {"range":[2.356194490192345,8.639379797371932]}
            """)
        #else
        XCTAssertEqual(Scale().range((Double.pi * 0.75)...(Double.pi * 2.75)).rawValue.jsonDebugDescription, """
            {"range":[2.3561944901923448,8.6393797973719302]}
            """)
        #if os(macOS) // on iOS: "error: type 'Float80' has no member 'pi'"
        XCTAssertEqual(Scale().range((Float80.pi * 0.75)...(Float80.pi * 2.75)).rawValue.jsonDebugDescription, """
            {"range":[2.3561944901923448,8.639379797371932]}
            """)
        #endif
        #endif

        try check(viz: Graphiq {
            Mark(.bar) {
                Encode(.x, field: "A") {
                    Scale()
                }
            }
        }, againstJSON: """
        {
            "mark": "bar",
            "encoding": {
                "x": {
                    "field": "A",
                    "scale": { }
                }
            }
        }
        """)

        try check(viz: Graphiq {
            Mark(.bar) {
                Encode(.y, field: "A") {
                    Scale()
                }
            }
        }, againstJSON: """
        {
            "mark": "bar",
            "encoding": {
                "y": {
                    "field": "A",
                    "scale": { }
                }
            }
        }
        """)


        try check(viz: Graphiq {
            Mark(.bar) {
                Encode(.color, field: "A") {
                    Scale()
                }
            }
        }, againstJSON: """
        {
            "mark": "bar",
            "encoding": {
                "color": {
                    "field": "A",
                    "scale": { }
                }
            }
        }
        """)

    }

    func testAxes() throws {
        try check(viz: Graphiq {
            Mark(.bar) {
                Encode(.x, field: "A") {
                    Guide()
                }
            }
        }, againstJSON: """
        {
            "mark": "bar",
            "encoding": {
                "x": {
                    "field": "A",
                    "axis": { }
                }
            }
        }
        """)

        try check(viz: Graphiq {
            Mark(.bar) {
                Encode(.y, field: "B") {
                    Guide(.axis).tickMinStep(10)
                }
            }
        }, againstJSON: """
        {
            "mark": "bar",
            "encoding": {
                "y": {
                    "field": "B",
                    "axis": { "tickMinStep": 10 }
                }
            }
        }
        """)
    }

    func testLegends() throws {
        try check(viz: Graphiq {
            Mark(.circle) {
                Encode(.fill, field: "C") {
                    Guide()
                }
            }
        }, againstJSON: """
        {
            "mark": "circle",
            "encoding": {
                "fill": {
                    "field": "C",
                    "legend": { }
                }
            }
        }
        """)
    }


    func testHeaders() throws {
        try check(viz: Graphiq {
            Mark(.text) {
                Encode(.facet, field: "R") {
                    Guide()
                }
            }
        }, againstJSON: """
        {
            "mark": "text",
            "encoding": {
                "facet": {
                    "field": "R",
                    "header": { }
                }
            }
        }
        """)

    }


    /// Verify that the raw legend is created by the builder DSL
    func testLegendValues() {
        let l1 = GG.LegendDef(
            columns: .init(1),
            legendX: .init(200),
            legendY: .init(80),
            orient: .init(.none),
            title: .init(.null)
        )

        let l2 = VizGuide(.legend)
            .columns(1)
            .legendX(200)
            .legendY(80)
            .orient(GG.LegendOrient.none)
            .title(.null)

        XCTAssertEqual(l1, l2.rawValue)
    }

    func testMarkSimple() throws {
        try check(viz: Graphiq {
            Mark(.square)
        }, againstJSON: """
            {"mark":"square"}
        """)
    }

    func testMarkCompound() throws {
        try check(viz: Graphiq {
            VizMark(.boxplot)
        }, againstJSON: """
            {"mark":"boxplot"}
        """)
    }

    func testTransform() throws {
        try check(viz: Graphiq {
            Transform(.sample) {
                Mark(.square) {
                }
            }
        }, againstJSON: """
            {
                "mark":"square",
                "transform":[
                    {"sample":999}
                ]
            }
            """)

        try check(viz: Graphiq {
            Transform(.loess, field: "A", on: "B") {
                Mark(.square)
            }
        }, againstJSON: """
            {
                "mark":"square",
                "transform":[
                    {"loess": "A", "on": "B"}
                ]
            }
            """)

        try check(viz: Graphiq {
            Transform(.density, field: "A", densityOutput: "DENSE") { sample, value in
                Mark(.square) {
                    Encode(.x, field: sample) {
//                        Guide(.axis)
                    }
                    Encode(.y, field: value)
                }
            }
        }, againstJSON: """
            { "encoding": { "x": { "field": "value" }, "y": { "field": "DENSE" } }, "mark": "square", "transform": [ { "as": [ "value", "DENSE" ], "density": "A" } ] }
            """)
    }

    func testDetailEncoding() throws {
        try check(viz: Graphiq {
            Mark(.circle) {
                Encode(.color, field: "C")
                    .aggregate(.min)
                    .sort(GG.Sort(.init(GG.SortByEncoding(encoding: .color, order: .init(.descending)))))

                Encode(.color, field: "D").aggregate(.max) // single-encoding override

                Encode(.detail, field: "X").aggregate(.min)
                Encode(.detail, field: GG.FieldName("Y")) // multi-encoding
                Encode(.detail).aggregate(.count) // multi-encoding
            }
            .opacity(0.8)
        }, againstJSON: """
        {
            "mark": { "opacity": 0.80000000000000004, "type": "circle" },
            "encoding": {
                "color": { "aggregate": "max", "field": "D" },
                "detail": [
                    { "aggregate": "min", "field": "X" },
                    { "field": "Y" },
                    { "aggregate": "count" }
                ]
            }
        }
        """)
    }

    func testOrderEncoding() throws {
        try check(viz: Graphiq {
            Mark(.point) {
                Encode(.order, field: "A").sort(.ascending)
                Encode(.order, field: "B").sort(.descending)
            }
        }, againstJSON: """
        {
            "mark": "point",
            "encoding": {
                "order": [
                    { "field": "A", "sort": "ascending" },
                    { "field": "B", "sort": "descending" }
                ]
            }
        }
        """)
    }

    func testFacets() throws {
        try check(viz: Graphiq {
            Mark(.rect) {
                Encode(.row, field: "ROW_FIELD")
                Encode(.column, field: "COLUMN_FIELD")
                Encode(.facet, field: "FACET_FIELD")
            }
        }, againstJSON: """
        {
          "mark": "rect",
          "encoding": {
            "column": {
              "field": "COLUMN_FIELD"
            },
            "facet": {
              "field": "FACET_FIELD"
            },
            "row": {
              "field": "ROW_FIELD"
            }
          }
        }
        """)
    }

    func testStrokeDash() throws {
        try check(viz: Graphiq {
            Mark(.line) {
                Encode(.strokeDash, value: [1, 2, 3])
            }
        }, againstJSON: """
        {
            "mark": "line",
            "encoding": {
                "strokeDash": {
                    "value": [1, 2, 3]
                }
            }
        }
        """)
    }

    func testText() throws {
        try check(viz: Graphiq {
            Mark(.text) {
                Encode(.text, values: ["Hello", "There!"])
            }
        }, againstJSON: """
        {
            "mark": "text",
            "encoding": {
                "text": {
                    "value": ["Hello", "There!"]
                }
            }
        }
        """)
    }

    func testTooltip() throws {
        try check(viz: Graphiq {
            Mark(.rect) {
                Encode(.tooltip, fields: ["A", "B"])
            }
        }, againstJSON: """
        {
            "mark": "rect",
            "encoding": {
                "tooltip": [
                    { "field": "A" },
                    { "field": "B" }
                ]
            }
        }
        """)
    }

    func testShapes() throws {
        try check(viz: Graphiq {
            Mark(.point) {
                Encode(.shape, value: .circle)
            }
        }, againstJSON: """
        {
            "mark": "point",
            "encoding": {
                "shape": {
                    "value": "circle"
                }
            }
        }
        """)

        try check(viz: Graphiq {
            Mark(.point) {
                Encode(.shape, value: .path("M0,0 L1,1"))
            }
        }, againstJSON: """
        {
            "mark": "point",
            "encoding": {
                "shape": {
                    "value": "M0,0 L1,1"
                }
            }
        }
        """)
    }

    func testLayer() throws {
        try check(viz: Graphiq {
            VizLayer(.overlay)
        }, againstJSON: """
        {
            "layer": []
        }
        """)

        try check(viz: Graphiq {
            VizLayer(.vertical)
        }, againstJSON: """
        {
            "vconcat": []
        }
        """)

        try check(viz: Graphiq {
            Layer(.wrap) {
                Mark(.bar) {
                    Encode(.x)
                    Encode(.y)
                }
            }
        }, againstJSON: """
        { "concat": [ { "encoding": { "x": { }, "y": { } }, "mark": "bar" } ] }
        """)
    }

    func testLayerMarkTypes() throws {
        try check(viz: Graphiq {
            Layer(.horizontal) {
                Encode(.x, value: .width)
                Encode(.y, value: .height)

                Mark(.arc)
                Mark(.area)
                Mark(.bar)
                Mark(.boxplot)
                Mark(.circle)
                Mark(.errorband)
                Mark(.errorbar)
                Mark(.geoshape)
                Mark(.image)
                Mark(.line)
                Mark(.point)
                Mark(.rect)
                Mark(.rule)
                Mark(.square)
                Mark(.text)
                Mark(.tick)
                Mark(.trail)
            }
        }, againstJSON: """
        {
            "encoding": {
                "x": { "value": "width" },
                "y": { "value": "height" }
            },
            "hconcat": [
                { "mark": "arc" },
                { "mark": "area" },
                { "mark": "bar" },
                { "mark": "boxplot" },
                { "mark": "circle" },
                { "mark": "errorband" },
                { "mark": "errorbar" },
                { "mark": "geoshape" },
                { "mark": "image" },
                { "mark": "line" },
                { "mark": "point" },
                { "mark": "rect" },
                { "mark": "rule" },
                { "mark": "square" },
                { "mark": "text" },
                { "mark": "tick" },
                { "mark": "trail" }
            ]
        }
        """)
    }

    func testLayerNesting() throws {
        try check(viz: Graphiq {
            Layer(.horizontal) {
                Encode(.x, value: .width)
                Layer(.vertical) {
                    Encode(.y, value: .height)
                    Mark(.bar) {
                        Encode(.size, value: 44)
                    }
                }
            }
        }, againstJSON: """
        {
          "encoding": { "x": { "value": "width" } },
          "hconcat": [
            {
              "encoding": { "y": { "value": "height" } },
              "vconcat": [
                {
                  "mark": "bar",
                  "encoding": { "size": { "value": 44 } }
                }
              ]
            }
          ]
        }
        """)
    }

    func testProjection() throws {
        try check(viz: Graphiq {
            GeoProjection()
        }, againstJSON: """
        {
            "projection": { }
        }
        """)

        try check(viz: Graphiq {
            GeoProjection(.albersUsa)
                .precision(0.1)
        }, againstJSON: """
        {
            "projection": {
                "precision": 0.1,
                "type": "albersUsa"
            }
        }
        """)
    }

    func testRepeat() throws {
        try check(viz: Graphiq {
            Repeat(.horizontal, fields: ["A", "B"]) { hfield in
                Repeat(.vertical, fields: ["C", "D"]) { vfield in
                    Mark(.bar) {
                        Encode(.x, repeat: hfield)
                        Encode(.y, repeat: vfield)
                    }
                }
            }
        }, againstJSON: """
        {
            "repeat": { "column": ["A","B"] }, "spec": {
                "repeat": {"row": ["C","D"] }, "spec": {
                    "mark": "bar",
                    "encoding": { "x": { "field": { "repeat": "column" } }, "y": { "field": { "repeat": "row" } } }
                }
            }
        }
        """)

        try check(viz: Graphiq {
            Repeat(.wrap, fields: ["A", "B", "C", "D"]) { ffield in
                Mark(.rule) {
                    Encode(.x, repeat: ffield)
                }
            }
        }, againstJSON: """
        {
            "repeat": ["A","B","C","D"],
            "spec": {
                "mark": "rule",
                "encoding": { "x": { "field": { "repeat": "repeat" } } }
            }
        }
        """)
    }

    func testEncodingVariations() throws {
        _ = Graphiq {
            VizTheme()
                .font("serif")
                .title(.init(fontSize: .init(GG.ExprRef(expr: GG.Expr("width * 0.05")))))
            

            Mark(.arc)
            Mark(.area)
            Mark(.geoshape)
            Mark(.text)
            Mark(.boxplot)

            Mark(.bar) {
                do {
                    Encode(.x)

                    Encode(.x).aggregate(GG.Aggregate(GG.NonArgAggregateOp.average))

                    Encode(.x, field: "a")
                    Encode(.x, value: .width)
                    Encode(.x, value: 22)
                    Encode(.x, datum: 22)
                    Encode(.x, expression: "1+2")
                    Encode(.x, repeat: GG.RepeatRef(repeat: .column))
                }

                do {
                    Encode(.y)
                    Encode(.y, field: "b")
                    Encode(.y, value: .height)
                    Encode(.y, value: 22)
                    Encode(.y, datum: 22)
                    Encode(.y, expression: "1+2")
                    Encode(.y, repeat: GG.RepeatRef(repeat: .row))
                }

                do {
                    Encode(.row)
                    Encode(.row, field: "FIELD")
                }

                do {
                    Encode(.column)
                    Encode(.column, field: "FIELD")
                }

                do {
                    Encode(.facet)
                    Encode(.facet, field: "FIELD")
                }

                do {
                    Encode(.x2)
                    Encode(.x2, field: "FIELD")
                }

                do {
                    Encode(.y2)
                    Encode(.y2, field: "FIELD")
                }

                do {
                    Encode(.latitude)
                    Encode(.latitude, field: GG.FieldName("FIELD"))
                    Encode(.latitude, datum: nil)
                    Encode(.latitude, datum: "X")
                    Encode(.latitude, datum: 1)
                }

                do {
                    Encode(.latitude2)
                    Encode(.latitude2, field: GG.FieldName("FIELD"))
                    Encode(.latitude2, datum: nil)
                    Encode(.latitude2, datum: "X")
                    Encode(.latitude2, datum: 1)
                }

                do {
                    Encode(.longitude)
                    Encode(.longitude, field: GG.FieldName("FIELD"))
                    Encode(.longitude, datum: nil)
                    Encode(.longitude, datum: "X")
                    Encode(.longitude, datum: 1)
                }

                do {
                    Encode(.longitude2)
                    Encode(.longitude2, field: GG.FieldName("FIELD"))
                    Encode(.longitude2, datum: nil)
                    Encode(.longitude2, datum: "X")
                    Encode(.longitude2, datum: 1)
                }

                do {
                    Encode(.href)
                    Encode(.href, field: GG.FieldName("FIELD"))
                    Encode(.href, value: nil)
                    Encode(.href, value: .null)
                    Encode(.href, value: "https://www.example.org")
                    Encode(.href, expr: .init(expr: GG.Expr("'https://' + 'whatever.net'")))
                }

                do {
                    Encode(.url)
                    Encode(.url, field: GG.FieldName("FIELD"))
                    Encode(.url, value: nil)
                    Encode(.url, value: .null)
                    Encode(.url, value: "https://www.example.org")
                    Encode(.url, expr: .init(expr: GG.Expr("'https://' + 'whatever.net'")))
                }

                do {
                    Encode(.description)
                    Encode(.description, field: GG.FieldName("FIELD"))
                    Encode(.description, value: nil)
                    Encode(.description, value: .null) // same
                    Encode(.description, value: "Description")
                    Encode(.description, expr: .init(expr: GG.Expr("'Desc' + 'ription'")))
                }

                do {
                    Encode(.strokeDash)
                    Encode(.strokeDash, field: GG.FieldName("FIELD"))
                    Encode(.strokeDash, value: [1, 2, 3])
                }

                do {
                    Encode(.description)
                    Encode(.description, field: GG.FieldName("FIELD"))
                    Encode(.description, value: nil)
                    Encode(.description, value: .null)
                    Encode(.description, value: "Accessible Description")
                }

                do {
                    Encode(.url)
                    Encode(.url, field: GG.FieldName("FIELD"))
                    Encode(.url, value: nil)
                    Encode(.url, value: .null)
                    Encode(.url, value: "https://www.example.org/image.png")
                }

                do {
                    Encode(.key)
                    Encode(.key, field: GG.FieldName("FIELD")) // key only permits field encodings
                }

                do {
                    Encode(.shape)
                    Encode(.shape, field: GG.FieldName("FIELD"))
                    Encode(.shape, value: nil)
                    Encode(.shape, value: GG.SymbolShape.circle)
                }

                do {
                    Encode(.detail)
                    Encode(.detail, field: "ABC")
                }


                do {
                    Encode(.order)
                    Encode(.order, value: 1)
                    Encode(.order, field: "ORDER_FIELD")
                        .sort(.ascending)
                }

                do {
                    Encode(.text)
                    Encode(.text, value: "text value")
                    Encode(.text, field: "TEXT_FIELD")
                    Encode(.text, values: ["text", "value"])
                    Encode(.text, expression: "'a' + 'b'")
                }

                do {
                    Encode(.tooltip)
                    Encode(.tooltip, value: "tip value")
                    Encode(.tooltip, field: "TIP_FIELD")
                    Encode(.tooltip, fields: ["TIP_FIELD1", "TIP_FIELD2"])
                }

                do {
                    Encode(.color)
                    Encode(.color, field: GG.FieldName("c"))
                        .legend(nil)
                        .title(.init("Colorful"))
                    Encode(.color, value: .null)
                    Encode(.color, value: "red")
                    //Encode(.color, value: .init(.init(.steelblue)))
                }

                do {
                    Encode(.size)
                    Encode(.size, field: GG.FieldName("dc"))
                        .legend(.init(nil))
                        .title(.init("Colorful"))
                    Encode(.size, value: 33)
                }

                Encode(.x, field: GG.FieldName("a"))
                    .type(.nominal)
                    .aggregate(.sum)
                    .axis(nil)

                Encode(.y)
                    .field(GG.SourceColumnRef(GG.FieldName("b")))
                    .type(.quantitative)
                    .bandPosition(11)

                Encode(.color, field: GG.FieldName("c"))
                    .legend(nil)
                    .type(.ordinal)

                Encode(.size, datum: 44)

            }
            .cornerRadius(10)
        }
        .title(.init("Bar Chart"))
        .description("A simple bar chart with embedded data.")
    }

    func testExpressions() throws {
        let viz = Graphiq {
            VizTheme()
                .font("serif")
                .title(.init(fontSize: .init(GG.ExprRef(expr: GG.Expr("width * 0.05")))))

            Mark(.bar) {
                Encode(.x, field: GG.FieldName("a"))
                    .type(.nominal)
                    .aggregate(.sum)
                    .axis(nil)

                Encode(.y, field: GG.FieldName("b"))
                    .type(.quantitative)
                    .bandPosition(11)

                Encode(.color, field: GG.FieldName("c"))
                    .legend(nil)
                    .type(.ordinal)

                Encode(.size, datum: 44)
            }
            .cornerRadius(10)
        }
        .title(.init("Bar Chart"))
        .description("A simple bar chart with embedded data.")

        try check(viz: viz, againstJSON: """
        {
            "title": "Bar Chart",
            "description": "A simple bar chart with embedded data.",
            "mark": { "cornerRadius": 10, "type": "bar" },
            "encoding": {
                "x": { "type": "nominal", "field": "a", "aggregate": "sum", "axis": null },
                "y": { "type": "quantitative", "field":"b", "bandPosition": 11 },
                "color": { "field": "c", "type": "ordinal", "legend": null },
                "size": { "datum": 44 }
            },
            "config": {
                "font": "serif",
                "title": {
                    "fontSize": {
                        "expr": "width * 0.05"
                    }
                }
            }
        }
        """)
    }



}

