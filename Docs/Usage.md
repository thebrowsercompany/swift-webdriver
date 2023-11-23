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