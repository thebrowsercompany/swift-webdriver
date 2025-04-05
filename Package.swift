// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "swift-webdriver",
    products: [
        .library(name: "WebDriver", targets: ["WebDriver"]),
    ] + ifWindows([
        .library(name: "WinAppDriver", targets: ["WinAppDriver"]),
    ]),
    targets: [
        .target(
            name: "WebDriver",
            path: "Sources/WebDriver",
            exclude: ["CMakeLists.txt"]),
        .target(
            name: "TestsCommon",
            path: "Tests/Common"),
        .testTarget(
            name: "UnitTests",
            dependencies: ["TestsCommon", "WebDriver"],
            // Ignore "LNK4217: locally defined symbol imported" spew due to SPM library support limitations
            linkerSettings: [ .unsafeFlags(["-Xlinker", "-ignore:4217"], .when(platforms: [.windows])) ]),
         .testTarget(
            name: "AppiumTests",
            dependencies: ["TestsCommon", "WebDriver"],
            // Ignore "LNK4217: locally defined symbol imported" spew due to SPM library support limitations
            linkerSettings: ifWindows([ .unsafeFlags(["-Xlinker", "-ignore:4217"]) ])),
    ] + ifWindows([
        .target(
            name: "WinAppDriver",
            dependencies: ["WebDriver"],
            path: "Sources/WinAppDriver",
            exclude: ["CMakeLists.txt"]),
        .testTarget(
            name: "WinAppDriverTests",
            dependencies: ["TestsCommon", "WebDriver", "WinAppDriver"],
            // Ignore "LNK4217: locally defined symbol imported" spew due to SPM library support limitations
            linkerSettings: [ .unsafeFlags(["-Xlinker", "-ignore:4217"]) ]),
    ])
)

func ifWindows<T>(_ values: [T]) -> [T] {
    #if os(Windows)
    return values
    #else
    return []
    #endif
}
