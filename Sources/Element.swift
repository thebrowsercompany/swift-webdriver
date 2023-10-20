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
        let result = try poll(timeout: retryTimeout ?? session.defaultRetryTimeout) {
            do {
                // Immediately bubble most failures, only retry on element not interactable.
                try webDriver.send(request)
                return PollResult.success(nil as ErrorResponse?)
            } catch let error as ErrorResponse where error.status == .winAppDriver_elementNotInteractable {
                return PollResult.failure(error)
            }
        }

        if let notInteractableError = result.value { throw notInteractableError }
    }

    /// Clicks this element via touch.
    public func touchClick(kind: TouchClickKind = .single, retryTimeout: TimeInterval? = nil) throws {
        let request = Requests.SessionTouchClick(session: session.id, kind: kind, element: id)
        let result = try poll(timeout: retryTimeout ?? session.defaultRetryTimeout) {
            do {
                // Immediately bubble most failures, only retry on element not interactable.
                try webDriver.send(request)
                return PollResult.success(nil as ErrorResponse?)
            } catch let error as ErrorResponse where error.status == .winAppDriver_elementNotInteractable {
                return PollResult.failure(error)
            }
        }

        if let notInteractableError = result.value { throw notInteractableError }
    }

    /// Finds an element by id, starting from this element.
    /// - Parameter byId: id of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The element that was found, if any.
    public func findElement(byId id: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(using: "id", value: id, retryTimeout: retryTimeout)
    }

    /// Search for an element by name, starting from this element.
    /// - Parameter byName: name of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The element that was found, if any.
    public func findElement(byName name: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(using: "name", value: name, retryTimeout: retryTimeout)
    }

    /// Search for an element in the accessibility tree, starting from this element.
    /// - Parameter byAccessibilityId: accessibiilty id of the element to search for.
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

    /// Search for elements by id, starting from this element.
    /// - Parameter byId: id of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The elements that were found, if any.

    public func findElements(byId id: String, retryTimeout: TimeInterval? = nil) throws -> [Element]? {
        try findElements(using: "id", value: id, retryTimeout: retryTimeout)
    }

    /// Search for elements by name, starting from this element.
    /// - Parameter byName: name of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The elements that were found, if any.

    public func findElements(byName name: String, retryTimeout: TimeInterval? = nil) throws -> [Element]? {
        try findElements(using: "name", value: name, retryTimeout: retryTimeout)
    }

    /// Search for elements in the accessibility tree, starting from this element.
    /// - Parameter byAccessibilityId: accessibiilty id of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The elements that were found, if any.
    public func findElements(byAccessibilityId id: String, retryTimeout: TimeInterval? = nil) throws -> [Element]? {
        try findElements(using: "accessibility id", value: id, retryTimeout: retryTimeout)
    }

    /// Search for elements by xpath, starting from this element.
    /// - Parameter byXPath: xpath of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The elements that were found, if any.
    public func findElements(byXPath xpath: String, retryTimeout: TimeInterval? = nil) throws -> [Element]? {
        try findElements(using: "xpath", value: xpath, retryTimeout: retryTimeout)
    }

    /// Search for elements by class name, starting from this element.
    /// - Parameter byClassName: class name of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The elements that were found, if any.
    public func findElements(byClassName className: String, retryTimeout: TimeInterval? = nil) throws -> [Element]? {
        try findElements(using: "class name", value: className, retryTimeout: retryTimeout)
    }

    // Helper for findElements functions above.
    private func findElements(using: String, value: String, retryTimeout: TimeInterval?) throws -> [Element]? {
        try session.findElements(startingAt: self, using: using, value: value, retryTimeout: retryTimeout)
    }

    /// Gets an attribute of this element.
    /// - Parameter name: the attribute name.
    /// - Returns: the attribute value string.
    public func getAttribute(name: String) throws -> String {
        try webDriver.send(Requests.ElementAttribute(
            session: session.id, element: id, attribute: name)).value
    }

    /// Sends key presses to this element.
    /// - Parameter keys: An array of key sequences according to the WebDriver spec.
    public func sendKeys(_ keys: [Keys]) throws {
        try webDriver.send(Requests.ElementValue(
            session: session.id, element: id, value: keys.map { $0.rawValue }))
    }

    /// Sends key presses to this element.
    /// - Parameter keys: A key sequence according to the WebDriver spec.
    public func sendKeys(_ keys: Keys) throws {
        try webDriver.send(Requests.ElementValue(
            session: session.id, element: id, value: [keys.rawValue]))
    }

    /// Clears the text of an editable element.
    public func clear() throws {
        try webDriver.send(Requests.ElementClear(
            session: session.id, element: id))
    }
}
