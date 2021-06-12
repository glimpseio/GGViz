// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "GGViz",
    products: [
        .library(
            name: "GGDSL",
            targets: ["GGDSL"]),
        .library(
            name: "GGViz",
            targets: ["GGViz"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jectivex/Judo.git", .branch("main")),
        .package(url: "https://github.com/glimpseio/GGSpec.git", .branch("main")),
    ],
    targets: [
        .target(
            name: "GGDSL",
            dependencies: ["GGSpec"],
            resources: [.process("Resources/")]),
        .testTarget(
            name: "GGDSLTests",
            dependencies: ["GGDSL"],
            resources: [.copy("TestResources/")]),
        .target(
            name: "GGViz",
            dependencies: ["Judo", "GGDSL"],
            resources: [.process("Resources/")]),
        .testTarget(
            name: "GGVizTests",
            dependencies: ["GGViz"],
            resources: [.copy("TestResources/")]),
    ]
)
