import struct Foundation.TimeInterval

// Represents an element in the WinAppDriver API
// (https://github.com/microsoft/WinAppDriver/blob/master/Docs/SupportedAPIs.md)
public struct Element {
    var webDriver: WebDriver { session.webDriver }
    public let session: Session
    public let id: String

    public init(in session: Session, id: String) {
        self.session = session
        self.id = id
    }

    /// click() - simulate clicking this Element
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidclick
    public func click(retryTimeout: TimeInterval? = nil) throws {
        let request = Requests.ElementClick(session: session.id, element: id)
        try retryUntil(retryTimeout ?? session.defaultRetryTimeout) {
            do {
                try webDriver.send(request)
                return true
            } catch let error as ErrorResponse where error.status == .winAppDriver_elementNotInteractable {
                return false
            }
        }
    }

    /// Simulates clicking this element via touch.
    public func touchClick(kind: TouchClickKind = .single, retryTimeout: TimeInterval? = nil) throws {
        let request = Requests.SessionTouchClick(session: session.id, kind: kind, element: id)
        try retryUntil(retryTimeout ?? session.defaultRetryTimeout) {
            do {
                try webDriver.send(request)
                return true
            } catch let error as ErrorResponse where error.status == .winAppDriver_elementNotInteractable {
                return false
            }
        }
    }

    /// text - the element text
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidtext
    public var text: String {
        get throws {
            try webDriver.send(Requests.ElementText(
                session: session.id, element: id)).value
        }
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
        try webDriver.send(Requests.ElementAttribute(
            session: session.id, element: id, attribute: name)).value
    }

    /// location - return x, y location of the element relative to the screen top left corner
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidlocation
    public var location: (x: Int, y: Int) {
        get throws {
            let responseValue = try webDriver.send(Requests.ElementLocation(
                session: session.id, element: id)).value
            return (responseValue.x, responseValue.y)
        }
    }

    /// size - return width, height of the element
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidsize
    public var size: (width: Int, height: Int) {
        get throws {
            let responseValue = try webDriver.send(Requests.ElementSize(
                session: session.id, element: id)).value
            return (responseValue.width, responseValue.height)
        }
    }

    /// displayed - Determine if an element is currently displayed.
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementiddisplayed
    public var displayed: Bool {
        get throws {
            try webDriver.send(Requests.ElementDisplayed(
                session: session.id, element: id)).value
        }
    }

    /// Send keys to an element
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidvalue
    public func sendKeys(value: [String]) throws {
        try webDriver.send(Requests.ElementValue(
            session: session.id, element: id, value: value))
    }

    /// Send keys to an element
    /// This overload takes a single string for simplicity
    public func sendKeys(value: String) throws { try sendKeys(value: [value]) }

    /// Clears the text of an editable element
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidclear
    public func clear() throws {
        try webDriver.send(Requests.ElementClear(
            session: session.id, element: id))
    }
}
