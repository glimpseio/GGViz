//
//  File.swift
//  
//
//  Created by Marc Prud'hommeaux on 6/24/21.
//

import GGDSL

extension GGDSLExampleTests {

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

}

