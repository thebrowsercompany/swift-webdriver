import Foundation

extension Session {
    /// title - the session title, usually the hwnd title
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidtitle
    public var title: String {
        get throws {
            let request = TitleRequest(session: id)
            return try webDriver.send(request).value
        }
    }

    struct TitleRequest: WebDriverRequest {
        typealias ResponseValue = String

        var session: String

        var pathComponents: [String] { ["session", session, "title"] }
        var method: HTTPMethod { .get }
    }

    /// screenshot()
    /// Take a screenshot of the current page.
    /// - Returns: The screenshot data as a PNG file.
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidscreenshot
    public func screenshot() throws -> Data {
        let request = ScreenshotRequest(session: id)

        let base64: String = try webDriver.send(request).value
        guard let data = Data(base64Encoded: base64) else {
            let codingPath = [WebDriverResponse<String>.CodingKeys.value]
            let description = "Invalid Base64 string while decoding screenshot response."
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: description))
        }
        return data
    }

    struct ScreenshotRequest: WebDriverRequest {
        typealias ResponseValue = String

        var session: String

        var pathComponents: [String] { ["session", session, "screenshot"] }
        var method: HTTPMethod { .get }
    }

    /// findElement(byName:)
    /// Search for an element by name, starting from the root.
    /// - Parameter byName: name of the element to search for
    ///  (https://learn.microsoft.com/en-us/windows/win32/winauto/inspect-objects)
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelement
    public func findElement(byName name: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(startingAt: nil, using: "name", value: name, retryTimeout: retryTimeout)
    }

    /// findElement(byAccessibilityId:)
    /// Search for an element in the accessibility tree, starting from the root.
    /// - Parameter byAccessiblityId: accessibiilty id of the element to search for
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelement
    public func findElement(byAccessibilityId id: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(startingAt: nil, using: "accessibility id", value: id, retryTimeout: retryTimeout)
    }

    /// findElement(byXPath:)
    /// Search for an element by xpath, starting from the root.
    /// - Parameter byXPath: xpath of the element to search for
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelement
    public func findElement(byXPath xpath: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(startingAt: nil, using: "xpath", value: xpath, retryTimeout: retryTimeout)
    }

    /// findElement(byClassName:)
    /// Search for an element by class name, starting from the root.
    /// - Parameter byClassName: class name of the element to search for
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelement
    public func findElement(byClassName className: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(startingAt: nil, using: "class name", value: className, retryTimeout: retryTimeout)
    }

    // Helper for findElement functions above.
    internal func findElement(startingAt element: Element?, using: String, value: String, retryTimeout: TimeInterval?) throws -> Element? {
        let request = ElementRequest(session: id, element: element?.id, using: using, value: value)

        let element = try retryUntil(retryTimeout ?? defaultRetryTimeout) {
            do {
                let responseValue = try webDriver.send(request).value
                return Element(in: self, id: responseValue.element)
            } catch let error as WebDriverError where error.status == .noSuchElement {
                return nil
            }
        }
        return element
    }

    struct ElementRequest: WebDriverRequest {
        var session: String
        var element: String?
        var using: String
        var value: String

        var pathComponents: [String] {
            if let element {
                return ["session", session, "element", element, "element"]
            } else {
                return ["session", session, "element"]
            }
        }

        var method: HTTPMethod { .post }
        var body: Body { .init(using: using, value: value) }

        struct Body: Codable {
            var using: String
            var value: String
        }

        struct ResponseValue: Codable {
            var element: String

            enum CodingKeys: String, CodingKey {
                case element = "ELEMENT"
            }
        }
    }

    /// Find active (focused) element
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementactive
    public var activeElement: Element? {
        get throws {
            let request = ActiveElementRequest(session: id)
            do {
                let value = try webDriver.send(request).value
                return Element(in: self, id: value.element)
            } catch let error as WebDriverError where error.status == .noSuchElement {
                return nil
            }
        }
    }

    struct ActiveElementRequest: WebDriverRequest {
        var session: String

        var pathComponents: [String] { ["session", session, "element", "active"] }
        var method: HTTPMethod { .post }

        struct ResponseValue: Codable {
            var element: String

            enum CodingKeys: String, CodingKey {
                case element = "ELEMENT"
            }
        }
    }

    /// moveTo(::) - move the pointer to a location relative to the current pointer position or an element
    /// - Parameters:
    ///   - element: if not nil the top left of the element provides the origin
    ///   - xOffset: x offset from the left of the element
    ///   - yOffset: y offset from the top of the element
    public func moveTo(element: Element? = nil, xOffset: Int = 0, yOffset: Int = 0) throws {
        precondition(element?.session == nil || element?.session === self)
        let request = MoveToRequest(session: id, element: element?.id, xOffset: xOffset, yOffset: yOffset)
        try webDriver.send(request)
    }

    struct MoveToRequest: WebDriverRequest {
        typealias Response = WebDriverResponseNoValue

        var session: String
        var element: String?
        var xOffset: Int
        var yOffset: Int

        var pathComponents: [String] { ["session", session, "moveto"] }
        var method: HTTPMethod { .post }
        var body: Body { .init(element: element, xOffset: xOffset, yOffset: yOffset) }

        struct Body: Codable {
            var element: String?
            var xOffset: Int
            var yOffset: Int
            enum CodingKeys: String, CodingKey {
                case element = "element"
                case xOffset = "xoffset"
                case yOffset = "yoffset"
            }
        }
    }

    enum ButtonRequestAction: String {
        case click
        case buttonUp = "buttonup"
        case buttonDown = "buttondown"
    }

    /// click(:) - click one of the mouse buttons
    /// - Parameter button: see MouseButton enum
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidclick
    public func click(button: MouseButton = .left) throws {
        let request = ButtonRequest(session: id, action: .click, button: button)
        try webDriver.send(request)
    }

    /// buttonDown(:) - press down one of the mouse buttons
    /// - Parameter button: see MouseButton enum
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidbuttondown
    public func buttonDown(button: MouseButton = .left) throws {
        let request = ButtonRequest(session: id, action: .buttonDown, button: button)
        try webDriver.send(request)
    }

    /// buttonUp(:) - release one of the mouse buttons
    /// - Parameter button: see MouseButton enum
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidbuttonup
    public func buttonUp(button: MouseButton = .left) throws {
        let request = ButtonRequest(session: id, action: .buttonUp, button: button)
        try webDriver.send(request)
    }

    struct ButtonRequest: WebDriverRequest {
        typealias Response = WebDriverResponseNoValue

        var session: String
        var action: ButtonRequestAction
        var button: MouseButton

        var pathComponents: [String] { ["session", session, action.rawValue] }
        var method: HTTPMethod { .post }
        var body: Body { .init(button: button) }

        struct Body: Codable {
            var button: MouseButton
        }
    }

    /// sendKeys(:) - send key strokes to the session
    /// - Parameter value: key strokes to send
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidkeys
    public func sendKeys(value: [String]) throws {
        let request = KeysRequest(session: id, value: value)
        try webDriver.send(request)
    }

    /// Send keys to the session
    /// This overload takes a single string for simplicity
    public func sendKeys(value: String) throws {
        return try sendKeys(value: [value])
    }

    struct KeysRequest: WebDriverRequest {
        typealias Response = WebDriverResponseNoValue

        var session: String
        var value: [String]

        var pathComponents: [String] { ["session", session, "keys"] }
        var method: HTTPMethod { .post }
        var body: Body { .init(value: value) }

        struct Body: Codable {
            var value: [String]
        }
    }
}
