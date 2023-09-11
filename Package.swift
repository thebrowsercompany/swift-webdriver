// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "webdriver-swift",
    products: [
        .library(name: "WebDriver", targets: ["WebDriver"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "WebDriver", path: "Sources"),
        .target(name: "TestsCommon", path: "Tests/Common"),
        .testTarget(
            name: "WebDriverTests",
            dependencies: ["WebDriver", "TestsCommon"],
            // Ignore "LNK4217: locally defined symbol imported" spew due to SPM library support limitations
            linkerSettings: [ .unsafeFlags(["-Xlinker", "-ignore:4217"]) ]),
        .testTarget(
            name: "UnitTests",
            dependencies: ["WebDriver", "TestsCommon"],
            // Ignore "LNK4217: locally defined symbol imported" spew due to SPM library support limitations
            linkerSettings: [ .unsafeFlags(["-Xlinker", "-ignore:4217"]) ]),
    ]
)
