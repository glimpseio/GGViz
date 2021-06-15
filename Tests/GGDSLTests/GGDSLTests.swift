import XCTest
import GGDSL

final class GGDSLTests: XCTestCase {
    typealias SimpleViz = Viz<Bric.ObjType>

    func check<M: Pure>(viz: Viz<M>, againstJSON json: String) throws {
        let checkSpec = try VizSpec<M>.loadFromJSON(data: json.data(using: .utf8) ?? Data())
        // first check if they both to serialize to the same JSON…
        XCTAssertEqual("\n" + viz.debugDescription + "\n", "\n" + checkSpec.jsonDebugDescription + "\n")
        if viz.debugDescription == checkSpec.jsonDebugDescription {
            // … then check for actual equality of thw structure
            XCTAssertEqual(viz.spec, checkSpec)
        }
    }

    func testVizMarkSimple() throws {
        try check(viz: SimpleViz {
            VizMark(.square)
        }, againstJSON: """
            {"mark":"square"}
        """)
    }

    func testVizMarkCompound() throws {
        try check(viz: SimpleViz {
            VizMark(.boxplot)
        }, againstJSON: """
            {"mark":"boxplot"}
        """)
    }

    func testVizTransform() throws {
        try check(viz: SimpleViz {
            VizTransform(.sample)
            VizMark(.square)
        }, againstJSON: """
            {
                "mark":"square",
                "transform":[
                    {"sample":999}
                ]
            }
            """)
    }


    func testVizFacets() throws {
        try check(viz: SimpleViz {
            VizMark(.rect) {
                VizEncode(.row, field: FieldName("ROW_FIELD"))
                VizEncode(.column, field: FieldName("COLUMN_FIELD"))
                VizEncode(.facet, field: FieldName("FACET_FIELD"))
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

    func testVizStrokeDash() throws {
        try check(viz: SimpleViz {
            VizMark(.line) {
                VizEncode(.strokeDash, value: [1, 2, 3])
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

    func testVizShapes() throws {
        try check(viz: SimpleViz {
            VizMark(.point) {
                VizEncode(.shape, value: .circle)
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

        try check(viz: SimpleViz {
            VizMark(.point) {
                VizEncode(.shape, value: .path("M0,0 L1,1"))
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

    func testVizLayer() throws {
        try check(viz: SimpleViz {
            VizLayer(.overlay)
        }, againstJSON: """
        {
            "layer": []
        }
        """)

        try check(viz: SimpleViz {
            VizLayer(.vconcat)
        }, againstJSON: """
        {
            "vconcat": []
        }
        """)

        try check(viz: SimpleViz {
            VizLayer(.concat) {
                VizMark(.bar) {
                    VizEncode(.x)
                    VizEncode(.y)
                }
            }
        }, againstJSON: """
        { "concat": [ { "encoding": { "x": { }, "y": { } }, "mark": "bar" } ] }
        """)
    }

    func testVizLayerMarkTypes() throws {
        try check(viz: SimpleViz {
            VizLayer(.hconcat) {
                VizMark(.arc)
                VizMark(.area)
                VizMark(.bar)
                VizMark(.boxplot)
                VizMark(.circle)
                VizMark(.errorband)
                VizMark(.errorbar)
                VizMark(.geoshape)
                VizMark(.image)
                VizMark(.line)
                VizMark(.point)
                VizMark(.rect)
                VizMark(.rule)
                VizMark(.square)
                VizMark(.text)
                VizMark(.tick)
                VizMark(.trail)
            }
        }, againstJSON: """
        {
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

    func testVizLayerNesting() throws {

        let actual = """
        {
          "hconcat": [
            {
              "encoding": {
                "x": {}
              }
            },
            {
              "vconcat": [
                {
                  "encoding": {
                    "y": {}
                  }
                },
                {
                  "mark": "bar",
                  "encoding": {
                    "size": {}
                  }
                }
              ]
            }
          ]
        }
        """

        let aspirational = """
        {
          "encoding": { "x": { } },
          "hconcat": [
            {
              "encoding": { "y": { } },
              "vconcat": [
                {
                  "mark": "bar",
                  "encoding": { "size": { } }
                }
              ]
            }
          ]
        }
        """

        try check(viz: SimpleViz {
            VizLayer(.hconcat) {
                VizEncode(.x)
                VizLayer(.vconcat) {
                    VizEncode(.y)
                    VizMark(.bar) {
                        VizEncode(.size)
                    }
                }
            }
        }, againstJSON: actual)
    }

    func testVizProjection() throws {
        try check(viz: SimpleViz {
            VizProjection()
        }, againstJSON: """
        {
            "projection": { }
        }
        """)

        try check(viz: SimpleViz {
            VizProjection(.albersUsa)
                .precision(.init(0.1))
        }, againstJSON: """
        {
            "projection": {
                "precision": 0.1,
                "type": "albersUsa"
            }
        }
        """)
    }

    func testEncodingVariations() throws {
        _ = SimpleViz {
            VizTheme()
                .font(.init("serif"))
                .title(.init(fontSize: .init(ExprRef(expr: Expr("width * 0.05")))))

            VizMark(.arc)
            VizMark(.area)
            VizMark(.geoshape)
            VizMark(.text)
            VizMark(.boxplot)

            VizMark(.bar) {
                do {
                    VizEncode(.x)

                    VizEncode(.x).aggregate(Aggregate(NonArgAggregateOp.average))

                    VizEncode(.x, field: FieldName("a"))
                    VizEncode(.x, value: .width)
                    VizEncode(.x, value: 22)
                    VizEncode(.x, datum: 22)
                    VizEncode(.x, expression: "1+2")
                    VizEncode(.x, repeat: RepeatRef(repeat: .column))
                }

                do {
                    VizEncode(.y)
                    VizEncode(.y, field: FieldName("b"))
                    VizEncode(.y, value: .height)
                    VizEncode(.y, value: 22)
                    VizEncode(.y, datum: 22)
                    VizEncode(.y, expression: "1+2")
                    VizEncode(.y, repeat: RepeatRef(repeat: .row))
                }


                do {
                    VizEncode(.row)
                    VizEncode(.row, field: FieldName("FIELD"))
                }

                do {
                    VizEncode(.column)
                    VizEncode(.column, field: FieldName("FIELD"))
                }

                do {
                    VizEncode(.facet)
                    VizEncode(.facet, field: FieldName("FIELD"))
                }

                do {
                    VizEncode(.x2)
                    VizEncode(.x2, field: FieldName("FIELD"))
                }

                do {
                    VizEncode(.y2)
                    VizEncode(.y2, field: FieldName("FIELD"))
                }

                do {
                    VizEncode(.latitude)
                    VizEncode(.latitude, field: FieldName("FIELD"))
                    VizEncode(.latitude, datum: nil)
                    VizEncode(.latitude, datum: "X")
                    VizEncode(.latitude, datum: 1)
                }

                do {
                    VizEncode(.latitude2)
                    VizEncode(.latitude2, field: FieldName("FIELD"))
                    VizEncode(.latitude2, datum: nil)
                    VizEncode(.latitude2, datum: "X")
                    VizEncode(.latitude2, datum: 1)
                }

                do {
                    VizEncode(.longitude)
                    VizEncode(.longitude, field: FieldName("FIELD"))
                    VizEncode(.longitude, datum: nil)
                    VizEncode(.longitude, datum: "X")
                    VizEncode(.longitude, datum: 1)
                }

                do {
                    VizEncode(.longitude2)
                    VizEncode(.longitude2, field: FieldName("FIELD"))
                    VizEncode(.longitude2, datum: nil)
                    VizEncode(.longitude2, datum: "X")
                    VizEncode(.longitude2, datum: 1)
                }

                do {
                    VizEncode(.href)
                    VizEncode(.href, field: FieldName("FIELD"))
                    VizEncode(.href, value: nil)
                    VizEncode(.href, value: .null)
                    VizEncode(.href, value: "https://www.example.org")
                    VizEncode(.href, expr: .init(expr: Expr("'https://' + 'whatever.net'")))
                }

                do {
                    VizEncode(.url)
                    VizEncode(.url, field: FieldName("FIELD"))
                    VizEncode(.url, value: nil)
                    VizEncode(.url, value: .null)
                    VizEncode(.url, value: "https://www.example.org")
                    VizEncode(.url, expr: .init(expr: Expr("'https://' + 'whatever.net'")))
                }

                do {
                    VizEncode(.description)
                    VizEncode(.description, field: FieldName("FIELD"))
                    VizEncode(.description, value: nil)
                    VizEncode(.description, value: .null) // same
                    VizEncode(.description, value: "Description")
                    VizEncode(.description, expr: .init(expr: Expr("'Desc' + 'ription'")))
                }

                do {
                    VizEncode(.strokeDash)
                    VizEncode(.strokeDash, field: FieldName("FIELD"))
                    VizEncode(.strokeDash, value: [1, 2, 3])
                }

                do {
                    VizEncode(.description)
                    VizEncode(.description, field: FieldName("FIELD"))
                    VizEncode(.description, value: nil)
                    VizEncode(.description, value: .null)
                    VizEncode(.description, value: "Accessible Description")
                }

                do {
                    VizEncode(.url)
                    VizEncode(.url, field: FieldName("FIELD"))
                    VizEncode(.url, value: nil)
                    VizEncode(.url, value: .null)
                    VizEncode(.url, value: "https://www.example.org/image.png")
                }

                do {
                    VizEncode(.key)
                    VizEncode(.key, field: FieldName("FIELD")) // key only permits field encodings
                }

                do {
                    VizEncode(.shape)
                    VizEncode(.shape, field: FieldName("FIELD"))
                    VizEncode(.shape, value: nil)
                    VizEncode(.shape, value: SymbolShape.circle)
                }


//                do {
//                    VizEncode(.order)
//                }
//                do {
//                    VizEncode(.text)
//                }
//
//                do {
//                    VizEncode(.tooltip)
//                }
//
//                do {
//                    VizEncode(.detail)
//                }

                do {
                    VizEncode(.color)
                    VizEncode(.color, field: FieldName("c"))
                        .legend(.init(nil))
                        .title(.init(.init("Colorful")))
                    VizEncode(.color, value: .null)
                    VizEncode(.color, value: "red")
                    //VizEncode(.color, value: .init(.init(.steelblue)))
                }

                do {
                    VizEncode(.size)
                    VizEncode(.size, field: FieldName("dc"))
                        .legend(.init(nil))
                        .title(.init(.init("Colorful")))
                    VizEncode(.size, value: 33)
                }

                VizEncode(.x, field: FieldName("a"))
                    .type(.nominal)
                    .aggregate(.sum)
                    .axis(.init(nil))

                VizEncode(.y)
                    .field(Field(FieldName("b")))
                    .type(.quantitative)
                    .bandPosition(11)

                VizEncode(.color, field: FieldName("c"))
                    .legend(.init(nil))
                    .type(.ordinal)

                VizEncode(.size, datum: 44)

            }
            .cornerRadius(.init(10))
        }
        .title(.init(.init("Bar Chart")))
        .description("A simple bar chart with embedded data.")
    }

    func testCondigSpec() throws {
        let viz = SimpleViz {
            VizTheme()
                .font(.init("serif"))
                .title(.init(fontSize: .init(ExprRef(expr: Expr("width * 0.05")))))

            VizMark(.bar) {
                VizEncode(.x, field: FieldName("a"))
                    .type(.nominal)
                    .aggregate(.sum)
                    .axis(.init(nil))

                VizEncode(.y, field: FieldName("b"))
                    .type(.quantitative)
                    .bandPosition(11)

                VizEncode(.color, field: FieldName("c"))
                    .legend(.init(nil))
                    .type(.ordinal)

                VizEncode(.size, datum: 44)
            }
            .cornerRadius(.init(10))
        }
        .title(.init(.init("Bar Chart")))
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

    func testSimpleVizSpec() throws {
        _ = SimpleVizSpec()
    }

    func testSimpleBarChart() throws {
        _ = """
        {
          "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
          "description": "A simple bar chart with embedded data.",
          "data": {
            "values": [
              {"a": "A", "b": 28}, {"a": "B", "b": 55}, {"a": "C", "b": 43},
              {"a": "D", "b": 91}, {"a": "E", "b": 81}, {"a": "F", "b": 53},
              {"a": "G", "b": 19}, {"a": "H", "b": 87}, {"a": "I", "b": 52}
            ]
          },
          "mark": "bar",
          "encoding": {
            "x": {"field": "a", "type": "nominal", "axis": {"labelAngle": 0}},
            "y": {"field": "b", "type": "quantitative"}
          }
        }
        """

//        _ = VizMark(.bar, description: "A simple bar chart with embedded data.") {
//            VizEncode(.x, field: "a", type: .nominal)
//                .axis(labelAngle: 0)
//            VizEncode(.y, field: "b", type: .quantitative)
//        }
    }

    func testStackedBarChartwithRoundedCorners() throws {
        _ = """
        {
          "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
          "data": {"url": "data/seattle-weather.csv"},
          "mark": {"type": "bar", "cornerRadiusTopLeft": 3, "cornerRadiusTopRight": 3},
          "encoding": {
            "x": {"timeUnit": "month", "field": "date", "type": "ordinal"},
            "y": {"aggregate": "count"},
            "color": {"field": "weather"}
          }
        }
        """

//        _ = VizMark(.bar) {
//            VizEncode(.x, field: "date")
//                .measure(.ordinal)
//                .timeUnit(.month)
//            VizEncode(.y, aggregate: .count)
//            VizEncode(.color, field: "weather")
//        }
//        .cornerRadiusTopLeft(3)
//        .cornerRadiusTopRight(3)
    }

    func testLineChartWithHighlightedRectangles() {
        _ = """
        {
          "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
          "description": "The population of the German city of Falkensee over time",
          "width": 500,
          "data": {
            "values": [
              {"year": "1875", "population": 1309},
              {"year": "2014", "population": 41777}
            ],
            "format": {
              "parse": {"year": "date:'%Y'"}
            }
          },
          "layer": [
            {
              "mark": "rect",
              "data": {
                "values": [
                  {
                    "start": "1933",
                    "end": "1945",
                    "event": "Nazi Rule"
                  },
                  {
                    "start": "1948",
                    "end": "1989",
                    "event": "GDR (East Germany)"
                  }
                ],
                "format": {
                  "parse": {"start": "date:'%Y'", "end": "date:'%Y'"}
                }
              },
              "encoding": {
                "x": {
                  "field": "start",
                  "timeUnit": "year"
                },
                "x2": {
                  "field": "end",
                  "timeUnit": "year"
                },
                "color": {"field": "event", "type": "nominal"}
              }
            },
            {
              "mark": "line",
              "encoding": {
                "x": {
                  "field": "year",
                  "timeUnit": "year",
                  "title": "year (year)"
                },
                "y": {"field": "population", "type": "quantitative"},
                "color": {"value": "#333"}
              }
            },
            {
              "mark": "point",
              "encoding": {
                "x": {
                  "field": "year",
                  "timeUnit": "year"
                },
                "y": {"field": "population", "type": "quantitative"},
                "color": {"value": "#333"}
              }
            }
          ]
        }
        """

//        _ = Viz {
//            Layer(.overlay) {
//                Mark(.rect) {
//                    Source {
//                        [
//                            ["start": "1933", "end": "1945", "event": "Nazi Rule"],
//                            ["start": "1948", "end": "1989", "event": "GDR (East Germany)"],
//                        ]
//                    }
//                    Encode(.x, field: "start").timeUnit(.year)
//                    Encode(.x2, field: "end").timeUnit(.year)
//                    Encode(.color, field: "event").measure(.nominal)
//                }
//                Mark(.line) {
//                    Encode(.x, field: "year").timeUnit(.year).title("year (year)")
//                    Encode(.y, field: "population").measure(.quantitative)
//                    Encode(.color, value: "#333")
//                }
//                Mark(.point) {
//                    Encode(.x, field: "year").timeUnit(.year)
//                    Encode(.y, field: "population").measure(.quantitative)
//                    Encode(.color, value: "#333")
//                }
//            }
//        }
//        .arrangement(.overlay)
//        .width(500)

    }

    func testMultiSeriesLineChartWithRepeatOperator() throws {
        _ = """
        {
          "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
          "data": {
            "url": "data/movies.json"
          },
          "repeat": {
            "layer": ["US Gross", "Worldwide Gross"]
          },
          "spec": {
            "mark": "line",
            "encoding": {
              "x": {
                "bin": true,
                "field": "IMDB Rating",
                "type": "quantitative"
              },
              "y": {
                "aggregate": "mean",
                "field": {"repeat": "layer"},
                "type": "quantitative",
                "title": "Mean of US and Worldwide Gross"
              },
              "color": {
                "datum": {"repeat": "layer"},
                "type": "nominal"
              }
            }
          }
        }
        """

//        _ = ZRepeat(["US Gross", "Worldwide Gross"]) { repeatField in
//            Mark(.line) {
//                Encode(.x, field: "IMDB Rating")
//                    .measure(.quantitative)
//                    .bin(true)
//                Encode(.y, field: repeatField)
//                    .aggregate(.mean)
//                    .title("Mean of US and Worldwide Gross")
//                Encode(.color, datum: repeatField, type: .nominal)
//            }
//        }
//        .cornerRadiusTopLeft(3)
//        .cornerRadiusTopRight(3)

    }
}

extension VizSpec {
//    static func sample() -> Self {
//        ZGroup {
//            Encode(.x, field: "a").axis(false)
//            Encode(.y, field: "b").axis(true)
//            VizMark(.bar) {
//                Encode(.color, field: "c").legend(true)
//                Encode(.tooltip, fields: ["d", "e"])
//            }
//            VizMark(.text) {
//                Encode(.text, value: "Fields")
//                Encode(.text, field: "c")
//                Encode(.text, field: "d")
//                Encode(.text, field: "e")
//                Encode(.color, value: .gray)
//            }
//        }
//    }

//    static func simple1() -> Self {
//        VizSpec(title: "Simple Bar Chart") {
//            ZLayer(fields: ["A", "B"]) { field in
//                Mark(.bar) {
//                    Channel(.x, from: Field("COL_A"), type: .temporal).axis(false)
//                    Channel(.y, from: Field("COL_B"), type: .ordinal)
//                    Channel(.fill, from: Field("COL_C"), type: .nominal).legend(true)
//                }
//                .axis(true)
//                .legend(true)
//
//                Mark(.text) {
//                    Channel(.x, from: Field("COL_A"), type: .temporal).axis(false)
//                    Channel(.y, from: Field("COL_B"), type: .ordinal)
//                    Channel(.fill, from: Field("COL_C"), type: .nominal).legend(true)
//                }
//                .axis(true)
//                .legend(true)
//            }
//            .arrangement(.overlay)
//        }
//    }
}

