import XCTest
import GGDSL

// This test case encapsulated all the sample specs and reproduces them using the GGDSL


/// - TODO: @available(*, deprecated, message: "DSL should not require access to GG types")
typealias GG = GGSchema.GG

final class GGDSLExampleTests: XCTestCase {
    func test_bar() throws {
        try check(viz: Graphiq {
            DataValues {
                [
                    ["a": "A", "b": 28],
                    ["a": "B", "b": 55],
                    ["a": "C", "b": 43],
                    ["a": "D", "b": 91],
                    ["a": "E", "b": 81],
                    ["a": "F", "b": 53],
                    ["a": "G", "b": 19],
                    ["a": "H", "b": 87],
                    ["a": "I", "b": 52],
                ]
            }

            Mark(.bar) {
                Encode(.x, field: "a") {
                    Guide().labelAngle(0)
                }
                .type(.nominal)

                Encode(.y, field: "b")
                    .type(.quantitative)
            }
        }
        , againstJSON: """
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
""")
    }

    func test_arc_donut() throws {
        try check(viz: Graphiq {
            Viewport().stroke(nil)

            DataValues {[
                ["category": 1, "value": 4],
                ["category": 2, "value": 6],
                ["category": 3, "value": 10],
                ["category": 4, "value": 3],
                ["category": 5, "value": 7],
                ["category": 6, "value": 8],
            ]}

            Mark(.arc) {
                Encode(.theta, field: "value").type(.quantitative)
                Encode(.color, field: "category").type(.nominal)
            }
            .innerRadius(50)
        }
        , againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A simple donut chart with embedded data.",
  "data": {
    "values": [
      {"category": 1, "value": 4},
      {"category": 2, "value": 6},
      {"category": 3, "value": 10},
      {"category": 4, "value": 3},
      {"category": 5, "value": 7},
      {"category": 6, "value": 8}
    ]
  },
  "mark": {"type": "arc", "innerRadius": 50},
  "encoding": {
    "theta": {"field": "value", "type": "quantitative"},
    "color": {"field": "category", "type": "nominal"}
  },
  "view": {"stroke": null}
}
""")
    }

    func test_arc_pie() throws {
        try check(viz: Graphiq {
            Viewport().stroke(nil)

            DataValues {[
                ["category": 1, "value": 4],
                ["category": 2, "value": 6],
                ["category": 3, "value": 10],
                ["category": 4, "value": 3],
                ["category": 5, "value": 7],
                ["category": 6, "value": 8],
            ]}

            Mark(.arc) {
                Encode(.theta, field: "value").type(.quantitative)
                Encode(.color, field: "category").type(.nominal)
            }
        }
        , againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A simple pie chart with embedded data.",
  "data": {
    "values": [
      {"category": 1, "value": 4},
      {"category": 2, "value": 6},
      {"category": 3, "value": 10},
      {"category": 4, "value": 3},
      {"category": 5, "value": 7},
      {"category": 6, "value": 8}
    ]
  },
  "mark": "arc",
  "encoding": {
    "theta": {"field": "value", "type": "quantitative"},
    "color": {"field": "category", "type": "nominal"}
  },
  "view": {"stroke": null}
}
""")
    }

    func test_arc_pie_pyramid() throws {
        try check(viz: Graphiq {
            Viewport().stroke(nil)

            DataValues {[
                ["category": "Sky", "value": 75, "order": 3],
                ["category": "Shady side of a pyramid", "value": 10, "order": 1],
                ["category": "Sunny side of a pyramid", "value": 15, "order": 2],
            ]}

            Mark(.arc) {
                Encode(.theta, field: "value") {
                    Scale()
                        .range(2.35619449...8.639379797)
                }
                .type(.quantitative)
                .stack(.init(.init(true)))

                Encode(.color, field: "category") {
                    Scale()
                        .scale(domainValue: "Sky", toRange: "#416D9D")
                        .scale(domainValue: "Shady side of a pyramid", toRange: "#674028")
                        .scale(domainValue: "Sunny side of a pyramid", toRange: "#DEAC58")

                    Guide()
                        .columns(1)
                        .legendX(200)
                        .legendY(80)
                        .orient(GG.LegendOrient.none)
                        .title(.init(.null))
                }
                .type(.nominal)

                Encode(.order, field: "order")

            }
            .outerRadius(.init(80))
        }
        , againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Reproducing http://robslink.com/SAS/democd91/pyramid_pie.htm",
  "data": {
    "values": [
      {"category": "Sky", "value": 75, "order": 3},
      {"category": "Shady side of a pyramid", "value": 10, "order": 1},
      {"category": "Sunny side of a pyramid", "value": 15, "order": 2}
    ]
  },
  "mark": {"type": "arc", "outerRadius": 80},
  "encoding": {
    "theta": {
      "field": "value", "type": "quantitative",
      "scale": {"range": [2.35619449, 8.639379797]},
      "stack": true
    },
    "color": {
      "field": "category", "type": "nominal",
      "scale": {
        "domain": ["Sky", "Shady side of a pyramid", "Sunny side of a pyramid"],
        "range": ["#416D9D", "#674028", "#DEAC58"]
      },
      "legend": {
        "orient": "none",
        "title": null,
        "columns": 1,
        "legendX": 200,
        "legendY": 80
      }
    },
    "order": {
      "field": "order"
    }
  },
  "view": {"stroke": null}
}
""")
    }

    func test_arc_radial() throws {
        try check(viz: Graphiq {
            Viewport().stroke(nil)
            DataValues { [12, 23, 47, 6, 52, 19] }
            Layer {
                Encode(.color, field: "data").type(.nominal).legend(nil)
                Encode(.theta, field: "data").type(.quantitative).stack(.init(true))
                Encode(.radius, field: "data") {
                    Scale().type(.sqrt).zero(true).rangeMin(20)
                }

                Mark(.arc) {
                }
                .innerRadius(20)
                .stroke(.init(GG.ColorLiteral(GG.HexColor("#fff"))))

                Mark(.text) {
                    Encode(.text, field: "data").type(.quantitative)
                }
                .radiusOffset(10)
            }
        }
        , againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A simple radial chart with embedded data.",
  "data": {
    "values": [12, 23, 47, 6, 52, 19]
  },
  "layer": [{
    "mark": {"type": "arc", "innerRadius": 20, "stroke": "#fff"}
  },{
    "mark": {"type": "text", "radiusOffset": 10},
    "encoding": {
      "text": {"field": "data", "type": "quantitative"}
    }
  }],
  "encoding": {
    "theta": {"field": "data", "type": "quantitative", "stack": true},
    "radius": {"field": "data", "scale": {"type": "sqrt", "zero": true, "rangeMin": 20}},
    "color": {"field": "data", "type": "nominal", "legend": null}
  },
  "view": {"stroke": null}
}
""")
    }

    func test_area() throws {
        try check(viz: Graphiq(width: 300, height: 200) {
            DataReference(path: "data/unemployment-across-industries.json")
            Mark(.area) {
                Encode(.x, field: "date") {
                    Guide()
                        .format("%Y")
                }
                .timeUnit(.yearmonth)
                Encode(.y, field: "count")
                    .aggregate(.sum)
                    .title(.init("count"))

            }
        }
        , againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "width": 300,
  "height": 200,
  "data": {"url": "data/unemployment-across-industries.json"},
  "mark": "area",
  "encoding": {
    "x": {
      "timeUnit": "yearmonth", "field": "date",
      "axis": {"format": "%Y"}
    },
    "y": {
      "aggregate": "sum", "field": "count",
      "title": "count"
    }
  }
}
""")
    }

    func test_area_cumulative_freq() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/movies.json")
            Transform(.window, field: "count", op: .init(.count), frame: .init(...0), sort: [("IMDB Rating", nil)], output: "Cumulative Count") { ccountField in
                Mark(.area) {
                    Encode(.x, field: "IMDB Rating").type(.quantitative)
                    Encode(.y, field: ccountField).type(.quantitative)
                }
            }
        }
        , againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/movies.json"},
  "transform": [{
    "sort": [{"field": "IMDB Rating"}],
    "window": [{"op": "count", "field": "count", "as": "Cumulative Count"}],
    "frame": [null, 0]
  }],
  "mark": "area",
  "encoding": {
    "x": {
      "field": "IMDB Rating",
      "type": "quantitative"
    },
    "y": {
      "field": "Cumulative Count",
      "type": "quantitative"
    }
  }
}
""")
    }

    func test_area_density() throws {
        try check(viz: Graphiq(width: 400, height: 100) {
            DataReference(path: "data/movies.json")
            Transform(.density, field: "IMDB Rating") { sampleValue, densityEstimate in
                Mark(.area) {
                    Encode(.x, field: sampleValue).type(.quantitative).title(.init("IMDB Rating"))
                    Encode(.y, field: densityEstimate).type(.quantitative)
                }
            }.bandwidth(0.3)
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "url": "data/movies.json"
  },
  "width": 400,
  "height": 100,
  "transform":[{
    "density": "IMDB Rating",
    "bandwidth": 0.3
  }],
  "mark": "area",
  "encoding": {
    "x": {
      "field": "value",
      "title": "IMDB Rating",
      "type": "quantitative"
    },
    "y": {
      "field": "density",
      "type": "quantitative"
    }
  }
}
""")
    }

    func test_area_density_facet() throws {
        try check(viz: Graphiq(width: 400, height: 80, title: "Distribution of Body Mass of Penguins") {
            DataReference(path: "data/penguins.json")
            Transform(.density, field: "Body Mass (g)") { sampleValue, densityEstimate in
                Mark(.area) {
                    Encode(.x, field: sampleValue).type(.quantitative).title(.init("Body Mass (g)"))
                    Encode(.y, field: densityEstimate).type(.quantitative).stack(.init(.zero))
                    Encode(.row, field: "Species")
                }
            }.groupby([.init("Species")]).extent([2500, 6500])
        }
        , againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "title": "Distribution of Body Mass of Penguins",
  "width": 400,
  "height": 80,
  "data": {
    "url": "data/penguins.json"
  },
  "mark": "area",
  "transform": [
    {
      "density": "Body Mass (g)",
      "groupby": ["Species"],
      "extent": [2500, 6500]
    }
  ],
  "encoding": {
    "x": {"field": "value", "type": "quantitative", "title": "Body Mass (g)"},
    "y": {"field": "density", "type": "quantitative", "stack": "zero"},
    "row": {"field": "Species"}
  }
}
""")
    }

    func test_area_density_stacked() throws {
        try check(viz: Graphiq(width: 400, height: 80, title: "Distribution of Body Mass of Penguins") {
            DataReference(path: "data/penguins.json")
            Transform(.density, field: "Body Mass (g)") { sampleValue, densityEstimate in
                Mark(.area) {
                    Encode(.x, field: sampleValue).type(.quantitative).title(.init("Body Mass (g)"))
                    Encode(.y, field: densityEstimate).type(.quantitative).stack(.init(.zero))
                    Encode(.color, field: "Species").type(.nominal)
                }
            }.groupby([.init("Species")]).extent([2500, 6500])
        }
        , againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "title": "Distribution of Body Mass of Penguins",
  "width": 400,
  "height": 80,
  "data": {
    "url": "data/penguins.json"
  },
  "mark": "area",
  "transform": [
    {
      "density": "Body Mass (g)",
      "groupby": ["Species"],
      "extent": [2500, 6500]
    }
  ],
  "encoding": {
    "x": {"field": "value", "type": "quantitative", "title": "Body Mass (g)"},
    "y": {"field": "density", "type": "quantitative", "stack": "zero"},
    "color": {"field": "Species", "type": "nominal"}
  }
}
""")
    }

    func test_line_monotone() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/stocks.csv")
            Transform(.filter, expression: "datum.symbol==='GOOG'") {
                Mark(.line) {
                    Encode(.x, field: "date").type(.temporal)
                    Encode(.y, field: "price").type(.quantitative)
                }
                .interpolate(.monotone)
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/stocks.csv"},
  "transform": [{"filter": "datum.symbol==='GOOG'"}],
  "mark": {
    "type": "line",
    "interpolate": "monotone"
  },
  "encoding": {
    "x": {"field": "date", "type": "temporal"},
    "y": {"field": "price", "type": "quantitative"}
  }
}
""")
    }

    func test_layer_line_rolling_mean_point_raw() throws {
        try check(viz: Graphiq(width: 400, height: 300) {
            DataReference(path: "data/seattle-weather.csv")
            Transform(.window, field: "temp_max", op: .init(.mean), frame: .init(-15...15), output: "rolling_mean") { rolling_mean in
                Layer {
                    Encode(.x, field: "date")
                        .type(.temporal)
                        .title(.init("Date"))
                    Encode(.y) {
                        Guide().title(.init("Max Temperature and Rolling Mean"))
                    }
                    .type(.quantitative)

                    Mark(.point) {
                        Encode(.y, field: "temp_max") {
                        }
                        .title(.init("Max Temperature"))
                    }
                    .opacity(0.3)

                    Mark(.line) {
                        Encode(.y, field: rolling_mean)
                            .title(.init("Rolling Mean of Max Temperature"))
                    }
                    .color(.init(.init("red")))
                    .size(3)
                }
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Plot showing a 30 day rolling average with raw values in the background.",
  "width": 400,
  "height": 300,
  "data": {"url": "data/seattle-weather.csv"},
  "transform": [{
    "window": [
      {
        "field": "temp_max",
        "op": "mean",
        "as": "rolling_mean"
      }
    ],
    "frame": [-15, 15]
  }],
  "encoding": {
    "x": {"field": "date", "type": "temporal", "title": "Date"},
    "y": {"type": "quantitative", "axis": {"title": "Max Temperature and Rolling Mean"}}
  },
  "layer": [
    {
      "mark": {"type": "point", "opacity": 0.3},
      "encoding": {
        "y": {"field": "temp_max", "title": "Max Temperature"}
      }
    },
    {
      "mark": {"type": "line", "color": "red", "size": 3},
      "encoding": {
        "y": {"field": "rolling_mean", "title": "Rolling Mean of Max Temperature"}
      }
    }
  ]
}
""")
    }

    func test_line_overlay() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/stocks.csv")
            Mark(.line) {
                Encode(.x, field: "date").timeUnit(.year)
                Encode(.y, field: "price").type(.quantitative).aggregate(.mean)
                Encode(.color, field: "symbol").type(.nominal)
            }
            .point(true)
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Stock prices of 5 Tech Companies over Time.",
  "data": {"url": "data/stocks.csv"},
  "mark": {
    "type": "line",
    "point": true
  },
  "encoding": {
    "x": {"timeUnit": "year", "field": "date"},
    "y": {"aggregate":"mean", "field": "price", "type": "quantitative"},
    "color": {"field": "symbol", "type": "nominal"}
  }
}
""")
    }

    func test_area_horizon() throws {
        try check(viz: Graphiq(width: 300, height: 50) {
            DataValues {
                [
                    ["x": 1,  "y": 28], ["x": 2,  "y": 55],
                    ["x": 3,  "y": 43], ["x": 4,  "y": 91],
                    ["x": 5,  "y": 81], ["x": 6,  "y": 53],
                    ["x": 7,  "y": 19], ["x": 8,  "y": 87],
                    ["x": 9,  "y": 52], ["x": 10, "y": 48],
                    ["x": 11, "y": 24], ["x": 12, "y": 49],
                    ["x": 13, "y": 87], ["x": 14, "y": 66],
                    ["x": 15, "y": 17], ["x": 16, "y": 27],
                    ["x": 17, "y": 68], ["x": 18, "y": 16],
                    ["x": 19, "y": 49], ["x": 20, "y": 15]
                ]
            }

            Layer {
                Encode(.x, field: "x") {
                    Scale().zero(false).nice(false)
                }.type(.quantitative)

                Encode(.y, field: "y") {
                    Scale().domain(0...50)
                    Guide().title(.init("y"))
                }.type(.quantitative)

                Mark(.area) {
                }
                .clip(true)
                .orient(.vertical)
                .opacity(0.6)

                Transform(.calculate, expression: "datum.y - 50", output: "ny") { calculateValue in
                    Mark(.area) {
                        Encode(.y, field: calculateValue) {
                            Scale().domain(0...50)
                        }.type(.quantitative)

                        Encode(.opacity, value: 0.3)
                    }
                    .clip(true)
                    .orient(.vertical)
                }
            }
            VizTheme()
                .area(.init(interpolate: .init(.monotone)))
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Horizon Graph with 2 layers. (See https://idl.cs.washington.edu/papers/horizon/ for more details on Horizon Graphs.)",
  "width": 300,
  "height": 50,
  "data": {
    "values": [
      {"x": 1,  "y": 28}, {"x": 2,  "y": 55},
      {"x": 3,  "y": 43}, {"x": 4,  "y": 91},
      {"x": 5,  "y": 81}, {"x": 6,  "y": 53},
      {"x": 7,  "y": 19}, {"x": 8,  "y": 87},
      {"x": 9,  "y": 52}, {"x": 10, "y": 48},
      {"x": 11, "y": 24}, {"x": 12, "y": 49},
      {"x": 13, "y": 87}, {"x": 14, "y": 66},
      {"x": 15, "y": 17}, {"x": 16, "y": 27},
      {"x": 17, "y": 68}, {"x": 18, "y": 16},
      {"x": 19, "y": 49}, {"x": 20, "y": 15}
    ]
  },
  "encoding": {
    "x": {
      "field": "x", "type": "quantitative",
      "scale": {"zero": false, "nice": false}
    },
    "y": {
      "field": "y", "type": "quantitative",
      "scale": {"domain": [0,50]},
      "axis": {"title": "y"}
    }
  },
  "layer": [{
    "mark": {"type": "area", "clip": true, "orient": "vertical", "opacity": 0.6}
  }, {
    "transform": [{"calculate": "datum.y - 50", "as": "ny"}],
    "mark": {"type": "area", "clip": true, "orient": "vertical"},
    "encoding": {
      "y": {
        "field": "ny", "type": "quantitative",
        "scale": {"domain": [0,50]}
      },
      "opacity": {"value": 0.3}
    }
  }],
  "config": {
    "area": {"interpolate": "monotone"}
  }
}
""")
    }

    func test_bar_size_responsive() throws {
        try check(viz: Graphiq(height: 250) {
            DataReference(path: "data/cars.json")
            Mark(.bar) {
                Encode(.x, field: "Origin")
                Encode(.y)
                    .aggregate(.count)
                    .title(.init(.init("Number of Cars")))
            }
        }
        .width(.init(.container)), againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "width": "container",
  "height": 250,
  "data": {"url": "data/cars.json"},
  "mark": "bar",
  "encoding": {
    "x": {"field": "Origin"},
    "y": {"aggregate": "count", "title": "Number of Cars"}
  }
}
""")
    }

    func test_line() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/stocks.csv")
            Transform(.filter, expression: "datum.symbol==='GOOG'") {
                Mark(.line) {
                    Encode(.x, field: "date")
                        .type(.temporal)
                    Encode(.y, field: "price")
                        .type(.quantitative)
                }
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Google's stock price over time.",
  "data": {"url": "data/stocks.csv"},
  "transform": [{"filter": "datum.symbol==='GOOG'"}],
  "mark": "line",
  "encoding": {
    "x": {"field": "date", "type": "temporal"},
    "y": {"field": "price", "type": "quantitative"}
  }
}
""")
    }

    func test_line_color() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/stocks.csv")
            Mark(.line) {
                Encode(.x, field: "date")
                    .type(.temporal)
                Encode(.y, field: "price")
                    .type(.quantitative)
                Encode(.color, field: "symbol")
                    .type(.nominal)
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Stock prices of 5 Tech Companies over Time.",
  "data": {"url": "data/stocks.csv"},
  "mark": "line",
  "encoding": {
    "x": {"field": "date", "type": "temporal"},
    "y": {"field": "price", "type": "quantitative"},
    "color": {"field": "symbol", "type": "nominal"}
  }
}
""")
    }

    func test_line_strokedash() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/stocks.csv")
            Mark(.line) {
                Encode(.x, field: "date")
                    .type(.temporal)
                Encode(.y, field: "price")
                    .type(.quantitative)
                Encode(.strokeDash, field: "symbol")
                    .type(.nominal)
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Stock prices of 5 Tech Companies over Time.",
  "data": {"url": "data/stocks.csv"},
  "mark": "line",
  "encoding": {
    "x": {"field": "date", "type": "temporal"},
    "y": {"field": "price", "type": "quantitative"},
    "strokeDash": {"field": "symbol", "type": "nominal"}
  }
}
""")
    }

    func test_point_bubble() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/cars.json")
            Mark(.point) {
                Encode(.x, field: "Horsepower")
                    .type(.quantitative)
                Encode(.y, field: "Miles_per_Gallon")
                    .type(.quantitative)
                Encode(.size, field: "Acceleration")
                    .type(.quantitative)
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A bubbleplot showing horsepower on x, miles per gallons on y, and binned acceleration on size.",
  "data": {"url": "data/cars.json"},
  "mark": "point",
  "encoding": {
    "x": {"field": "Horsepower", "type": "quantitative"},
    "y": {"field": "Miles_per_Gallon", "type": "quantitative"},
    "size": {"field": "Acceleration", "type": "quantitative"}
  }
}
""")
    }

    func test_trellis_scatter() throws {
        try check(viz: Graphiq() {
            DataReference(path: "data/movies.json")
            Mark(.point) {
                Encode(.x, field: "Worldwide Gross")
                    .type(.quantitative)
                Encode(.y, field: "US DVD Sales")
                    .type(.quantitative)
                Encode(.facet, field: "MPAA Rating")
                    .type(.ordinal)
                    .columns(2)
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/movies.json"},
  "mark": "point",

  "encoding": {
    "facet": {"field": "MPAA Rating", "type": "ordinal", "columns": 2},
    "x": {"field": "Worldwide Gross", "type": "quantitative"},
    "y": {"field": "US DVD Sales", "type": "quantitative"}
  }
}
""")
    }

    func test_trellis_stacked_bar() throws {
        try check(viz: Graphiq() {
            DataReference(path: "data/barley.json")
            Mark(.bar) {
                Encode(.column, field: "year")
                Encode(.x, field: "yield")
                    .type(.quantitative)
                    .aggregate(.sum)
                Encode(.y, field: "variety")
                    .type(.nominal)
                Encode(.color, field: "site")
                    .type(.nominal)
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/barley.json"},
  "mark": "bar",
  "encoding": {
    "column": {"field": "year"},
    "x": {"field": "yield", "type": "quantitative", "aggregate": "sum"},
    "y": {"field": "variety", "type": "nominal"},
    "color": {"field": "site", "type": "nominal"}
  }
}
""")
    }

    func test_area_overlay() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/stocks.csv")
            Transform(.filter, expression: "datum.symbol==='GOOG'") {
                Mark(.area) {
                    Encode(.x, field: "date").type(.temporal)
                    Encode(.y, field: "price").type(.quantitative)
                }
                .line(true)
                .point(true)
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Google's stock price over time.",
  "data": {"url": "data/stocks.csv"},
  "transform": [{"filter": "datum.symbol==='GOOG'"}],
  "mark": {"type": "area", "line": true, "point": true},
  "encoding": {
    "x": {"field": "date", "type": "temporal"},
    "y": {"field": "price", "type": "quantitative"}
  }
}
""")
    }

    func test_tick_dot() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/seattle-weather.csv")
            Mark(.tick) {
                Encode(.x, field: "precipitation").type(.quantitative)
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/seattle-weather.csv"},
  "mark": "tick",
  "encoding": {
    "x": {"field": "precipitation", "type": "quantitative"}
  }
}
""")
    }

    func test_circle() throws {
        try check(viz: Graphiq() {
            DataReference(path: "data/cars.json")
            Mark(.circle) {
                Encode(.x, field: "Horsepower").type(.quantitative)
                Encode(.y, field: "Miles_per_Gallon").type(.quantitative)
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/cars.json"},
  "mark": "circle",
  "encoding": {
    "x": {"field": "Horsepower", "type": "quantitative"},
    "y": {"field": "Miles_per_Gallon", "type": "quantitative"}
  }
}
""")
    }

    func test_tick_strip() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/cars.json")
            Mark(.tick) {
                Encode(.x, field: "Horsepower").type(.quantitative)
                Encode(.y, field: "Cylinders").type(.ordinal)
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Shows the relationship between horsepower and the number of cylinders using tick marks.",
  "data": {"url": "data/cars.json"},
  "mark": "tick",
  "encoding": {
    "x": {"field": "Horsepower", "type": "quantitative"},
    "y": {"field": "Cylinders", "type": "ordinal"}
  }
}
""")
    }

    func test_point_2d() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/cars.json")
            Mark(.point) {
                Encode(.x, field: "Horsepower").type(.quantitative)
                Encode(.y, field: "Miles_per_Gallon").type(.quantitative)
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A scatterplot showing horsepower and miles per gallons for various cars.",
  "data": {"url": "data/cars.json"},
  "mark": "point",
  "encoding": {
    "x": {"field": "Horsepower", "type": "quantitative"},
    "y": {"field": "Miles_per_Gallon", "type": "quantitative"}
  }
}
""")
    }

    func test_stacked_bar_count_corner_radius_mark() throws {
        try check(viz: Graphiq() {
            DataReference(path: "data/seattle-weather.csv")
            Mark(.bar) {
                Encode(.x, field: "date").type(.ordinal).timeUnit(.month)
                Encode(.y).aggregate(.count)
                Encode(.color, field: "weather")
            }
            .cornerRadiusTopLeft(3)
            .cornerRadiusTopRight(3)
        }, againstJSON: """
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
""")
    }

    func test_stacked_bar_h() throws {
        try check(viz: Graphiq() {
            DataReference(path: "data/barley.json")
            Mark(.bar) {
                Encode(.x, field: "yield").aggregate(.sum)
                Encode(.y, field: "variety")
                Encode(.color, field: "site")
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/barley.json"},
  "mark": "bar",
  "encoding": {
    "x": {"aggregate": "sum", "field": "yield"},
    "y": {"field": "variety"},
    "color": {"field": "site"}
  }
}
""")
    }

    func test_bar_argmax() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/movies.json")
            Mark(.bar) {
                Encode(.x, field: "Production Budget")
                    .type(.quantitative)
                    .aggregate(.argmax("US Gross"))
                Encode(.y, field: "Major Genre")
                    .type(.nominal)
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "The production budget of the movie that has the highest US Gross in each major genre.",
  "data": {"url": "data/movies.json"},
  "mark": "bar",
  "encoding": {
    "x": {
      "aggregate": {"argmax": "US Gross"},
      "field": "Production Budget",
      "type": "quantitative"
    },
    "y": {"field": "Major Genre", "type": "nominal"}
  }
}
""")
    }

    func test_histogram() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/movies.json")
            Mark(.bar) {
                Encode(.x, field: "IMDB Rating").bin(.init(true))
                Encode(.y).aggregate(.count)
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/movies.json"},
  "mark": "bar",
  "encoding": {
    "x": {
      "bin": true,
      "field": "IMDB Rating"
    },
    "y": {"aggregate": "count"}
  }
}
""")
    }

    func test_histogram_log() throws {
        try check(viz: Graphiq {
            DataValues { [ ["x": 0.01], ["x": 0.1], ["x": 1], ["x": 1], ["x": 1], ["x": 1], ["x": 10], ["x": 10], ["x": 100], ["x": 500],
                    ["x": 800] ] }

            Transform(.calculate, expression: "log(datum.x)/log(10)", output: "log_x") { log_x in
                Transform(.bin, field: log_x, outputStart: "bin_log_x") { bin_log_x, _ in
                    Transform(.calculate, expression: "pow(10, datum.bin_log_x)", output: "x1") { x1 in
                        Transform(.calculate, expression: "pow(10, datum.bin_log_x_end)", output: "x2") { x2 in
                            Mark(.bar) {
                                Encode(.x, field: x1) {
                                    Guide().tickCount(5)
                                    Scale().type(.log).base(10)
                                }
                                Encode(.x2, field: x2)
                                Encode(.y).aggregate(.count)
                            }
                        }
                    }
                }
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Log-scaled Histogram.  We may improve the support of this. See https://github.com/vega/vega-lite/issues/4792.",
  "data": {
    "values": [
      {"x": 0.01},
      {"x": 0.1},
      {"x": 1},
      {"x": 1},
      {"x": 1},
      {"x": 1},
      {"x": 10},
      {"x": 10},
      {"x": 100},
      {"x": 500},
      {"x": 800}
    ]
  },
  "transform": [{
      "calculate": "log(datum.x)/log(10)", "as": "log_x"
  }, {
      "bin": true,
      "field": "log_x",
      "as": "bin_log_x"
  }, {
    "calculate": "pow(10, datum.bin_log_x)", "as": "x1"
  }, {
    "calculate": "pow(10, datum.bin_log_x_end)", "as": "x2"
  }],
  "mark": "bar",
  "encoding": {
    "x": {
      "field": "x1",
      "scale": {"type": "log", "base": 10},
      "axis": {"tickCount": 5}
    },
    "x2": {"field": "x2"},
    "y": {"aggregate": "count"}
  }
}
""")
    }

    func test_layer_bar_labels() throws {
        try check(viz: Graphiq {
            DataValues { [ ["a": "A", "b": 28], ["a": "B", "b": 55], ["a": "C", "b": 43] ] }
            Layer {
                Encode(.y, field: "a").type(.nominal)
                Encode(.x, field: "b") {
                    Scale().domain(0...60)
                }.type(.quantitative)

                Mark(.bar)
                Mark(.text) {
                    Encode(.text, field: "b").type(.quantitative)
                }
                .align(.init(.left))
                .baseline(.init(.middle))
                .dx(3)
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Bar chart with text labels. Set domain to make the frame cover the labels.",
  "data": {
    "values": [
      {"a": "A", "b": 28},
      {"a": "B", "b": 55},
      {"a": "C", "b": 43}
    ]
  },
  "encoding": {
    "y": {"field": "a", "type": "nominal"},
    "x": {"field": "b", "type": "quantitative", "scale": {"domain": [0, 60]}}
  },
  "layer": [{
    "mark": "bar"
  }, {
    "mark": {
      "type": "text",
      "align": "left",
      "baseline": "middle",
      "dx": 3
    },
    "encoding": {
      "text": {"field": "b", "type": "quantitative"}
    }
  }]
}
""")
    }

    func test_layer_bar_labels_grey() throws {
        try check(viz: Graphiq(width: 200) {
            DataReference(path: "data/movies.json")
            Layer {
                Encode(.y, field: "Major Genre")
                    .type(.nominal)
                    .axis(nil)

                Mark(.bar) {
                    Encode(.x, field: "IMDB Rating") {
                        Scale().domain(0...10)
                    }
                    .title(.init("Mean IMDB Ratings"))
                    .aggregate(.mean)
                }
                .color(.init(GG.HexColor(rawValue: "#ddd")))

                Mark(.text) {
                    Encode(.text, field: "Major Genre")
                    Encode(.detail).aggregate(.count)
                }
                .align(.left)
                .x(5)
            }
        }
        .height(.init(step: 16))
        , againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "width": 200,
  "height": {"step": 16},
  "data": {"url": "data/movies.json"},
  "encoding": {
    "y": {
      "field": "Major Genre",
      "type": "nominal",
      "axis": null
    }
  },
  "layer": [{
    "mark": {"type": "bar", "color": "#ddd"},
    "encoding": {
      "x": {
        "aggregate": "mean",
        "field": "IMDB Rating",
        "scale": {"domain": [0, 10]},
        "title": "Mean IMDB Ratings"
      }
    }
  }, {
    "mark": {"type": "text", "align": "left", "x": 5},
    "encoding": {
      "text": {"field": "Major Genre"},
      "detail": {"aggregate": "count"}
    }
  }]
}
""")
    }

    func test_layer_histogram_global_mean() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/movies.json")
            Layer {
                Mark(.bar) {
                    Encode(.x, field: "IMDB Rating").bin(.init(true))
                    Encode(.y).aggregate(.count)
                }
                Mark(.rule) {
                    Encode(.x, field: "IMDB Rating").aggregate(.mean)
                    Encode(.color, value: "red")
                    Encode(.size, value: 5)
                }
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/movies.json"},
  "layer": [{
    "mark": "bar",
    "encoding": {
      "x": {"field": "IMDB Rating", "bin": true},
      "y": {"aggregate": "count"}
    }
  },{
    "mark": "rule",
    "encoding": {
      "x": {"aggregate": "mean", "field": "IMDB Rating"},
      "color": {"value": "red"},
      "size": {"value": 5}
    }
  }]
}
""")
    }

    func test_layer_line_mean_point_raw() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/stocks.csv")
            Transform(.filter, expression: "datum.symbol==='GOOG'") {
                Layer {
                    Mark(.point) {
                        Encode(.x, field: "date").timeUnit(.year)
                        Encode(.y, field: "price").type(.quantitative)
                    }
                    .opacity(0.3)
                    Mark(.line) {
                        Encode(.x, field: "date").timeUnit(.year)
                        Encode(.y, field: "price").aggregate(.mean)
                    }
                }
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Plot showing average data with raw values in the background.",
  "data": {"url": "data/stocks.csv"},
  "transform": [{"filter": "datum.symbol==='GOOG'"}],
  "layer": [{
    "mark": {"type": "point", "opacity": 0.3},
    "encoding": {
      "x": {"timeUnit":"year", "field": "date"},
      "y": {"field": "price", "type": "quantitative"}
    }
  }, {
    "mark": "line",
    "encoding": {
      "x": {"timeUnit":"year", "field": "date"},
      "y": {"aggregate": "mean", "field": "price"}
    }
  }]
}
""")
    }

    func test_line_dashed_part() throws {
        try check(viz: Graphiq {
            DataValues {
                [
                    ["a": "A", "b": 28, "predicted": false],
                    ["a": "B", "b": 55, "predicted": false],
                    ["a": "D", "b": 91, "predicted": false],
                    ["a": "E", "b": 81, "predicted": false],
                    ["a": "E", "b": 81, "predicted": true],
                    ["a": "G", "b": 19, "predicted": true],
                    ["a": "H", "b": 87, "predicted": true]
                ]
            }

            Mark(.line) {
                Encode(.x, field: "a").type(.ordinal)
                Encode(.y, field: "b").type(.quantitative)
                Encode(.strokeDash, field: "predicted").type(.nominal)
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Line chart with a dashed part created by drawing multiple connecting lines. Note that the data source contains the data point at (E, 81) twice.",
  "data": {
    "values": [
      {"a": "A", "b": 28, "predicted": false},
      {"a": "B", "b": 55, "predicted": false},
      {"a": "D", "b": 91, "predicted": false},
      {"a": "E", "b": 81, "predicted": false},
      {"a": "E", "b": 81, "predicted": true},
      {"a": "G", "b": 19, "predicted": true},
      {"a": "H", "b": 87, "predicted": true}
    ]
  },
  "mark": "line",
  "encoding": {
    "x": {"field": "a", "type": "ordinal"},
    "y": {"field": "b", "type": "quantitative"},
    "strokeDash": {"field": "predicted", "type": "nominal"}
  }
}
""")
    }

    func test_layer_point_errorbar_stdev() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/barley.json")
            Layer {
                Encode(.y, field: "variety").type(.ordinal)
                Mark(.point) {
                    Encode(.x, field: "yield") {
                        Scale().zero(false)
                    }
                    .type(.quantitative)
                    .aggregate(.mean)
                    .title(.init("Barley Yield"))

                    Encode(.color, value: "black")
                }
                .filled(true)

                Mark(.errorbar) {
                    Encode(.x, field: "yield")
                        .type(.quantitative)
                        .title(.init("Barley Yield"))
                }
                .extent(.stdev)
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/barley.json"},
  "encoding": {"y": {"field": "variety", "type": "ordinal"}},
  "layer": [
    {
      "mark": {"type": "point", "filled": true},
      "encoding": {
        "x": {
          "aggregate": "mean",
          "field": "yield",
          "type": "quantitative",
          "scale": {"zero": false},
          "title": "Barley Yield"
        },
        "color": {"value": "black"}
      }
    },
    {
      "mark": {"type": "errorbar", "extent": "stdev"},
      "encoding": {
        "x": {"field": "yield", "type": "quantitative", "title": "Barley Yield"}
      }
    }
  ]
}
""")
    }

    func test_layer_point_errorbar_ci() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/barley.json")
            Layer {
                Encode(.y, field: "variety").type(.ordinal)
                Mark(.point) {
                    Encode(.x, field: "yield") {
                        Scale().zero(false)
                    }
                    .type(.quantitative)
                    .aggregate(.mean)
                    .title(.init("Barley Yield"))

                    Encode(.color, value: "black")
                }
                .filled(true)

                Mark(.errorbar) {
                    Encode(.x, field: "yield")
                        .type(.quantitative)
                        .title(.init("Barley Yield"))
                }
                .extent(.ci)
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/barley.json"},
  "encoding": {"y": {"field": "variety", "type": "ordinal"}},
  "layer": [
    {
      "mark": {"type": "point", "filled": true},
      "encoding": {
        "x": {
          "aggregate": "mean",
          "field": "yield",
          "type": "quantitative",
          "scale": {"zero": false},
          "title": "Barley Yield"
        },
        "color": {"value": "black"}
      }
    },
    {
      "mark": {"type": "errorbar", "extent": "ci"},
      "encoding": {
        "x": {"field": "yield", "type": "quantitative", "title": "Barley Yield"}
      }
    }
  ]
}
""")
    }

    func test_layer_precipitation_mean() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/seattle-weather.csv")
            Layer {
                Mark(.bar) {
                    Encode(.x, field: "date").timeUnit(.month).type(.ordinal)
                    Encode(.y, field: "precipitation").aggregate(.mean).type(.quantitative)
                }
                Mark(.rule) {
                    Encode(.y, field: "precipitation").aggregate(.mean).type(.quantitative)
                    Encode(.color, value: "red")
                    Encode(.size, value: 3)
                }
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/seattle-weather.csv"},
  "layer": [
    {
      "mark": "bar",
      "encoding": {
        "x": {
          "timeUnit": "month",
          "field": "date",
          "type": "ordinal"

        },
        "y": {
          "aggregate": "mean",
          "field": "precipitation",
          "type": "quantitative"
        }
      }
    },
    {
      "mark": "rule",
      "encoding": {
        "y": {
          "aggregate": "mean",
          "field": "precipitation",
          "type": "quantitative"
        },
        "color": {"value": "red"},
        "size": {"value": 3}
      }
    }
  ]
}
""")
    }

    func test_line_skip_invalid_mid_overlay() throws {
        try check(viz: Graphiq {
            DataValues {
                [
                    ["x": 1, "y": 10],
                    ["x": 2, "y": 30],
                    ["x": 3, "y": nil],
                    ["x": 4, "y": 15],
                    ["x": 5, "y": nil],
                    ["x": 6, "y": 40],
                    ["x": 7, "y": 20]
                ]
            }
            Mark(.line) {
                Encode(.x, field: "x").type(.quantitative)
                Encode(.y, field: "y").type(.quantitative)
            }
            .point(true)
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "values": [
      {
        "x": 1,
        "y": 10
      },
      {
        "x": 2,
        "y": 30
      },
      {
        "x": 3,
        "y": null
      },
      {
        "x": 4,
        "y": 15
      },
      {
        "x": 5,
        "y": null
      },
      {
        "x": 6,
        "y": 40
      },
      {
        "x": 7,
        "y": 20
      }
    ]
  },
  "mark": {"type": "line", "point": true},
  "encoding": {
    "x": {"field": "x", "type": "quantitative"},
    "y": {"field": "y", "type": "quantitative"}
  }
}
""")
    }

    func test_line_slope() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/barley.json")
            Mark(.line) {
                Encode(.x, field: "year") {
                    Scale().padding(0.5)
                }.type(.ordinal)
                Encode(.y, field: "yield").aggregate(.median).type(.quantitative)
                Encode(.color, field: "site").type(.nominal)
            }
        }
        .width(.init(step: 50))
        , againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/barley.json"},
  "description": "Slope graph showing the change in yield for different barley sites. It shows the error in the year labels for the Morris site.",
  "mark": "line",
  "width": {"step": 50},
  "encoding": {
    "x": {
      "field": "year",
      "type": "ordinal",
      "scale": {"padding": 0.5}
    },
    "y": {
      "aggregate": "median",
      "field": "yield",
      "type": "quantitative"
    },
    "color": {"field": "site", "type": "nominal"}
  }
}
""")
    }
    
    func test_line_step() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/stocks.csv")
            Transform(.filter, expression: "datum.symbol==='GOOG'") {
                Mark(.line) {
                    Encode(.x, field: "date").type(.temporal)
                    Encode(.y, field: "price").type(.quantitative)
                }
                .interpolate(.stepAfter)
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Google's stock price over time.",
  "data": {"url": "data/stocks.csv"},
  "transform": [{"filter": "datum.symbol==='GOOG'"}],
  "mark": {
    "type": "line",
    "interpolate": "step-after"
  },
  "encoding": {
    "x": {"field": "date", "type": "temporal"},
    "y": {"field": "price", "type": "quantitative"}
  }
}
""")
    }
    
    func test_lookup() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/lookup_groups.csv")
            Transform(.lookup, field: "person", data: GG.LookupData(data: GG.DataProvider(GG.DataSource(GG.UrlData(url: "data/lookup_people.csv"))), fields: [.init("age"), .init("height")], key: .init("name"))) {
                Mark(.bar) {
                    Encode(.x, field: "group")
                    Encode(.y, field: "age").aggregate(.mean)
                }
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/lookup_groups.csv"},
  "transform": [{
    "lookup": "person",
    "from": {
      "data": {"url": "data/lookup_people.csv"},
      "key": "name",
      "fields": ["age", "height"]
    }
  }],
  "mark": "bar",
  "encoding": {
    "x": {"field": "group"},
    "y": {"field": "age", "aggregate": "mean"}
  }
}
""")
    }

    func test_point_href() throws {
        try check(viz: Graphiq {
            DataReference(path: "data/cars.json")
            Transform(.calculate, expression: "'https://www.google.com/search?q=' + datum.Name", output: "url") { urlField in
                Mark(.point) {
                    Encode(.x, field: "Horsepower").type(.quantitative)
                    Encode(.y, field: "Miles_per_Gallon").type(.quantitative)
                    Encode(.color, field: "Origin").type(.nominal)
                    Encode(.tooltip, field: "Name").type(.nominal)
                    Encode(.href, field: urlField).type(.nominal)
                }
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A scatterplot showing horsepower and miles per gallons that opens a Google search for the car that you click on.",
  "data": {"url": "data/cars.json"},
  "mark": "point",
  "transform": [{
    "calculate": "'https://www.google.com/search?q=' + datum.Name", "as": "url"
  }],
  "encoding": {
    "x": {"field": "Horsepower", "type": "quantitative"},
    "y": {"field": "Miles_per_Gallon", "type": "quantitative"},
    "color": {"field": "Origin", "type": "nominal"},
    "tooltip": {"field": "Name", "type": "nominal"},
    "href": {"field": "url", "type": "nominal"}
  }
}
""")
    }
    
    func test_stacked_area() throws {
        try check(viz: Graphiq(width: 300, height: 200) {
            DataReference(path: "data/unemployment-across-industries.json")
            Mark(.area) {
                Encode(.x, field: "date") {
                    Guide().format("%Y")
                }
                .timeUnit(.yearmonth)
                Encode(.y, field: "count") {
                }
                .aggregate(.sum)
                Encode(.color, field: "series") {
                    Scale().scheme("category20b")
                }
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "width": 300, "height": 200,
  "data": {"url": "data/unemployment-across-industries.json"},
  "mark": "area",
  "encoding": {
    "x": {
      "timeUnit": "yearmonth", "field": "date",
      "axis": {"format": "%Y"}
    },
    "y": {
      "aggregate": "sum", "field": "count"
    },
    "color": {
      "field": "series",
      "scale": {"scheme": "category20b"}
    }
  }
}
""")
    }

    func test_stacked_area_stream() throws {
        try check(viz: Graphiq(width: 300, height: 200) {
            DataReference(path: "data/unemployment-across-industries.json")
            Mark(.area) {
                Encode(.x, field: "date") {
                    Guide().domain(false).format("%Y").tickSize(0)
                }
                .timeUnit(.yearmonth)
                Encode(.y, field: "count") {
                }
                .aggregate(.sum)
                .axis(.null)
                .stack(.init(.center))
                Encode(.color, field: "series") {
                    Scale().scheme("category20b")
                }
            }
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "width": 300, "height": 200,
  "data": {"url": "data/unemployment-across-industries.json"},
  "mark": "area",
  "encoding": {
    "x": {
      "timeUnit": "yearmonth", "field": "date",
      "axis": {"domain": false, "format": "%Y", "tickSize": 0}
    },
    "y": {
      "aggregate": "sum", "field": "count",
      "axis": null,
      "stack": "center"
    },
    "color": {"field":"series", "scale":{"scheme": "category20b"}}
  }
}
""")
    }

}

