import Foundation

extension Session {
    /// title - the session title, usually the hwnd title
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidtitle
    public var title: String {
        get throws {
            let sessionTitleRequest = TitleRequest(self)
            return try webDriver.send(sessionTitleRequest).value
        }
    }

    struct TitleRequest: WebDriverRequest {
        typealias ResponseValue = String

        private let session: Session

        init(_ session: Session) {
            self.session = session
        }

        var pathComponents: [String] { ["session", session.id, "title"] }
        var method: HTTPMethod { .get }
        var body: Body { .init() }
    }

    /// screenshot()
    /// Take a screenshot of the current page.
    /// - Returns: The screenshot Data.
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidscreenshot
    public func makePNGScreenshot() throws -> Data {
        let screenshotRequest = ScreenshotRequest(self)

        let base64: String = try webDriver.send(screenshotRequest).value
        guard let data = Data(base64Encoded: base64) else {
            let codingPath = [WebDriverResponse<String>.CodingKeys.value]
            let description = "Invalid Base64 string while decoding screenshot response."
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: description))
        }
        return data
    }

    struct ScreenshotRequest: WebDriverRequest {
        typealias ResponseValue = String

        private let session: Session
        init(_ session: Session) {
            self.session = session
        }

        var pathComponents: [String] { ["session", session.id, "screenshot"] }
        var method: HTTPMethod { .get }
        var body: Body { .init() }
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
        let elementRequest = ElementRequest(self, startingAt: element, using: using, value: value)

        let element = try retryUntil(retryTimeout ?? defaultRetryTimeout) {
            let responseValue: ElementRequest.ResponseValue
            do {
                responseValue = try webDriver.send(elementRequest).value
                return Element(in: self, id: responseValue.ELEMENT)
            } catch let error as WebDriverError where error.status == .noSuchElement {
                return nil
            }
        }
        return element
    }

    struct ElementRequest: WebDriverRequest {
        let session: Session
        let element: Element?

        init(_ session: Session, startingAt element: Element?, using strategy: String, value: String) {
            self.session = session
            self.element = element
            body = .init(using: strategy, value: value)
        }

        var pathComponents: [String] {
            if let element {
                return ["session", session.id, "element", element.id, "element"]
            } else {
                return ["session", session.id, "element"]
            }
        }

        var method: HTTPMethod { .post }
        var body: Body

        struct Body: Codable {
            var using: String
            var value: String
        }

        struct ResponseValue: Codable {
            var ELEMENT: String
        }
    }

    /// Find active (focused) element
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementactive
    public var activeElement: Element? {
        get throws {
            let activeElementRequest = ActiveElementRequest(self)
            var value: Session.ActiveElementRequest.ResponseValue
            do {
                value = try webDriver.send(activeElementRequest).value
            } catch let error as WebDriverError where error.status == .noSuchElement {
                return nil
            }
            return Element(in: self, id: value.ELEMENT)
        }
    }

    struct ActiveElementRequest: WebDriverRequest {
        let session: Session

        init(_ session: Session) {
            self.session = session
        }

        var pathComponents: [String] { ["session", session.id, "element", "active"] }
        var method: HTTPMethod { .post }
        var body: Body = .init()

        struct ResponseValue: Codable {
            var ELEMENT: String
        }
    }

    /// moveTo(::) - move the pointer to a location relative to the current pointer position or an element
    /// - Parameters:
    ///   - element: if not nil the top left of the element provides the origin
    ///   - xOffset: x offset from the left of the element
    ///   - yOffset: y offset from the top of the element
    public func moveTo(element: Element? = nil, xOffset: Int = 0, yOffset: Int = 0) throws {
        let moveToRequest = MoveToRequest(self, element: element, xOffset: xOffset, yOffset: yOffset)
        try webDriver.send(moveToRequest)
    }

    struct MoveToRequest: WebDriverRequest {
        typealias ResponseValue = CodableNone

        let session: Session
        let element: Element?

        init(_ session: Session, element: Element?, xOffset: Int, yOffset: Int) {
            self.session = session
            self.element = element
            body = .init(elementId: element?.id ?? "", xOffset: xOffset, yOffset: yOffset)
        }

        var pathComponents: [String] { ["session", session.id, "moveto"] }
        var method: HTTPMethod { .post }
        var body: Body

        struct Body: Codable {
            var elementId: String
            var xOffset: Int
            var yOffset: Int
            enum CodingKeys: String, CodingKey {
                case elementId = "element"
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
        let clickRequest = ButtonRequest(self, buttonRequestAction: .click, button: button)
        try webDriver.send(clickRequest)
    }

    /// buttonDown(:) - press down one of the mouse buttons
    /// - Parameter button: see MouseButton enum
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidbuttondown
    public func buttonDown(button: MouseButton = .left) throws {
        let buttonDownRequest = ButtonRequest(self, buttonRequestAction: .buttonDown, button: button)
        try webDriver.send(buttonDownRequest)
    }

    /// buttonUp(:) - release one of the mouse buttons
    /// - Parameter button: see MouseButton enum
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidbuttonup
    public func buttonUp(button: MouseButton = .left) throws {
        let buttonUpRequest = ButtonRequest(self, buttonRequestAction: .buttonUp, button: button)
        try webDriver.send(buttonUpRequest)
    }

    struct ButtonRequest: WebDriverRequest {
        typealias ResponseValue = CodableNone

        let session: Session
        let buttonRequestAction: ButtonRequestAction

        init(_ session: Session, buttonRequestAction: ButtonRequestAction, button: MouseButton) {
            self.session = session
            body = .init(button: button)
            self.buttonRequestAction = buttonRequestAction
        }

        var pathComponents: [String] { ["session", session.id, buttonRequestAction.rawValue] }
        var method: HTTPMethod { .post }
        var body: Body

        struct Body: Codable {
            var button: MouseButton
        }
    }

    /// sendKeys(:) - send key strokes to the session
    /// - Parameter value: key strokes to send
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidkeys
    public func sendKeys(value: [String]) throws {
        let keysRequest = KeysRequest(self, value: value)
        try webDriver.send(keysRequest)
    }

    /// Send keys to the session
    /// This overload takes a single string for simplicity
    public func sendKeys(value: String) throws {
        let keysRequest = KeysRequest(self, value: [value])
        try webDriver.send(keysRequest)
    }

    struct KeysRequest: WebDriverRequest {
        typealias ResponseValue = CodableNone

        let session: Session
        init(_ session: Session, value: [String]) {
            self.session = session
            body = .init(value: value)
        }

        var pathComponents: [String] { ["session", session.id, "keys"] }
        var method: HTTPMethod { .post }
        var body: Body

        struct Body: Codable {
            var value: [String]
        }
    }
}
