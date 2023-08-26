import Foundation

extension Element {
    /// click() - simulate clicking this Element
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidclick
    public func click(retryTimeout: TimeInterval? = nil) throws {
        let request = ClickRequest(session: session.id, element: id)
        try retryUntil(retryTimeout ?? session.defaultRetryTimeout) {
            do {
                try webDriver.send(request)
                return true
            } catch let error as WebDriverError where error.status == .winAppDriver_elementNotInteractable {
                return false
            }
        }
    }

    struct ClickRequest: WebDriverRequest {
        typealias Response = WebDriverResponseNoValue

        var session: String
        var element: String

        var pathComponents: [String] { ["session", session, "element", element, "click"] }
        var method: HTTPMethod { .post }
    }

    /// text - the element text
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidtext
    public var text: String {
        get throws {
            let request = TextRequest(session: session.id, element: id)
            return try webDriver.send(request).value
        }
    }

    struct TextRequest: WebDriverRequest {
        typealias ResponseValue = String

        var session: String
        var element: String

        var pathComponents: [String] { ["session", session, "element", element, "text"] }
        var method: HTTPMethod { .get }
    }

    /// findElement(byName:)
    /// Search for an element by name, starting from this element.
    /// - Parameter byName: name of the element to search for
    ///  (https://learn.microsoft.com/en-us/windows/win32/winauto/inspect-objects)
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidelement
    public func findElement(byName name: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(using: "name", value: name, retryTimeout: retryTimeout)
    }

    /// findElement(byAccessibilityId:)
    /// Search for an element in the accessibility tree, starting from this element
    /// - Parameter byAccessiblityId: accessibiilty id of the element to search for
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidelement
    public func findElement(byAccessibilityId id: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(using: "accessibility id", value: id, retryTimeout: retryTimeout)
    }

    /// findElement(byXPath:)
    /// Search for an element by xpath, starting from this element
    /// - Parameter byXPath: xpath of the element to search for
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidelement
    public func findElement(byXPath xpath: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(using: "xpath", value: xpath, retryTimeout: retryTimeout)
    }

    /// findElement(byClassName:)
    /// Search for an element by class name, starting from this element
    /// - Parameter byClassName: class name of the element to search for
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidelement
    public func findElement(byClassName className: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(using: "class name", value: className, retryTimeout: retryTimeout)
    }

    // Helper for findElement functions above
    private func findElement(using: String, value: String, retryTimeout: TimeInterval?) throws -> Element? {
        try session.findElement(startingAt: self, using: using, value: value, retryTimeout: retryTimeout)
    }

    /// getAttribute(name:)
    /// Return a specific attribute of an element
    /// - Parameter name: the attribute name as given by inspect.exe
    /// - Returns: the attribute value string
    /// - calls fatalError for any other error
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidattributename
    public func getAttribute(name: String) throws -> String {
        let request = AttributeRequest(session: session.id, element: id, attribute: name)
        return try webDriver.send(request).value
    }

    struct AttributeRequest: WebDriverRequest {
        typealias ResponseValue = String

        var session: String
        var element: String
        var attribute: String

        var pathComponents: [String] { ["session", session, "element", element, "attribute", attribute] }
        var method: HTTPMethod { .get }
    }

    /// location - return x, y location of the element relative to the screen top left corner
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidlocation
    public var location: (x: Int, y: Int) {
        get throws {
            let request = LocationRequest(session: session.id, element: id)
            let responseValue = try webDriver.send(request).value
            return (responseValue.x, responseValue.y)
        }
    }

    struct LocationRequest: WebDriverRequest {
        var session: String
        var element: String

        var pathComponents: [String] { ["session", session, "element", element, "location"] }
        var method: HTTPMethod { .get }

        struct ResponseValue: Codable {
            let x: Int
            let y: Int
        }
    }

    /// size - return width, height of the element
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidsize
    public var size: (width: Int, height: Int) {
        get throws {
            let request = SizeRequest(session: session.id, element: id)
            let responseValue = try webDriver.send(request).value
            return (responseValue.width, responseValue.height)
        }
    }

    struct SizeRequest: WebDriverRequest {
        var session: String
        var element: String

        var pathComponents: [String] { ["session", session, "element", element, "size"] }
        var method: HTTPMethod { .get }

        struct ResponseValue: Codable {
            let width: Int
            let height: Int
        }
    }

    /// displayed - Determine if an element is currently displayed.
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementiddisplayed
    public var displayed: Bool {
        get throws {
            let request = DisplayedRequest(session: session.id, element: id)
            return try webDriver.send(request).value
        }
    }

    struct DisplayedRequest: WebDriverRequest {
        var session: String
        var element: String

        var pathComponents: [String] { ["session", session, "element", element, "displayed"] }
        var method: HTTPMethod { .get }

        // Override the whole Response struct instead of just ResponseValue
        // because the value property is a boolean instead of a struct
        // and Bool does not conform to Codable.
        struct Response: Codable {
            // We don't care about the session id and other fields
            let value: Bool
        }
    }

    /// Send keys to an element
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidvalue
    public func sendKeys(value: [String]) throws {
        let request = KeysRequest(session: session.id, element: id, value: value)
        try webDriver.send(request)
    }

    /// Send keys to an element
    /// This overload takes a single string for simplicity
    public func sendKeys(value: String) throws { try sendKeys(value: [value]) }

    struct KeysRequest: WebDriverRequest {
        typealias Response = WebDriverResponseNoValue

        var session: String
        var element: String
        var value: [String]

        var pathComponents: [String] { ["session", session, "element", element, "value"] }
        var method: HTTPMethod { .post }
        var body: Body { Body(value: value) }

        struct Body: Codable {
            var value: [String]
        }
    }
}
