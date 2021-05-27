import XCTest

import GGViz
import MiscKit
import BricBrac

final class GGVizTests: XCTestCase {

    func testCompileGrammar() throws {
        let dataSet = InlineDataset([
            ["A": 1],
            ["B": 2],
            ["C": 3],
        ])

        let spec = SimpleVizSpec(data: .init(.init(.init(InlineData(values: dataSet)))), mark: AnyMark(Mark.bar))
        let ctx = try GGContext()
        let value = try ctx.compileGrammar(spec: spec)
        dbg("compiled", value.toJSON(indent: 2))
        let compiled = try value.toDecodable(ofType: Bric.self)

        let parsed = try ctx.parseViz(value)
        dbg("parsed", parsed.toJSON(indent: 2))

        let rendered = try ctx.renderViz(value)

        XCTAssertEqual(rendered.stringValue, """
            """)
        
//        measure { // measured [Time, seconds] average: 0.005, relative standard deviation: 24.014%, values: [0.007017, 0.005723, 0.005122, 0.007813, 0.004534, 0.004649, 0.004680, 0.004304, 0.004095, 0.003790]
//            let value = try? ctx.compileGrammar(spec: spec)
//            let _ = try? value?.toDecodable(ofType: Bric.self)
//        }

        XCTAssertEqual(compiled, [
            "spec": [
              "$schema": "https://vega.github.io/schema/vega/v5.json",
              "background": "white",
              "padding": 5,
              "width": 20,
              "height": 20,
              "style": "cell",
              "data": [
                [
                  "name": "source_0",
                  "values": [
                    [
                      "A": 1
                    ],
                    [
                      "B": 2
                    ],
                    [
                      "C": 3
                    ]
                  ]
                ]
              ],
              "marks": [
                [
                  "name": "marks",
                  "type": "rect",
                  "style": [
                    "bar"
                  ],
                  "from": [
                    "data": "source_0"
                  ],
                  "encode": [
                    "update": [
                      "fill": [
                        "value": "#4c78a8"
                      ],
                      "ariaRoleDescription": [
                        "value": "bar"
                      ],
                      "x": [
                        "field": [
                          "group": "width"
                        ]
                      ],
                      "x2": [
                        "value": 0
                      ],
                      "y": [
                        "value": 0
                      ],
                      "y2": [
                        "field": [
                          "group": "height"
                        ]
                      ]
                    ]
                  ]
                ]
              ]
            ],
            "normalized": [
              "data": [
                "values": [
                  [
                    "A": 1
                  ],
                  [
                    "B": 2
                  ],
                  [
                    "C": 3
                  ]
                ]
              ],
              "mark": "bar"
            ]
        ])
    }
}
