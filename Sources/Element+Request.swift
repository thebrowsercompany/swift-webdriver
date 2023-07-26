import Foundation

extension Element {
    /// click() - simulate clicking this Element
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidclick
    public func click() {
        let clickRequest = ClickRequest(element: self)
        try! webDriver.send(clickRequest)
    }

    struct ClickRequest: WebDriverRequest {
        typealias ResponseValue = WebDriverNoResponseValue

        private let element: Element

        init(element: Element) {
            self.element = element
        }

        var pathComponents: [String] { ["session", element.session.id, "element", element.id, "click"] }
        var method: HTTPMethod { .post }
        var body: Body { .init() }
    }

    /// text - the element text
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidtext
    public var text: String {
        let textRequest = TextRequest(element: self)
        return try! webDriver.send(textRequest).value!
    }

    struct TextRequest: WebDriverRequest {
        typealias ResponseValue = String

        private let element: Element

        init(element: Element) {
            self.element = element
        }

        var pathComponents: [String] { ["session", element.session.id, "element", element.id, "text"] }
        var method: HTTPMethod { .get }
        var body: Body { .init() }
    }

    /// findElement(byName:)
    /// Search for an element by name, starting from this element.
    /// - Parameter byName: name of the element to search for
    ///  (https://learn.microsoft.com/en-us/windows/win32/winauto/inspect-objects)
    /// - Parameter retryTimeout: Optional value to override Session.defaultRetryTimeout.
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidelement
    public func findElement(byName name: String, retryTimeout: TimeInterval? = nil) -> Element? {
        findElement(using: "name", value: name, retryTimeout: retryTimeout)
    }

    /// findElement(byAccessibilityId:)
    /// Search for an element in the accessibility tree, starting from this element
    /// - Parameter byAccessiblityId: accessibiilty id of the element to search for
    /// - Parameter retryTimeout: Optional value to override Session.defaultRetryTimeout.
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidelement
    public func findElement(byAccessibilityId id: String, retryTimeout: TimeInterval? = nil) -> Element? {
        findElement(using: "accessibility id", value: id, retryTimeout: retryTimeout)
    }

    /// findElement(byXPath:)
    /// Search for an element by xpath, starting from this element
    /// - Parameter byXPath: xpath of the element to search for
    /// - Parameter retryTimeout: Optional value to override Session.defaultRetryTimeout.
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidelement
    public func findElement(byXPath xpath: String, retryTimeout: TimeInterval? = nil) -> Element? {
        findElement(using: "xpath", value: xpath, retryTimeout: retryTimeout)
    }

    /// findElement(byClassName:)
    /// Search for an element by class name, starting from this element
    /// - Parameter byClassName: class name of the element to search for
    /// - Parameter retryTimeout: Optional value to override Session.defaultRetryTimeout.
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidelement
    public func findElement(byClassName className: String, retryTimeout: TimeInterval? = nil) -> Element? {
        findElement(using: "class name", value: className, retryTimeout: retryTimeout)
    }

    // Helper for findElement functions above
    private func findElement(using: String, value: String, retryTimeout: TimeInterval?) -> Element? {
        session.findElement(startingAt: self, using: using, value: value, retryTimeout: retryTimeout)
    }

    /// getAttribute(name:)
    /// Return a specific attribute of an element
    /// - Parameter name: the attribute name as given by inspect.exe
    /// - Returns: the attribute value string
    /// - calls fatalError for any other error
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidattributename
    public func getAttribute(name: String) -> String {
        let attributeRequest = AttributeRequest(self, name: name)
        return try! webDriver.send(attributeRequest).value!
    }

    struct AttributeRequest: WebDriverRequest {
        typealias ResponseValue = String

        let element: Element
        let name: String

        init(_ element: Element, name: String) {
            self.element = element
            self.name = name
        }

        var pathComponents: [String] { ["session", element.session.id, "element", element.id, "attribute", name] }
        var method: HTTPMethod { .get }
        var body: Body = .init()
    }

    /// location - return x, y location of the element relative to the screen top left corner
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidlocation
    public var location: (x: Int, y: Int) {
        let locationRequest = LocationRequest(element: self)
        let responseValue = try! webDriver.send(locationRequest).value!
        return (responseValue.x, responseValue.y)
    }

    struct LocationRequest: WebDriverRequest {
        private let element: Element

        init(element: Element) {
            self.element = element
        }

        var pathComponents: [String] { ["session", element.session.id, "element", element.id, "location"] }
        var method: HTTPMethod { .get }
        var body: Body = .init()

        struct ResponseValue: Codable {
            let x: Int
            let y: Int
        }
    }

    /// size - return width, height of the element
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidsize
    public var size: (width: Int, height: Int) {
        let sizeRequest = SizeRequest(element: self)
        let response = try! webDriver.send(sizeRequest)
        let responseValue = response.value!
        return (responseValue.width, responseValue.height)
    }

    struct SizeRequest: WebDriverRequest {
        private let element: Element

        init(element: Element) {
            self.element = element
        }

        var pathComponents: [String] { ["session", element.session.id, "element", element.id, "size"] }
        var method: HTTPMethod { .get }
        var body: Body { .init() }

        struct ResponseValue: Codable {
            let width: Int
            let height: Int
        }
    }

    /// displayed - Determine if an element is currently displayed.
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementiddisplayed
    public var displayed: Bool {
        let displayedRequest = DisplayedRequest(element: self)
        return try! webDriver.send(displayedRequest).value
    }

    struct DisplayedRequest: WebDriverRequest {
        private let element: Element

        init(element: Element) {
            self.element = element
        }

        var pathComponents: [String] { ["session", element.session.id, "element", element.id, "displayed"] }
        var method: HTTPMethod { .get }
        var body: Body = .init()

        // Override the whole Response struct instead of just ResponseValue
        // because the value property is a boolean instead of a struct
        // and Bool does not conform to Codable.
        struct Response: Codable {
            // Don't care about session id, other fields
            let value: Bool
        }
    }

    /// Send keys to an element
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidvalue
    public func sendKeys(value: [String]) {
        let keysRequest = KeysRequest(element: self, value: value)
        try! webDriver.send(keysRequest)
    }

    /// Send keys to an element
    /// This overload takes a single string for simplicity
    public func sendKeys(value: String) {
        let keysRequest = KeysRequest(element: self, value: [value])
        try! webDriver.send(keysRequest)
    }

    struct KeysRequest: WebDriverRequest {
        typealias ResponseValue = CodableNone

        private let element: Element

        init(element: Element, value: [String]) {
            self.element = element
            body = .init(value: value)
        }

        var pathComponents: [String] { ["session", element.session.id, "element", element.id, "value"] }
        var method: HTTPMethod { .post }
        var body: Body

        struct Body: Codable {
            var value: [String]
        }
    }
}
