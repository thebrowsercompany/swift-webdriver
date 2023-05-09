# webdriver-swift

A Swift library for communicating with WebDriver endpoints such as WebDriver, Appium or WinAppDriver on Windows.

This libraray provides swift bindings wrapping the REST API's supported by these servers, in the same spirit as Selenium or WinAppDriver do in other language such as ObjC or C#. A description of these API's can be found [here](https://www.selenium.dev/documentation/legacy/json_wire_protocol/). Not that these APIs were initialy targetted at web page testing (HTML content). WinAppDriver and Appium repurposed them for application testing and has such, implement a subset of the protocol and exhibit some other small differences. 

Documentation about WinAppDriver, which we will use for testing Arc can be found on [this GitHub project](https://github.com/microsoft/WinAppDriver). The subset of APIs supported by WinAppDriver is described [here](https://github.com/microsoft/WinAppDriver/blob/master/Docs/SupportedAPIs.md).

The Swift bindings implementing in this project are organized as methods or computed properties of the main objects defined by the API, such as WebDriver, Session and Element. This allows developers to write tests using the Swift language in a natural manner, without having to concern themselves with the underlying implementation as http requests.

```
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


## Architecture

Examples of usage of the APIs are in the `Tests\WebDriverTests` folder, including tests for common apps such as Calculator. They are written to be callable by XCTest, Apple's testing framework. They are organized using `XCTestCase` classes and individual test method names need to start with `test` to be discovered by the testing framework.

The `setUp()` method of the `XCTestCase` class instantiates the WinAppDriver using `WinAppDriverProcess` and create a testing session, passing it the location of the Windows app to launch as the test target. The target app will be launched and terminated for each test session.

Implementations of the bindings are in the `Sources` folder. `WebDriver.swift`, `Session.swift`, `Element.swift` implement the corresponding object structs or classes. Files with the same names followed by `+requests` implement the actual bindings.

Each binding consist of a request struct confomring to the `WebDriverRequest` protocol and specializing the request, and of a method of the appropriate object instantiating that struct and passing it to `WebDriver.send<Request>(:)`. This allows to encapsulate the specifics of the underlying http requests to that function.

## Building and running the project

In VSCode, the project can be built and run with the following command in the Terminal: 
```
> swift test
```
This will build the project, discover the tests, run them and report results in the Output window.

Using the Testing VSCode extension (in the left bar in VSCode), tests can be run or debugged individually, by XCTestCase, or all at once.

## Contributing

Only a relatively small set of the bdingins are currently implemented. We intend to implement the rest as needed. As such, if you are writing tests for Arc or another application and find a missing binding, you are encouraged to submit a PR with the implementation of said binding. When you add a new binding, please also add tests in the `Text\WedDriverTests` folder exercising these bidings on a well known Windows application (such as Calendar or Notepad) as a way to test the bindings themselves.
