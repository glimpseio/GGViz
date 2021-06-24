import XCTest
import GGDSL

final class GGDSLScratchTests : XCTestCase {


    func test_layer_precipitation_mean() throws {
        try check(viz: Graphiq {
            //DataReference(path: "XXX/XXX")
            //Layer {
            //    Mark(.XXX) {
            //        Encode(.XXX, field: "XXX") {
            //            Guide()
            //            Scale()
            //        }
            //    }
            //}
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

    func test_area_gradient() throws {
        try check(viz: Graphiq {
            //DataReference(path: "XXX/XXX")
            //Layer {
            //    Mark(.XXX) {
            //        Encode(.XXX, field: "XXX") {
            //            Guide()
            //            Scale()
            //        }
            //    }
            //}
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

}

