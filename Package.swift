// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "GGViz",
    platforms: [
        .macOS(.v10_11), .iOS(.v9), .tvOS(.v9), .watchOS(.v2)
    ],
    products: [
        .library(
            name: "GGDSL",
            targets: ["GGDSL"]),
        .library(
            name: "GGViz",
            targets: ["GGViz"]),
        .library(
            name: "GGBundle",
            targets: ["GGBundle"]),
        .executable( // SR-1954
            name: "ggtool", // SR-1954
            targets: ["GGTool"]), // SR-1954
    ],
    dependencies: [
        .package(url: "https://github.com/jectivex/Judo.git", .branch("main")),
        .package(url: "https://github.com/glimpseio/GGGrammar.git", .branch("main")),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMinor(from: "0.9.12")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.4.3")),
    ],
    targets: [
        .target(
            name: "GGDSL",
            dependencies: [.product(name: "GGSchema", package: "GGGrammar")],
            resources: [.process("Resources/")]),
        .testTarget(
            name: "GGDSLTests",
            dependencies: [
                .product(name: "GGSamples", package: "GGGrammar"),
                "GGDSL",
            ],
            resources: [.copy("TestResources/")]),
        .target(
            name: "GGBundle",
            dependencies: [.product(name: "GGSchema", package: "GGGrammar")],
            resources: [.process("Resources/")]),
        .testTarget(
            name: "GGBundleTests",
            dependencies: ["GGBundle"],
            resources: [.copy("TestResources/")]),
        .target(
            name: "GGViz",
            dependencies: ["Judo", "GGDSL"],
            resources: [.process("Resources/")]),
        .testTarget(
            name: "GGVizTests",
            dependencies: [
                "GGViz",
                .product(name: "GGSamples", package: "GGGrammar"),
                .product(name: "GGSources", package: "GGGrammar"),
            ],
            resources: [.copy("TestResources/")]),
        .target( // SR-1954
            name: "GGTool", // SR-1954
            dependencies: [ // SR-1954
                "GGBundle", // SR-1954
                "GGViz", // SR-1954
                "ZIPFoundation", // SR-1954
                .product(name: "ArgumentParser", package: "swift-argument-parser") // SR-1954
            ]), // SR-1954
        .testTarget( // SR-1954
            name: "GGToolTests", // SR-1954
            dependencies: ["GGTool"]), // SR-1954
    ]
)
