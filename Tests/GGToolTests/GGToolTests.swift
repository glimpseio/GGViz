import XCTest
import class Foundation.Bundle

final class GGToolTests: XCTestCase {
    func testExample() throws {
        print("###### RUNNING EXAMPLE") // not called on linux…
        XCTAssertEqual(try runGGTool(["--count", "1", "ABC"]), "ABC\n")
        XCTAssertEqual(try runGGTool(["--count", "2", "ABC"]), "ABC\nABC\n")
        XCTAssertEqual(try runGGTool(["--count", "3", "ABC"]), "ABC\nABC\nABC\n")
    }

    func runGGTool(_ args: [String]) throws -> String? {
        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return nil
        }

        // Mac Catalyst won't have `Process`, but it is supported for executables.
        #if !targetEnvironment(macCatalyst)

        // the relative path to the tool
        let toolPath: String = "ggtool"

        let ggtool = buildOutputFolder().appendingPathComponent(toolPath)

        let process = Process()
        process.executableURL = ggtool
        process.arguments = args

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        return output
        #else
        return nil
        #endif
    }

    /// Returns path to the built products directory.
    func buildOutputFolder() -> URL {
        #if os(macOS) // check for Xcode test bundles
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        #endif

        // on linux, this should be the folder above the tool
        return Bundle.main.bundleURL
    }
}
