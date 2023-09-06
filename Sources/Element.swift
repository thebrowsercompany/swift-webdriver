import struct Foundation.TimeInterval

// Represents an element in the WebDriver protocol.
public struct Element {
    var webDriver: WebDriver { session.webDriver }
    public let session: Session
    public let id: String

    public init(in session: Session, id: String) {
        self.session = session
        self.id = id
    }

    /// The element's textual contents.
    public var text: String {
        get throws {
            try webDriver.send(Requests.ElementText(
                session: session.id, element: id)).value
        }
    }

    /// The x and y location of the element relative to the screen top left corner.
    public var location: (x: Int, y: Int) {
        get throws {
            let responseValue = try webDriver.send(Requests.ElementLocation(
                session: session.id, element: id)).value
            return (responseValue.x, responseValue.y)
        }
    }

    /// Gets the width and height of this element in pixels.
    public var size: (width: Int, height: Int) {
        get throws {
            let responseValue = try webDriver.send(Requests.ElementSize(
                session: session.id, element: id)).value
            return (responseValue.width, responseValue.height)
        }
    }

    /// Gets a value indicating whether this element is currently displayed.
    public var displayed: Bool {
        get throws {
            try webDriver.send(Requests.ElementDisplayed(
                session: session.id, element: id)).value
        }
    }

    /// Clicks this element.
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

    /// Clicks this element via touch.
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

    /// Search for an element by name, starting from this element.
    /// - Parameter byName: name of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The element that was found, if any.
    public func findElement(byName name: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(using: "name", value: name, retryTimeout: retryTimeout)
    }

    /// Search for an element in the accessibility tree, starting from this element.
    /// - Parameter byAccessiblityId: accessibiilty id of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The element that was found, if any.
    public func findElement(byAccessibilityId id: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(using: "accessibility id", value: id, retryTimeout: retryTimeout)
    }

    /// Search for an element by xpath, starting from this element.
    /// - Parameter byXPath: xpath of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: a new instance of Element wrapping the found element, nil if not found.
    public func findElement(byXPath xpath: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(using: "xpath", value: xpath, retryTimeout: retryTimeout)
    }

    /// Search for an element by class name, starting from this element.
    /// - Parameter byClassName: class name of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The element that was found, if any.
    public func findElement(byClassName className: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(using: "class name", value: className, retryTimeout: retryTimeout)
    }

    // Helper for findElement functions above.
    private func findElement(using: String, value: String, retryTimeout: TimeInterval?) throws -> Element? {
        try session.findElement(startingAt: self, using: using, value: value, retryTimeout: retryTimeout)
    }

    /// Gets an attribute of this element.
    /// - Parameter name: the attribute name.
    /// - Returns: the attribute value string.
    public func getAttribute(name: String) throws -> String {
        try webDriver.send(Requests.ElementAttribute(
            session: session.id, element: id, attribute: name)).value
    }

    /// Send keys to an element
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidvalue
    public func sendKeys(rawValue: [String]) throws {
        try webDriver.send(Requests.ElementValue(
            session: session.id, element: id, value: rawValue))
    }

    public func sendKeys(rawValue: String) throws {
        try sendKeys(rawValue: [rawValue])
    }

    public func sendKeys(_ keys: [KeyCode]) throws {
        try sendKeys(rawValue: keys.map { $0.rawValue }.joined())
    }

    public func sendKeys(_ key: KeyCode) throws {
        try sendKeys([key])
    }

    /// Clears the text of an editable element.
    public func clear() throws {
        try webDriver.send(Requests.ElementClear(
            session: session.id, element: id))
    }
}
