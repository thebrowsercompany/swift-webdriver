# swift-webdriver

[![Build & Test](https://github.com/thebrowsercompany/swift-webdriver/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/thebrowsercompany/swift-webdriver/actions/workflows/build-and-test.yml)

A Swift library for UI automation of apps and browsers via communication with [WebDriver](https://w3c.github.io/webdriver/) endpoints, such as [Selenium](https://www.selenium.dev/), [Appium](http://appium.io/) or the [Windows Application Driver](https://github.com/microsoft/WinAppDriver).

`swift-webdriver` is meant to support both the [Selenium legacy JSON wire protocol](https://www.selenium.dev/documentation/legacy/json_wire_protocol/) and its successor, the W3C-standard [WebDriver protocol](https://w3c.github.io/webdriver/), against any WebDriver endpoint. In practice, it has been developed and tested for WinAppDriver-based scenarios on Windows, and may have gaps in other environments.

## Usage

A `swift-webdriver` "Hello world" using `WinAppDriver` might look like this:

```swift
let session = Session(
    webDriver: WinAppDriver.start(), // Requires WinAppDriver to be installed on the machine
    desiredCapabilities: WinAppDriver.Capabilities.startApp(name: "notepad.exe"))
session.findElement(byName: "close")?.click()
```

To use `swift-webdriver` in your project, add a reference to it in your `Package.swift` file as follows:

```swift
let package = Package(
    name: "MyPackage",
    dependencies: [
        .package(url: "https://github.com/thebrowsercompany/swift-webdriver", branch: "main")
    ],
    targets: [
        .testTarget(
            name: "UITests",
            dependencies: [
                .product(name: "WebDriver", package: "swift-webdriver"),
            ]
        )
    ]
)
```

Build and run tests using `swift build` and `swift test`, or use the [Swift extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=sswg.swift-lang).

For additional examples, refer to the `Tests\WebDriverTests` directory.

### CMake

To build with CMake, use the Ninja generator:
```powershell
cmake -S . -B build -G Ninja
cmake --build .\build\
```

## Architecture

The library has two logical layers:

- **Wire layer**: The `WebDriver` and `Request` protocols and their implementations provide a strongly-typed representation for sending REST requests to WebDriver endpoints. Each request is represented by a struct under `Requests`. The library can be used and extended only at this layer if desired.
- **Session API layer**: The `Session` and `Element` types provide an object-oriented representation of WebDriver concepts with straightforward functions for every supported command such as `findElement(id:)` and `click()`.

Where WebDriver endpoint-specific functionality is provided, such as for launching and using a WinAppDriver instance, the code is kept separate from generic WebDriver functionality as much as possible.

## Timeouts
For UI testing, it is often useful to support retrying some operations until a timeout elapses (to account for animations or asynchrony). `swift-webdriver` offers two such mechanisms:

- **Implicit wait timeout**: A duration for which `findElement` operations will implicitly wait if they cannot immediately find the element being queried. This feature is built into the WebDriver protocol, but optionally implemented by drivers. For drivers that do not support it, the library emulates it by repeating the query until the timeout elapses. By spec, this timeout defaults to zero.
- **Interaction retry timeout**: A duration for which `click`, `flick` and similar operations will retry until they result in a successful interaction (e.g. the button is not disabled). This feature is not part of the WebDriver protocol, but rather implemented by the library. This timeout defaults to zero.

## Contributing

We welcome contributions for:
- Additional command bindings from the WebDriver and Selenium legacy JSON wire protocols
- Improved support for other platforms and WebDriver endpoints

Please include tests with your submissions. Tests launching apps should rely only on GUI applications that ship with the Windows OS, such as notepad.
