// swift-tools-version: 5.8

import PackageDescription

#if !os(Windows)
fatalError("swift-webdriver does not support this OS")
#endif

let package = Package(
    name: "swift-webdriver",
    products: [
        .library(name: "WebDriver", targets: ["WebDriver", "WinAppDriver"]),
    ],
    targets: [
        .target(
            name: "WebDriver",
            path: "Sources/WebDriver"),
        .target(
            name: "WinAppDriver",
            dependencies: ["WebDriver"],
            path: "Sources/WinAppDriver"),
        .target(
            name: "TestsCommon",
            path: "Tests/Common"),
        .testTarget(
            name: "WinAppDriverTests",
            dependencies: ["TestsCommon", "WebDriver", "WinAppDriver"],
            // Ignore "LNK4217: locally defined symbol imported" spew due to SPM library support limitations
            linkerSettings: [ .unsafeFlags(["-Xlinker", "-ignore:4217"]) ]),
        .testTarget(
            name: "UnitTests",
            dependencies: ["TestsCommon", "WebDriver", "WinAppDriver"],
            // Ignore "LNK4217: locally defined symbol imported" spew due to SPM library support limitations
            linkerSettings: [ .unsafeFlags(["-Xlinker", "-ignore:4217"]) ]),
    ]
)
