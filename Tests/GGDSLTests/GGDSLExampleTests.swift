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
        .description("A simple bar chart with embedded data.")
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

    func test_airport_connections() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "An interactive visualization of connections among major U.S. airports in 2008. Based on a U.S. airports example by Mike Bostock.",
  "layer": [
    {
      "mark": {
        "type": "geoshape",
        "fill": "#ddd",
        "stroke": "#fff",
        "strokeWidth": 1
      },
      "data": {
        "url": "data/us-10m.json",
        "format": {"type": "topojson", "feature": "states"}
      }
    },
    {
      "mark": {"type": "rule", "color": "#000", "opacity": 0.35},
      "data": {"url": "data/flights-airport.csv"},
      "transform": [
        {"filter": {"param": "org", "empty": false}},
        {
          "lookup": "origin",
          "from": {
            "data": {"url": "data/airports.csv"},
            "key": "iata",
            "fields": ["latitude", "longitude"]
          }
        },
        {
          "lookup": "destination",
          "from": {
            "data": {"url": "data/airports.csv"},
            "key": "iata",
            "fields": ["latitude", "longitude"]
          },
          "as": ["lat2", "lon2"]
        }
      ],
      "encoding": {
        "latitude": {"field": "latitude"},
        "longitude": {"field": "longitude"},
        "latitude2": {"field": "lat2"},
        "longitude2": {"field": "lon2"}
      }
    },
    {
      "mark": {"type": "circle"},
      "data": {"url": "data/flights-airport.csv"},
      "transform": [
        {"aggregate": [{"op": "count", "as": "routes"}], "groupby": ["origin"]},
        {
          "lookup": "origin",
          "from": {
            "data": {"url": "data/airports.csv"},
            "key": "iata",
            "fields": ["state", "latitude", "longitude"]
          }
        },
        {"filter": "datum.state !== 'PR' && datum.state !== 'VI'"}
      ],
      "params": [{
        "name": "org",
        "select": {
          "type": "point",
          "on": "mouseover",
          "nearest": true,
          "fields": ["origin"]
        }
      }],
      "encoding": {
        "latitude": {"field": "latitude"},
        "longitude": {"field": "longitude"},
        "size": {
          "field": "routes",
          "type": "quantitative",
          "scale": {"rangeMax": 1000},
          "legend": null
        },
        "order": {
          "field": "routes",
          "sort": "descending"
        }
      }
    }
  ],
  "projection": {"type": "albersUsa"},
  "width": 900,
  "height": 500,
  "config": {"view": {"stroke": null}}
}
""")
    }

    func test_arc_donut() throws {
        try check(viz: Graphiq {
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
        .view(GG.ViewBackground(stroke: .null))
        .description("A simple donut chart with embedded data."), againstJSON: """
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
        .view(GG.ViewBackground(stroke: .null))
        .description("A simple pie chart with embedded data."), againstJSON: """
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

            }.outerRadius(.init(80))
        }
        .description("Reproducing http://robslink.com/SAS/democd91/pyramid_pie.htm")
        .view(GG.ViewBackground(stroke: .init(.null))), againstJSON: """
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
            DataValues { [12, 23, 47, 6, 52, 19] }
            Layer {
                Encode(.color, field: "data").type(.nominal).legend(.init(.null))
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
        .view(GG.ViewBackground(stroke: .null))
        .description("A simple radial chart with embedded data."), againstJSON: """
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
        try check(viz: Graphiq {
            DataReference(path: "data/unemployment-across-industries.json")
            Mark(.area) {
                Encode(.x, field: "date") {
                    Guide()
                        .format("%Y")
                }
                .timeUnit(.init(.init(.yearmonth)))
                Encode(.y, field: "count")
                    .aggregate(.init(.sum))
                    .title(.init("count"))

            }
        }
        .width(300)
        .height(200), againstJSON: """
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
        }, againstJSON: """
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
        try check(viz: Graphiq {
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
        try check(viz: Graphiq {
        }, againstJSON: """
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
        try check(viz: Graphiq {
        }, againstJSON: """
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

    func test_area_gradient() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Google's stock price over time.",
  "data": {
    "url": "data/stocks.csv"
  },
  "transform": [
    {
      "filter": "datum.symbol==='GOOG'"
    }
  ],
  "mark": {
    "type": "area",
    "line": {
      "color": "darkgreen"
    },
    "color": {
      "x1": 1,
      "y1": 1,
      "x2": 1,
      "y2": 0,
      "gradient": "linear",
      "stops": [
        {
          "offset": 0,
          "color": "white"
        },
        {
          "offset": 1,
          "color": "darkgreen"
        }
      ]
    }
  },
  "encoding": {
    "x": {
      "field": "date",
      "type": "temporal"
    },
    "y": {
      "field": "price",
      "type": "quantitative"
    }
  }
}
""")
    }

    func test_area_horizon() throws {
        try check(viz: Graphiq {
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

    func test_area_overlay() throws {
        try check(viz: Graphiq {
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

    func test_bar_aggregate() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A bar chart showing the US population distribution of age groups in 2000.",
  "height": {"step": 17},
  "data": { "url": "data/population.json"},
  "transform": [{"filter": "datum.year == 2000"}],
  "mark": "bar",
  "encoding": {
    "y": {"field": "age"},
    "x": {
      "aggregate": "sum", "field": "people",
      "title": "population"
    }
  }
}
""")
    }

    func test_bar_aggregate_sort_by_encoding() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A bar chart that sorts the y-values by the x-values.",
  "data": {"url": "data/population.json"},
  "transform": [{"filter": "datum.year == 2000"}],
  "height": {"step": 17},
  "mark": "bar",
  "encoding": {
    "y": {
      "field": "age",
      "type": "ordinal",
      "sort": "-x"
    },
    "x": {
      "aggregate": "sum",
      "field": "people",
      "title": "population"
    }
  }
}
""")
    }

    func test_bar_argmax() throws {
        try check(viz: Graphiq {
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

    func test_bar_axis_space_saving() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Bar Chart with a spacing-saving y-axis",
  "data": {"url": "data/cars.json"},
  "height": {"step": 50},
  "mark": {"type": "bar", "yOffset": 5, "cornerRadiusEnd": 2, "height": {"band": 0.5}},
  "encoding": {
    "y": {
      "field": "Origin",
      "scale": {"padding": 0},
      "axis": {
        "bandPosition": 0,
        "grid": true,
        "domain": false,
        "ticks": false,
        "labelAlign": "left",
        "labelBaseline": "middle",
        "labelPadding": -5,
        "labelOffset": -15,
        "titleX": 5,
        "titleY": -5,
        "titleAngle": 0,
        "titleAlign": "left"
      }
    },
    "x": {
      "aggregate": "count",
      "axis": {"grid": false},
      "title": "Number of Cars"
    }
  }
}
""")
    }

    func test_bar_binned_data() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "values": [
      {"bin_start": 8, "bin_end": 10, "count": 7},
      {"bin_start": 10, "bin_end": 12, "count": 29},
      {"bin_start": 12, "bin_end": 14, "count": 71},
      {"bin_start": 14, "bin_end": 16, "count": 127},
      {"bin_start": 16, "bin_end": 18, "count": 94},
      {"bin_start": 18, "bin_end": 20, "count": 54},
      {"bin_start": 20, "bin_end": 22, "count": 17},
      {"bin_start": 22, "bin_end": 24, "count": 5}
    ]
  },
  "mark": "bar",
  "encoding": {
    "x": {
      "field": "bin_start",
      "bin": {"binned": true, "step": 2}
    },
    "x2": {"field": "bin_end"},
    "y": {
      "field": "count",
      "type": "quantitative"
    }
  }
}
""")
    }

    func test_bar_color_disabled_scale() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A bar chart that directly encodes color names in the data.",
  "data": {
    "values": [
      {
        "color": "red",
        "b": 28
      },
      {
        "color": "green",
        "b": 55
      },
      {
        "color": "blue",
        "b": 43
      }
    ]
  },
  "mark": "bar",
  "encoding": {
    "x": {
      "field": "color",
      "type": "nominal"
    },
    "y": {
      "field": "b",
      "type": "quantitative"
    },
    "color": {
      "field": "color",
      "type": "nominal",
      "scale": null
    }
  }
}
""")
    }

    func test_bar_count_minimap() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/cars.json"},
  "hconcat": [{
    "mark": "bar",
    "transform": [{
      "filter": {"param": "brush"}
    }],
    "encoding": {
      "y": {
        "field": "Name",
        "type": "nominal",
        "axis": {"minExtent": 200, "title": null},
        "sort": "-x"
      },
      "x": {
        "aggregate": "count",
        "scale":{"domain":  [0, 6]},
        "axis": {"orient": "top"}
      }
    }
  }, {
    "height": 200,
    "width": 50,
    "params": [{
      "name": "brush",
      "select": {
        "type": "interval",
        "encodings": ["y"]
      }
    }],
    "mark": "bar",
    "encoding": {
      "y": {
        "field": "Name",
        "type": "nominal",
        "sort": "-x",
        "axis": null
      },
      "x": {
        "aggregate": "count",
        "axis": null
      }
    }
  }]
}
""")
    }

    func test_bar_diverging_stack_population_pyramid() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A population pyramid for the US in 2000, created using stack. See https://vega.github.io/vega-lite/examples/concat_population_pyramid.html for a variant of this created using concat.",
  "data": { "url": "data/population.json"},
  "transform": [
    {"filter": "datum.year == 2000"},
    {"calculate": "datum.sex == 2 ? 'Female' : 'Male'", "as": "gender"},
    {"calculate": "datum.sex == 2 ? -datum.people : datum.people", "as": "signed_people"}
  ],
  "width": 300,
  "height": 200,
  "mark": "bar",
  "encoding": {
    "y": {
      "field": "age",
      "axis": null, "sort": "descending"
    },
    "x": {
      "aggregate": "sum", "field": "signed_people",
      "title": "population",
      "axis": {"format": "s"}
    },
    "color": {
      "field": "gender",
      "scale": {"range": ["#675193", "#ca8861"]},
      "legend": {"orient": "top", "title": null}
    }
  },
  "config": {
    "view": {"stroke": null},
    "axis": {"grid": false}
  }
}
""")
    }

    func test_bar_diverging_stack_transform() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A diverging stacked bar chart for sentiments towards a set of eight questions, displayed as percentages with neutral responses straddling the 0% mark",
  "data": {
    "values": [
      {"question": "Question 1", "type": "Strongly disagree", "value": 24, "percentage": 0.7},
      {"question": "Question 1", "type": "Disagree", "value": 294, "percentage": 9.1},
      {"question": "Question 1", "type": "Neither agree nor disagree", "value": 594, "percentage": 18.5},
      {"question": "Question 1", "type": "Agree", "value": 1927, "percentage": 59.9},
      {"question": "Question 1", "type": "Strongly agree", "value": 376, "percentage": 11.7},
      {"question": "Question 2", "type": "Strongly disagree", "value": 2, "percentage": 18.2},
      {"question": "Question 2", "type": "Disagree", "value": 2, "percentage": 18.2},
      {"question": "Question 2", "type": "Neither agree nor disagree", "value": 0, "percentage": 0},
      {"question": "Question 2", "type": "Agree", "value": 7, "percentage": 63.6},
      {"question": "Question 2", "type": "Strongly agree", "value": 11, "percentage": 0},
      {"question": "Question 3", "type": "Strongly disagree", "value": 2, "percentage": 20},
      {"question": "Question 3", "type": "Disagree", "value": 0, "percentage": 0},
      {"question": "Question 3", "type": "Neither agree nor disagree", "value": 2, "percentage": 20},
      {"question": "Question 3", "type": "Agree", "value": 4, "percentage": 40},
      {"question": "Question 3", "type": "Strongly agree", "value": 2, "percentage": 20},
      {"question": "Question 4", "type": "Strongly disagree", "value": 0, "percentage": 0},
      {"question": "Question 4", "type": "Disagree", "value": 2, "percentage": 12.5},
      {"question": "Question 4", "type": "Neither agree nor disagree", "value": 1, "percentage": 6.3},
      {"question": "Question 4", "type": "Agree", "value": 7, "percentage": 43.8},
      {"question": "Question 4", "type": "Strongly agree", "value": 6, "percentage": 37.5},
      {"question": "Question 5", "type": "Strongly disagree", "value": 0, "percentage": 0},
      {"question": "Question 5", "type": "Disagree", "value": 1, "percentage": 4.2},
      {"question": "Question 5", "type": "Neither agree nor disagree", "value": 3, "percentage": 12.5},
      {"question": "Question 5", "type": "Agree", "value": 16, "percentage": 66.7},
      {"question": "Question 5", "type": "Strongly agree", "value": 4, "percentage": 16.7},
      {"question": "Question 6", "type": "Strongly disagree", "value": 1, "percentage": 6.3},
      {"question": "Question 6", "type": "Disagree", "value": 1, "percentage": 6.3},
      {"question": "Question 6", "type": "Neither agree nor disagree", "value": 2, "percentage": 12.5},
      {"question": "Question 6", "type": "Agree", "value": 9, "percentage": 56.3},
      {"question": "Question 6", "type": "Strongly agree", "value": 3, "percentage": 18.8},
      {"question": "Question 7", "type": "Strongly disagree", "value": 0, "percentage": 0},
      {"question": "Question 7", "type": "Disagree", "value": 0, "percentage": 0},
      {"question": "Question 7", "type": "Neither agree nor disagree", "value": 1, "percentage": 20},
      {"question": "Question 7", "type": "Agree", "value": 4, "percentage": 80},
      {"question": "Question 7", "type": "Strongly agree", "value": 0, "percentage": 0},
      {"question": "Question 8", "type": "Strongly disagree", "value": 0, "percentage": 0},
      {"question": "Question 8", "type": "Disagree", "value": 0, "percentage": 0},
      {"question": "Question 8", "type": "Neither agree nor disagree", "value": 0, "percentage": 0},
      {"question": "Question 8", "type": "Agree", "value": 0, "percentage": 0},
      {"question": "Question 8", "type": "Strongly agree", "value": 2, "percentage": 100}
    ]
  },
  "transform": [
    {
      "calculate": "if(datum.type === 'Strongly disagree',-2,0) + if(datum.type==='Disagree',-1,0) + if(datum.type =='Neither agree nor disagree',0,0) + if(datum.type ==='Agree',1,0) + if(datum.type ==='Strongly agree',2,0)",
      "as": "q_order"
    },
    {
      "calculate": "if(datum.type === 'Disagree' || datum.type === 'Strongly disagree', datum.percentage,0) + if(datum.type === 'Neither agree nor disagree', datum.percentage / 2,0)",
      "as": "signed_percentage"
    },
    {"stack": "percentage", "as": ["v1", "v2"], "groupby": ["question"]},
    {
      "joinaggregate": [
        {
          "field": "signed_percentage",
          "op": "sum",
          "as": "offset"
        }
      ],
      "groupby": ["question"]
    },
    {"calculate": "datum.v1 - datum.offset", "as": "nx"},
    {"calculate": "datum.v2 - datum.offset", "as": "nx2"}
  ],
  "mark": "bar",
  "encoding": {
    "x": {
      "field": "nx",
      "type": "quantitative",
      "title": "Percentage"
    },
    "x2": {"field": "nx2"},
    "y": {
      "field": "question",
      "type": "nominal",
      "title": "Question",
      "axis": {
        "offset": 5,
        "ticks": false,
        "minExtent": 60,
        "domain": false
      }
    },
    "color": {
      "field": "type",
      "type": "nominal",
      "title": "Response",
      "scale": {
        "domain": ["Strongly disagree", "Disagree", "Neither agree nor disagree", "Agree", "Strongly agree"],
        "range": ["#c30d24", "#f3a583", "#cccccc", "#94c6da", "#1770ab"],
        "type": "ordinal"
      }
    }
  }
}
""")
    }

    func test_bar_gantt() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A simple bar chart with ranged data (aka Gantt Chart).",
  "data": {
    "values": [
      {"task": "A", "start": 1, "end": 3},
      {"task": "B", "start": 3, "end": 8},
      {"task": "C", "start": 8, "end": 10}
    ]
  },
  "mark": "bar",
  "encoding": {
    "y": {"field": "task", "type": "ordinal"},
    "x": {"field": "start", "type": "quantitative"},
    "x2": {"field": "end"}
  }
}
""")
    }

    func test_bar_grouped() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": { "url": "data/population.json"},
  "transform": [
    {"filter": "datum.year == 2000"},
    {"calculate": "datum.sex == 2 ? 'Female' : 'Male'", "as": "gender"}
  ],
  "width": {"step": 12},
  "mark": "bar",
  "encoding": {
    "column": {
      "field": "age", "type": "ordinal", "spacing": 10
    },
    "y": {
      "aggregate": "sum", "field": "people",
      "title": "population",
      "axis": {"grid": false}
    },
    "x": {
      "field": "gender",
      "axis": {"title": ""}
    },
    "color": {
      "field": "gender",
      "scale": {"range": ["#675193", "#ca8861"]}
    }
  },
  "config": {
    "view": {"stroke": "transparent"},
    "axis": {"domainWidth": 1}
  }
}
""")
    }

    func test_bar_layered_transparent() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A bar chart showing the US population distribution of age groups and gender in 2000.",
  "data": { "url": "data/population.json"},
  "transform": [
    {"filter": "datum.year == 2000"},
    {"calculate": "datum.sex == 2 ? 'Female' : 'Male'", "as": "gender"}
  ],
  "width": {"step": 17},
  "mark": "bar",
  "encoding": {
    "x": {"field": "age", "type": "ordinal"},
    "y": {
      "aggregate": "sum", "field": "people",
      "title": "population",
      "stack": null
    },
    "color": {
      "field": "gender",
      "scale": {"range": ["#675193", "#ca8861"]}
    },
    "opacity": {"value": 0.7}
  }
}
""")
    }

    func test_bar_layered_weather() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A layered bar chart with floating bars representing weekly weather data",
  "config": {
    "style": {
      "hilo": {
        "size": 20
      }
    }
  },
  "title": {
    "text": ["Weekly Weather", "Observations and Predictions"],
    "frame": "group"
  },
  "data": {
    "url": "data/weather.json"
  },
  "width": 250,
  "height": 200,
  "encoding": {
    "x": {
      "field": "id",
      "type": "ordinal",
      "axis": {
        "domain": false,
        "ticks": false,
        "labels": false,
        "title": null,
        "titlePadding": 25,
        "orient": "top"
      }
    },
    "y": {
      "type": "quantitative",
      "scale": {"domain": [10, 70]},
      "axis": {"title": "Temperature (F)"}
    }
  },
  "layer": [
    {
      "mark": {"type": "bar", "size": 20, "color": "#ccc"},
      "encoding": {
        "y": {"field": "record.low"},
        "y2": {"field": "record.high"}
      }
    },
    {
      "mark": {"type": "bar", "size": 20, "color": "#999"},
      "encoding": {
        "y": {"field": "normal.low"},
        "y2": {"field": "normal.high"}
      }
    },
    {
      "mark": {"type": "bar", "size": 12, "color": "#000"},
      "encoding": {
        "y": {"field": "actual.low"},
        "y2": {"field": "actual.high"}
      }
    },
    {
      "mark": {"type": "bar", "size": 12, "color": "#000"},
      "encoding": {
        "y": {"field": "forecast.low.low"},
        "y2": {"field": "forecast.low.high"}
      }
    },
    {
      "mark": {"type": "bar", "size": 3, "color": "#000"},
      "encoding": {
        "y": {"field": "forecast.low.high"},
        "y2": {"field": "forecast.high.low"}
      }
    },
    {
      "mark": {"type": "bar", "size": 12, "color": "#000"},
      "encoding": {
        "y": {"field": "forecast.high.low"},
        "y2": {"field": "forecast.high.high"}
      }
    },
    {
      "mark": {"type": "text", "align": "center", "baseline": "bottom", "y": -5},
      "encoding": {
        "text": {"field": "day"}
      }
    }
  ]
}
""")
    }

    func test_bar_month_temporal_initial() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Using `labelExpr` to show only initial letters of month names.",
  "data": {"url": "data/seattle-weather.csv"},
  "mark": "bar",
  "encoding": {
    "x": {
      "timeUnit": "month",
      "field": "date",
      "axis": {
        "labelAlign": "left",
        "labelExpr": "datum.label[0]"
      }
    },
    "y": {"aggregate": "mean", "field": "precipitation"}
  }
}
""")
    }

    func test_bar_negative() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A bar chart with negative values. We can hide the axis domain line, and instead use a conditional grid color to draw a zero baseline.",
  "data": {
    "values": [
      {"a": "A", "b": -28}, {"a": "B", "b": 55}, {"a": "C", "b": -33},
      {"a": "D", "b": 91}, {"a": "E", "b": 81}, {"a": "F", "b": 53},
      {"a": "G", "b": -19}, {"a": "H", "b": 87}, {"a": "I", "b": 52}
    ]
  },
  "mark": "bar",
  "encoding": {
    "x": {
      "field": "a", "type": "nominal",
      "axis": {
        "domain": false,
        "ticks": false,
        "labelAngle": 0,
        "labelPadding": 4
      }
    },
    "y": {
      "field": "b", "type": "quantitative",
      "axis": {
        "gridColor": {
          "condition": {"test": "datum.value === 0", "value": "black"},
          "value": "#ddd"
        }
      }
    }
  }
}
""")
    }

    func test_bar_negative_horizontal_label() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A bar chart with negative values. We can hide the axis domain line, and instead use a conditional grid color to draw a zero baseline.",
  "data": {
    "values": [
      {"a": "A", "b": -28},
      {"a": "B", "b": 55},
      {"a": "C", "b": -33},
      {"a": "D", "b": 91},
      {"a": "E", "b": 81},
      {"a": "F", "b": 53},
      {"a": "G", "b": -19},
      {"a": "H", "b": 87},
      {"a": "I", "b": 52}
    ]
  },
  "encoding": {
    "y": {
      "field": "a",
      "type": "nominal",
      "axis": {
        "domain": false,
        "ticks": false,
        "labelAngle": 0,
        "labelPadding": 4
      }
    },
    "x": {
      "field": "b",
      "type": "quantitative",
      "scale": {"padding": 20},
      "axis": {
        "gridColor": {
          "condition": {"test": "datum.value === 0", "value": "black"},
          "value": "#ddd"
        }
      }
    }
  },
  "layer": [
    {"mark": "bar"},
    {
      "mark": {
        "type": "text",
        "align": {"expr": "datum.b < 0 ? 'right' : 'left'"},
        "dx": {"expr": "datum.b < 0 ? -2 : 2"}
      },
      "encoding": {"text": {"field": "b", "type": "quantitative"}}
    }
  ]
}
""")
    }

    func test_bar_size_responsive() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
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

    func test_boxplot_2D_vertical() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A vertical box plot showing median and lower and upper quartiles of the distribution of body mass of penguins.",
  "data": {"url": "data/penguins.json"},
  "mark": "boxplot",
  "encoding": {
    "x": {"field": "Species", "type": "nominal"},
    "color": {"field": "Species", "type": "nominal", "legend": null},
    "y": {
      "field": "Body Mass (g)",
      "type": "quantitative",
      "scale": {"zero": false}
    }
  }
}
""")
    }

    func test_boxplot_minmax_2D_vertical() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A vertical box plot showing median, min, and max body mass of penguins.",
  "data": {"url": "data/penguins.json"},
  "mark": {
    "type": "boxplot",
    "extent": "min-max"
  },
  "encoding": {
    "x": {"field": "Species", "type": "nominal"},
    "color": {"field": "Species", "type": "nominal", "legend": null},
    "y": {
      "field": "Body Mass (g)",
      "type": "quantitative",
      "scale": {"zero": false}
    }
  }
}
""")
    }

    func test_boxplot_preaggregated() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
   "title": "Body Mass of Penguin Species (g)",
  "data": {
    "values": [{
      "Species": "Adelie",
      "lower": 2850,
      "q1": 3350,
      "median": 3700,
      "q3": 4000,
      "upper": 4775,
      "outliers": []
    },{
      "Species": "Chinstrap",
      "lower": 2700,
      "q1": 3487.5,
      "median": 3700,
      "q3": 3950,
      "upper": 4800,
      "outliers": [2700,4800]
    },{
      "Species": "Gentoo",
      "lower": 3950,
      "q1": 4700,
      "median": 5000,
      "q3": 5500,
      "upper": 6300,
      "outliers": []
    }]
  },
  "encoding": {"y": {"field": "Species", "type": "nominal", "title": null}},
  "layer": [
    {
      "mark": {"type": "rule"},
      "encoding": {
        "x": {"field": "lower", "type": "quantitative","scale": {"zero": false}, "title": null},
        "x2": {"field": "upper"}
      }
    },
    {
      "mark": {"type": "bar", "size": 14},
      "encoding": {
        "x": {"field": "q1", "type": "quantitative"},
        "x2": {"field": "q3"},
        "color": {"field": "Species", "type": "nominal", "legend": null}
      }
    },
    {
      "mark": {"type": "tick", "color": "white", "size": 14},
      "encoding": {
        "x": {"field": "median", "type": "quantitative"}
      }
    },
    {
      "transform": [{"flatten": ["outliers"]}],
      "mark": {"type": "point", "style": "boxplot-outliers"},
      "encoding": {
        "x": {"field": "outliers", "type": "quantitative"}
      }
    }
  ]
}
""")
    }

    func test_brush_table() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Drag a rectangular brush to show (first 20) selected points in a table.",
  "data": {"url": "data/cars.json"},
  "transform": [{
    "window": [{"op": "row_number", "as": "row_number"}]
  }],
  "hconcat": [{
    "params": [{"name": "brush", "select": "interval"}],
    "mark": "point",
    "encoding": {
      "x": {"field": "Horsepower", "type": "quantitative"},
      "y": {"field": "Miles_per_Gallon", "type": "quantitative"},
      "color": {
        "condition": {"param": "brush", "field": "Cylinders", "type": "ordinal"},
        "value": "grey"
      }
    }
  }, {
    "transform": [
      {"filter": {"param": "brush"}},
      {"window": [{"op": "rank", "as": "rank"}]},
      {"filter": {"field": "rank", "lt": 20}}
    ],
    "hconcat": [{
      "width": 50,
      "title": "Horsepower",
      "mark": "text",
      "encoding": {
        "text": {"field": "Horsepower", "type": "nominal"},
        "y": {"field": "row_number", "type": "ordinal", "axis": null}
      }
    }, {
      "width": 50,
      "title": "MPG",
      "mark": "text",
      "encoding": {
        "text": {"field": "Miles_per_Gallon", "type": "nominal"},
        "y": {"field": "row_number", "type": "ordinal", "axis": null}
      }
    }, {
      "width": 50,
      "title": "Origin",
      "mark": "text",
      "encoding": {
        "text": {"field": "Origin", "type": "nominal"},
        "y": {"field": "row_number", "type": "ordinal", "axis": null}
      }
    }]
  }],
  "resolve": {"legend": {"color": "independent"}}
}
""")
    }

    func test_circle() throws {
        try check(viz: Graphiq {
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

    func test_circle_binned() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/movies.json"},
  "mark": "circle",
  "encoding": {
    "x": {
      "bin": {"maxbins": 10},
      "field": "IMDB Rating"
    },
    "y": {
      "bin": {"maxbins": 10},
      "field": "Rotten Tomatoes Rating"
    },
    "size": {"aggregate": "count"}
  }
}
""")
    }

    func test_circle_bubble_health_income() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A bubble plot showing the correlation between health and income for 187 countries in the world (modified from an example in Lisa Charlotte Rost's blog post 'One Chart, Twelve Charting Libraries' --http://lisacharlotterost.github.io/2016/05/17/one-chart-code/).",
  "width": 500,"height": 300,
  "data": {
    "url": "data/gapminder-health-income.csv"
  },
  "params": [{
    "name": "view",
    "select": "interval",
    "bind": "scales"
  }],
  "mark": "circle",
  "encoding": {
    "y": {
      "field": "health",
      "type": "quantitative",
      "scale": {"zero": false},
      "axis": {"minExtent": 30}
    },
    "x": {
      "field": "income",
      "scale": {"type": "log"}
    },
    "size": {"field": "population", "type": "quantitative"},
    "color": {"value": "#000"}
  }
}
""")
    }

    func test_circle_custom_tick_labels() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "url": "data/movies.json"
  },
  "mark": {"size": 80, "type": "circle"},
  "encoding": {
    "x": {
      "aggregate": "mean",
      "axis": {
        "labelExpr": "datum.label == 0 ? 'Poor' : datum.label == 5 ? 'Neutral' : 'Great'",
        "labelFlush": false,
        "values": [0, 5, 10]
      },
      "field": "IMDB Rating",
      "scale": {"domain": [0, 10]},
      "title": null
    },
    "y": {"field": "Major Genre", "sort": "x", "title": null}
  }
}
""")
    }

    func test_circle_github_punchcard() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Punchcard Visualization like on Github. The day on y-axis uses a custom order from Monday to Sunday.  The sort property supports both full day names (e.g., 'Monday') and their three letter initials (e.g., 'mon') -- both of which are case insensitive.",
  "data": { "url": "data/github.csv"},
  "mark": "circle",
  "encoding": {
    "y": {
      "field": "time",
      "type": "ordinal",
      "timeUnit": "day",
      "sort": ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
    },
    "x": {
      "field": "time",
      "type": "ordinal",
      "timeUnit": "hours"
    },
    "size": {
      "field": "count",
      "type": "quantitative",
      "aggregate": "sum"
    }
  }
}
""")
    }

    func test_circle_natural_disasters() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "url": "data/disasters.csv"
  },
  "width": 600,
  "height": 400,
  "transform": [
    {"filter": "datum.Entity !== 'All natural disasters'"}
  ],
  "mark": {
    "type": "circle",
    "opacity": 0.8,
    "stroke": "black",
    "strokeWidth": 1
  },
  "encoding": {
    "x": {
      "field": "Year",
      "type": "temporal",
      "axis": {"grid": false}
    },
    "y": {"field": "Entity", "type": "nominal", "axis": {"title": ""}},
    "size": {
      "field": "Deaths",
      "type": "quantitative",
      "title": "Annual Global Deaths",
      "legend": {"clipHeight": 30},
      "scale": {"rangeMax": 5000}
    },
    "color": {"field": "Entity", "type": "nominal", "legend": null}
  }
}
""")
    }

    func test_circle_wilkinson_dotplot() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A Wilkinson Dot Plot",
  "height": 100,
  "data": {
    "values": [
      1,1,1,1,1,1,1,1,1,1,
      2,2,2,
      3,3,
      4,4,4,4,4,4
    ]
  },
  "transform": [{
    "window": [{"op": "rank", "as": "id"}],
    "groupby": ["data"]
  }],
  "mark": {
  	"type": "circle",
  	"opacity": 1
  },
  "encoding": {
    "x": {"field": "data", "type": "ordinal"},
    "y": {"field": "id", "type": "ordinal", "axis": null, "sort": "descending"}
  }
}
""")
    }

    func test_concat_bar_scales_discretize() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Horizontally concatenated charts that show different types of discretizing scales.",
  "data": {
    "values": [
      {"a": "A", "b": 28},
      {"a": "B", "b": 55},
      {"a": "C", "b": 43},
      {"a": "D", "b": 91},
      {"a": "E", "b": 81},
      {"a": "F", "b": 53},
      {"a": "G", "b": 19},
      {"a": "H", "b": 87},
      {"a": "I", "b": 52}
    ]
  },
  "hconcat": [
    {
      "mark": "circle",
      "encoding": {
        "y": {
          "field": "b",
          "type": "nominal",
          "sort": null,
          "axis": {
            "ticks": false,
            "domain": false,
            "title": null
          }
        },
        "size": {
          "field": "b",
          "type": "quantitative",
          "scale": {
            "type": "quantize"
          }
        },
        "color": {
          "field": "b",
          "type": "quantitative",
          "scale": {
            "type": "quantize",
            "zero": true
          },
          "legend": {
            "title": "Quantize"
          }
        }
      }
    },
    {
      "mark": "circle",
      "encoding": {
        "y": {
          "field": "b",
          "type": "nominal",
          "sort": null,
          "axis": {
            "ticks": false,
            "domain": false,
            "title": null
          }
        },
        "size": {
          "field": "b",
          "type": "quantitative",
          "scale": {
            "type": "quantile",
            "range": [80, 160, 240, 320, 400]
          }
        },
        "color": {
          "field": "b",
          "type": "quantitative",
          "scale": {
            "type": "quantile",
            "scheme": "magma"
          },
          "legend": {
            "format": "d",
            "title": "Quantile"
          }
        }
      }
    },
    {
      "mark": "circle",
      "encoding": {
        "y": {
          "field": "b",
          "type": "nominal",
          "sort": null,
          "axis": {
            "ticks": false,
            "domain": false,
            "title": null
          }
        },
        "size": {
          "field": "b",
          "type": "quantitative",
          "scale": {
            "type": "threshold",
            "domain": [30, 70],
            "range": [80, 200, 320]
          }
        },
        "color": {
          "field": "b",
          "type": "quantitative",
          "scale": {
            "type": "threshold",
            "domain": [30, 70],
            "scheme": "viridis"
          },
          "legend": {
            "title": "Threshold"
          }
        }
      }
    }
  ],
  "resolve": {
    "scale": {
      "color": "independent",
      "size": "independent"
    }
  }
}
""")
    }

    func test_concat_layer_voyager_result() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "values": [
      {
        "measure": "Open Exploration",
        "mean": 1.813,
        "lo": 1.255,
        "hi": 2.37,
        "study": "PoleStar vs Voyager"
      },
      {
        "measure": "Focused Question Answering",
        "mean": -1.688,
        "lo": -2.325,
        "hi": -1.05,
        "study": "PoleStar vs Voyager"
      },
      {
        "measure": "Open Exploration",
        "mean": 2.1875,
        "lo": 1.665,
        "hi": 2.71,
        "study": "PoleStar vs Voyager 2"
      },
      {
        "measure": "Focused Question Answering",
        "mean": -0.0625,
        "lo": -0.474,
        "hi": 0.349,
        "study": "PoleStar vs Voyager 2"
      }
    ]
  },
  "spacing": 10,
  "vconcat": [
    {
      "title": {
        "text": "Mean of Subject Ratings (95% CIs)",
        "frame": "bounds"
      },
      "encoding": {
        "y": {
          "field": "study",
          "type": "nominal",
          "axis": {
            "title": null,
            "labelPadding": 5,
            "domain": false,
            "ticks": false,
            "grid": false
          }
        },
        "x": {
          "type": "quantitative",
          "scale": {"domain": [-3, 3]},
          "axis": {
            "title": "",
            "gridDash": [3, 3],
            "gridColor": {
              "condition": {
                "test": "datum.value === 0",
                "value": "#666"
              },
              "value": "#CCC"
            }
          }
        }
      },
      "layer": [
        {
          "mark": "rule",
          "encoding": {
            "x": {"field": "lo"},
            "x2": {"field": "hi"}
          }
        },
        {
          "mark": {
            "type": "circle",
            "stroke": "black",
            "opacity": 1
          },
          "encoding": {
            "x": {"field": "mean"},
            "color": {
              "field": "measure",
              "type": "nominal",
              "scale": {
                "range": ["black", "white"]
              },
              "legend": null
            }
          }
        }
      ]
    },
    {
      "data": {
        "values": [
          {
            "from": -0.25,
            "to": -2.9,
            "label": "PoleStar"
          },
          {
            "from": 0.25,
            "to": 2.9,
            "label": "Voyager / Voyager 2"
          }
        ]
      },
      "encoding": {
        "x": {
          "type": "quantitative",
          "scale": {"zero": false},
          "axis": null
        }
      },
      "layer": [
        {
          "mark": "rule",
          "encoding": {
            "x": {"field": "from"},
            "x2": {"field": "to"}
          }
        },
        {
          "mark": {
            "type": "point",
            "filled": true,
            "size": 60,
            "fill": "black"
          },
          "encoding": {
            "x": {"field": "to"},
            "shape": {
              "condition": {
                "test": "datum.to > 0",
                "value": "triangle-right"
              },
              "value": "triangle-left"
            }
          }
        },
        {
          "mark": {
            "type": "text",
            "align": "right",
            "style": "arrow-label",
            "text": ["Polestar", "More Valuable"]
          },
          "transform": [{"filter": "datum.label === 'PoleStar'"}],
          "encoding": {
            "x": {"field": "from"}
          }
        },
        {
          "mark": {
            "type": "text",
            "align": "left",
            "style": "arrow-label",
            "text": ["Voyager / Voyager 2", "More Valuable"]
          },
          "transform": [{"filter": "datum.label !== 'PoleStar'"}],
          "encoding": {
            "x": {"field": "from"}
          }
        }
      ]
    }
  ],
  "config": {
    "view": {"stroke": "transparent"},
    "style": {
      "arrow-label": {"dy": 12, "fontSize": 9.5},
      "arrow-label2": {"dy": 24, "fontSize": 9.5}
    },
    "title": {"fontSize": 12}
  }
}
""")
    }

    func test_concat_marginal_histograms() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/movies.json"},
  "spacing": 15,
  "bounds": "flush",
  "vconcat": [{
    "mark": "bar",
    "height": 60,
    "encoding": {
      "x": {
        "bin": true,
        "field": "IMDB Rating",
        "axis": null
      },
      "y": {
        "aggregate": "count",
        "scale": {
          "domain": [0,1000]
        },
        "title": ""
      }
    }
  }, {
    "spacing": 15,
    "bounds": "flush",
    "hconcat": [{
      "mark": "rect",
      "encoding": {
        "x": {"bin": true, "field": "IMDB Rating"},
        "y": {"bin": true, "field": "Rotten Tomatoes Rating"},
        "color": {"aggregate": "count"}
      }
    }, {
      "mark": "bar",
      "width": 60,
      "encoding": {
        "y": {
          "bin": true,
          "field": "Rotten Tomatoes Rating",
          "axis": null
        },
        "x": {
          "aggregate": "count",
          "scale": {"domain": [0,1000]},
          "title": ""
        }
      }
    }]
  }],
  "config": {
    "view": {
      "stroke": "transparent"
    }
  }
}
""")
    }

    func test_concat_population_pyramid() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A population pyramid for the US in 2000.",
  "data": { "url": "data/population.json"},
  "transform": [
    {"filter": "datum.year == 2000"},
    {"calculate": "datum.sex == 2 ? 'Female' : 'Male'", "as": "gender"}
  ],
  "spacing": 0,
  "hconcat": [{
    "transform": [{
      "filter": {"field": "gender", "equal": "Female"}
    }],
    "title": "Female",
    "mark": "bar",
    "encoding": {
      "y": {
        "field": "age", "axis": null, "sort": "descending"
      },
      "x": {
        "aggregate": "sum", "field": "people",
        "title": "population",
        "axis": {"format": "s"},
        "sort": "descending"
      },
      "color": {
        "field": "gender",
        "scale": {"range": ["#675193", "#ca8861"]},
        "legend": null
      }
    }
  }, {
    "width": 20,
    "view": {"stroke": null},
    "mark": {
      "type": "text",
      "align": "center"
    },
    "encoding": {
      "y": {"field": "age", "type": "ordinal", "axis": null, "sort": "descending"},
      "text": {"field": "age", "type": "quantitative"}
    }
  }, {
    "transform": [{
      "filter": {"field": "gender", "equal": "Male"}
    }],
    "title": "Male",
    "mark": "bar",
    "encoding": {
      "y": {
        "field": "age", "title": null,
        "axis": null, "sort": "descending"
      },
      "x": {
        "aggregate": "sum", "field": "people",
        "title": "population",
        "axis": {"format": "s"}
      },
      "color": {
        "field": "gender",
        "legend": null
      }
    }
  }],
  "config": {
    "view": {"stroke": null},
    "axis": {"grid": false}
  }
}
""")
    }

    func test_connected_scatterplot() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/driving.json"},
  "mark": {"type": "line", "point": true},
  "encoding": {
    "x": {
      "field": "miles", "type": "quantitative",
      "scale": {"zero": false}
    },
    "y": {
      "field": "gas", "type": "quantitative",
      "scale": {"zero": false}
    },
    "order": {"field": "year"}
  }
}
""")
    }

    func test_facet_bullet() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "values": [
      {"title":"Revenue", "subtitle":"US$, in thousands", "ranges":[150,225,300],"measures":[220,270],"markers":[250]},
      {"title":"Profit", "subtitle":"%", "ranges":[20,25,30],"measures":[21,23],"markers":[26]},
      {"title":"Order Size", "subtitle":"US$, average", "ranges":[350,500,600],"measures":[100,320],"markers":[550]},
      {"title":"New Customers", "subtitle":"count", "ranges":[1400,2000,2500],"measures":[1000,1650],"markers":[2100]},
      {"title":"Satisfaction", "subtitle":"out of 5", "ranges":[3.5,4.25,5],"measures":[3.2,4.7],"markers":[4.4]}
    ]
  },
  "facet": {
    "row": {
      "field": "title", "type": "ordinal",
      "header": {"labelAngle": 0, "title": ""}
    }
  },
  "spacing": 10,
  "spec": {
    "encoding": {
      "x": {
        "type": "quantitative",
        "scale": {"nice": false},
        "title": null
      }
    },
    "layer": [{
      "mark": {"type": "bar", "color": "#eee"},
      "encoding": {"x": {"field": "ranges[2]"}}
    },{
      "mark": {"type": "bar", "color": "#ddd"},
      "encoding": {"x": {"field": "ranges[1]"}}
    },{
      "mark": {"type": "bar", "color": "#ccc"},
      "encoding": {"x": {"field": "ranges[0]"}}
    },{
      "mark": {"type": "bar", "color": "lightsteelblue", "size": 10},
      "encoding": {"x": {"field": "measures[1]"}}
    },{
      "mark": {"type": "bar", "color": "steelblue", "size": 10},
      "encoding": {"x": {"field": "measures[0]"}}
    },{
      "mark": {"type": "tick", "color": "black"},
      "encoding": {"x": {"field": "markers[0]"}}
    }]
  },
  "resolve": {"scale": {"x": "independent"}},
  "config": {"tick": {"thickness": 2}}
}
""")
    }

    func test_facet_grid_bar() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A simple grid of bar charts to compare performance data.",
  "data": {
    "values": [
      {"a": "a1", "b": "b1", "c": "x", "p": "0.14"},
      {"a": "a1", "b": "b1", "c": "y", "p": "0.60"},
      {"a": "a1", "b": "b1", "c": "z", "p": "0.03"},
      {"a": "a1", "b": "b2", "c": "x", "p": "0.80"},
      {"a": "a1", "b": "b2", "c": "y", "p": "0.38"},
      {"a": "a1", "b": "b2", "c": "z", "p": "0.55"},
      {"a": "a1", "b": "b3", "c": "x", "p": "0.11"},
      {"a": "a1", "b": "b3", "c": "y", "p": "0.58"},
      {"a": "a1", "b": "b3", "c": "z", "p": "0.79"},
      {"a": "a2", "b": "b1", "c": "x", "p": "0.83"},
      {"a": "a2", "b": "b1", "c": "y", "p": "0.87"},
      {"a": "a2", "b": "b1", "c": "z", "p": "0.67"},
      {"a": "a2", "b": "b2", "c": "x", "p": "0.97"},
      {"a": "a2", "b": "b2", "c": "y", "p": "0.84"},
      {"a": "a2", "b": "b2", "c": "z", "p": "0.90"},
      {"a": "a2", "b": "b3", "c": "x", "p": "0.74"},
      {"a": "a2", "b": "b3", "c": "y", "p": "0.64"},
      {"a": "a2", "b": "b3", "c": "z", "p": "0.19"},
      {"a": "a3", "b": "b1", "c": "x", "p": "0.57"},
      {"a": "a3", "b": "b1", "c": "y", "p": "0.35"},
      {"a": "a3", "b": "b1", "c": "z", "p": "0.49"},
      {"a": "a3", "b": "b2", "c": "x", "p": "0.91"},
      {"a": "a3", "b": "b2", "c": "y", "p": "0.38"},
      {"a": "a3", "b": "b2", "c": "z", "p": "0.91"},
      {"a": "a3", "b": "b3", "c": "x", "p": "0.99"},
      {"a": "a3", "b": "b3", "c": "y", "p": "0.80"},
      {"a": "a3", "b": "b3", "c": "z", "p": "0.37"}
    ]
  },
  "width": 60,
  "height": {"step": 8},
  "spacing": 5,
  "mark": "bar",
  "encoding": {
    "y": {"field": "c", "type": "nominal", "axis": null},
    "x": {
      "field": "p",
      "type": "quantitative",
      "axis": {"format": "%"},
      "title": null
    },
    "color": {
      "field": "c",
      "type": "nominal",
      "legend": {"orient": "bottom", "titleOrient": "left"},
      "title": "settings"
    },
    "row": {"field": "a", "title": "Factor A", "header": {"labelAngle": 0}},
    "column": {"field": "b", "title": "Factor B"}
  }
}
""")
    }

    func test_geo_choropleth() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "width": 500,
  "height": 300,
  "data": {
    "url": "data/us-10m.json",
    "format": {
      "type": "topojson",
      "feature": "counties"
    }
  },
  "transform": [{
    "lookup": "id",
    "from": {
      "data": {
        "url": "data/unemployment.tsv"
      },
      "key": "id",
      "fields": ["rate"]
    }
  }],
  "projection": {
    "type": "albersUsa"
  },
  "mark": "geoshape",
  "encoding": {
    "color": {
      "field": "rate",
      "type": "quantitative"
    }
  }
}
""")
    }

    func test_geo_circle() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "width": 500,
  "height": 300,
  "data": {
    "url": "data/zipcodes.csv"
  },
  "transform": [{"calculate": "substring(datum.zip_code, 0, 1)", "as": "digit"}],
  "projection": {
    "type": "albersUsa"
  },
  "mark": "circle",
  "encoding": {
    "longitude": {
      "field": "longitude",
      "type": "quantitative"
    },
    "latitude": {
      "field": "latitude",
      "type": "quantitative"
    },
    "size": {"value": 1},
    "color": {"field": "digit", "type": "nominal"}
  }
}
""")
    }

    func test_geo_layer() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "width": 500,
  "height": 300,
  "layer": [
    {
      "data": {
        "url": "data/us-10m.json",
        "format": {
          "type": "topojson",
          "feature": "states"
        }
      },
      "projection": {
        "type": "albersUsa"
      },
      "mark": {
        "type": "geoshape",
        "fill": "lightgray",
        "stroke": "white"
      }
    },
    {
      "data": {
        "url": "data/airports.csv"
      },
      "projection": {
        "type": "albersUsa"
      },
      "mark": "circle",
      "encoding": {
        "longitude": {
          "field": "longitude",
          "type": "quantitative"
        },
        "latitude": {
          "field": "latitude",
          "type": "quantitative"
        },
        "size": {"value": 10},
        "color": {"value": "steelblue"}
      }
    }
  ]
}
""")
    }

    func test_geo_layer_line_london() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "width": 700,
  "height": 500,
  "view": {
    "stroke": "transparent"
  },
  "layer": [
    {
      "data": {
        "url": "data/londonBoroughs.json",
        "format": {
          "type": "topojson",
          "feature": "boroughs"
        }
      },
      "mark": {
        "type": "geoshape",
        "stroke": "white",
        "strokeWidth": 2
      },
      "encoding": {
        "color": {
          "value": "#eee"
        }
      }
    },
    {
      "data": {
        "url": "data/londonCentroids.json",
        "format": {
          "type": "json"
        }
      },
      "transform": [
        {
          "calculate": "indexof (datum.name,' ') > 0  ? substring(datum.name,0,indexof(datum.name, ' ')) : datum.name",
          "as": "bLabel"
        }
      ],
      "mark": "text",
      "encoding": {
        "longitude": {
          "field": "cx",
          "type": "quantitative"
        },
        "latitude": {
          "field": "cy",
          "type": "quantitative"
        },
        "text": {
          "field": "bLabel",
          "type": "nominal"
        },
        "size": {
          "value": 8
        },
        "opacity": {
          "value": 0.6
        }
      }
    },
    {
      "data": {
        "url": "data/londonTubeLines.json",
        "format": {
          "type": "topojson",
          "feature": "line"
        }
      },
      "mark": {
        "type": "geoshape",
        "filled": false,
        "strokeWidth": 2
      },
      "encoding": {
        "color": {
          "field": "id",
          "type": "nominal",
          "legend": {
            "title": null,
            "orient": "bottom-right",
            "offset": 0
          },
          "scale": {
            "domain": [
              "Bakerloo",
              "Central",
              "Circle",
              "District",
              "DLR",
              "Hammersmith & City",
              "Jubilee",
              "Metropolitan",
              "Northern",
              "Piccadilly",
              "Victoria",
              "Waterloo & City"
            ],
            "range": [
              "rgb(137,78,36)",
              "rgb(220,36,30)",
              "rgb(255,206,0)",
              "rgb(1,114,41)",
              "rgb(0,175,173)",
              "rgb(215,153,175)",
              "rgb(106,114,120)",
              "rgb(114,17,84)",
              "rgb(0,0,0)",
              "rgb(0,24,168)",
              "rgb(0,160,226)",
              "rgb(106,187,170)"
            ]
          }
        }
      }
    }
  ]
}
""")
    }

    func test_geo_line() throws {
        try check(viz: Graphiq {
//            VizLayer(.overlay) {
//                // background map
//                VizMark(.geoshape) {
//                    //VizData(.topojson, feature: "states", url: "data/us-10m.json")
//                    //VizProjection(.albersUsa)
//                }
//                .fill(.init(.init(ColorCode("#eee"))))
//                .stroke(.init(.init(ColorCode("white"))))
//
//                // circles over the map
//                VizMark(.circle) {
//                    //VizProjection(.albersUsa)
//                    VizEncode(.longitude, field: "longitude").type(.quantitative)
//                    VizEncode(.latitude, field: "latitude").type(.quantitative)
//                    VizEncode(.size, value: 5)
//                    VizEncode(.color, value: "gray")
//                }
//
//                VizMark(.line) {
//                    VizEncode(.longitude, field: "longitude").type(.quantitative)
//                    VizEncode(.latitude, field: "latitude").type(.quantitative)
//                    VizEncode(.order, field: "order")
//                }
//            }
//        }
//        .description("Line drawn between airports in the U.S. simulating a flight itinerary")
//        .width(800.0)
//        .height(500.0)
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Line drawn between airports in the U.S. simulating a flight itinerary",
  "width": 800,
  "height": 500,
  "layer": [
    {
      "data": {
        "url": "data/us-10m.json",
        "format": {
          "type": "topojson",
          "feature": "states"
        }
      },
      "projection": {
        "type": "albersUsa"
      },
      "mark": {
        "type": "geoshape",
        "fill": "#eee",
        "stroke": "white"
      }
    },
    {
      "data": {
        "url": "data/airports.csv"
      },
      "projection": {
        "type": "albersUsa"
      },
      "mark": "circle",
      "encoding": {
        "longitude": {
          "field": "longitude",
          "type": "quantitative"
        },
        "latitude": {
          "field": "latitude",
          "type": "quantitative"
        },
        "size": {
          "value": 5
        },
        "color": {
          "value": "gray"
        }
      }
    },
    {
      "data": {
        "values": [
          {"airport": "SEA", "order": 1},
          {"airport": "SFO", "order": 2},
          {"airport": "LAX", "order": 3},
          {"airport": "LAS", "order": 4},
          {"airport": "DFW", "order": 5},
          {"airport": "DEN", "order": 6},
          {"airport": "ORD", "order": 7},
          {"airport": "JFK", "order": 8}
        ]
      },
      "transform": [
        {
          "lookup": "airport",
          "from": {
            "data": {
              "url": "data/airports.csv"
            },
            "key": "iata",
            "fields": [
              "latitude",
              "longitude"
            ]
          }
        }
      ],
      "projection": {
        "type": "albersUsa"
      },
      "mark": "line",
      "encoding": {
        "longitude": {
          "field": "longitude",
          "type": "quantitative"
        },
        "latitude": {
          "field": "latitude",
          "type": "quantitative"
        },
        "order": {
          "field": "order"
        }
      }
    }
  ]
}
""")
    }

    func test_geo_params_projections() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "width": 500,
  "height": 300,
  "params": [
    {
      "name": "projection",
      "value": "equalEarth",
      "bind": {
        "input": "select",
        "options": [
          "albers",
          "albersUsa",
          "azimuthalEqualArea",
          "azimuthalEquidistant",
          "conicConformal",
          "conicEqualArea",
          "conicEquidistant",
          "equalEarth",
          "equirectangular",
          "gnomonic",
          "mercator",
          "naturalEarth1",
          "orthographic",
          "stereographic",
          "transverseMercator"
        ]
      }
    }
  ],
  "data": {
    "url": "data/world-110m.json",
    "format": {"type": "topojson", "feature": "countries"}
  },
  "projection": {"type": {"expr": "projection"}},
  "mark": {"type": "geoshape", "fill": "lightgray", "stroke": "gray"}
}
""")
    }

    func test_geo_repeat() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "the population per state, engineers per state, and hurricanes per state",
  "repeat": {"row": ["population", "engineers", "hurricanes"]},
  "resolve": {
    "scale": {
      "color": "independent"
    }
  },
  "spec": {
    "width": 500,
    "height": 300,
    "data": {
      "url": "data/population_engineers_hurricanes.csv"
    },
    "transform": [
      {
        "lookup": "id",
        "from": {
          "data": {
            "url": "data/us-10m.json",
            "format": {
              "type": "topojson",
              "feature": "states"
            }
          },
          "key": "id"
        },
        "as": "geo"
      }
    ],
    "projection": {"type": "albersUsa"},
    "mark": "geoshape",
    "encoding": {
      "shape": {
        "field": "geo",
        "type": "geojson"
      },
      "color": {
        "field": {"repeat": "row"},
        "type": "quantitative"
      }
    }
  }
}
""")
    }

    func test_geo_rule() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "width": 800,
  "height": 500,
  "layer": [
    {
      "data": {
        "url": "data/us-10m.json",
        "format": {
          "type": "topojson",
          "feature": "states"
        }
      },
      "projection": {
        "type": "albersUsa"
      },
      "mark": {
        "type": "geoshape",
        "fill": "lightgray",
        "stroke": "white"
      }
    },
    {
      "data": {
        "url": "data/airports.csv"
      },
      "projection": {
        "type": "albersUsa"
      },
      "mark": "circle",
      "encoding": {
        "longitude": {
          "field": "longitude",
          "type": "quantitative"
        },
        "latitude": {
          "field": "latitude",
          "type": "quantitative"
        },
        "size": {"value": 5},
        "color": {"value": "gray"}
      }
    },
    {
      "data": {
        "url": "data/flights-airport.csv"
      },
      "transform": [
        {"filter": {"field": "origin", "equal": "SEA"}},
        {
          "lookup": "origin",
          "from": {
            "data": {
              "url": "data/airports.csv"
            },
            "key": "iata",
            "fields": ["latitude", "longitude"]
          },
          "as": ["origin_latitude", "origin_longitude"]
        },
        {
          "lookup": "destination",
          "from": {
            "data": {
              "url": "data/airports.csv"
            },
            "key": "iata",
            "fields": ["latitude", "longitude"]
          },
          "as": ["dest_latitude", "dest_longitude"]
        }
      ],
      "projection": {
        "type": "albersUsa"
      },
      "mark": "rule",
      "encoding": {
        "longitude": {
          "field": "origin_longitude",
          "type": "quantitative"
        },
        "latitude": {
          "field": "origin_latitude",
          "type": "quantitative"
        },
        "longitude2": {"field": "dest_longitude"},
        "latitude2": {"field": "dest_latitude"}
      }
    }
  ]
}
""")
    }

    func test_geo_text() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "width": 800,
  "height": 500,
  "projection": {
    "type": "albersUsa"
  },
  "layer": [
    {
      "data": {
        "url": "data/us-10m.json",
        "format": {
          "type": "topojson",
          "feature": "states"
        }
      },
      "mark": {
        "type": "geoshape",
        "fill": "lightgray",
        "stroke": "white"
      }
    },
    {
      "data": {
        "url": "data/us-state-capitals.json"
      },
      "encoding": {
        "longitude": {
          "field": "lon",
          "type": "quantitative"
        },
        "latitude": {
          "field": "lat",
          "type": "quantitative"
        }
      },
      "layer": [{
        "mark": {
          "type": "circle",
          "color": "orange"
        }
      }, {
        "mark": {
          "type": "text",
          "dy": -10
        },
        "encoding": {
          "text": {"field": "city", "type": "nominal"}
        }
      }]
    }
  ]
}
""")
    }

    func test_geo_trellis() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "width": 500,
  "height": 300,
  "data": {
    "url": "data/income.json"
  },
  "transform": [
    {
      "lookup": "id",
      "from": {
        "data": {
          "url": "data/us-10m.json",
          "format": {
            "type": "topojson",
            "feature": "states"
          }
        },
        "key": "id"
      },
      "as": "geo"
    }
  ],
  "projection": {"type": "albersUsa"},
  "mark": "geoshape",
  "encoding": {
    "shape": {"field": "geo", "type": "geojson"},
    "color": {"field": "pct", "type": "quantitative"},
    "row": {"field": "group"}
  }
}
""")
    }

    func test_histogram() throws {
        try check(viz: Graphiq {
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

    func test_histogram_rel_freq() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Relative frequency histogram. The data is binned with first transform. The number of values per bin and the total number are calculated in the second and third transform to calculate the relative frequency in the last transformation step.",
  "data": {"url": "data/cars.json"},
  "transform": [{
      "bin": true, "field": "Horsepower", "as": "bin_Horsepwoer"
    }, {
      "aggregate": [{"op": "count", "as": "Count"}],
      "groupby": ["bin_Horsepwoer", "bin_Horsepwoer_end"]
    }, {
      "joinaggregate": [{"op": "sum", "field": "Count", "as": "TotalCount"}]
    }, {
      "calculate": "datum.Count/datum.TotalCount", "as": "PercentOfTotal"
    }
  ],
  "mark": {"type": "bar", "tooltip": true},
  "encoding": {
    "x": {
      "title": "Horsepower",
      "field": "bin_Horsepwoer",
      "bin": {"binned": true}
    },
    "x2": {"field": "bin_Horsepwoer_end"},
    "y": {
      "title": "Relative Frequency",
      "field": "PercentOfTotal",
      "type": "quantitative",
      "axis": {
        "format": ".1~%"
        }
    }
  }
}
""")
    }

    func test_interactive_area_brush() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/unemployment-across-industries.json"},
  "encoding": {
      "x": {"timeUnit": "yearmonth", "field": "date"},
      "y": {"aggregate": "sum", "field": "count"}
  },
  "layer": [{
    "params": [{
      "name": "brush",
      "select": {"type": "interval", "encodings": ["x"]}
    }],
    "mark": "area"
  }, {
    "transform": [
      {"filter": {"param": "brush"}}
    ],
    "mark": {"type": "area", "color": "goldenrod"}
  }]
}
""")
    }

    func test_interactive_bar_select_highlight() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A bar chart with highlighting on hover and selecting on click. (Inspired by Tableau's interaction style.)",
  "data": {
    "values": [
      {"a": "A", "b": 28}, {"a": "B", "b": 55}, {"a": "C", "b": 43},
      {"a": "D", "b": 91}, {"a": "E", "b": 81}, {"a": "F", "b": 53},
      {"a": "G", "b": 19}, {"a": "H", "b": 87}, {"a": "I", "b": 52}
    ]
  },
  "params": [
    {
      "name": "highlight",
      "select": {"type": "point", "on": "mouseover"}
    },
    {"name": "select", "select": "point"}
  ],
  "mark": {
    "type": "bar",
    "fill": "#4C78A8",
    "stroke": "black",
    "cursor": "pointer"
  },
  "encoding": {
    "x": {"field": "a", "type": "ordinal"},
    "y": {"field": "b", "type": "quantitative"},
    "fillOpacity": {
      "condition": {"param": "select", "value": 1},
      "value": 0.3
    },
    "strokeWidth": {
      "condition": [
        {
          "param": "select",
          "empty": false,
          "value": 2
        },
        {
          "param": "highlight",
          "empty": false,
          "value": 1
        }
      ],
      "value": 0
    }
  },
  "config": {
    "scale": {
      "bandPaddingInner": 0.2
    }
  }
}
""")
    }

    func test_interactive_bin_extent() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "url": "data/flights-5k.json",
    "format": {"parse": {"date": "date"}}
  },
  "transform": [{"calculate": "hours(datum.date) + minutes(datum.date) / 60", "as": "time"}],
  "vconcat": [{
    "width": 963,
    "height": 100,
    "params": [{
      "name": "brush",
      "select": {"type": "interval", "encodings": ["x"]}
    }],
    "mark": "bar",
    "encoding": {
      "x": {"field": "time", "bin": {"maxbins": 30}},
      "y": {"aggregate": "count"}
    }
  }, {
    "width": 963,
    "height": 100,
    "mark": "bar",
    "encoding": {
      "x": {
        "field": "time",
        "bin": {"maxbins": 30, "extent": {"param": "brush"}}
      },
      "y": {"aggregate": "count"}
    }
  }]
}
""")
    }

    func test_interactive_brush() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Drag out a rectangular brush to highlight points.",
  "data": {"url": "data/cars.json"},
  "params": [{
    "name": "brush",
    "select": "interval",
    "value": {"x": [55, 160], "y": [13, 37]}
  }],
  "mark": "point",
  "encoding": {
    "x": {"field": "Horsepower", "type": "quantitative"},
    "y": {"field": "Miles_per_Gallon", "type": "quantitative"},
    "color": {
      "condition": {"param": "brush", "field": "Cylinders", "type": "ordinal"},
      "value": "grey"
    }
  }
}
""")
    }

    func test_interactive_concat_layer() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A dashboard with cross-highlighting.",
  "data": {"url": "data/movies.json"},
  "vconcat": [
    {
      "layer": [{
        "mark": "rect",
        "encoding": {
          "x": {
            "bin": {"maxbins": 10},
            "field": "IMDB Rating"
          },
          "y": {
            "bin": {"maxbins": 10},
            "field": "Rotten Tomatoes Rating"
          },
          "color": {
            "aggregate": "count",
            "legend": {
              "title": "All Movies Count",
              "direction": "horizontal",
              "gradientLength": 120
            }
          }
        }
      }, {
        "transform": [{
          "filter": {"param": "pts"}
        }],
        "mark": "point",
        "encoding": {
          "x": {
            "bin": {"maxbins": 10},
            "field": "IMDB Rating"
          },
          "y": {
            "bin": {"maxbins": 10},
            "field": "Rotten Tomatoes Rating"
          },
          "size": {
            "aggregate": "count",
            "legend": {"title": "Selected Category Count"}
          },
          "color": {
            "value": "#666"
          }
        }
      }]
    }, {
      "width": 330,
      "height": 120,
      "mark": "bar",
      "params": [{
        "name": "pts",
        "select": {"type": "point", "encodings": ["x"]}
      }],
      "encoding": {
        "x": {"field": "Major Genre", "axis": {"labelAngle": -40}},
        "y": {"aggregate": "count"},
        "color": {
          "condition": {
            "param": "pts",
            "value": "steelblue"
          },
          "value": "grey"
        }
      }
    }
  ],
  "resolve": {
    "legend": {
      "color": "independent",
      "size": "independent"
    }
  }
}
""")
    }

    func test_interactive_global_development() throws {
        try check(viz: Graphiq {
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

    func test_interactive_index_chart() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "url": "data/stocks.csv",
    "format": {"parse": {"date": "date"}}
  },
  "width": 650,
  "height": 300,
  "layer": [
    {
      "params": [{
        "name": "index",
        "value": [{"x": {"year": 2005, "month": 1, "date": 1}}],
        "select": {
          "type": "point",
          "encodings": ["x"],
          "on": "mouseover",
          "nearest": true
        }
      }],
      "mark": "point",
      "encoding": {
        "x": {"field": "date", "type": "temporal", "axis": null},
        "opacity": {"value": 0}
      }
    },
    {
      "transform": [
        {
          "lookup": "symbol",
          "from": {"param": "index", "key": "symbol"}
        },
        {
          "calculate": "datum.index && datum.index.price > 0 ? (datum.price - datum.index.price)/datum.index.price : 0",
          "as": "indexed_price"
        }
      ],
      "mark": "line",
      "encoding": {
        "x": {"field": "date", "type": "temporal", "axis": null},
        "y": {
          "field": "indexed_price", "type": "quantitative",
          "axis": {"format": "%"}
        },
        "color": {"field": "symbol", "type": "nominal"}
      }
    },
    {
      "transform": [{"filter": {"param": "index"}}],
      "encoding": {
        "x": {"field": "date", "type": "temporal", "axis": null},
        "color": {"value": "firebrick"}
      },
      "layer": [
        {"mark": {"type": "rule", "strokeWidth": 0.5}},
        {
          "mark": {"type": "text", "align": "center", "fontWeight": 100},
          "encoding": {
            "text": {"field": "date", "timeUnit": "yearmonth"},
            "y": {"value": 310}
          }
        }
      ]
    }
  ]
}
""")
    }

    func test_interactive_layered_crossfilter() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "url": "data/flights-2k.json",
    "format": {"parse": {"date": "date"}}
  },
  "transform": [{"calculate": "hours(datum.date)", "as": "time"}],
  "repeat": {"column": ["distance", "delay", "time"]},
  "spec": {
    "layer": [{
      "params": [{
        "name": "brush",
        "select": {"type": "interval", "encodings": ["x"]}
      }],
      "mark": "bar",
      "encoding": {
        "x": {
          "field": {"repeat": "column"},
          "bin": {"maxbins": 20}
        },
        "y": {"aggregate": "count"},
        "color": {"value": "#ddd"}
      }
    }, {
      "transform": [{"filter": {"param": "brush"}}],
      "mark": "bar",
      "encoding": {
        "x": {
          "field": {"repeat": "column"},
          "bin": {"maxbins": 20}
        },
        "y": {"aggregate": "count"}
      }
    }]
  }
}
""")
    }

    func test_interactive_legend() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "width": 300, "height": 200,
  "data": {"url": "data/unemployment-across-industries.json"},
  "mark": "area",
  "params": [{
    "name": "industry",
    "select": {"type": "point", "fields": ["series"]},
    "bind": "legend"
  }],
  "encoding": {
    "x": {
      "timeUnit": "yearmonth", "field": "date",
      "axis": {"domain": false, "format": "%Y", "tickSize": 0}
    },
    "y": {
      "aggregate": "sum", "field": "count",
      "stack": "center", "axis": null
    },
    "color": {
      "field":"series",
      "scale": {"scheme": "category20b"}
    },
    "opacity": {
      "condition": {"param": "industry", "value": 1},
      "value": 0.2
    }
  }
}
""")
    }

    func test_interactive_line_hover() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Multi-series line chart with labels and interactive highlight on hover.  We also set the selection's initial value to provide a better screenshot",
  "data": {"url": "data/stocks.csv"},
  "transform": [{"filter": "datum.symbol!=='IBM'"}],
  "encoding": {
    "x": {"field": "date", "type": "temporal", "title": "date"},
    "y": {"field": "price", "type": "quantitative", "title": "price"},
    "color": {
      "condition": {
        "param": "hover",
        "field":"symbol",
        "type":"nominal",
        "legend": null
      },
      "value": "grey"
    },
    "opacity": {
      "condition": {
        "param": "hover",
        "value": 1
      },
      "value": 0.2
    }
  },
  "layer": [{
    "description": "transparent layer to make it easier to trigger selection",
    "params": [{
      "name": "hover",
      "value": [{"symbol": "AAPL"}],
      "select": {
        "type": "point",
        "fields": ["symbol"],
        "on": "mouseover"
      }
    }],
    "mark": {"type": "line", "strokeWidth": 8, "stroke": "transparent"}
  }, {
    "mark": "line"
  }, {
    "encoding": {
      "x": {"aggregate": "max", "field": "date"},
      "y": {"aggregate": {"argmax": "date"}, "field": "price"}
    },
    "layer": [{
      "mark": {"type": "circle"}
    }, {
      "mark": {"type": "text", "align": "left", "dx": 4},
      "encoding": {"text": {"field":"symbol", "type": "nominal"}}
    }]
  }],
  "config": {"view": {"stroke": null}}
}
""")
    }

    func test_interactive_multi_line_label() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "url": "data/stocks.csv"
  },
  "width": 400,
  "height": 300,
  "layer": [
    {
      "encoding": {
        "x": {"field": "date", "type": "temporal"},
        "y": {"field": "price", "type": "quantitative"},
        "color": {"field": "symbol", "type": "nominal"}
      },
      "layer": [
        {"mark": "line"},
        {
          "params": [{
            "name": "label",
            "select": {
              "type": "point",
              "encodings": ["x"],
              "nearest": true,
              "on": "mouseover"
            }
          }],
          "mark": "point",
          "encoding": {
            "opacity": {
              "condition": {
                "param": "label",
                "empty": false,
                "value": 1
              },
              "value": 0
            }
          }
        }
      ]
    },
    {
      "transform": [{"filter": {"param": "label", "empty": false}}],
      "layer": [
        {
          "mark": {"type": "rule", "color": "gray"},
          "encoding": {
            "x": {"type": "temporal", "field": "date", "aggregate": "min"}
          }
        },
        {
          "encoding": {
            "text": {"type": "quantitative", "field": "price"},
            "x": {"type": "temporal", "field": "date"},
            "y": {"type": "quantitative", "field": "price"}
          },
          "layer": [
            {
              "mark": {
                "type": "text",
                "stroke": "white",
                "strokeWidth": 2,
                "align": "left",
                "dx": 5,
                "dy": -5
              }
            },
            {
              "mark": {"type": "text", "align": "left", "dx": 5, "dy": -5},
              "encoding": {
                "color": {"type": "nominal", "field": "symbol"}
              }
            }
          ]
        }
      ]
    }
  ]
}
""")
    }

    func test_interactive_multi_line_pivot_tooltip() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/stocks.csv"},
  "width": 400,
  "height": 300,
  "encoding": {"x": {"field": "date", "type": "temporal"}},
  "layer": [
    {
      "encoding": {
        "color": {"field": "symbol", "type": "nominal"},
        "y": {"field": "price", "type": "quantitative"}
      },
      "layer": [
        {"mark": "line"},
        {"transform": [{"filter": {"param": "hover", "empty": false}}], "mark": "point"}
      ]
    },
    {
      "transform": [{"pivot": "symbol", "value": "price", "groupby": ["date"]}],
      "mark": "rule",
      "encoding": {
        "opacity": {
          "condition": {"value": 0.3, "param": "hover", "empty": false},
          "value": 0
        },
        "tooltip": [
          {"field": "AAPL", "type": "quantitative"},
          {"field": "AMZN", "type": "quantitative"},
          {"field": "GOOG", "type": "quantitative"},
          {"field": "IBM", "type": "quantitative"},
          {"field": "MSFT", "type": "quantitative"}
        ]
      },
      "params": [{
        "name": "hover",
        "select": {
          "type": "point",
          "fields": ["date"],
          "nearest": true,
          "on": "mouseover",
          "clear": "mouseout"
        }
      }]
    }
  ]
}
""")
    }

    func test_interactive_multi_line_tooltip() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/seattle-weather.csv"},
  "encoding": {
    "x": {"timeUnit": "yearmonthdate", "field": "date"},
    "tooltip": [
      {"timeUnit": "yearmonthdate", "field": "date"},
      {"field": "temp_max", "type": "quantitative"},
      {"field": "temp_min", "type": "quantitative"}
    ]
  },
  "layer": [{
    "mark": {"type": "line", "color": "orange"},
    "encoding": {
      "y": {"field": "temp_max", "type": "quantitative"}
    }
  }, {
    "mark": {"type": "line", "color": "red"},
    "encoding": {
      "y": {"field": "temp_min", "type": "quantitative"}
    }
  }, {
    "mark": "rule",
    "params": [{
      "name": "hover",
      "select": {"type": "point", "on": "mouseover"}
    }],
    "encoding": {
      "color": {
        "condition": {
          "param": "hover",
          "empty": false,
          "value": "black"
        },
        "value": "transparent"
      }
    }
  }],
  "config": {"axisY": {"minExtent": 30}}
}
""")
    }

    func test_interactive_overview_detail() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/sp500.csv"},
  "vconcat": [{
    "width": 480,
    "mark": "area",
    "encoding": {
      "x": {
        "field": "date",
        "type": "temporal",
        "scale": {"domain": {"param": "brush"}},
        "axis": {"title": ""}
      },
      "y": {"field": "price", "type": "quantitative"}
    }
  }, {
    "width": 480,
    "height": 60,
    "mark": "area",
    "params": [{
      "name": "brush",
      "select": {"type": "interval", "encodings": ["x"]}
    }],
    "encoding": {
      "x": {
        "field": "date",
        "type": "temporal"
      },
      "y": {
        "field": "price",
        "type": "quantitative",
        "axis": {"tickCount": 3, "grid": false}
      }
    }
  }]
}
""")
    }

    func test_interactive_paintbrush() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Select multiple points with the shift key.",
  "data": {"url": "data/cars.json"},
  "params": [{
    "name": "paintbrush",
    "select": {"type": "point", "on": "mouseover", "nearest": true}
  }],
  "mark": "point",
  "encoding": {
    "x": {"field": "Horsepower", "type": "quantitative"},
    "y": {"field": "Miles_per_Gallon", "type": "quantitative"},
    "size": {
      "condition": {"param": "paintbrush", "value": 300},
      "value": 50
    }
  }
}
""")
    }

    func test_interactive_query_widgets() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Drag the sliders to highlight points.",
  "data": {"url": "data/cars.json"},
  "transform": [{"calculate": "year(datum.Year)", "as": "Year"}],
  "layer": [{
    "params": [{
      "name": "CylYr",
      "value": [{"Cylinders": 4, "Year": 1977}],
      "select": {"type": "point", "fields": ["Cylinders", "Year"]},
      "bind": {
        "Cylinders": {"input": "range", "min": 3, "max": 8, "step": 1},
        "Year": {"input": "range", "min": 1969, "max": 1981, "step": 1}
      }
    }],
    "mark": "circle",
    "encoding": {
      "x": {"field": "Horsepower", "type": "quantitative"},
      "y": {"field": "Miles_per_Gallon", "type": "quantitative"},
      "color": {
        "condition": {"param": "CylYr", "field": "Origin", "type": "nominal"},
        "value": "grey"
      }
    }
  }, {
    "transform": [{"filter": {"param": "CylYr"}}],
    "mark": "circle",
    "encoding": {
      "x": {"field": "Horsepower", "type": "quantitative"},
      "y": {"field": "Miles_per_Gallon", "type": "quantitative"},
      "color": {"field": "Origin", "type": "nominal"},
      "size": {"value": 100}
    }
  }]
}
""")
    }

    func test_interactive_seattle_weather() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "title": "Seattle Weather, 2012-2015",
  "data": {
    "url": "data/seattle-weather.csv"
  },
  "vconcat": [
    {
      "encoding": {
        "color": {
          "condition": {
            "param": "brush",
            "title": "Weather",
            "field": "weather",
            "type": "nominal",
            "scale": {
              "domain": ["sun", "fog", "drizzle", "rain", "snow"],
              "range": ["#e7ba52", "#a7a7a7", "#aec7e8", "#1f77b4", "#9467bd"]
            }
          },
          "value": "lightgray"
        },
        "size": {
          "title": "Precipitation",
          "field": "precipitation",
          "scale": {"domain": [-1, 50]},
          "type": "quantitative"
        },
        "x": {
          "field": "date",
          "timeUnit": "monthdate",
          "title": "Date",
          "axis": {"format": "%b"}
        },
        "y": {
          "title": "Maximum Daily Temperature (C)",
          "field": "temp_max",
          "scale": {"domain": [-5, 40]},
          "type": "quantitative"
        }
      },
      "width": 600,
      "height": 300,
      "mark": "point",
      "params": [{
        "name": "brush",
        "select": {"type": "interval", "encodings": ["x"]}
      }],
      "transform": [{"filter": {"param": "click"}}]
    },
    {
      "encoding": {
        "color": {
          "condition": {
            "param": "click",
            "field": "weather",
            "scale": {
              "domain": ["sun", "fog", "drizzle", "rain", "snow"],
              "range": ["#e7ba52", "#a7a7a7", "#aec7e8", "#1f77b4", "#9467bd"]
            }
          },
          "value": "lightgray"
        },
        "x": {"aggregate": "count"},
        "y": {"title": "Weather", "field": "weather"}
      },
      "width": 600,
      "mark": "bar",
      "params": [{
        "name": "click",
        "select": {"type": "point", "encodings": ["color"]}
      }],
      "transform": [{"filter": {"param": "brush"}}]
    }
  ]
}

""")
    }

    func test_interactive_splom() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "repeat": {
    "row": ["Horsepower", "Acceleration", "Miles_per_Gallon"],
    "column": ["Miles_per_Gallon", "Acceleration", "Horsepower"]
  },
  "spec": {
    "data": {"url": "data/cars.json"},
    "mark": "point",
    "params": [
      {
        "name": "brush",
        "select": {
          "type": "interval",
          "resolve": "union",
          "on": "[mousedown[event.shiftKey], window:mouseup] > window:mousemove!",
          "translate": "[mousedown[event.shiftKey], window:mouseup] > window:mousemove!",
          "zoom": "wheel![event.shiftKey]"
        }
      },
      {
        "name": "grid",
        "select": {
          "type": "interval",
          "resolve": "global",
          "translate": "[mousedown[!event.shiftKey], window:mouseup] > window:mousemove!",
          "zoom": "wheel![!event.shiftKey]"
        },
        "bind": "scales"
      }
    ],
    "encoding": {
      "x": {"field": {"repeat": "column"}, "type": "quantitative"},
      "y": {
        "field": {"repeat": "row"},
        "type": "quantitative",
        "axis": {"minExtent": 30}
      },
      "color": {
        "condition": {
          "param": "brush",
          "field": "Origin",
          "type": "nominal"
        },
        "value": "grey"
      }
    }
  }
}
""")
    }

    func test_isotype_bar_chart() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "config": {"view": {"stroke": ""}},
  "width": 800,
  "height": 200,
  "data": {
    "values": [
      {"country": "Great Britain", "animal": "cattle", "col": 3},
      {"country": "Great Britain", "animal": "cattle", "col": 2},
      {"country": "Great Britain", "animal": "cattle", "col": 1},
      {"country": "Great Britain", "animal": "pigs", "col": 2},
      {"country": "Great Britain", "animal": "pigs", "col": 1},
      {"country": "Great Britain", "animal": "sheep", "col": 10},
      {"country": "Great Britain", "animal": "sheep", "col": 9},
      {"country": "Great Britain", "animal": "sheep", "col": 8},
      {"country": "Great Britain", "animal": "sheep", "col": 7},
      {"country": "Great Britain", "animal": "sheep", "col": 6},
      {"country": "Great Britain", "animal": "sheep", "col": 5},
      {"country": "Great Britain", "animal": "sheep", "col": 4},
      {"country": "Great Britain", "animal": "sheep", "col": 3},
      {"country": "Great Britain", "animal": "sheep", "col": 2},
      {"country": "Great Britain", "animal": "sheep", "col": 1},
      {"country": "United States", "animal": "cattle", "col": 9},
      {"country": "United States", "animal": "cattle", "col": 8},
      {"country": "United States", "animal": "cattle", "col": 7},
      {"country": "United States", "animal": "cattle", "col": 6},
      {"country": "United States", "animal": "cattle", "col": 5},
      {"country": "United States", "animal": "cattle", "col": 4},
      {"country": "United States", "animal": "cattle", "col": 3},
      {"country": "United States", "animal": "cattle", "col": 2},
      {"country": "United States", "animal": "cattle", "col": 1},
      {"country": "United States", "animal": "pigs", "col": 6},
      {"country": "United States", "animal": "pigs", "col": 5},
      {"country": "United States", "animal": "pigs", "col": 4},
      {"country": "United States", "animal": "pigs", "col": 3},
      {"country": "United States", "animal": "pigs", "col": 2},
      {"country": "United States", "animal": "pigs", "col": 1},
      {"country": "United States", "animal": "sheep", "col": 7},
      {"country": "United States", "animal": "sheep", "col": 6},
      {"country": "United States", "animal": "sheep", "col": 5},
      {"country": "United States", "animal": "sheep", "col": 4},
      {"country": "United States", "animal": "sheep", "col": 3},
      {"country": "United States", "animal": "sheep", "col": 2},
      {"country": "United States", "animal": "sheep", "col": 1}
    ]
  },
  "mark": {"type": "point", "filled": true},
  "encoding": {
    "x": {"field": "col", "type": "ordinal", "axis": null},
    "y": {"field": "animal", "type": "ordinal", "axis": null},
    "row": {"field": "country", "header": {"title": ""}},
    "shape": {
      "field": "animal",
      "type": "nominal",
      "scale": {
        "domain": ["person", "cattle", "pigs", "sheep"],
        "range": [
          "M1.7 -1.7h-0.8c0.3 -0.2 0.6 -0.5 0.6 -0.9c0 -0.6 -0.4 -1 -1 -1c-0.6 0 -1 0.4 -1 1c0 0.4 0.2 0.7 0.6 0.9h-0.8c-0.4 0 -0.7 0.3 -0.7 0.6v1.9c0 0.3 0.3 0.6 0.6 0.6h0.2c0 0 0 0.1 0 0.1v1.9c0 0.3 0.2 0.6 0.3 0.6h1.3c0.2 0 0.3 -0.3 0.3 -0.6v-1.8c0 0 0 -0.1 0 -0.1h0.2c0.3 0 0.6 -0.3 0.6 -0.6v-2c0.2 -0.3 -0.1 -0.6 -0.4 -0.6z",
          "M4 -2c0 0 0.9 -0.7 1.1 -0.8c0.1 -0.1 -0.1 0.5 -0.3 0.7c-0.2 0.2 1.1 1.1 1.1 1.2c0 0.2 -0.2 0.8 -0.4 0.7c-0.1 0 -0.8 -0.3 -1.3 -0.2c-0.5 0.1 -1.3 1.6 -1.5 2c-0.3 0.4 -0.6 0.4 -0.6 0.4c0 0.1 0.3 1.7 0.4 1.8c0.1 0.1 -0.4 0.1 -0.5 0c0 0 -0.6 -1.9 -0.6 -1.9c-0.1 0 -0.3 -0.1 -0.3 -0.1c0 0.1 -0.5 1.4 -0.4 1.6c0.1 0.2 0.1 0.3 0.1 0.3c0 0 -0.4 0 -0.4 0c0 0 -0.2 -0.1 -0.1 -0.3c0 -0.2 0.3 -1.7 0.3 -1.7c0 0 -2.8 -0.9 -2.9 -0.8c-0.2 0.1 -0.4 0.6 -0.4 1c0 0.4 0.5 1.9 0.5 1.9l-0.5 0l-0.6 -2l0 -0.6c0 0 -1 0.8 -1 1c0 0.2 -0.2 1.3 -0.2 1.3c0 0 0.3 0.3 0.2 0.3c0 0 -0.5 0 -0.5 0c0 0 -0.2 -0.2 -0.1 -0.4c0 -0.1 0.2 -1.6 0.2 -1.6c0 0 0.5 -0.4 0.5 -0.5c0 -0.1 0 -2.7 -0.2 -2.7c-0.1 0 -0.4 2 -0.4 2c0 0 0 0.2 -0.2 0.5c-0.1 0.4 -0.2 1.1 -0.2 1.1c0 0 -0.2 -0.1 -0.2 -0.2c0 -0.1 -0.1 -0.7 0 -0.7c0.1 -0.1 0.3 -0.8 0.4 -1.4c0 -0.6 0.2 -1.3 0.4 -1.5c0.1 -0.2 0.6 -0.4 0.6 -0.4z",
          "M1.2 -2c0 0 0.7 0 1.2 0.5c0.5 0.5 0.4 0.6 0.5 0.6c0.1 0 0.7 0 0.8 0.1c0.1 0 0.2 0.2 0.2 0.2c0 0 -0.6 0.2 -0.6 0.3c0 0.1 0.4 0.9 0.6 0.9c0.1 0 0.6 0 0.6 0.1c0 0.1 0 0.7 -0.1 0.7c-0.1 0 -1.2 0.4 -1.5 0.5c-0.3 0.1 -1.1 0.5 -1.1 0.7c-0.1 0.2 0.4 1.2 0.4 1.2l-0.4 0c0 0 -0.4 -0.8 -0.4 -0.9c0 -0.1 -0.1 -0.3 -0.1 -0.3l-0.2 0l-0.5 1.3l-0.4 0c0 0 -0.1 -0.4 0 -0.6c0.1 -0.1 0.3 -0.6 0.3 -0.7c0 0 -0.8 0 -1.5 -0.1c-0.7 -0.1 -1.2 -0.3 -1.2 -0.2c0 0.1 -0.4 0.6 -0.5 0.6c0 0 0.3 0.9 0.3 0.9l-0.4 0c0 0 -0.4 -0.5 -0.4 -0.6c0 -0.1 -0.2 -0.6 -0.2 -0.5c0 0 -0.4 0.4 -0.6 0.4c-0.2 0.1 -0.4 0.1 -0.4 0.1c0 0 -0.1 0.6 -0.1 0.6l-0.5 0l0 -1c0 0 0.5 -0.4 0.5 -0.5c0 -0.1 -0.7 -1.2 -0.6 -1.4c0.1 -0.1 0.1 -1.1 0.1 -1.1c0 0 -0.2 0.1 -0.2 0.1c0 0 0 0.9 0 1c0 0.1 -0.2 0.3 -0.3 0.3c-0.1 0 0 -0.5 0 -0.9c0 -0.4 0 -0.4 0.2 -0.6c0.2 -0.2 0.6 -0.3 0.8 -0.8c0.3 -0.5 1 -0.6 1 -0.6z",
          "M-4.1 -0.5c0.2 0 0.2 0.2 0.5 0.2c0.3 0 0.3 -0.2 0.5 -0.2c0.2 0 0.2 0.2 0.4 0.2c0.2 0 0.2 -0.2 0.5 -0.2c0.2 0 0.2 0.2 0.4 0.2c0.2 0 0.2 -0.2 0.4 -0.2c0.1 0 0.2 0.2 0.4 0.1c0.2 0 0.2 -0.2 0.4 -0.3c0.1 0 0.1 -0.1 0.4 0c0.3 0 0.3 -0.4 0.6 -0.4c0.3 0 0.6 -0.3 0.7 -0.2c0.1 0.1 1.4 1 1.3 1.4c-0.1 0.4 -0.3 0.3 -0.4 0.3c-0.1 0 -0.5 -0.4 -0.7 -0.2c-0.3 0.2 -0.1 0.4 -0.2 0.6c-0.1 0.1 -0.2 0.2 -0.3 0.4c0 0.2 0.1 0.3 0 0.5c-0.1 0.2 -0.3 0.2 -0.3 0.5c0 0.3 -0.2 0.3 -0.3 0.6c-0.1 0.2 0 0.3 -0.1 0.5c-0.1 0.2 -0.1 0.2 -0.2 0.3c-0.1 0.1 0.3 1.1 0.3 1.1l-0.3 0c0 0 -0.3 -0.9 -0.3 -1c0 -0.1 -0.1 -0.2 -0.3 -0.2c-0.2 0 -0.3 0.1 -0.4 0.4c0 0.3 -0.2 0.8 -0.2 0.8l-0.3 0l0.3 -1c0 0 0.1 -0.6 -0.2 -0.5c-0.3 0.1 -0.2 -0.1 -0.4 -0.1c-0.2 -0.1 -0.3 0.1 -0.4 0c-0.2 -0.1 -0.3 0.1 -0.5 0c-0.2 -0.1 -0.1 0 -0.3 0.3c-0.2 0.3 -0.4 0.3 -0.4 0.3l0.2 1.1l-0.3 0l-0.2 -1.1c0 0 -0.4 -0.6 -0.5 -0.4c-0.1 0.3 -0.1 0.4 -0.3 0.4c-0.1 -0.1 -0.2 1.1 -0.2 1.1l-0.3 0l0.2 -1.1c0 0 -0.3 -0.1 -0.3 -0.5c0 -0.3 0.1 -0.5 0.1 -0.7c0.1 -0.2 -0.1 -1 -0.2 -1.1c-0.1 -0.2 -0.2 -0.8 -0.2 -0.8c0 0 -0.1 -0.5 0.4 -0.8z"
        ]
      },
      "legend": null
    },
    "color": {
      "field": "animal",
      "type": "nominal",
      "legend": null,
      "scale": {
        "domain": ["person", "cattle", "pigs", "sheep"],
        "range": [
          "rgb(162,160,152)",
          "rgb(194,81,64)",
          "rgb(93,93,93)",
          "rgb(91,131,149)"
        ]
      }
    },
    "opacity": {"value": 1},
    "size": {"value": 200}
  }
}
""")
    }

    func test_isotype_bar_chart_emoji() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "config": {"view": {"stroke": ""}},
  "width": 800,
  "height": 200,
  "data": {
    "values": [
      {"country": "Great Britain", "animal": "pigs"},
      {"country": "Great Britain", "animal": "pigs"},
      {"country": "Great Britain", "animal": "cattle"},
      {"country": "Great Britain", "animal": "cattle"},
      {"country": "Great Britain", "animal": "cattle"},
      {"country": "Great Britain", "animal": "sheep"},
      {"country": "Great Britain", "animal": "sheep"},
      {"country": "Great Britain", "animal": "sheep"},
      {"country": "Great Britain", "animal": "sheep"},
      {"country": "Great Britain", "animal": "sheep"},
      {"country": "Great Britain", "animal": "sheep"},
      {"country": "Great Britain", "animal": "sheep"},
      {"country": "Great Britain", "animal": "sheep"},
      {"country": "Great Britain", "animal": "sheep"},
      {"country": "Great Britain", "animal": "sheep"},
      {"country": "United States", "animal": "pigs"},
      {"country": "United States", "animal": "pigs"},
      {"country": "United States", "animal": "pigs"},
      {"country": "United States", "animal": "pigs"},
      {"country": "United States", "animal": "pigs"},
      {"country": "United States", "animal": "pigs"},
      {"country": "United States", "animal": "cattle"},
      {"country": "United States", "animal": "cattle"},
      {"country": "United States", "animal": "cattle"},
      {"country": "United States", "animal": "cattle"},
      {"country": "United States", "animal": "cattle"},
      {"country": "United States", "animal": "cattle"},
      {"country": "United States", "animal": "cattle"},
      {"country": "United States", "animal": "cattle"},
      {"country": "United States", "animal": "cattle"},
      {"country": "United States", "animal": "sheep"},
      {"country": "United States", "animal": "sheep"},
      {"country": "United States", "animal": "sheep"},
      {"country": "United States", "animal": "sheep"},
      {"country": "United States", "animal": "sheep"},
      {"country": "United States", "animal": "sheep"},
      {"country": "United States", "animal": "sheep"}
    ]
  },
  "transform": [
    {
      "calculate": "{'cattle': '🐄', 'pigs': '🐖', 'sheep': '🐏'}[datum.animal]",
      "as": "emoji"
    },
    {"window": [{"op": "rank", "as": "rank"}], "groupby": ["country", "animal"]}
  ],
  "mark": {"type": "text", "baseline": "middle"},
  "encoding": {
    "x": {"field": "rank", "type": "ordinal", "axis": null},
    "y": {"field": "animal", "type": "nominal", "axis": null, "sort": null},
    "row": {"field": "country", "header": {"title": ""}},
    "text": {"field": "emoji", "type": "nominal"},
    "size": {"value": 65}
  }
}
""")
    }

    func test_isotype_grid() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "config": {"view": {"stroke": ""}},
  "width": 400,
  "height": 400,
  "data": {
    "values": [
      {"id": 1},
      {"id": 2},
      {"id": 3},
      {"id": 4},
      {"id": 5},
      {"id": 6},
      {"id": 7},
      {"id": 8},
      {"id": 9},
      {"id": 10},
      {"id": 11},
      {"id": 12},
      {"id": 13},
      {"id": 14},
      {"id": 15},
      {"id": 16},
      {"id": 17},
      {"id": 18},
      {"id": 19},
      {"id": 20},
      {"id": 21},
      {"id": 22},
      {"id": 23},
      {"id": 24},
      {"id": 25},
      {"id": 26},
      {"id": 27},
      {"id": 28},
      {"id": 29},
      {"id": 30},
      {"id": 31},
      {"id": 32},
      {"id": 33},
      {"id": 34},
      {"id": 35},
      {"id": 36},
      {"id": 37},
      {"id": 38},
      {"id": 39},
      {"id": 40},
      {"id": 41},
      {"id": 42},
      {"id": 43},
      {"id": 44},
      {"id": 45},
      {"id": 46},
      {"id": 47},
      {"id": 48},
      {"id": 49},
      {"id": 50},
      {"id": 51},
      {"id": 52},
      {"id": 53},
      {"id": 54},
      {"id": 55},
      {"id": 56},
      {"id": 57},
      {"id": 58},
      {"id": 59},
      {"id": 60},
      {"id": 61},
      {"id": 62},
      {"id": 63},
      {"id": 64},
      {"id": 65},
      {"id": 66},
      {"id": 67},
      {"id": 68},
      {"id": 69},
      {"id": 70},
      {"id": 71},
      {"id": 72},
      {"id": 73},
      {"id": 74},
      {"id": 75},
      {"id": 76},
      {"id": 77},
      {"id": 78},
      {"id": 79},
      {"id": 80},
      {"id": 81},
      {"id": 82},
      {"id": 83},
      {"id": 84},
      {"id": 85},
      {"id": 86},
      {"id": 87},
      {"id": 88},
      {"id": 89},
      {"id": 90},
      {"id": 91},
      {"id": 92},
      {"id": 93},
      {"id": 94},
      {"id": 95},
      {"id": 96},
      {"id": 97},
      {"id": 98},
      {"id": 99},
      {"id": 100}
    ]
  },
  "transform": [
    {"calculate": "ceil (datum.id/10)", "as": "col"},
    {"calculate": "datum.id - datum.col*10", "as": "row"}
  ],
  "mark": {"type": "point", "filled": true},
  "encoding": {
    "x": {"field": "col", "type": "ordinal", "axis": null},
    "y": {"field": "row", "type": "ordinal", "axis": null},
    "shape": {
      "value": "M1.7 -1.7h-0.8c0.3 -0.2 0.6 -0.5 0.6 -0.9c0 -0.6 -0.4 -1 -1 -1c-0.6 0 -1 0.4 -1 1c0 0.4 0.2 0.7 0.6 0.9h-0.8c-0.4 0 -0.7 0.3 -0.7 0.6v1.9c0 0.3 0.3 0.6 0.6 0.6h0.2c0 0 0 0.1 0 0.1v1.9c0 0.3 0.2 0.6 0.3 0.6h1.3c0.2 0 0.3 -0.3 0.3 -0.6v-1.8c0 0 0 -0.1 0 -0.1h0.2c0.3 0 0.6 -0.3 0.6 -0.6v-2c0.2 -0.3 -0.1 -0.6 -0.4 -0.6z"
    },
    "color": {
      "condition": {"param": "highlight", "value": "rgb(194,81,64)"},
      "value": "rgb(167,165,156)"
    },
    "size": {"value": 90}
  },
  "params": [{"name": "highlight", "select": "interval"}]
}
""")
    }

    func test_joinaggregate_mean_difference() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/movies.json"},
  "transform": [
    {"filter": "datum['IMDB Rating'] != null"},
    {
      "joinaggregate": [{
        "op": "mean",
        "field": "IMDB Rating",
        "as": "AverageRating"
      }]
    },
    {"filter": "(datum['IMDB Rating'] - datum.AverageRating) > 2.5"}
  ],
  "layer": [
    {
      "mark": "bar",
      "encoding": {
        "x": {
          "field": "IMDB Rating", "type": "quantitative",
          "title": "IMDB Rating"
        },
        "y": {"field": "Title", "type": "ordinal"}
      }
    },
    {
      "mark": {"type": "rule", "color": "red"},
      "encoding": {
        "x": {
          "aggregate": "average",
          "field": "AverageRating",
          "type": "quantitative"
        }
      }
    }
  ]
}
""")
    }

    func test_joinaggregate_mean_difference_by_year() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Bar graph showing the best films for the year they were produced, where best is defined by at least 2.5 points above average for that year. The red point shows the average rating for a film in that year, and the bar is the rating that the film recieved.",
  "data": {
    "url": "data/movies.json"
  },
  "transform": [
      {"filter": "datum['IMDB Rating'] != null"},
      {"timeUnit": "year", "field": "Release Date", "as": "year"},
      {
        "joinaggregate": [{
          "op": "mean",
          "field": "IMDB Rating",
          "as": "AverageYearRating"
        }],
        "groupby": [
          "year"
        ]
      },
      {
        "filter": "(datum['IMDB Rating'] - datum.AverageYearRating) > 2.5"
      }
  ],
  "layer": [{
      "mark": {"type": "bar", "clip": true},
      "encoding": {
        "x": {
          "field": "IMDB Rating",
          "type": "quantitative",
          "title": "IMDB Rating"
        },
        "y": {
          "field": "Title",
          "type": "ordinal"
        }
      }
    },
    {
      "mark": "tick",
      "encoding": {
        "x": {
          "field": "AverageYearRating",
          "type": "quantitative"
        },
        "y": {
          "field": "Title",
          "type": "ordinal"
        },
        "color": {"value": "red"}
      }
    }
  ]
}
""")
    }

    func test_joinaggregate_residual_graph() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A dot plot showing each movie in the database, and the difference from the average movie rating. The display is sorted by year to visualize everything in sequential order. The graph is for all Movies before 2019.",
  "data": {
    "url": "data/movies.json"
  },
  "transform": [
    {"filter": "datum['IMDB Rating'] != null"},
    {"filter": {"timeUnit": "year", "field": "Release Date", "range": [null, 2019]}},
    {
      "joinaggregate": [{
        "op": "mean",
        "field": "IMDB Rating",
        "as": "AverageRating"
      }]
    },
    {
      "calculate": "datum['IMDB Rating'] - datum.AverageRating",
      "as": "RatingDelta"
    }
  ],
  "mark": "point",
  "encoding": {
    "x": {
      "field": "Release Date",
      "type": "temporal"
    },
    "y": {
      "field": "RatingDelta",
      "type": "quantitative",
      "title": "Rating Delta"
    },
    "color": {
      "field": "RatingDelta",
      "type": "quantitative",
      "scale": {"domainMid": 0},
      "title": "Rating Delta"
    }
  }
}
""")
    }

    func test_layer_arc_label() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A simple pie chart with labels.",
  "data": {
    "values": [
      {"category": "a", "value": 4},
      {"category": "b", "value": 6},
      {"category": "c", "value": 10},
      {"category": "d", "value": 3},
      {"category": "e", "value": 7},
      {"category": "f", "value": 8}
    ]
  },
  "encoding": {
    "theta": {"field": "value", "type": "quantitative", "stack": true},
    "color": {"field": "category", "type": "nominal", "legend": null}
  },
  "layer": [{
    "mark": {"type": "arc", "outerRadius": 80}
  }, {
    "mark": {"type": "text", "radius": 90},
    "encoding": {
      "text": {"field": "category", "type": "nominal"}
    }
  }],
  "view": {"stroke": null}
}
""")
    }

    func test_layer_bar_annotations() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "The PM2.5 value of Beijing observed 15 days, highlighting the days when PM2.5 level is hazardous to human health. Data source https://chartaccent.github.io/chartaccent.html",
    "layer": [{
      "data": {
        "values": [
          {"Day": 1, "Value": 54.8},
          {"Day": 2, "Value": 112.1},
          {"Day": 3, "Value": 63.6},
          {"Day": 4, "Value": 37.6},
          {"Day": 5, "Value": 79.7},
          {"Day": 6, "Value": 137.9},
          {"Day": 7, "Value": 120.1},
          {"Day": 8, "Value": 103.3},
          {"Day": 9, "Value": 394.8},
          {"Day": 10, "Value": 199.5},
          {"Day": 11, "Value": 72.3},
          {"Day": 12, "Value": 51.1},
          {"Day": 13, "Value": 112.0},
          {"Day": 14, "Value": 174.5},
          {"Day": 15, "Value": 130.5}
        ]
      },
      "layer": [{
        "mark": "bar",
        "encoding": {
          "x": {"field": "Day", "type": "ordinal", "axis": {"labelAngle": 0}},
          "y": {"field": "Value", "type": "quantitative"}
        }
      }, {
        "mark": "bar",
        "transform": [
          {"filter": "datum.Value >= 300"},
          {"calculate": "300", "as": "baseline"}
        ],
        "encoding": {
          "x": {"field": "Day", "type": "ordinal"},
          "y": {"field": "baseline", "type": "quantitative", "title": "PM2.5 Value"},
          "y2": {"field": "Value"},
          "color": {"value": "#e45755"}
        }
      }
    ]}, {
      "data": {
         "values": [{}]
      },
      "encoding": {
        "y": {"datum": 300}
      },
      "layer": [{
        "mark": "rule"
      }, {
        "mark": {
          "type": "text",
          "align": "right",
          "baseline": "bottom",
          "dx": -2,
          "dy": -2,
          "x": "width",
          "text": "hazardous"
        }
      }]
    }
  ]
}
""")
    }

    func test_layer_bar_fruit() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Vega-Lite version of bar chart from https://observablehq.com/@d3/learn-d3-scales.",
  "width": 400,
  "data": {
    "values": [
      {"name": "🍊", "count": 21},
      {"name": "🍇", "count": 13},
      {"name": "🍏", "count": 8},
      {"name": "🍌", "count": 5},
      {"name": "🍐", "count": 3},
      {"name": "🍋", "count": 2},
      {"name": "🍎", "count": 1},
      {"name": "🍉", "count": 1}
    ]
  },
  "encoding": {
    "y": {"field": "name", "type": "nominal", "sort": "-x", "title": null},
    "x": {"field": "count", "type": "quantitative", "title": null}
  },
  "layer": [{
    "mark": "bar",
    "encoding": {
      "color": {
        "field": "count",
        "type": "quantitative",
        "title": "Number of fruit"
      }
    }
  }, {
    "mark": {
      "type": "text",
      "align": "right",
      "xOffset": -4,
      "aria": false
    },
    "encoding": {
      "text": {"field": "count", "type": "quantitative"},
      "color": {
        "condition": {
          "test": {"field": "count", "gt": 10},
          "value": "white"
        },
        "value": "black"
      }
    }
  }]
}
""")
    }

    func test_layer_bar_labels() throws {
        try check(viz: Graphiq {
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
        try check(viz: Graphiq {
        }, againstJSON: """
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

    func test_layer_candlestick() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "width": 400,
  "description": "A candlestick chart inspired by an example in Protovis (http://mbostock.github.io/protovis/ex/candlestick.html)",
  "data": {"url": "data/ohlc.json"},
  "encoding": {
    "x": {
      "field": "date",
      "type": "temporal",
      "title": "Date in 2009",
      "axis": {
        "format": "%m/%d",
        "labelAngle": -45,
        "title": "Date in 2009"
      }
    },
    "y": {
      "type": "quantitative",
      "scale": {"zero": false},
      "axis": {"title": "Price"}
    },
    "color": {
      "condition": {
        "test": "datum.open < datum.close",
        "value": "#06982d"
      },
      "value": "#ae1325"
    }
  },
  "layer": [
    {
      "mark": "rule",
      "encoding": {
        "y": {"field": "low"},
        "y2": {"field": "high"}
      }
    },
    {
      "mark": "bar",
      "encoding": {
        "y": {"field": "open"},
        "y2": {"field": "close"}
      }
    }
  ]
}

""")
    }

    func test_layer_cumulative_histogram() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/movies.json"},
  "transform": [{
    "bin": true,
    "field": "IMDB Rating",
    "as": "bin_IMDB_Rating"
  }, {
    "aggregate": [{"op": "count", "as": "count"}],
    "groupby": ["bin_IMDB_Rating", "bin_IMDB_Rating_end"]
  }, {
    "filter": "datum.bin_IMDB_Rating !== null"
  }, {
    "sort": [{"field": "bin_IMDB_Rating"}],
    "window": [{"op": "sum", "field": "count", "as": "Cumulative Count"}],
    "frame": [null, 0]
  }],
  "encoding": {
    "x": {
      "field": "bin_IMDB_Rating", "type": "quantitative",
      "scale": {"zero": false},
      "title": "IMDB Rating"
    },
    "x2": {"field": "bin_IMDB_Rating_end"}
  },
  "layer": [{
    "mark": "bar",
    "encoding": {
      "y": {"field": "Cumulative Count", "type": "quantitative"}
    }
  }, {
    "mark": {"type": "bar", "color": "yellow", "opacity": 0.5},
    "encoding": {
      "y": {"field": "count", "type": "quantitative"}
    }
  }]
}
""")
    }

    func test_layer_dual_axis() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A dual axis chart, created by setting y's scale resolution to `\"independent\"`",
  "width": 400, "height": 300,
  "data": {
    "url": "data/weather.csv"
  },
  "transform": [{"filter": "datum.location == \"Seattle\""}],
  "encoding": {
    "x": {
      "timeUnit": "month",
      "field": "date",
      "axis": {"format": "%b", "title": null}
    }
  },
  "layer": [
    {
      "mark": {"opacity": 0.3, "type": "area", "color": "#85C5A6"},
      "encoding": {
        "y": {
          "aggregate": "average",
          "field": "temp_max",
          "scale": {"domain": [0, 30]},
          "title": "Avg. Temperature (°C)",
          "axis": {"titleColor": "#85C5A6"}
        },

        "y2": {
          "aggregate": "average",
          "field": "temp_min"
        }
      }
    },
    {
      "mark": {"stroke": "#85A9C5", "type": "line", "interpolate": "monotone"},
      "encoding": {
        "y": {
          "aggregate": "average",
          "field": "precipitation",
          "title": "Precipitation (inches)",
          "axis": {"titleColor":"#85A9C5"}
        }
      }
    }
  ],
  "resolve": {"scale": {"y": "independent"}}
}
""")
    }

    func test_layer_falkensee() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "The population of the German city of Falkensee over time",
  "width": 500,
  "data": {
    "values": [
      {"year": "1875", "population": 1309},
      {"year": "1890", "population": 1558},
      {"year": "1910", "population": 4512},
      {"year": "1925", "population": 8180},
      {"year": "1933", "population": 15915},
      {"year": "1939", "population": 24824},
      {"year": "1946", "population": 28275},
      {"year": "1950", "population": 29189},
      {"year": "1964", "population": 29881},
      {"year": "1971", "population": 26007},
      {"year": "1981", "population": 24029},
      {"year": "1985", "population": 23340},
      {"year": "1989", "population": 22307},
      {"year": "1990", "population": 22087},
      {"year": "1991", "population": 22139},
      {"year": "1992", "population": 22105},
      {"year": "1993", "population": 22242},
      {"year": "1994", "population": 22801},
      {"year": "1995", "population": 24273},
      {"year": "1996", "population": 25640},
      {"year": "1997", "population": 27393},
      {"year": "1998", "population": 29505},
      {"year": "1999", "population": 32124},
      {"year": "2000", "population": 33791},
      {"year": "2001", "population": 35297},
      {"year": "2002", "population": 36179},
      {"year": "2003", "population": 36829},
      {"year": "2004", "population": 37493},
      {"year": "2005", "population": 38376},
      {"year": "2006", "population": 39008},
      {"year": "2007", "population": 39366},
      {"year": "2008", "population": 39821},
      {"year": "2009", "population": 40179},
      {"year": "2010", "population": 40511},
      {"year": "2011", "population": 40465},
      {"year": "2012", "population": 40905},
      {"year": "2013", "population": 41258},
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
""")
    }

    func test_layer_histogram_global_mean() throws {
        try check(viz: Graphiq {
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

    func test_layer_likert() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Likert Scale Ratings Distributions and Medians. (Figure 9 from @jhoffswell and @zcliu's ['Interactive Repair of Tables Extracted from PDF Documents on Mobile Devices'](https://idl.cs.washington.edu/files/2019-InteractiveTableRepair-CHI.pdf))",
  "datasets": {
    "medians": [
      {"name": "Identify Errors:", "median": 1.999976, "lo": "Easy", "hi": "Hard"},
      {"name": "Fix Errors:", "median": 2, "lo": "Easy", "hi": "Hard"},
      {"name": "Easier to Fix:", "median": 1.999969, "lo": "Toolbar", "hi": "Gesture"},
      {"name": "Faster to Fix:", "median": 2.500045, "lo": "Toolbar", "hi": "Gesture"},
      {"name": "Easier on Phone:", "median": 1.500022, "lo": "Toolbar", "hi": "Gesture"},
      {"name": "Easier on Tablet:", "median": 2.99998, "lo": "Toolbar", "hi": "Gesture"},
      {"name": "Device Preference:", "median": 4.500007, "lo": "Phone", "hi": "Tablet"}
    ],
    "values": [
      {"value": "P1", "name": "Participant ID", "id": "P1"},
      {"value": 2, "name": "Identify Errors:", "id": "P1"},
      {"value": 2, "name": "Fix Errors:", "id": "P1"},
      {"value": 3, "name": "Easier to Fix:", "id": "P1"},
      {"value": 4, "name": "Faster to Fix:", "id": "P1"},
      {"value": 2, "name": "Easier on Phone:", "id": "P1"},
      {"value": 5, "name": "Easier on Tablet:", "id": "P1"},
      {"value": 5, "name": "Device Preference:", "id": "P1"},
      {"value": 1, "name": "Tablet_First", "id": "P1"},
      {"value": 1, "name": "Toolbar_First", "id": "P1"},
      {"value": "P2", "name": "Participant ID", "id": "P2"},
      {"value": 2, "name": "Identify Errors:", "id": "P2"},
      {"value": 3, "name": "Fix Errors:", "id": "P2"},
      {"value": 4, "name": "Easier to Fix:", "id": "P2"},
      {"value": 5, "name": "Faster to Fix:", "id": "P2"},
      {"value": 5, "name": "Easier on Phone:", "id": "P2"},
      {"value": 5, "name": "Easier on Tablet:", "id": "P2"},
      {"value": 5, "name": "Device Preference:", "id": "P2"},
      {"value": 1, "name": "Tablet_First", "id": "P2"},
      {"value": 1, "name": "Toolbar_First", "id": "P2"},
      {"value": "P3", "name": "Participant ID", "id": "P3"},
      {"value": 2, "name": "Identify Errors:", "id": "P3"},
      {"value": 2, "name": "Fix Errors:", "id": "P3"},
      {"value": 2, "name": "Easier to Fix:", "id": "P3"},
      {"value": 1, "name": "Faster to Fix:", "id": "P3"},
      {"value": 2, "name": "Easier on Phone:", "id": "P3"},
      {"value": 1, "name": "Easier on Tablet:", "id": "P3"},
      {"value": 5, "name": "Device Preference:", "id": "P3"},
      {"value": 1, "name": "Tablet_First", "id": "P3"},
      {"value": 0, "name": "Toolbar_First", "id": "P3"},
      {"value": "P4", "name": "Participant ID", "id": "P4"},
      {"value": 3, "name": "Identify Errors:", "id": "P4"},
      {"value": 3, "name": "Fix Errors:", "id": "P4"},
      {"value": 2, "name": "Easier to Fix:", "id": "P4"},
      {"value": 2, "name": "Faster to Fix:", "id": "P4"},
      {"value": 4, "name": "Easier on Phone:", "id": "P4"},
      {"value": 1, "name": "Easier on Tablet:", "id": "P4"},
      {"value": 5, "name": "Device Preference:", "id": "P4"},
      {"value": 1, "name": "Tablet_First", "id": "P4"},
      {"value": 0, "name": "Toolbar_First", "id": "P4"},
      {"value": "P5", "name": "Participant ID", "id": "P5"},
      {"value": 2, "name": "Identify Errors:", "id": "P5"},
      {"value": 2, "name": "Fix Errors:", "id": "P5"},
      {"value": 4, "name": "Easier to Fix:", "id": "P5"},
      {"value": 4, "name": "Faster to Fix:", "id": "P5"},
      {"value": 4, "name": "Easier on Phone:", "id": "P5"},
      {"value": 5, "name": "Easier on Tablet:", "id": "P5"},
      {"value": 5, "name": "Device Preference:", "id": "P5"},
      {"value": 0, "name": "Tablet_First", "id": "P5"},
      {"value": 1, "name": "Toolbar_First", "id": "P5"},
      {"value": "P6", "name": "Participant ID", "id": "P6"},
      {"value": 1, "name": "Identify Errors:", "id": "P6"},
      {"value": 3, "name": "Fix Errors:", "id": "P6"},
      {"value": 3, "name": "Easier to Fix:", "id": "P6"},
      {"value": 4, "name": "Faster to Fix:", "id": "P6"},
      {"value": 4, "name": "Easier on Phone:", "id": "P6"},
      {"value": 4, "name": "Easier on Tablet:", "id": "P6"},
      {"value": 4, "name": "Device Preference:", "id": "P6"},
      {"value": 0, "name": "Tablet_First", "id": "P6"},
      {"value": 1, "name": "Toolbar_First", "id": "P6"},
      {"value": "P7", "name": "Participant ID", "id": "P7"},
      {"value": 2, "name": "Identify Errors:", "id": "P7"},
      {"value": 3, "name": "Fix Errors:", "id": "P7"},
      {"value": 4, "name": "Easier to Fix:", "id": "P7"},
      {"value": 5, "name": "Faster to Fix:", "id": "P7"},
      {"value": 3, "name": "Easier on Phone:", "id": "P7"},
      {"value": 2, "name": "Easier on Tablet:", "id": "P7"},
      {"value": 4, "name": "Device Preference:", "id": "P7"},
      {"value": 0, "name": "Tablet_First", "id": "P7"},
      {"value": 0, "name": "Toolbar_First", "id": "P7"},
      {"value": "P8", "name": "Participant ID", "id": "P8"},
      {"value": 3, "name": "Identify Errors:", "id": "P8"},
      {"value": 1, "name": "Fix Errors:", "id": "P8"},
      {"value": 2, "name": "Easier to Fix:", "id": "P8"},
      {"value": 4, "name": "Faster to Fix:", "id": "P8"},
      {"value": 2, "name": "Easier on Phone:", "id": "P8"},
      {"value": 5, "name": "Easier on Tablet:", "id": "P8"},
      {"value": 5, "name": "Device Preference:", "id": "P8"},
      {"value": 0, "name": "Tablet_First", "id": "P8"},
      {"value": 0, "name": "Toolbar_First", "id": "P8"},
      {"value": "P9", "name": "Participant ID", "id": "P9"},
      {"value": 2, "name": "Identify Errors:", "id": "P9"},
      {"value": 3, "name": "Fix Errors:", "id": "P9"},
      {"value": 2, "name": "Easier to Fix:", "id": "P9"},
      {"value": 4, "name": "Faster to Fix:", "id": "P9"},
      {"value": 1, "name": "Easier on Phone:", "id": "P9"},
      {"value": 4, "name": "Easier on Tablet:", "id": "P9"},
      {"value": 4, "name": "Device Preference:", "id": "P9"},
      {"value": 1, "name": "Tablet_First", "id": "P9"},
      {"value": 1, "name": "Toolbar_First", "id": "P9"},
      {"value": "P10", "name": "Participant ID", "id": "P10"},
      {"value": 2, "name": "Identify Errors:", "id": "P10"},
      {"value": 2, "name": "Fix Errors:", "id": "P10"},
      {"value": 1, "name": "Easier to Fix:", "id": "P10"},
      {"value": 1, "name": "Faster to Fix:", "id": "P10"},
      {"value": 1, "name": "Easier on Phone:", "id": "P10"},
      {"value": 1, "name": "Easier on Tablet:", "id": "P10"},
      {"value": 5, "name": "Device Preference:", "id": "P10"},
      {"value": 1, "name": "Tablet_First", "id": "P10"},
      {"value": 1, "name": "Toolbar_First", "id": "P10"},
      {"value": "P11", "name": "Participant ID", "id": "P11"},
      {"value": 2, "name": "Identify Errors:", "id": "P11"},
      {"value": 2, "name": "Fix Errors:", "id": "P11"},
      {"value": 1, "name": "Easier to Fix:", "id": "P11"},
      {"value": 1, "name": "Faster to Fix:", "id": "P11"},
      {"value": 1, "name": "Easier on Phone:", "id": "P11"},
      {"value": 1, "name": "Easier on Tablet:", "id": "P11"},
      {"value": 4, "name": "Device Preference:", "id": "P11"},
      {"value": 1, "name": "Tablet_First", "id": "P11"},
      {"value": 0, "name": "Toolbar_First", "id": "P11"},
      {"value": "P12", "name": "Participant ID", "id": "P12"},
      {"value": 1, "name": "Identify Errors:", "id": "P12"},
      {"value": 3, "name": "Fix Errors:", "id": "P12"},
      {"value": 2, "name": "Easier to Fix:", "id": "P12"},
      {"value": 3, "name": "Faster to Fix:", "id": "P12"},
      {"value": 1, "name": "Easier on Phone:", "id": "P12"},
      {"value": 3, "name": "Easier on Tablet:", "id": "P12"},
      {"value": 3, "name": "Device Preference:", "id": "P12"},
      {"value": 0, "name": "Tablet_First", "id": "P12"},
      {"value": 1, "name": "Toolbar_First", "id": "P12"},
      {"value": "P13", "name": "Participant ID", "id": "P13"},
      {"value": 2, "name": "Identify Errors:", "id": "P13"},
      {"value": 2, "name": "Fix Errors:", "id": "P13"},
      {"value": 1, "name": "Easier to Fix:", "id": "P13"},
      {"value": 1, "name": "Faster to Fix:", "id": "P13"},
      {"value": 1, "name": "Easier on Phone:", "id": "P13"},
      {"value": 1, "name": "Easier on Tablet:", "id": "P13"},
      {"value": 5, "name": "Device Preference:", "id": "P13"},
      {"value": 0, "name": "Tablet_First", "id": "P13"},
      {"value": 0, "name": "Toolbar_First", "id": "P13"},
      {"value": "P14", "name": "Participant ID", "id": "P14"},
      {"value": 3, "name": "Identify Errors:", "id": "P14"},
      {"value": 3, "name": "Fix Errors:", "id": "P14"},
      {"value": 2, "name": "Easier to Fix:", "id": "P14"},
      {"value": 2, "name": "Faster to Fix:", "id": "P14"},
      {"value": 1, "name": "Easier on Phone:", "id": "P14"},
      {"value": 1, "name": "Easier on Tablet:", "id": "P14"},
      {"value": 1, "name": "Device Preference:", "id": "P14"},
      {"value": 1, "name": "Tablet_First", "id": "P14"},
      {"value": 1, "name": "Toolbar_First", "id": "P14"},
      {"value": "P15", "name": "Participant ID", "id": "P15"},
      {"value": 4, "name": "Identify Errors:", "id": "P15"},
      {"value": 5, "name": "Fix Errors:", "id": "P15"},
      {"value": 1, "name": "Easier to Fix:", "id": "P15"},
      {"value": 1, "name": "Faster to Fix:", "id": "P15"},
      {"value": 1, "name": "Easier on Phone:", "id": "P15"},
      {"value": 1, "name": "Easier on Tablet:", "id": "P15"},
      {"value": 5, "name": "Device Preference:", "id": "P15"},
      {"value": 1, "name": "Tablet_First", "id": "P15"},
      {"value": 0, "name": "Toolbar_First", "id": "P15"},
      {"value": "P16", "name": "Participant ID", "id": "P16"},
      {"value": 1, "name": "Identify Errors:", "id": "P16"},
      {"value": 3, "name": "Fix Errors:", "id": "P16"},
      {"value": 2, "name": "Easier to Fix:", "id": "P16"},
      {"value": 2, "name": "Faster to Fix:", "id": "P16"},
      {"value": 1, "name": "Easier on Phone:", "id": "P16"},
      {"value": 4, "name": "Easier on Tablet:", "id": "P16"},
      {"value": 5, "name": "Device Preference:", "id": "P16"},
      {"value": 0, "name": "Tablet_First", "id": "P16"},
      {"value": 1, "name": "Toolbar_First", "id": "P16"},
      {"value": "P17", "name": "Participant ID", "id": "P17"},
      {"value": 3, "name": "Identify Errors:", "id": "P17"},
      {"value": 2, "name": "Fix Errors:", "id": "P17"},
      {"value": 2, "name": "Easier to Fix:", "id": "P17"},
      {"value": 2, "name": "Faster to Fix:", "id": "P17"},
      {"value": 1, "name": "Easier on Phone:", "id": "P17"},
      {"value": 3, "name": "Easier on Tablet:", "id": "P17"},
      {"value": 2, "name": "Device Preference:", "id": "P17"},
      {"value": 0, "name": "Tablet_First", "id": "P17"},
      {"value": 0, "name": "Toolbar_First", "id": "P17"}
    ]
  },
  "data": {"name": "medians"},
  "title": "Questionnaire Ratings",
  "width": 250,
  "height": 175,
  "encoding": {
    "y": {
      "field": "name",
      "type": "nominal",
      "sort": null,
      "axis": {
        "domain": false,
        "offset": 50,
        "labelFontWeight": "bold",
        "ticks": false,
        "grid": true,
        "title": null
      }
    },
    "x": {
      "type": "quantitative",
      "scale": {"domain": [0, 6]},
      "axis": {"grid": false, "values": [1, 2, 3, 4, 5], "title": null}
    }
  },
  "view": {"stroke": null},
  "layer": [
    {
      "mark": "circle",
      "data": {"name": "values"},
      "transform": [
        {"filter": "datum.name != 'Toolbar_First'"},
        {"filter": "datum.name != 'Tablet_First'"},
        {"filter": "datum.name != 'Participant ID'"}
      ],
      "encoding": {
        "x": {"field": "value"},
        "size": {
          "aggregate": "count",
          "type": "quantitative",
          "title": "Number of Ratings",
          "legend": {"offset": 75}
        },
        "color": {"value": "#6EB4FD"}
      }
    },
    {
      "mark": "tick",
      "encoding": {
        "x": {"field": "median"},
        "color": {"value": "black"}
      }
    },
    {
      "mark": {"type": "text", "x": -5, "align": "right"},
      "encoding": {
        "text": {"field": "lo"}
      }
    },
    {
      "mark": {"type": "text", "x": 255, "align": "left"},
      "encoding": {
        "text": {"field": "hi"}
      }
    }
  ]
}
""")
    }

    func test_layer_line_co2_concentration() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "url": "data/co2-concentration.csv",
    "format": {"parse": {"Date": "utc:'%Y-%m-%d'"}}
  },
  "width": 800,
  "height": 500,
  "transform": [
    {"calculate": "year(datum.Date)", "as": "year"},
    {"calculate": "floor(datum.year / 10)", "as": "decade"},
    {
      "calculate": "(datum.year % 10) + (month(datum.Date)/12)",
      "as": "scaled_date"
    },
    {
      "calculate": "datum.first_date === datum.scaled_date ? 'first' : datum.last_date === datum.scaled_date ? 'last' : null",
      "as": "end"
    }
  ],
  "encoding": {
    "x": {
      "type": "quantitative",
      "title": "Year into Decade",
      "axis": {"tickCount": 11}
    },
    "y": {
      "title": "CO2 concentration in ppm",
      "type": "quantitative",
      "scale": {"zero": false}
    },
    "color": {
      "field": "decade",
      "type": "ordinal",
      "scale": {"scheme": "magma"},
      "legend": null
    }
  },

  "layer": [
    {
      "mark": "line",
      "encoding": {
        "x": {"field": "scaled_date"},
        "y": {"field": "CO2"}
      }
    },
    {
      "mark": {"type": "text", "baseline": "top", "aria": false},
      "encoding": {
        "x": {"aggregate": "min", "field": "scaled_date"},
        "y": {"aggregate": {"argmin": "scaled_date"}, "field": "CO2"},
        "text": {"aggregate": {"argmin": "scaled_date"}, "field": "year"}
      }
    },
    {
      "mark": {"type": "text", "aria": false},
      "encoding": {
        "x": {"aggregate": "max", "field": "scaled_date"},
        "y": {"aggregate": {"argmax": "scaled_date"}, "field": "CO2"},
        "text": {"aggregate": {"argmax": "scaled_date"}, "field": "year"}
      }
    }
  ],
  "config": {"text": {"align": "left", "dx": 3, "dy": 1}}
}
""")
    }

    func test_layer_line_errorband_ci() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/cars.json"},
  "encoding": {
    "x": {
      "field": "Year",
      "timeUnit": "year"
    }
  },
  "layer": [
    {
      "mark": {"type": "errorband", "extent": "ci"},
      "encoding": {
        "y": {
          "field": "Miles_per_Gallon",
          "type": "quantitative",
          "title": "Mean of Miles per Gallon (95% CIs)"
        }
      }
    },
    {
      "mark": "line",
      "encoding": {
        "y": {
          "aggregate": "mean",
          "field": "Miles_per_Gallon"
        }
      }
    }
  ]
}
""")
    }

    func test_layer_line_mean_point_raw() throws {
        try check(viz: Graphiq {
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

    func test_layer_line_rolling_mean_point_raw() throws {
        try check(viz: Graphiq {
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

    func test_layer_line_window() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "width": 400,
  "height": 200,
  "encoding": {
    "x": {
      "field": "row",
      "type": "quantitative",
      "title": "Trial",
      "scale": {"nice": false},
      "axis": {"grid": false}
      },
    "y": {
      "field": "fps",
      "title": "Frames Per Second (fps)",
      "axis": {"grid": false},
      "scale": {"type": "log"}
    },
    "color": {
      "field": "system",
      "type": "nominal",
      "title": "System",
      "legend": {
        "orient": "bottom-right"
      }
    },
    "size": {"value": 1}
  },
  "layer": [{
    "data": {
      "name": "falcon"
    },
    "transform": [
      {"window": [{"op": "row_number", "as": "row"}]},
      {"calculate": "1000/datum.data", "as": "fps"},
      {"calculate": "'Falcon'", "as": "system"}
    ],
    "mark": "line"
  },
  {
    "data": {
      "name": "square"
    },
    "transform": [
      {"window": [{"op": "row_number", "as": "row"}]},
      {"calculate": "1000/datum.data", "as": "fps"},
      {"calculate": "'Square Crossfilter (3M)'", "as": "system"}
    ],
    "mark": "line"
  }],
  "datasets": {
    "falcon": [16.81999969482422,19.759998321533203,16.079999923706055,19.579999923706055,16.420000076293945,16.200000762939453,16.020000457763672,15.9399995803833,16.280000686645508,16.119998931884766,16.15999984741211,16.119998931884766,16.139999389648438,16.100000381469727,16.200000762939453,16.260000228881836,19.35999870300293,19.700000762939453,15.9399995803833,19.139999389648438,16.200000762939453,16.119998931884766,19.520000457763672,19.700000762939453,16.200000762939453,20.979999542236328,16.299999237060547,16.420000076293945,16.81999969482422,16.5,16.560001373291016,16.18000030517578,16.079999923706055,16.239999771118164,16.040000915527344,16.299999237060547,19.399999618530273,15.699999809265137,16.239999771118164,15.920000076293945,16.259998321533203,16.219999313354492,16.520000457763672,16.459999084472656,16.360000610351562,15.719999313354492,16.060001373291016,15.960000991821289,16.479999542236328,16.600000381469727,16.240001678466797,16.940000534057617,16.220001220703125,15.959999084472656,15.899999618530273,16.479999542236328,16.31999969482422,15.75999927520752,15.999998092651367,16.18000030517578,16.219999313354492,15.800000190734863,16.139999389648438,16.299999237060547,16.360000610351562,16.260000228881836,15.959999084472656,15.9399995803833,16.53999900817871,16.139999389648438,16.259998321533203,16.200000762939453,15.899999618530273,16.079999923706055,16.079999923706055,15.699999809265137,15.660000801086426,16.139999389648438,23.100000381469727,16.600000381469727,16.420000076293945,16.020000457763672,15.619999885559082,16.35999870300293,15.719999313354492,15.920001029968262,15.5600004196167,16.34000015258789,22.82000160217285,15.660000801086426,15.5600004196167,16,16,15.819999694824219,16.399999618530273,16.46000099182129,16.059999465942383,16.239999771118164,15.800000190734863,16.15999984741211,16.360000610351562,19.700000762939453,16.10000228881836,16.139999389648438,15.819999694824219,16.439998626708984,16.139999389648438,16.020000457763672,15.860000610351562,16.059999465942383,16.020000457763672,15.920000076293945,15.819999694824219,16.579999923706055,15.880000114440918,16.579999923706055,15.699999809265137,19.380001068115234,19.239999771118164,16,15.980000495910645,15.959999084472656,16.200000762939453,15.980000495910645,16.34000015258789,16.31999969482422,16.260000228881836,15.920000076293945,15.540000915527344,16.139999389648438,16.459999084472656,16.34000015258789,15.819999694824219,19.719999313354492,15.75999927520752,16.499998092651367,15.719999313354492,16.079999923706055,16.439998626708984,16.200000762939453,15.959999084472656,16,16.100000381469727,19.31999969482422,16.100000381469727,16.18000030517578,15.959999084472656,22.639999389648438,15.899999618530273,16.279998779296875,16.100000381469727,15.920000076293945,16.079999923706055,16.260000228881836,15.899999618530273,15.820001602172852,15.699999809265137,15.979998588562012,16.380001068115234,16.040000915527344,19.420000076293945,15.9399995803833,16.15999984741211,15.960000991821289,16.259998321533203,15.780000686645508,15.880000114440918,15.980000495910645,16.060001373291016,16.119998931884766,23.020000457763672,15.619999885559082,15.920000076293945,16.060001373291016,14.780000686645508,16.260000228881836,19.520000457763672,16.31999969482422,16.600000381469727,16.219999313354492,19.740001678466797,19.46000099182129,15.940000534057617,15.839999198913574,16.100000381469727,16.46000099182129,16.17999839782715,16.100000381469727,15.9399995803833,16.060001373291016,15.860000610351562,15.819999694824219,16.03999900817871,16.17999839782715,15.819999694824219,17.299999237060547,15.9399995803833,15.739999771118164,15.719999313354492,15.679998397827148,15.619999885559082,15.600000381469727,16.03999900817871,15.5,15.600001335144043,19.439998626708984,15.960000991821289,16.239999771118164,16.040000915527344,16.239999771118164],
    "square": [24.200000762939453,17.899999618530273,15.800000190734863,58.400001525878906,151,2523.10009765625,245.3000030517578,136,72.30000305175781,55.70000076293945,42.400001525878906,37.70000076293945,30.100000381469727,30.100000381469727,21.799999237060547,20.600000381469727,21.799999237060547,17.600000381469727,18.200000762939453,21,941.7000122070312,177.39999389648438,2821.800048828125,359.20001220703125,318,217.10000610351562,126,69,57.79999923706055,45.29999923706055,35.599998474121094,29.100000381469727,23.799999237060547,44.20000076293945,17.700000762939453,17.700000762939453,15.699999809265137,27.799999237060547,22.799999237060547,3853.60009765625,91.5999984741211,181.39999389648438,476.29998779296875,265.8999938964844,254.60000610351562,2583.199951171875,124.80000305175781,73.19999694824219,56.400001525878906,48.70000076293945,41.599998474121094,21.100000381469727,20.299999237060547,21.299999237060547,18.299999237060547,17.100000381469727,19.5,828.2000122070312,162.1999969482422,217.89999389648438,205.5,197.60000610351562,2249.800048828125,103.0999984741211,71.69999694824219,57.599998474121094,41.400001525878906,34.5,22,20.5,21.700000762939453,18.299999237060547,17.299999237060547,19.399999618530273,666.7999877929688,214.89999389648438,212.3000030517578,125.80000305175781,67.69999694824219,56.099998474121094,45.79999923706055,38.29999923706055,33,35.400001525878906,22.700000762939453,19.399999618530273,19.899999618530273,24.100000381469727,19.299999237060547,21.299999237060547,3508.699951171875,204.10000610351562,125.4000015258789,65.30000305175781,60.79999923706055,44.099998474121094,36.29999923706055,30.5,28.600000381469727,16.5,18.600000381469727,23.700000762939453,22.299999237060547,17.600000381469727,19.200000762939453,448.79998779296875,124.4000015258789,66.5999984741211,53.5,51,45.20000076293945,28.399999618530273,29.200000762939453,26.700000762939453,25.899999618530273,18.100000381469727,17.600000381469727,20.100000381469727,25.200000762939453,3332,67.5,53.599998474121094,56.599998474121094,39.900001525878906,27.600000381469727,29.600000381469727,33.5,17.200000762939453,18.799999237060547,25.200000762939453,16.700000762939453,16.899999618530273,240.1999969482422,52.400001525878906,42.099998474121094,33.900001525878906,28,28.600000381469727,17.299999237060547,20,21,22.799999237060547,16.700000762939453,19.200000762939453,175.39999389648438,43.5,34.70000076293945,29.700000762939453,34.900001525878906,25.799999237060547,17.299999237060547,22.600000381469727,17.600000381469727,17.200000762939453,19.200000762939453,111.80000305175781,35.400001525878906,27.600000381469727,25.399999618530273,21.899999618530273,18.600000381469727,18.100000381469727,21.200000762939453,17.899999618530273,17,80.5999984741211,29.799999237060547,30.100000381469727,16,26.799999237060547,17.5,22.299999237060547,16.799999237060547,22.399999618530273,77.4000015258789,31,29.700000762939453,28.700000762939453,26,16.899999618530273,15.800000190734863,19,52.599998474121094,25.200000762939453,16.700000762939453,17.899999618530273,21,19.799999237060547,18.799999237060547,46.5,17.5,16.799999237060547,18.299999237060547,18.299999237060547,14.899999618530273,41,18.299999237060547,17.299999237060547,17,17.5,32.29999923706055,22.600000381469727,16.600000381469727,17.899999618530273,25.600000381469727,17.5,20.299999237060547,25.200000762939453,18.600000381469727,17.700000762939453]
  }
}
""")
    }

    func test_layer_point_errorbar_ci() throws {
        try check(viz: Graphiq {
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

    func test_layer_point_errorbar_stdev() throws {
        try check(viz: Graphiq {
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

    func test_layer_point_line_loess() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "url": "data/movies.json"
  },
  "layer": [
    {
      "mark": {
        "type": "point",
        "filled": true
      },
      "encoding": {
        "x": {
          "field": "Rotten Tomatoes Rating",
          "type": "quantitative"
        },
        "y": {
          "field": "IMDB Rating",
          "type": "quantitative"
        }
      }
    },
    {
      "mark": {
        "type": "line",
        "color": "firebrick"
      },
      "transform": [
        {
          "loess": "IMDB Rating",
          "on": "Rotten Tomatoes Rating"
        }
      ],
      "encoding": {
        "x": {
          "field": "Rotten Tomatoes Rating",
          "type": "quantitative"
        },
        "y": {
          "field": "IMDB Rating",
          "type": "quantitative"
        }
      }
    }
  ]
}
""")
    }

    func test_layer_point_line_regression() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "url": "data/movies.json"
  },
  "layer": [
    {
      "mark": {
        "type": "point",
        "filled": true
      },
      "encoding": {
        "x": {
          "field": "Rotten Tomatoes Rating",
          "type": "quantitative"
        },
        "y": {
          "field": "IMDB Rating",
          "type": "quantitative"
        }
      }
    },
    {
      "mark": {
        "type": "line",
        "color": "firebrick"
      },
      "transform": [
        {
          "regression": "IMDB Rating",
          "on": "Rotten Tomatoes Rating"
        }
      ],
      "encoding": {
        "x": {
          "field": "Rotten Tomatoes Rating",
          "type": "quantitative"
        },
        "y": {
          "field": "IMDB Rating",
          "type": "quantitative"
        }
      }
    },
    {
      "transform": [
        {
          "regression": "IMDB Rating",
          "on": "Rotten Tomatoes Rating",
          "params": true
        },
        {"calculate": "'R²: '+format(datum.rSquared, '.2f')", "as": "R2"}
      ],
      "mark": {
        "type": "text",
        "color": "firebrick",
        "x": "width",
        "align": "right",
        "y": -5
      },
      "encoding": {
        "text": {"type": "nominal", "field": "R2"}
      }
    }
  ]
}
""")
    }

    func test_layer_precipitation_mean() throws {
        try check(viz: Graphiq {
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

    func test_layer_ranged_dot() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A ranged dot plot that uses 'layer' to convey changing life expectancy for the five most populous countries (between 1955 and 2000).",
  "data": {"url": "data/countries.json"},
  "transform": [
    {
      "filter": {
        "field": "country",
        "oneOf": ["China", "India", "United States", "Indonesia", "Brazil"]
      }
    },
    {
      "filter": {
        "field": "year",
        "oneOf": [1955, 2000]
      }
    }
  ],
  "encoding": {
    "x": {
      "field": "life_expect",
      "type": "quantitative",
      "title": "Life Expectancy (years)"
    },
    "y": {
      "field": "country",
      "type": "nominal",
      "title": "Country",
      "axis": {
        "offset": 5,
        "ticks": false,
        "minExtent": 70,
        "domain": false
      }
    }
  },
  "layer": [
    {
      "mark": "line",
      "encoding": {
        "detail": {
          "field": "country",
          "type": "nominal"
        },
        "color": {"value": "#db646f"}
      }
    },
    {
      "mark": {
        "type": "point",
        "filled": true
      },
      "encoding": {
        "color": {
          "field": "year",
          "type": "ordinal",
          "scale": {
            "domain": [1955, 2000],
            "range": ["#e6959c", "#911a24"]
          },
          "title": "Year"
        },
        "size": {"value": 100},
        "opacity": {"value": 1}
      }
    }
  ]
}
""")
    }

    func test_layer_scatter_errorband_1D_stdev_global_mean() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A scatterplot showing horsepower and miles per gallons for various cars.",
  "data": {"url": "data/cars.json"},
  "layer": [
    {
      "mark": "point",
      "encoding": {
        "x": {"field": "Horsepower", "type": "quantitative"},
        "y": {"field": "Miles_per_Gallon", "type": "quantitative"}
      }
    },
    {
      "mark": {"type": "errorband", "extent": "stdev", "opacity": 0.2},
      "encoding": {
        "y": {
          "field": "Miles_per_Gallon",
          "type": "quantitative",
          "title": "Miles per Gallon"
        }
      }
    },
    {
      "mark": "rule",
      "encoding": {
        "y": {
          "field": "Miles_per_Gallon",
          "type": "quantitative",
          "aggregate": "mean"
        }
      }
    }
  ]
}
""")
    }

    func test_layer_text_heatmap() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/cars.json"},
  "transform": [
    {
      "aggregate": [{"op": "count", "as": "num_cars"}],
      "groupby": ["Origin", "Cylinders"]
    }
  ],
  "encoding": {
    "y": {"field": "Origin", "type": "ordinal"},
    "x": {"field": "Cylinders", "type": "ordinal"}
  },
  "layer": [
    {
      "mark": "rect",
      "encoding": {
        "color": {
          "field": "num_cars",
          "type": "quantitative",
          "title": "Count of Records",
          "legend": {"direction": "horizontal", "gradientLength": 120}
        }
      }
    },
    {
      "mark": "text",
      "encoding": {
        "text": {"field": "num_cars", "type": "quantitative"},
        "color": {
          "condition": {"test": "datum['num_cars'] < 40", "value": "black"},
          "value": "white"
        }
      }
    }
  ],
  "config": {
    "axis": {"grid": true, "tickBand": "extent"}
  }
}
""")
    }

    func test_line() throws {
        try check(viz: Graphiq {
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

    func test_line_bump() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Bump chart",
  "data": {
    "values": [
      {"build": 1, "result": "PASSED"},
      {"build": 2, "result": "PASSED"},
      {"build": 3, "result": "FAILED"},
      {"build": 4, "result": "FAILED"},
      {"build": 5, "result": "SKIPPED"},
      {"build": 6, "result": "PASSED"},
      {"build": 7, "result": "PASSED"},
      {"build": 8, "result": "FAILED"},
      {"build": 9, "result": "PASSED"},
      {"build": 10, "result": "PASSED"},
      {"build": 11, "result": "SKIPPED"},
      {"build": 12, "result": "PASSED"},
      {"build": 13, "result": "PASSED"},
      {"build": 14, "result": "FAILED"},
      {"build": 15, "result": "PASSED"},
      {"build": 16, "result": "SKIPPED"}
    ]
  },
  "mark": {"type": "line", "point": true},
  "encoding": {
    "x": {"field": "build", "type": "quantitative"},
    "y": {"field": "result", "type": "nominal"},
    "order": {"field": "build", "type": "quantitative"}
  }
}
""")
    }

    func test_line_color() throws {
        try check(viz: Graphiq {
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

    func test_line_color_halo() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Multi-series Line Chart with Halo. Use pivot and repeat-layer as a workaround to facet groups of lines and their halo strokes. See https://github.com/vega/vega-lite/issues/6192 for more discussion.",
  "data": {"url": "data/stocks.csv"},
  "transform": [{
    "pivot": "symbol",
    "value": "price",
    "groupby": ["date"]
  }],
  "repeat": {
    "layer": ["AAPL", "AMZN", "GOOG", "IBM", "MSFT"]
  },
  "spec": {
    "layer": [{
      "mark": {"type": "line", "stroke": "white", "strokeWidth": 4},
      "encoding": {
        "x": {"field": "date", "type": "temporal"},
        "y": {"field": {"repeat": "layer"}, "type": "quantitative", "title": "price"}
      }
    },{
      "mark": {"type": "line"},
      "encoding": {
        "x": {"field": "date", "type": "temporal"},
        "y": {"field": {"repeat": "layer"}, "type": "quantitative", "title": "price"},
        "stroke": {"datum": {"repeat": "layer"}, "type": "nominal"}
      }
    }]
  }
}
""")
    }

    func test_line_conditional_axis() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Line chart with conditional axis ticks, labels, and grid.",
  "data": {"url": "data/stocks.csv"},
  "transform": [
  	{"filter": "datum.symbol==='GOOG'"},
  	{"filter": {"field": "date", "timeUnit": "year", "range": [2006, 2007]}}
  ],
  "width": 400,
  "mark": "line",
  "encoding": {
    "x": {
      "field": "date", "type": "temporal",
      "axis": {
        "tickCount": 8,
        "labelAlign": "left",
        "labelExpr": "[timeFormat(datum.value, '%b'), timeFormat(datum.value, '%m') == '01' ? timeFormat(datum.value, '%Y') : '']",
        "labelOffset": 4,
        "labelPadding": -24,
        "tickSize": 30,
        "gridDash": {
          "condition": {"test": {"field": "value", "timeUnit": "month", "equal": 1}, "value": []},
          "value": [2,2]
        },
        "tickDash": {
          "condition": {"test": {"field": "value", "timeUnit": "month", "equal": 1}, "value": []},
          "value": [2,2]
        }
      }
    },
    "y": {"field": "price", "type": "quantitative"}
  },
  "config": {
    "axis": {
      "domainColor": "#ddd",
      "tickColor": "#ddd"
    }
  }
}
""")
    }

    func test_line_dashed_part() throws {
        try check(viz: Graphiq {
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

    func test_line_monotone() throws {
        try check(viz: Graphiq {
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

    func test_line_overlay() throws {
        try check(viz: Graphiq {
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

    func test_line_overlay_stroked() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Stock prices of 5 Tech Companies over Time.",
  "data": {"url": "data/stocks.csv"},
  "mark": {
    "type": "line",
    "point": {
      "filled": false,
      "fill": "white"
    }
  },
  "encoding": {
    "x": {"timeUnit": "year", "field": "date"},
    "y": {"aggregate":"mean", "field": "price", "type": "quantitative"},
    "color": {"field": "symbol", "type": "nominal"}
  }
}
""")
    }

    func test_line_skip_invalid_mid_overlay() throws {
        try check(viz: Graphiq {
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
        }, againstJSON: """
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

    func test_line_strokedash() throws {
        try check(viz: Graphiq {
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

    func test_lookup() throws {
        try check(viz: Graphiq {
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

    func test_nested_concat_align() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Nested concatenation aligned by setting axis minExtent",
  "data": {
    "url": "data/movies.json"
  },
  "vconcat": [{
    "title": "Ratings",
    "repeat": {"column": ["Rotten Tomatoes Rating", "IMDB Rating"]},
    "spec": {
      "width": 150,
      "height": 50,
      "mark": "bar",
      "encoding": {
        "x": {
          "field": {"repeat": "column"},
          "bin": {"maxbins": 20}
        },
        "y": {"aggregate": "count"}
      }
    }
  },{
    "title": "Gross",
    "repeat": {"column": ["US Gross", "Worldwide Gross"]},
    "spec": {
      "width": 150,
      "height": 50,
      "encoding": {
        "x": {
          "field": {"repeat": "column"},
          "bin": {"maxbins": 20}
        },
        "y": {"aggregate": "count"}
      },
      "mark": "bar"
    }
  }],
  "config": {
    "countTitle": "Count",
    "axisX": {"titleLimit": 150},
    "axisY": {
      "minExtent": 40
    }
  }
}
""")
    }

    func test_parallel_coordinate() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Though Vega-Lite supports only one scale per axes, one can create a parallel coordinate plot by folding variables, using `joinaggregate` to normalize their values and using ticks and rules to manually create axes.",
  "data": {
    "url": "data/penguins.json"
  },
  "width": 600,
  "height": 300,
  "transform": [
    {"filter": "datum['Beak Length (mm)']"},
    {"window": [{"op": "count", "as": "index"}]},
    {"fold": ["Beak Length (mm)", "Beak Depth (mm)", "Flipper Length (mm)", "Body Mass (g)"]},
    {
      "joinaggregate": [
        {"op": "min", "field": "value", "as": "min"},
        {"op": "max", "field": "value", "as": "max"}
      ],
      "groupby": ["key"]
    },
    {
      "calculate": "(datum.value - datum.min) / (datum.max-datum.min)",
      "as": "norm_val"
    },
    {
      "calculate": "(datum.min + datum.max) / 2",
      "as": "mid"
    }
  ],
  "layer": [{
    "mark": {"type": "rule", "color": "#ccc"},
    "encoding": {
      "detail": {"aggregate": "count"},
      "x": {"field": "key"}
    }
  }, {
    "mark": "line",
    "encoding": {
      "color": {"type": "nominal", "field": "Species"},
      "detail": {"type": "nominal", "field": "index"},
      "opacity": {"value": 0.3},
      "x": {"type": "nominal", "field": "key"},
      "y": {"type": "quantitative", "field": "norm_val", "axis": null},
      "tooltip": [{
        "type": "quantitative",
        "field": "Beak Length (mm)"
      }, {
        "type": "quantitative",
        "field": "Beak Depth (mm)"
      }, {
        "type": "quantitative",
        "field": "Flipper Length (mm)"
      }, {
        "type": "quantitative",
        "field": "Body Mass (g)"
      }]
    }
  }, {
    "encoding": {
      "x": {"type": "nominal", "field": "key"},
      "y": {"value": 0}
    },
    "layer": [{
      "mark": {"type": "text", "style": "label"},
      "encoding": {
        "text": {"aggregate": "max", "field": "max"}
      }
    }, {
      "mark": {"type": "tick", "style": "tick", "size": 8, "color": "#ccc"}
    }]
  }, {
    "encoding": {
      "x": {"type": "nominal", "field": "key"},
      "y": {"value": 150}
    },
    "layer": [{
      "mark": {"type": "text", "style": "label"},
      "encoding": {
        "text": {"aggregate": "min", "field": "mid"}
      }
    }, {
      "mark": {"type": "tick", "style": "tick", "size": 8, "color": "#ccc"}
    }]
  }, {
    "encoding": {
      "x": {"type": "nominal", "field": "key"},
      "y": {"value": 300}
    },
    "layer": [{
      "mark": {"type": "text", "style": "label"},
      "encoding": {
        "text": {"aggregate": "min", "field": "min"}
      }
    }, {
      "mark": {"type": "tick", "style": "tick", "size": 8, "color": "#ccc"}
    }]
  }],
  "config": {
    "axisX": {"domain": false, "labelAngle": 0, "tickColor": "#ccc", "title": null},
    "view": {"stroke": null},
    "style": {
      "label": {"baseline": "middle", "align": "right", "dx": -5},
      "tick": {"orient": "horizontal"}
    }
  }
}
""")
    }

    func test_point_2d() throws {
        try check(viz: Graphiq {
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

    func test_point_angle_windvector() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Vector array map showing wind speed and direction.",
  "width": 615,
  "height": 560,
  "data": {
    "url": "data/windvectors.csv",
    "format": {"type": "csv", "parse": {"longitude": "number", "latitude": "number"}}
  },
  "projection": {"type": "equalEarth"},
  "mark": {"type": "point", "shape": "wedge", "filled": true},
  "encoding": {
    "longitude": {"field": "longitude", "type": "quantitative"},
    "latitude": {"field": "latitude", "type": "quantitative"},
    "color": {
      "field": "dir", "type": "quantitative",
      "scale": {"domain": [0, 360], "scheme": "rainbow"},
      "legend": null
    },
    "angle": {
      "field": "dir", "type": "quantitative",
      "scale": {"domain": [0, 360], "range": [180, 540]}
    },
    "size": {
      "field": "speed", "type": "quantitative",
      "scale": {"rangeMax": 500}
    }
  },
  "config": {
    "aria": false,
    "view": {"step": 10, "fill": "black"}
  }
}
""")
    }

    func test_point_bubble() throws {
        try check(viz: Graphiq {
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

    func test_point_color_with_shape() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A scatterplot showing body mass and flipper lengths of penguins.",
  "data": {
    "url": "data/penguins.json"
  },
  "mark": "point",
  "encoding": {
    "x": {
      "field": "Flipper Length (mm)",
      "type": "quantitative",
      "scale": {"zero": false}
    },
    "y": {
      "field": "Body Mass (g)",
      "type": "quantitative",
      "scale": {"zero": false}
    },
    "color": {"field": "Species", "type": "nominal"},
    "shape": {"field": "Species", "type": "nominal"}
  }
}
""")
    }

    func test_point_href() throws {
        try check(viz: Graphiq {
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

    func test_point_invalid_color() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "url": "data/movies.json"
  },
  "mark": "point",
  "encoding": {
    "x": {
      "field": "IMDB Rating",
      "type": "quantitative"
    },
    "y": {
      "field": "Rotten Tomatoes Rating",
      "type": "quantitative"
    },
    "color": {
      "condition": {
        "test": "datum['IMDB Rating'] === null || datum['Rotten Tomatoes Rating'] === null",
        "value": "#aaa"
      }
    }
  },
  "config": {
    "mark": {"invalid": null}
  }
}
""")
    }

    func test_point_quantile_quantile() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "url": "data/normal-2d.json"
  },
  "transform": [
    {
      "quantile": "u",
      "step": 0.01,
      "as": [
        "p",
        "v"
      ]
    },
    {
      "calculate": "quantileUniform(datum.p)",
      "as": "unif"
    },
    {
      "calculate": "quantileNormal(datum.p)",
      "as": "norm"
    }
  ],
  "hconcat": [
    {
      "mark": "point",
      "encoding": {
        "x": {
          "field": "unif",
          "type": "quantitative"
        },
        "y": {
          "field": "v",
          "type": "quantitative"
        }
      }
    },
    {
      "mark": "point",
      "encoding": {
        "x": {
          "field": "norm",
          "type": "quantitative"
        },
        "y": {
          "field": "v",
          "type": "quantitative"
        }
      }
    }
  ]
}
""")
    }

    func test_rect_binned_heatmap() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/movies.json"},
  "transform": [{
    "filter": {"and": [
      {"field": "IMDB Rating", "valid": true},
      {"field": "Rotten Tomatoes Rating", "valid": true}
    ]}
  }],
  "mark": "rect",
  "width": 300,
  "height": 200,
  "encoding": {
    "x": {
      "bin": {"maxbins":60},
      "field": "IMDB Rating",
      "type": "quantitative"
    },
    "y": {
      "bin": {"maxbins": 40},
      "field": "Rotten Tomatoes Rating",
      "type": "quantitative"
    },
    "color": {
      "aggregate": "count",
      "type": "quantitative"
    }
  },
  "config": {
    "view": {
      "stroke": "transparent"
    }
  }
}
""")
    }

    func test_rect_heatmap() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/cars.json"},
  "mark": "rect",
  "encoding": {
    "y": {"field": "Origin", "type": "nominal"},
    "x": {"field": "Cylinders", "type": "ordinal"},
    "color": {"aggregate": "mean", "field": "Horsepower"}
  },
  "config": {
    "axis": {"grid": true, "tickBand": "extent"}
  }
}
""")
    }

    func test_rect_heatmap_weather() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
      "url": "data/seattle-weather.csv"
  },
  "title": "Daily Max Temperatures (C) in Seattle, WA",
  "config": {
      "view": {
          "strokeWidth": 0,
          "step": 13
      },
      "axis": {
          "domain": false
      }
  },
  "mark": "rect",
  "encoding": {
      "x": {
          "field": "date",
          "timeUnit": "date",
          "type": "ordinal",
          "title": "Day",
          "axis": {
              "labelAngle": 0,
              "format": "%e"
          }
      },
      "y": {
          "field": "date",
          "timeUnit": "month",
          "type": "ordinal",
          "title": "Month"
      },
      "color": {
          "field": "temp_max",
          "aggregate": "max",
          "type": "quantitative",
          "legend": {
              "title": null
          }
      }
  }
}
""")
    }

    func test_rect_lasagna() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "transform": [{"filter": "datum.symbol !== 'GOOG'"}],
  "width": 300,
  "height": 100,
  "data": {
    "url": "data/stocks.csv"
  },
  "mark": "rect",
  "encoding": {
    "x": {
      "timeUnit": "yearmonthdate",
      "field": "date",
      "type": "ordinal",
      "title": "Time",
      "axis": {
        "format": "%Y",
        "labelAngle": 0,
        "labelOverlap": false,
        "labelColor": {
          "condition": {
            "test": {
              "timeUnit": "monthdate",
              "field": "value",
              "equal": {"month": 1, "date": 1}
            },
            "value": "black"
          },
          "value": null
        },
        "tickColor": {
          "condition": {
            "test": {
              "timeUnit": "monthdate",
              "field": "value",
              "equal": {"month": 1, "date": 1}
            },
            "value": "black"
          },
          "value": null
        }
      }
    },
    "color": {
      "aggregate": "sum",
      "field": "price",
      "type": "quantitative",
      "title": "Price"
    },
    "y": {
      "field": "symbol",
      "type": "nominal",
      "title": null
    }
  }
}
""")
    }

    func test_rect_mosaic_labelled_with_offset() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "url": "data/cars.json"
  },
  "transform": [
    {
      "aggregate": [
        {
          "op": "count",
          "as": "count_*"
        }
      ],
      "groupby": [
        "Origin",
        "Cylinders"
      ]
    },
    {
      "stack": "count_*",
      "groupby": [],
      "as": [
        "stack_count_Origin1",
        "stack_count_Origin2"
      ],
      "offset": "normalize",
      "sort": [
        {
          "field": "Origin",
          "order": "ascending"
        }
      ]
    },
    {
      "window": [
        {
          "op": "min",
          "field": "stack_count_Origin1",
          "as": "x"
        },
        {
          "op": "max",
          "field": "stack_count_Origin2",
          "as": "x2"
        },
        {
          "op": "dense_rank",
          "as": "rank_Cylinders"
        },
        {
          "op": "distinct",
          "field": "Cylinders",
          "as": "distinct_Cylinders"
        }
      ],
      "groupby": [
        "Origin"
      ],
      "frame": [
        null,
        null
      ],
      "sort": [
        {
          "field": "Cylinders",
          "order": "ascending"
        }
      ]
    },
    {
      "window": [
        {
          "op": "dense_rank",
          "as": "rank_Origin"
        }
      ],
      "frame": [
        null,
        null
      ],
      "sort": [
        {
          "field": "Origin",
          "order": "ascending"
        }
      ]
    },
    {
      "stack": "count_*",
      "groupby": [
        "Origin"
      ],
      "as": [
        "y",
        "y2"
      ],
      "offset": "normalize",
      "sort": [
        {
          "field": "Cylinders",
          "order": "ascending"
        }
      ]
    },
    {
      "calculate": "datum.y + (datum.rank_Cylinders - 1) * datum.distinct_Cylinders * 0.01 / 3",
      "as": "ny"
    },
    {
      "calculate": "datum.y2 + (datum.rank_Cylinders - 1) * datum.distinct_Cylinders * 0.01 / 3",
      "as": "ny2"
    },
    {
      "calculate": "datum.x + (datum.rank_Origin - 1) * 0.01",
      "as": "nx"
    },
    {
      "calculate": "datum.x2 + (datum.rank_Origin - 1) * 0.01",
      "as": "nx2"
    },
    {
      "calculate": "(datum.nx+datum.nx2)/2",
      "as": "xc"
    },
    {
      "calculate": "(datum.ny+datum.ny2)/2",
      "as": "yc"
    }
  ],
  "vconcat": [
    {
      "mark": {
        "type": "text",
        "baseline": "middle",
        "align": "center"
      },
      "encoding": {
        "x": {
          "aggregate": "min",
          "field": "xc",
          "title": "Origin",
          "axis": {
            "orient": "top"
          }
        },
        "color": {
          "field": "Origin",
          "legend": null
        },
        "text": {"field": "Origin"}
      }
    },
    {
      "layer": [
        {
          "mark": {
            "type": "rect"
          },
          "encoding": {
            "x": {
              "field": "nx",
              "type": "quantitative",
              "axis": null
            },
            "x2": {"field": "nx2"},
            "y": {
              "field": "ny",
              "type": "quantitative"
            },
            "y2": {"field": "ny2"},
            "color": {
              "field": "Origin",
              "type": "nominal",
              "legend": null
            },
            "opacity": {
              "field": "Cylinders",
              "type": "quantitative",
              "legend": null
            },
            "tooltip": [
              {
                "field": "Origin",
                "type": "nominal"
              },
              {
                "field": "Cylinders",
                "type": "quantitative"
              }
            ]
          }
        },
        {
          "mark": {
            "type": "text",
            "baseline": "middle"
          },
          "encoding": {
            "x": {
              "field": "xc",
              "type": "quantitative",
              "axis": null
            },
            "y": {
              "field": "yc",
              "type": "quantitative",
              "axis": {
                "title": "Cylinders"
              }
            },
            "text": {
              "field": "Cylinders",
              "type": "nominal"
            }
          }
        }
      ]
    }
  ],
  "resolve": {
    "scale": {
      "x": "shared"
    }
  },
  "config": {
    "view": {
      "stroke": ""
    },
    "concat": {"spacing": 10},
    "axis": {
      "domain": false,
      "ticks": false,
      "labels": false,
      "grid": false
    }
  }
}
""")
    }

    func test_repeat_histogram() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "repeat": ["Horsepower", "Miles_per_Gallon", "Acceleration", "Displacement"],
  "columns": 2,
  "spec": {
    "data": {"url": "data/cars.json"},
    "mark": "bar",
    "encoding": {
      "x": {"field": {"repeat": "repeat"}, "bin": true},
      "y": {"aggregate": "count"},
      "color": {"field": "Origin"}
    }
  }
}
""")
    }

    func test_repeat_layer() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
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
""")
    }

    func test_scatter_image() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "values": [
      {"x": 0.5, "y": 0.5, "img": "data/ffox.png"},
      {"x": 1.5, "y": 1.5, "img": "data/gimp.png"},
      {"x": 2.5, "y": 2.5, "img": "data/7zip.png"}
    ]
  },
  "mark": {"type": "image", "width": 50, "height": 50},
  "encoding": {
    "x": {"field": "x", "type": "quantitative"},
    "y": {"field": "y", "type": "quantitative"},
    "url": {"field": "img", "type": "nominal"}
  }
}
""")
    }

    func test_selection_heatmap() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "values": [
      {"actual": "A", "predicted": "A", "count": 13},
      {"actual": "A", "predicted": "B", "count": 0},
      {"actual": "A", "predicted": "C", "count": 0},
      {"actual": "B", "predicted": "A", "count": 0},
      {"actual": "B", "predicted": "B", "count": 10},
      {"actual": "B", "predicted": "C", "count": 6},
      {"actual": "C", "predicted": "A", "count": 0},
      {"actual": "C", "predicted": "B", "count": 0},
      {"actual": "C", "predicted": "C", "count": 9}
    ]
  },
  "params": [{"name": "highlight", "select": "point"}],
  "mark": {"type": "rect", "strokeWidth": 2},
  "encoding": {
    "y": {
      "field": "actual",
      "type": "nominal"
    },
    "x": {
      "field": "predicted",
      "type": "nominal"
    },
    "fill": {
      "field": "count",
      "type": "quantitative"
    },
    "stroke": {
      "condition": {
        "param": "highlight",
        "empty": false,
        "value": "black"
      },
      "value": null
    },
    "opacity": {
      "condition": {"param": "highlight", "value": 1},
      "value": 0.5
    },
    "order": {"condition": {"param": "highlight", "value": 1}, "value": 0}
  },
  "config": {
    "scale": {
      "bandPaddingInner": 0,
      "bandPaddingOuter": 0
    },
    "view": {"step": 40},
    "range": {
      "ramp": {
        "scheme": "yellowgreenblue"
      }
    },
    "axis": {
      "domain": false
    }
  }
}
""")
    }

    func test_selection_layer_bar_month() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/seattle-weather.csv"},
  "layer": [{
    "params": [{
      "name": "brush",
      "select": {"type": "interval", "encodings": ["x"]}
    }],
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
      },
      "opacity": {
        "condition": {
          "param": "brush", "value": 1
        },
        "value": 0.7
      }
    }
  }, {
    "transform": [{
      "filter": {"param": "brush"}
    }],
    "mark": "rule",
    "encoding": {
      "y": {
        "aggregate": "mean",
        "field": "precipitation",
        "type": "quantitative"
      },
      "color": {"value": "firebrick"},
      "size": {"value": 3}
    }
  }]
}
""")
    }

    func test_selection_translate_scatterplot_drag() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/cars.json"},
  "params": [{
    "name": "grid",
    "select": "interval",
    "bind": "scales"
  }],
  "mark": "circle",
  "encoding": {
    "x": {
      "field": "Horsepower", "type": "quantitative",
      "scale": {"domain": [75, 150]}
    },
    "y": {
      "field": "Miles_per_Gallon", "type": "quantitative",
      "scale": {"domain": [20, 40]}
    },
    "size": {"field": "Cylinders", "type": "quantitative"}
  }
}
""")
    }

    func test_sequence_line_fold() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Plots two functions using a generated sequence.",
  "width": 300,
  "height": 150,
  "data": {
    "sequence": {
      "start": 0,
      "stop": 12.7,
      "step": 0.1,
      "as": "x"
    }
  },
  "transform": [
    {
      "calculate": "sin(datum.x)",
      "as": "sin(x)"
    },
    {
      "calculate": "cos(datum.x)",
      "as": "cos(x)"
    },
    {
      "fold": ["sin(x)", "cos(x)"]
    }
  ],
  "mark": "line",
  "encoding": {
    "x": {
      "type": "quantitative",
      "field": "x"
    },
    "y": {
      "field": "value",
      "type": "quantitative"
    },
    "color": {
      "field": "key",
      "type": "nominal",
      "title": null
    }
  }
}
""")
    }

    func test_stacked_area() throws {
        try check(viz: Graphiq {
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

    func test_stacked_area_normalize() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/unemployment-across-industries.json"},
  "width": 300, "height": 200,
  "mark": "area",
  "encoding": {
    "x": {
      "timeUnit": "yearmonth", "field": "date",
      "axis": {"domain": false, "format": "%Y"}
    },
    "y": {
      "aggregate": "sum", "field": "count",
      "axis": null,
      "stack": "normalize"

    },
    "color": {"field":"series", "scale":{"scheme": "category20b"}}
  }
}
""")
    }

    func test_stacked_area_stream() throws {
        try check(viz: Graphiq {
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

    func test_stacked_bar_count_corner_radius_mark() throws {
        try check(viz: Graphiq {
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
        try check(viz: Graphiq {
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

    func test_stacked_bar_normalize() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": { "url": "data/population.json"},
  "transform": [
    {"filter": "datum.year == 2000"},
    {"calculate": "datum.sex == 2 ? 'Female' : 'Male'", "as": "gender"}
  ],
  "mark": "bar",
  "width": {"step": 17},
  "encoding": {
    "y": {
      "aggregate": "sum", "field": "people",
      "title": "population",
      "stack":  "normalize"
    },
    "x": {"field": "age"},
    "color": {
      "field": "gender",
      "scale": {"range": ["#675193", "#ca8861"]}
    }
  }
}
""")
    }

    func test_stacked_bar_weather() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/seattle-weather.csv"},
  "mark": "bar",
  "encoding": {
    "x": {
      "timeUnit": "month",
      "field": "date",
      "type": "ordinal",
      "title": "Month of the year"
    },
    "y": {
      "aggregate": "count",
      "type": "quantitative"
    },
    "color": {
      "field": "weather",
      "type": "nominal",
      "scale": {
        "domain": ["sun", "fog", "drizzle", "rain", "snow"],
        "range": ["#e7ba52", "#c7c7c7", "#aec7e8", "#1f77b4", "#9467bd"]
      },
      "title": "Weather type"
    }
  }
}
""")
    }

    func test_text_scatterplot_colored() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/cars.json"},
  "transform": [{
    "calculate": "datum.Origin[0]",
    "as": "OriginInitial"
  }],
  "mark": "text",
  "encoding": {
    "x": {"field": "Horsepower", "type": "quantitative"},
    "y": {"field": "Miles_per_Gallon", "type": "quantitative"},
    "color": {"field": "Origin", "type": "nominal"},
    "text": {"field": "OriginInitial", "type": "nominal"}
  }
}
""")
    }

    func test_tick_dot() throws {
        try check(viz: Graphiq {
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

    func test_tick_strip() throws {
        try check(viz: Graphiq {
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

    func test_trail_color() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Stock prices of 5 Tech Companies over Time.",
  "data": {"url": "data/stocks.csv"},
  "mark": "trail",
  "encoding": {
    "x": {"field": "date", "type": "temporal"},
    "y": {"field": "price", "type": "quantitative"},
    "size": {"field": "price", "type": "quantitative"},
    "color": {"field": "symbol", "type": "nominal"}
  }
}
""")
    }

    func test_trail_comet() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/barley.json"},
  "title": "Barley Yield comparison between 1932 and 1931",
  "transform": [
    {"pivot": "year", "value": "yield", "groupby": ["variety", "site"]},
    {"fold": ["1931", "1932"], "as": ["year", "yield"]},
    {"calculate": "toNumber(datum.year)", "as": "year"},
    {"calculate": "datum['1932'] - datum['1931']", "as": "delta"}
  ],
  "mark": "trail",
  "encoding": {
    "x": {"field": "year", "title": null},
    "y": {"field": "variety", "title": "Variety"},
    "size": {
      "field": "yield",
      "type": "quantitative",
      "scale": {"range": [0, 12]},
      "legend": {"values": [20, 60]},
      "title": "Barley Yield (bushels/acre)"
    },
    "tooltip": [{"field": "year", "type": "quantitative"}, {"field": "yield"}],
    "color": {
      "field": "delta",
      "type": "quantitative",
      "scale": {"domainMid": 0},
      "title": "Yield Delta (%)"
    },
    "column": {"field": "site", "title": "Site"}
  },
  "view": {"stroke": null},
  "config": {"legend": {"orient": "bottom", "direction": "horizontal"}}
}
""")
    }

    func test_trellis_anscombe() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Anscombe's Quartet",
  "data": {"url": "data/anscombe.json"},
  "mark": "circle",
  "encoding": {
    "column": {"field": "Series"},
    "x": {
      "field": "X",
      "type": "quantitative",
      "scale": {"zero": false}
    },
    "y": {
      "field": "Y",
      "type": "quantitative",
      "scale": {"zero": false}
    },
    "opacity": {"value": 1}
  }
}
""")
    }

    func test_trellis_area() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Stock prices of four large companies as a small multiples of area charts.",
  "transform": [{"filter": "datum.symbol !== 'GOOG'"}],
  "width": 300,
  "height": 40,
  "data": {"url": "data/stocks.csv"},
  "mark": "area",
  "encoding": {
    "x": {
      "field": "date",
      "type": "temporal",
      "title": "Time",
      "axis": {"grid": false}
    },
    "y": {
      "field": "price",
      "type": "quantitative",
      "title": "Price",
      "axis": {"grid": false}
    },
    "color": {
      "field": "symbol",
      "type": "nominal",
      "legend": null
    },
    "row": {
      "field": "symbol",
      "type": "nominal",
      "title": "Symbol"
    }
  }
}
""")
    }

    func test_trellis_area_seattle() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Temperature normals in Seattle. Derived from [Seattle Annual Temperate](https://vega.github.io/vega/examples/annual-temperature/) example from the Vega example gallery.",
  "title": "Seattle Temperature Normals",
  "data": {"url": "data/seattle-weather-hourly-normals.csv"},
  "transform": [
    {"calculate": "(hours(datum.date) + 18) % 24", "as": "order"}
  ],
  "spacing": {"row": 1},
  "facet": {
    "row": {
      "field": "date",
      "timeUnit": "hours",
      "type": "nominal",
      "sort": {"field": "order"},
      "header": {
        "labelAngle": 0,
        "labelPadding": 2,
        "titlePadding": -4,
        "labelAlign": "left",
        "labelExpr": "hours(datum.value) == 0 ? 'Midnight' : hours(datum.value) == 12 ? 'Noon' : timeFormat(datum.value, '%I:%M %p')"
      }
    }
  },
  "spec": {
    "width": 800,
    "height": 25,
    "view": {"stroke": null},
    "mark": "area",
    "encoding": {
      "x": {
        "field": "date",
        "type": "temporal",
        "title": "Month",
        "timeUnit": "monthdate",
        "axis": {"format": "%b"}
      },
      "y": {
        "field": "temperature",
        "type": "quantitative",
        "aggregate": "mean",
        "scale": {"zero": false},
        "axis": {"title": null, "labels": false, "ticks": false}
      }
    }
  },
  "config": {"axis": {"grid": false, "domain": false}}
}
""")
    }

    func test_trellis_bar() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A trellis bar chart showing the US population distribution of age groups and gender in 2000.",
  "data": { "url": "data/population.json"},
  "transform": [
    {"filter": "datum.year == 2000"},
    {"calculate": "datum.sex == 2 ? 'Female' : 'Male'", "as": "gender"}
  ],
  "width": {"step": 17},
  "mark": "bar",
  "encoding": {
    "row": {"field": "gender"},
    "y": {
      "aggregate": "sum", "field": "people",
      "title": "population"
    },
    "x": {"field": "age"},
    "color": {
      "field": "gender",
      "scale": {"range": ["#675193", "#ca8861"]}
    }
  }
}
""")
    }

    func test_trellis_bar_histogram() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data/cars.json"},
  "mark": "bar",
  "encoding": {
    "x": {
      "bin": {"maxbins": 15},
      "field": "Horsepower",
      "type": "quantitative"
    },
    "y": {
      "aggregate": "count",
      "type": "quantitative"
    },
    "row": {"field": "Origin"}
  }
}
""")
    }

    func test_trellis_barley() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "name": "trellis_barley",
  "description": "The Trellis display by Becker et al. helped establish small multiples as a “powerful mechanism for understanding interactions in studies of how a response depends on explanatory variables”. Here we reproduce a trellis of Barley yields from the 1930s, complete with main-effects ordering to facilitate comparison.",
  "data": {"url": "data/barley.json"},
  "mark": "point",
  "height": {"step": 12},
  "encoding": {
    "facet": {
      "field": "site",
      "type": "ordinal",
      "columns": 2,
      "sort": {"op": "median", "field": "yield"}
    },
    "x": {
      "aggregate": "median",
      "field": "yield",
      "type": "quantitative",
      "scale": {"zero": false}
    },
    "y": {
      "field": "variety",
      "type": "ordinal",
      "sort": "-x"
    },
    "color": {"field": "year", "type": "nominal"}
  }
}
""")
    }

    func test_trellis_scatter() throws {
        try check(viz: Graphiq {
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
        try check(viz: Graphiq {
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

    func test_vconcat_weather() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Two vertically concatenated charts that show a histogram of precipitation in Seattle and the relationship between min and max temperature.",
  "data": {
    "url": "data/weather.csv"
  },
  "transform": [{
    "filter": "datum.location === 'Seattle'"
  }],
  "vconcat": [
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
      "mark": "point",
      "encoding": {
        "x": {
          "field": "temp_min",
          "type": "quantitative",
          "bin": true
        },
        "y": {
          "field": "temp_max",
          "type": "quantitative",
          "bin": true
        },
        "size": {
          "aggregate": "count",
          "type": "quantitative"
        }
      }
    }
  ]
}
""")
    }

    func test_waterfall_chart() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {
    "values": [
      {"label": "Begin", "amount": 4000},
      {"label": "Jan", "amount": 1707},
      {"label": "Feb", "amount": -1425},
      {"label": "Mar", "amount": -1030},
      {"label": "Apr", "amount": 1812},
      {"label": "May", "amount": -1067},
      {"label": "Jun", "amount": -1481},
      {"label": "Jul", "amount": 1228},
      {"label": "Aug", "amount": 1176},
      {"label": "Sep", "amount": 1146},
      {"label": "Oct", "amount": 1205},
      {"label": "Nov", "amount": -1388},
      {"label": "Dec", "amount": 1492},
      {"label": "End", "amount": 0}
    ]
  },
  "width": 800,
  "height": 450,
  "transform": [
    {"window": [{"op": "sum", "field": "amount", "as": "sum"}]},
    {"window": [{"op": "lead", "field": "label", "as": "lead"}]},
    {
      "calculate": "datum.lead === null ? datum.label : datum.lead",
      "as": "lead"
    },
    {
      "calculate": "datum.label === 'End' ? 0 : datum.sum - datum.amount",
      "as": "previous_sum"
    },
    {
      "calculate": "datum.label === 'End' ? datum.sum : datum.amount",
      "as": "amount"
    },
    {
      "calculate": "(datum.label !== 'Begin' && datum.label !== 'End' && datum.amount > 0 ? '+' : '') + datum.amount",
      "as": "text_amount"
    },
    {"calculate": "(datum.sum + datum.previous_sum) / 2", "as": "center"},
    {
      "calculate": "datum.sum < datum.previous_sum ? datum.sum : ''",
      "as": "sum_dec"
    },
    {
      "calculate": "datum.sum > datum.previous_sum ? datum.sum : ''",
      "as": "sum_inc"
    }
  ],
  "encoding": {
    "x": {
      "field": "label",
      "type": "ordinal",
      "sort": null,
      "axis": {"labelAngle": 0, "title": "Months"}
    }
  },
  "layer": [
    {
      "mark": {"type": "bar", "size": 45},
      "encoding": {
        "y": {
          "field": "previous_sum",
          "type": "quantitative",
          "title": "Amount"
        },
        "y2": {"field": "sum"},
        "color": {
          "condition": [
            {
              "test": "datum.label === 'Begin' || datum.label === 'End'",
              "value": "#f7e0b6"
            },
            {"test": "datum.sum < datum.previous_sum", "value": "#f78a64"}
          ],
          "value": "#93c4aa"
        }
      }
    },
    {
      "mark": {
        "type": "rule",
        "color": "#404040",
        "opacity": 1,
        "strokeWidth": 2,
        "xOffset": -22.5,
        "x2Offset": 22.5
      },
      "encoding": {
        "x2": {"field": "lead"},
        "y": {"field": "sum", "type": "quantitative"}
      }
    },
    {
      "mark": {"type": "text", "dy": -4, "baseline": "bottom"},
      "encoding": {
        "y": {"field": "sum_inc", "type": "quantitative"},
        "text": {"field": "sum_inc", "type": "nominal"}
      }
    },
    {
      "mark": {"type": "text", "dy": 4, "baseline": "top"},
      "encoding": {
        "y": {"field": "sum_dec", "type": "quantitative"},
        "text": {"field": "sum_dec", "type": "nominal"}
      }
    },
    {
      "mark": {"type": "text", "fontWeight": "bold", "baseline": "middle"},
      "encoding": {
        "y": {"field": "center", "type": "quantitative"},
        "text": {"field": "text_amount", "type": "nominal"},
        "color": {
          "condition": [
            {
              "test": "datum.label === 'Begin' || datum.label === 'End'",
              "value": "#725a30"
            }
          ],
          "value": "white"
        }
      }
    }
  ],
  "config": {"text": {"fontWeight": "bold", "color": "#404040"}}
}
""")
    }

    func test_wheat_wages() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "width": 900,
  "height": 400,
  "data": { "url": "data/wheat.json"},
  "transform": [{"calculate": "+datum.year + 5", "as": "year_end"}],
  "encoding": {
    "y": {
      "type": "quantitative",
      "axis": { "zindex": 1 }
    },
    "x": {
      "type": "quantitative",
      "axis": {"tickCount": 5, "format": "d"}
    }
  },
  "layer": [
    {
      "mark": {"type": "bar", "fill": "#aaa", "stroke": "#999"},
      "encoding": {
        "x": {"field": "year"},
        "x2": {"field": "year_end"},
        "y": {"field": "wheat"}
      }
    },
    {
      "data": {
        "values": [
          { "year": "1600" },
          { "year": "1650" },
          { "year": "1700" },
          { "year": "1750" },
          { "year": "1800" }
        ]
      },
      "mark": {
        "type": "rule",
        "stroke": "#000",
        "strokeWidth": 0.6,
        "opacity": 0.5
      },
      "encoding": {
        "x": {"field": "year"}
      }
    },
    {
      "mark": {
        "type": "area",
        "color": "#a4cedb",
        "opacity": 0.7
      },
      "encoding": {
        "x": {"field": "year"},
        "y": {"field": "wages"}
      }
    },
    {
      "mark": {"type": "line", "color": "#000", "opacity": 0.7},
      "encoding": {
        "x": {"field": "year"},
        "y": {"field": "wages"}
      }
    },
    {
      "mark": {"type": "line", "yOffset": -2, "color": "#EE8182"},
      "encoding": {
        "x": {"field": "year"},
        "y": {"field": "wages"}
      }
    },
    {
      "data": {"url": "data/monarchs.json"},
      "transform": [
        { "calculate": "((!datum.commonwealth && datum.index % 2) ? -1: 1) * 2 + 95", "as": "offset" },
        { "calculate": "95", "as": "y" }
      ],
      "mark": {"type": "bar", "stroke": "#000"},
      "encoding": {
        "x": {"field": "start"},
        "x2": {"field": "end"},
        "y": {"field": "y"},
        "y2": { "field": "offset" },
        "fill": {
          "field": "commonwealth",
          "scale": { "range": ["black", "white"] },
          "legend": null
        }
      }
    },
    {
      "data": {"url": "data/monarchs.json"},
      "transform": [
        { "calculate": "((!datum.commonwealth && datum.index % 2) ? -1: 1) + 95", "as": "off2" },
        { "calculate": "+datum.start + (+datum.end - +datum.start)/2", "as": "x"}
      ],
      "mark": {
        "type": "text",
        "yOffset": 16,
        "fontSize": 9,
        "baseline": "bottom",
        "fontStyle": "italic"
      },
      "encoding": {
        "x": {"field": "x"},
        "y": {"field": "off2"},
        "text": {"field": "name"}
      }
    }
  ],
  "config": {
    "axis": {
      "title": null,
      "gridColor": "white",
      "gridOpacity": 0.25,
      "domain": false
    },
    "view": { "stroke": "transparent" }
  }
}
""")
    }

    func test_window_percent_of_total() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A bar graph showing what activites consume what percentage of the day.",
  "data": {
    "values": [
      {"Activity": "Sleeping", "Time": 8},
      {"Activity": "Eating", "Time": 2},
      {"Activity": "TV", "Time": 4},
      {"Activity": "Work", "Time": 8},
      {"Activity": "Exercise", "Time": 2}
    ]
  },
  "transform": [{
    "window": [{
      "op": "sum",
      "field": "Time",
      "as": "TotalTime"
    }],
    "frame": [null, null]
  },
  {
    "calculate": "datum.Time/datum.TotalTime * 100",
    "as": "PercentOfTotal"
  }],
  "height": {"step": 12},
  "mark": "bar",
  "encoding": {
    "x": {
      "field": "PercentOfTotal",
      "type": "quantitative",
      "title": "% of total Time"
    },
    "y": {"field": "Activity", "type": "nominal"}
  }
}
""")
    }

    func test_window_rank() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "title": {
    "text": "World Cup 2018: Group F Rankings",
    "frame": "bounds"
  },
  "data": {
    "values": [
      {"team": "Germany", "matchday": 1, "point": 0, "diff": -1},
      {"team": "Mexico", "matchday": 1, "point": 3, "diff": 1},
      {"team": "South Korea", "matchday": 1, "point": 0, "diff": -1},
      {"team": "Sweden", "matchday": 1, "point": 3, "diff": 1},
      {"team": "Germany", "matchday": 2, "point": 3, "diff": 0},
      {"team": "Mexico", "matchday": 2, "point": 6, "diff": 2},
      {"team": "South Korea", "matchday": 2, "point": 0, "diff": -2},
      {"team": "Sweden", "matchday": 2, "point": 3, "diff": 0},
      {"team": "Germany", "matchday": 3, "point": 3, "diff": -2},
      {"team": "Mexico", "matchday": 3, "point": 6, "diff": -1},
      {"team": "South Korea", "matchday": 3, "point": 3, "diff": 0},
      {"team": "Sweden", "matchday": 3, "point": 6, "diff": 3}
    ]
  },
  "transform": [{
    "sort": [
      {"field": "point", "order": "descending"},
      {"field": "diff", "order": "descending"}
    ],
    "window": [{
      "op": "rank",
      "as": "rank"
    }],
    "groupby": ["matchday"]
  }],
  "mark": {"type": "line", "orient": "vertical"},
  "encoding": {
    "x": {"field": "matchday", "type": "ordinal"},
    "y": {"field": "rank", "type": "ordinal"},
    "color": {
      "field": "team", "type": "nominal",
      "scale": {
        "domain": ["Germany", "Mexico", "South Korea", "Sweden"],
        "range": ["black", "#127153", "#C91A3C", "#0C71AB"]
      }
    }
  }
}
""")
    }

    func test_window_top_k() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "A bar graph showing the scores of the top 5 students. This shows an example of the window transform, for how the top K (5) can be filtered, and also how a rank can be computed for each student.",
  "data": {
    "values": [
      {"student": "A", "score": 100}, {"student": "B", "score": 56},
      {"student": "C", "score": 88}, {"student": "D", "score": 65},
      {"student": "E", "score": 45}, {"student": "F", "score": 23},
      {"student": "G", "score": 66}, {"student": "H", "score": 67},
      {"student": "I", "score": 13}, {"student": "J", "score": 12},
      {"student": "K", "score": 50}, {"student": "L", "score": 78},
      {"student": "M", "score": 66}, {"student": "N", "score": 30},
      {"student": "O", "score": 97}, {"student": "P", "score": 75},
      {"student": "Q", "score": 24}, {"student": "R", "score": 42},
      {"student": "S", "score": 76}, {"student": "T", "score": 78},
      {"student": "U", "score": 21}, {"student": "V", "score": 46}
    ]
  },
  "transform": [
    {
      "window": [{
        "op": "rank",
        "as": "rank"
      }],
      "sort": [{ "field": "score", "order": "descending" }]
    }, {
      "filter": "datum.rank <= 5"
    }
  ],
  "mark": "bar",
  "encoding": {
    "x": {
        "field": "score",
        "type": "quantitative"
    },
    "y": {
        "field": "student",
        "type": "nominal",
        "sort": {"field": "score", "op": "average", "order":"descending"}
    }
  }
}
""")
    }

    func test_window_top_k_others() throws {
        try check(viz: Graphiq {
        }, againstJSON: """
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Top-K plot with \"others\" by Trevor Manz, adapted from https://observablehq.com/@manzt/top-k-plot-with-others-vega-lite-example.",
  "title": "Top Directors by Average Worldwide Gross",
  "data": {"url": "data/movies.json"},
  "mark": "bar",
  "transform": [
    {
      "aggregate": [{"op": "mean", "field": "Worldwide Gross", "as": "aggregate_gross"}],
      "groupby": ["Director"]
    },
    {
      "window": [{"op": "row_number", "as": "rank"}],
      "sort": [{ "field": "aggregate_gross", "order": "descending" }]
    },
    {
      "calculate": "datum.rank < 10 ? datum.Director : 'All Others'", "as": "ranked_director"
    }
  ],
  "encoding": {
    "x": {
      "aggregate": "mean",
      "field": "aggregate_gross",
      "type": "quantitative",
      "title": null
    },
    "y": {
      "sort": {"op": "mean", "field": "aggregate_gross", "order": "descending"},
      "field": "ranked_director",
      "type": "ordinal",
      "title": null
    }
  }
}
""")
    }
}

