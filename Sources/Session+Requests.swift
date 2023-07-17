extension Session {

    /// title - the session title, usually the hwnd title
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidtitle
    public var title: String {
        let sessionTitleRequest = TitleRequest(self)
        return try! webDriver.send(sessionTitleRequest).value!
    }

    struct TitleRequest : WebDriverRequest {
        typealias ResponseValue = String

        private let session: Session

        init(_ session: Session) {
            self.session = session
        }

        var pathComponents: [String] { [ "session", session.id, "title" ] }
        var method: HTTPMethod { .get }
        var body: Body { .init() }
    }

    /// findElement(byName:)
    /// Search for an element by name, starting from the root.
    /// - Parameter byName: name of the element to search for
    ///  (https://learn.microsoft.com/en-us/windows/win32/winauto/inspect-objects)
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelement
    public func findElement(byName name: String) -> Element? {
        return findElement(using: "name", value: name)
    }

    /// findElement(byAccessibilityId:)
    /// Search for an element in the accessibility tree, starting from the root.
    /// - Parameter byAccessiblityId: accessibiilty id of the element to search for
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelement
    public func findElement(byAccessibilityId id: String) -> Element? {
        return findElement(using: "accessibility id", value: id)
    }

    /// findElement(byXPath:)
    /// Search for an element by xpath, starting from the root.
    /// - Parameter byXPath: xpath of the element to search for
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelement
    public func findElement(byXPath xpath: String) -> Element? {
        return findElement(using: "xpath", value: xpath)
    }

    /// findElement(byClassName:)
    /// Search for an element by class name, starting from the root.
    /// - Parameter byClassName: class name of the element to search for
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelement
    public func findElement(byClassName className: String) -> Element? {
        return findElement(using: "class name", value: className)
    }

    // Helper for findElement functions above
    private func findElement(using: String, value: String) -> Element? {
        let elementRequest = ElementRequest(self, using: using, value: value)
        let value: Session.ElementRequest.ResponseValue
        do {
            value = try webDriver.send(elementRequest).value!
        } catch let error as WebDriverError {
            if error.status == .noSuchElement {
                return nil
            } else {
                fatalError()
            }
        } catch {
            fatalError()
        }
        return Element(in: self, id: value.ELEMENT)
    }

    struct ElementRequest : WebDriverRequest {
        let session: Session

        init(_ session: Session, using strategy: String, value: String) {
            self.session = session
            body = .init(using: strategy, value: value)
        }

        var pathComponents: [String] { [ "session", session.id, "element" ] }
        var method: HTTPMethod { .post }
        var body: Body

        struct Body : Codable {
            var using: String
            var value: String
        }

        struct ResponseValue : Codable {
            var ELEMENT: String
        }
    }

    /// Find active (focused) element
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementactive
    public var activeElement: Element? {
        let activeElementRequest = ActiveElementRequest(self)
        var value: Session.ActiveElementRequest.ResponseValue?
        do {
            value = try webDriver.send(activeElementRequest).value
        } catch let error as WebDriverError {
            if error.status == .noSuchElement {
                return nil
            } else {
                fatalError()
            }
        } catch {
            fatalError()
        }
        return Element(in: self, id: value!.ELEMENT)
    }

    struct ActiveElementRequest : WebDriverRequest {
        let session: Session

        init(_ session: Session) {
            self.session = session
        }

        var pathComponents: [String] { [ "session", session.id, "element", "active" ] }
        var method: HTTPMethod { .post }
        var body: Body = .init()

        struct ResponseValue : Codable {
            var ELEMENT: String
        }
    }

    /// moveTo(::) - move the pointer to a location relative to the current pointer position or an element
    /// - Parameters:
    ///   - element: if not nil the top left of the element provides the origin
    ///   - xOffset: x offset from the left of the element
    ///   - yOffset: y offset from the top of the element
    public func moveTo(element: Element? = nil, xOffset: Int = 0, yOffset: Int = 0) {
        let moveToRequest = MoveToRequest(self, element: element, xOffset: xOffset, yOffset: yOffset)
        try! webDriver.send(moveToRequest)
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

        var pathComponents: [String] { [ "session", session.id, "moveto"] }
        var method: HTTPMethod { .post }
        var body: Body

        struct Body : Codable {
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
        case click = "click"
        case buttonUp = "buttonup"
        case buttonDown = "buttondown"
    }

    /// click(:) - click one of the mouse buttons
    /// - Parameter button: see MouseButton enum
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidclick
    public func click(button: MouseButton = .left) {
        let clickRequest = ButtonRequest(self, buttonRequestAction: .click, button: button)
        try! webDriver.send(clickRequest)
    }

    /// buttonDown(:) - press down one of the mouse buttons
    /// - Parameter button: see MouseButton enum
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidbuttondown
    public func buttonDown(button: MouseButton = .left) {
        let buttonDownRequest = ButtonRequest(self, buttonRequestAction: .buttonDown, button: button)
        try! webDriver.send(buttonDownRequest)
    }

    /// buttonUp(:) - release one of the mouse buttons
    /// - Parameter button: see MouseButton enum
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidbuttonup
    public func buttonUp(button: MouseButton = .left) {
        let buttonUpRequest = ButtonRequest(self, buttonRequestAction: .buttonUp, button: button)
        try! webDriver.send(buttonUpRequest)
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

        var pathComponents: [String] { [ "session", session.id, buttonRequestAction.rawValue] }
        var method: HTTPMethod { .post }
        var body: Body

        struct Body : Codable {
            var button: MouseButton
        }
    }
}