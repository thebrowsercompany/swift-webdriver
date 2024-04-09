// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "swift-webdriver",
    products: [
        .library(name: "WebDriver", targets: ["WebDriver"]),
    ],
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
    ]
)

#if os(Windows)
package.products += [
    .library(name: "WinAppDriver", targets: ["WinAppDriver"])
]
package.targets += [
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
]
#endif
