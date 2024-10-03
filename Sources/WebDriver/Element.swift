import struct Foundation.TimeInterval

// Represents an element in the WebDriver protocol.
public struct Element {
    var webDriver: WebDriver { session.webDriver }
    public let session: Session
    public let id: String

    public init(session: Session, id: String) {
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

    /// Gets a value indicating whether this element is currently enabled.
    public var enabled: Bool {
        get throws {
            try webDriver.send(Requests.ElementEnabled(
                session: session.id, element: id)).value
        }
    }

    /// Clicks this element.
    public func click(retryTimeout: TimeInterval? = nil) throws {
        let request = Requests.ElementClick(session: session.id, element: id)
        try session.sendInteraction(request, retryTimeout: retryTimeout)
    }

    /// Clicks this element via touch.
    public func touchClick(kind: TouchClickKind = .single, retryTimeout: TimeInterval? = nil) throws {
        let request = Requests.SessionTouchClick(session: session.id, kind: kind, element: id)
        try session.sendInteraction(request, retryTimeout: retryTimeout)
    }

    /// Double clicks an element by id.
    public func doubleClick(retryTimeout: TimeInterval? = nil) throws {
        let request = Requests.SessionTouchDoubleClick(session: session.id, element: id)
        try session.sendInteraction(request, retryTimeout: retryTimeout)
    }

    /// - Parameters:
    ///   - retryTimeout: The amount of time to retry the operation. Overrides the implicit interaction retry timeout.
    ///   - element: Element id to click
    ///   - xOffset: The x offset in pixels to flick by.
    ///   - yOffset: The y offset in pixels to flick by.
    ///   - speed: The speed in pixels per seconds.
    public func flick(xOffset: Double, yOffset: Double, speed: Double, retryTimeout: TimeInterval? = nil) throws {
        let request = Requests.SessionTouchFlickElement(session: session.id, element: id, xOffset: xOffset, yOffset: yOffset, speed: speed)
        try session.sendInteraction(request, retryTimeout: retryTimeout)
    }

    /// Search for an element using a given locator, starting from this element.
    /// - Parameter locator: The locator strategy to use.
    /// - Parameter waitTimeout: The amount of time to wait for element existence. Overrides the implicit wait timeout.
    /// - Returns: The element that was found, if any.
    public func findElement(locator: ElementLocator, waitTimeout: TimeInterval? = nil) throws -> Element? {
        try session.findElement(startingAt: self, locator: locator, waitTimeout: waitTimeout)
    }

    /// Search for elements using a given locator, starting from this element.
    /// - Parameter using: The locator strategy to use.
    /// - Parameter waitTimeout: The amount of time to wait for element existence. Overrides the implicit wait timeout.
    /// - Returns: The elements that were found, if any.
    public func findElements(locator: ElementLocator, waitTimeout: TimeInterval? = nil) throws -> [Element] {
        try session.findElements(startingAt: self, locator: locator, waitTimeout: waitTimeout)
    }

    /// Finds an element using a given locator, starting from this element, and throwing upon failure.
    /// - Parameter locator: The locator strategy to use.
    /// - Parameter description: A human-readable description of the element, included in thrown errors.
    /// - Parameter waitTimeout: The amount of time to wait for element existence. Overrides the implicit wait timeout.
    /// - Returns: The element that was found.
    @discardableResult // for use as an assertion
    public func requireElement(locator: ElementLocator, description: String? = nil, waitTimeout: TimeInterval? = nil) throws -> Element {
        try session.requireElement(startingAt: self, locator: locator, description: description, waitTimeout: waitTimeout)
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
