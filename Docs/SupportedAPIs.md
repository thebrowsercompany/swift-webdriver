## Command Summary

This table shows a mapping between WebDriver commands, backend support (currently just WinAppDriver), and the
swift-webdriver API that implements the given command.

Contributions to expand support to unimplemented functionality are always welcome.

| Method | Command Path                                        | WinAppDriver | swift-webdriver API |
|--------|-----------------------------------------------------|--------------|---------------------|
| GET    | `/status`                                           | Supported    | `WebDriver.status`  |
| POST   | `/session`                                          | Supported    | `Session.init()`    |
| GET    | `/sessions`                                         | Supported    | Not implemented     |
| DELETE | `/session/:sessionId`                               | Supported    | `Session.delete()`, `Session.deinit()`|
| POST   | `/session/:sessionId/appium/app/launch`             | Supported    | Not implemented     |
| POST   | `/session/:sessionId/appium/app/close`              | Supported    | Not implemented     |
| POST   | `/session/:sessionId/back`                          | Supported    | `Session.back()`    |
| POST   | `/session/:sessionId/buttondown`                    | Supported    | `Session.buttonDown()`|
| POST   | `/session/:sessionId/buttonup`                      | Supported    | `Session.buttonUp()`|
| POST   | `/session/:sessionId/click`                         | Supported    | `Session.click()`   |
| POST   | `/session/:sessionId/doubleclick`                   | Supported    | `Session.doubleClick()`|
| POST   | `/session/:sessionId/element`                       | Supported    | `Session.findElement()`|
| POST   | `/session/:sessionId/elements`                      | Supported    | `Session.findElements()`|
| POST   | `/session/:sessionId/element/active`                | Supported    | `Session.activeElement`|
| GET    | `/session/:sessionId/element/:id/attribute/:name`   | Supported    | `Element.getAttribute`|
| POST   | `/session/:sessionId/element/:id/clear`             | Supported    | `Element.clear()`   |
| POST   | `/session/:sessionId/element/:id/click`             | Supported    | `Element.click()`   |
| GET    | `/session/:sessionId/element/:id/displayed`         | Supported    | `Element.displayed` |
| GET    | `/session/:sessionId/element/:id/element`           | Supported    | `Element.findElement()`|
| GET    | `/session/:sessionId/element/:id/elements`          | Supported    | `Element.findElements()`|
| GET    | `/session/:sessionId/element/:id/enabled`           | Supported    | `Element.enabled`   |
| GET    | `/session/:sessionId/element/:id/equals`            | Supported    | Not implemented     |
| GET    | `/session/:sessionId/element/:id/location`          | Supported    | `Element.location`  |
| GET    | `/session/:sessionId/element/:id/location_in_view`  | Supported    | Not implemented     |
| GET    | `/session/:sessionId/element/:id/name`              | Supported    | Not implemented     |
| GET    | `/session/:sessionId/element/:id/screenshot`        | Supported    | Not implemented     |
| GET    | `/session/:sessionId/element/:id/selected`          | Supported    | Not implemented     |
| GET    | `/session/:sessionId/element/:id/size`              | Supported    | `Element.size`      |
| GET    | `/session/:sessionId/element/:id/text`              | Supported    | `Element.text`      |
| POST   | `/session/:sessionId/element/:id/value`             | Supported    | `Element.sendKeys()`|
| POST   | `/session/:sessionId/forward`                       | Supported    | `Session.forward()` |
| POST   | `/session/:sessionId/keys`                          | Supported    | `Session.sendKeys()`|
| GET    | `/session/:sessionId/location`                      | Supported    | Not implemented     |
| POST   | `/session/:sessionId/moveto`                        | Supported    | `Session.moveTo()`  |
| GET    | `/session/:sessionId/orientation`                   | Supported    | Not implemented     |
| POST   | `/session/:sessionId/refresh`                       | Not supported| `Session.refresh()` |
| GET    | `/session/:sessionId/screenshot`                    | Supported    | `Session.screenshot()`|
| GET    | `/session/:sessionId/source`                        | Supported    | Not implemented     |
| POST   | `/session/:sessionId/timeouts`                      | Supported    | `Session.setTimeout()`|
| GET    | `/session/:sessionId/title`                         | Supported    | `Session.title`     |
| POST   | `/session/:sessionId/touch/click`                   | Supported    | `Element.touchClick()`|
| POST   | `/session/:sessionId/touch/doubleclick`             | Supported    | Not implemented     |
| POST   | `/session/:sessionId/touch/down`                    | Supported    | `Session.touchDown()`|
| POST   | `/session/:sessionId/touch/flick`                   | Supported    | Not implemented     |
| POST   | `/session/:sessionId/touch/longclick`               | Supported    | Not implemented     |
| POST   | `/session/:sessionId/touch/move`                    | Supported    | `Session.touchMove()`|
| POST   | `/session/:sessionId/touch/scroll`                  | Supported    | `Session.touchScroll()`|
| POST   | `/session/:sessionId/touch/up`                      | Supported    | `Session.touchUp()` |
| GET    | `/session/:sessionId/url`                           | Not supported| `Session.url`       |
| POST   | `/session/:sessionId/url`                           | Not supported| `Session.url()`     |
| DELETE | `/session/:sessionId/window`                        | Supported    | `Session.close()`   |
| POST   | `/session/:sessionId/window`                        | Supported    | `Session.focus()`   |
| POST   | `/session/:sessionId/window/maximize`               | Supported    | Not implemented     |
| POST   | `/session/:sessionId/window/size`                   | Supported    | Not implemented     |
| GET    | `/session/:sessionId/window/size`                   | Supported    | Not implemented     |
| POST   | `/session/:sessionId/window/:windowHandle/size`     | Supported    | `Session.resize()`  |
| GET    | `/session/:sessionId/window/:windowHandle/size`     | Supported    | `Session.size()`    |
| POST   | `/session/:sessionId/window/:windowHandle/position` | Supported    | Not implemented     |
| GET    | `/session/:sessionId/window/:windowHandle/position` | Supported    | Not implemented     |
| POST   | `/session/:sessionId/window/:windowHandle/maximize` | Supported    | Not implemented     |
| GET    | `/session/:sessionId/window_handle`                 | Supported    | Not implemented     |
| GET    | `/session/:sessionId/window_handles`                | Supported    | Not implemented     |


## Example Usage

### 1. Installing Swift
Swift-WebDriver works with Swift 5.9 and onwards. If you haven't already, install the [most recent release of swift here](https://www.swift.org/install/windows/#installation-via-windows-package-manager). Verify installation with `swift -v` in the terminal

### 2. Initialize Directory
Once you have verified the installation run the command in Windows Command Prompt:
```cmd
mkdir swift-webdriver ^
cd swift-webdriver ^
swift package init --name swift-webdriver --type executable ^
``` 

### 3. Add Swift-WebDriver
In your chosen code editor open the `Package.swift` file and add swift-webdriver to your packages. And example may look like this:
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

### 4. Use Implemented Methods
In the `main.swift` file add the following code:
```swift
var session = Session()

// Focus on the currently opened window
session.focus("<Current-Window>")

// Scroll the window down 100px relative to the pointer position
session.moveTo(nil, 0, -100)

// Screenshot the current window 
session.screenshot()

// Close the selected window
session.close("<Current-Window>")
```
Save the file and execute the command `swift run`.