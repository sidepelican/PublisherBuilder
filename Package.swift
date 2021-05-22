// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PublisherBuilder",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(
            name: "PublisherBuilder",
            targets: ["PublisherBuilder"]),
        .executable(
            name: "WaiwaiPublisherBuilder1",
            targets: ["WaiwaiPublisherBuilder1"]),
        .executable(
            name: "WaiwaiPublisherBuilder2",
            targets: ["WaiwaiPublisherBuilder2"]),
        .executable(
            name: "WaiwaiPublisherBuilder2-2",
            targets: ["WaiwaiPublisherBuilder2-2"]),
        .executable(
            name: "WaiwaiPublisherBuilder3",
            targets: ["WaiwaiPublisherBuilder3"]),
    ],
    targets: [
        .target(
            name: "PublisherBuilder",
            dependencies: []),
        .target(
            name: "WaiwaiPublisherBuilder1",
            dependencies: []),
        .target(
            name: "WaiwaiPublisherBuilder2",
            dependencies: []),
        .target(
            name: "WaiwaiPublisherBuilder2-2",
            dependencies: []),
        .target(
            name: "WaiwaiPublisherBuilder3",
            dependencies: []),
        .testTarget(
            name: "PublisherBuilderTests",
            dependencies: ["PublisherBuilder"]),
    ]
)
