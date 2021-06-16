import XCTest
import GGDSL

typealias SimpleViz = Viz<Bric.ObjType>

extension XCTestCase {
    func check<M: Pure>(viz: Viz<M>, againstJSON json: String, file: StaticString = #file, line: UInt = #line, function: StaticString = #function) throws {
        if viz.spec == Viz({ }).spec {
            throw XCTSkip("skip empty check for \(function)", file: file, line: line)
        }

        let checkSpec = try VizSpec<M>.loadFromJSON(data: json.data(using: .utf8) ?? Data())
        // first check if they both to serialize to the same JSON…
        XCTAssertEqual("\n" + viz.debugDescription + "\n", "\n" + checkSpec.jsonDebugDescription + "\n")
        if viz.debugDescription == checkSpec.jsonDebugDescription {
            // … then check for actual equality of thw structure
            XCTAssertEqual(viz.spec, checkSpec)
        }
    }
}

final class GGDSLTests: XCTestCase {

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

    func testVizDetailEncoding() throws {
        try check(viz: SimpleViz {
            VizMark(.circle) {
                VizEncode(.detail, field: "X")
                VizEncode(.detail, field: FieldName("Y"))
            }
        }, againstJSON: """
            {"mark":"circle", "encoding": { "detail": {"field":"Y"} } }
        """)
    }

    func testVizFacets() throws {
        try check(viz: SimpleViz {
            VizMark(.rect) {
                VizEncode(.row, field: "ROW_FIELD")
                VizEncode(.column, field: "COLUMN_FIELD")
                VizEncode(.facet, field: "FACET_FIELD")
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

                    VizEncode(.x, field: "a")
                    VizEncode(.x, value: .width)
                    VizEncode(.x, value: 22)
                    VizEncode(.x, datum: 22)
                    VizEncode(.x, expression: "1+2")
                    VizEncode(.x, repeat: RepeatRef(repeat: .column))
                }

                do {
                    VizEncode(.y)
                    VizEncode(.y, field: "b")
                    VizEncode(.y, value: .height)
                    VizEncode(.y, value: 22)
                    VizEncode(.y, datum: 22)
                    VizEncode(.y, expression: "1+2")
                    VizEncode(.y, repeat: RepeatRef(repeat: .row))
                }


                do {
                    VizEncode(.row)
                    VizEncode(.row, field: "FIELD")
                }

                do {
                    VizEncode(.column)
                    VizEncode(.column, field: "FIELD")
                }

                do {
                    VizEncode(.facet)
                    VizEncode(.facet, field: "FIELD")
                }

                do {
                    VizEncode(.x2)
                    VizEncode(.x2, field: "FIELD")
                }

                do {
                    VizEncode(.y2)
                    VizEncode(.y2, field: "FIELD")
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

                do {
                    VizEncode(.detail)
                    VizEncode(.detail, field: "ABC")
                }


//                do {
//                    VizEncode(.order)
//                }
//
//                do {
//                    VizEncode(.text)
//                }
//
//                do {
//                    VizEncode(.tooltip)
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
                    .field(SourceColumnRef(FieldName("b")))
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



    func test_interactive_global_development() throws {
        throw XCTSkip();
        try check(viz: SimpleViz {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "An interactive scatter plot of global health statistics by country and year.",
  "data": {"url": "data/gapminder.json"},
  "width": 800,
  "height": 500,
  "layer": [
    {
      "transform": [
        {"filter": {"field": "country", "equal": "Afghanistan"}},
        {"filter": {"param": "year"}}
      ],
      "mark": {
        "type": "text",
        "fontSize": 100,
        "x": 420,
        "y": 250,
        "opacity": 0.06
      },
      "encoding": {"text": {"field": "year"}}
    },
    {
      "transform": [
        {
          "lookup": "cluster",
          "from": {
            "key": "id",
            "fields": ["name"],
            "data": {
              "values": [
                {"id": 0, "name": "South Asia"},
                {"id": 1, "name": "Europe & Central Asia"},
                {"id": 2, "name": "Sub-Saharan Africa"},
                {"id": 3, "name": "America"},
                {"id": 4, "name": "East Asia & Pacific"},
                {"id": 5, "name": "Middle East & North Africa"}
              ]
            }
          }
        }
      ],
      "encoding": {
        "x": {
          "field": "fertility",
          "type": "quantitative",
          "scale": {"domain": [0, 9]},
          "axis": {"tickCount": 5, "title": "Fertility"}
        },
        "y": {
          "field": "life_expect",
          "type": "quantitative",
          "scale": {"domain": [20, 85]},
          "axis": {"tickCount": 5, "title": "Life Expectancy"}
        }
      },
      "layer": [
        {
          "mark": {
            "type": "line",
            "size": 4,
            "color": "lightgray",
            "strokeCap": "round"
          },
          "encoding": {
            "detail": {"field": "country"},
            "order": {"field": "year"},
            "opacity": {
              "condition": {
                "test": {"or": [
                  {"param": "hovered", "empty": false},
                  {"param": "clicked", "empty": false}
                ]},
                "value": 0.8
              },
              "value": 0
            }
          }
        },
        {
          "params": [
            {
              "name": "year",
              "value": [{"year": 1955}],
              "select": {
                "type": "point",
                "fields": ["year"]
              },
              "bind": {
                "name": "Year",
                "input": "range",
                "min": 1955, "max": 2005, "step": 5
              }
            },
            {
              "name": "hovered",
              "select": {
                "type": "point",
                "fields": ["country"],
                "toggle": false,
                "on": "mouseover"
              }
            },
            {
              "name": "clicked",
              "select": {"type": "point", "fields": ["country"]}
            }
          ],
          "transform": [{"filter": {"param": "year"}}],
          "mark": {"type": "circle", "size": 100, "opacity": 0.9},
          "encoding": {"color": {"field": "name", "title": "Region"}}
        },
        {
          "transform": [
            {
              "filter": {
                "and": [
                  {"param": "year"},
                  {"or": [
                    {"param": "clicked", "empty": false},
                    {"param": "hovered", "empty": false}
                  ]}
                ]
              }
            }
          ],
          "mark": {
            "type": "text",
            "yOffset": -12,
            "fontSize": 12,
            "fontWeight": "bold"
          },
          "encoding": {
            "text": {"field": "country"},
            "color": {"field": "name", "title": "Region"}
          }
        },
        {
          "transform": [
            {"filter": {"param": "hovered", "empty": false}},
            {"filter": {"not": {"param": "year"}}}
          ],
          "layer": [
            {
              "mark": {
                "type": "text",
                "yOffset": -12,
                "fontSize": 12,
                "color": "gray"
              },
              "encoding": {"text": {"field": "year"}}
            },
            {"mark": {"type": "circle", "color": "gray"}}
          ]
        }
      ]
    }
  ]
}
""")
    }
}

