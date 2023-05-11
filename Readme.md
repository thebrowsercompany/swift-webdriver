# webdriver-swift

A Swift library for communicating with WebDriver endpoints such as WebDriver, Appium or WinAppDriver on Windows.

TThis library provides swift bindings wrapping the REST APIs ([documented here](https://www.selenium.dev/documentation/legacy/json_wire_protocol/) supported by these servers, in the same spirit as Selenium and Appium provide in other languages such as Objective-C or C#. WebDriver was initially targeted at web page testing (HTML content), but WinAppDriver and Appium repurpose them for application testing. As such, they implement a subset of the protocol and exhibit some other small differences. 

Documentation about WinAppDriver, for testing Windows applications, can be found on [this GitHub project](https://github.com/microsoft/WinAppDriver). The subset of APIs supported by WinAppDriver is described [here](https://github.com/microsoft/WinAppDriver/blob/master/Docs/SupportedAPIs.md).

The Swift bindings implementing in this project are organized as methods or computed properties of the main objects defined by the API, such as WebDriver, Session and Element. This allows developers to write tests using the Swift language in a natural manner, without having to concern themselves with the underlying implementation as http requests.

```swift
class WebDriver {
    public func newSession(app: String) -> Session
}

class Session {
    public var title: String
    public func findElement(byName name: String) -> Element?
}

class Element {
    public func click() 
}
```

A typical use of these bindings to implement a test that launches Notepad and clicks its `close` button would look like this:

```swift
let winAppDriver = WinAppDriverProcess()
let webDriver = WebDriver(endpoint: winAppDriver.endpoint)
let session = webDriver.createSession(app: "notepad.exe")
session.findElement(byName: "close").click()
```
For additional examples, refere to folder `Test\WebDriverTests`.

## Architecture

Examples of usage of the APIs are in the `Tests\WebDriverTests` folder, including tests for common apps such as Calculator. They are written to be callable by XCTest, Apple's testing framework. They are organized using `XCTestCase` classes and individual test method names need to start with `test` to be discovered by the testing framework.

The `setUp()` method of the `XCTestCase` class instantiates the WinAppDriver using `WinAppDriverProcess` and creates a testing session, passing it the location of the Windows app to launch as the test target. The target app will be launched and terminated for each test session.

Implementations of the bindings are in the `Sources` folder. `WebDriver.swift`, `Session.swift`, `Element.swift` implement the corresponding object structs or classes. Files with the same names followed by `+requests` implement the actual bindings as extensions of these structs or classes.

Each binding consist of a request struct confomring to the `WebDriverRequest` protocol and specializing the request, and of a method of the appropriate object instantiating that struct and passing it to `WebDriver.send<Request>(:)`. This encapsulates the specifics of the underlying http requests to that function.

## Building and running the project

In VSCode, install the Swift extension to integrate with standard build and test IDE features, including the testing sidbar, in which tests can be run or debugged individually, by XCTestCase, or all at once.

From the command line, use `swift build` and `swift test` to build or build and run tests, respectively. Refer to `swift test -help` for command parameters. 

## Contributing

We welcome contributions for:
- Additional webdriver bindings
- Better support for other platforms and webdriver endpoints
Please include tests with your submissions. Tests launching apps should rely only on GUI applications that ship with the Windows OS, such as notepad.
