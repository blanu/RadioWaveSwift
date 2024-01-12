// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RadioWave",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RadioWave",
            targets: ["RadioWave"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OperatorFoundation/Datable", branch: "main"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.2"),
        .package(url: "https://github.com/OperatorFoundation/SwiftHexTools", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Transmission", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RadioWave",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),

                "Datable",
                "Transmission",
            ]
        ),
        .testTarget(
            name: "RadioWaveTests",
            dependencies: [
                "RadioWave",
                "SwiftHexTools",
            ]),
    ],
    swiftLanguageVersions: [.v5]
)
