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
        .executable(
            name: "ggtool",
            targets: ["GGTool"]),
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
            dependencies: ["GGDSL"],
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
            dependencies: ["GGViz"],
            resources: [.copy("TestResources/")]),
        .target(
            name: "GGTool",
            dependencies: [
                "GGBundle", 
                "GGViz", 
                "ZIPFoundation", 
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ])
    ]
)
