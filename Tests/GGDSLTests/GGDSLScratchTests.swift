import XCTest
import GGDSL

final class GGDSLScratchTests : XCTestCase {


    func testXXX() throws {
        Encode(.y, field: "count").stack(.init(.center))
    }

    func test_repeat_histogram() throws {
        try check(viz: Graphiq {
            //DataReference(path: "data/cars.json")
            //Layer {
            //    Mark(.bar) {
            //        Encode(.XXX, field: "XXX") {
            //            Guide()
            //            Scale()
            //        }
            //    }
            //}
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

}

