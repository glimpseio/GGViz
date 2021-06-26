import XCTest
import GGDSL
import GGSamples

final class GGAffordancesTests : XCTestCase {

    /// Attempt to parse all of the available sample spec againt the generated schema
    ///
    /// The test is run on all cores using `DispatchQueue.concurrentPerform` in order to verify that the spec can be loaded on background threads (which have a lower maximum stack size on macOS)
    func testParseSampleVizSpec() throws {
        measure { // measured [Time, seconds] average: 0.135, relative standard deviation: 6.521%, values: [0.158417, 0.131659, 0.137847, 0.128122, 0.125872, 0.136956, 0.131422, 0.132509, 0.141240, 0.130322]
            let allSamples = GGSample.allCases
            DispatchQueue.concurrentPerform(iterations: allSamples.count) {
                let sample = allSamples[$0]

                //dbg("loading sample", sample)
                guard let url = sample.resourceURL else {
                    return XCTFail("unable load load URL for sample: \(sample)")
                }

                // attempt to parse into a `SimpleVizSpec`
                do {
                    let _ = try SimpleVizSpec.loadJSON(url: url)
                } catch {
                    XCTFail("error parsing sample: \(sample): \(error)")
                }
            }
        }
    }
}

