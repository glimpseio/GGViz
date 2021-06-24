//
//  File.swift
//  
//
//  Created by Marc Prud'hommeaux on 6/24/21.
//

import GGDSL

extension GGDSLExampleTests {


//    func test_layer_line_rolling_mean_point_raw() throws {
//        try check(viz: Graphiq(width: 400, height: 300) {
//            DataReference(path: "data/seattle-weather.csv")
//            Transform(.window, field: "temp_max", op: .mean, output: "rolling_mean") { rolling_mean in
//                Layer {
//                    Encode(.x, field: "date")
//                    Encode(.y)
//                }
//                Mark(.point) {
//                    Encode(.y, field: "temp_max") {
//                        Guide().title(.init("Max Temperature and Rolling Mean"))
//                    }
//                }
//                .opacity(0.3)
//                Mark(.line) {
//                    Encode(.y, field: rolling_mean)
//                        .title(.init("Rolling Mean of Max Temperature"))
//                }
//                .color(.init(.init("red")))
//                .size(3)
//            }
//        }, againstJSON: """
//{
//  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
//  "description": "Plot showing a 30 day rolling average with raw values in the background.",
//  "width": 400,
//  "height": 300,
//  "data": {"url": "data/seattle-weather.csv"},
//  "transform": [{
//    "window": [
//      {
//        "field": "temp_max",
//        "op": "mean",
//        "as": "rolling_mean"
//      }
//    ],
//    "frame": [-15, 15]
//  }],
//  "encoding": {
//    "x": {"field": "date", "type": "temporal", "title": "Date"},
//    "y": {"type": "quantitative", "axis": {"title": "Max Temperature and Rolling Mean"}}
//  },
//  "layer": [
//    {
//      "mark": {"type": "point", "opacity": 0.3},
//      "encoding": {
//        "y": {"field": "temp_max", "title": "Max Temperature"}
//      }
//    },
//    {
//      "mark": {"type": "line", "color": "red", "size": 3},
//      "encoding": {
//        "y": {"field": "rolling_mean", "title": "Rolling Mean of Max Temperature"}
//      }
//    }
//  ]
//}
//""")
//    }
}

