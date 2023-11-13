import Foundation

/// Represents a session in the WebDriver protocol,
/// which manages the lifetime of a page or app under UI automation.
public class Session {
    public let webDriver: any WebDriver
    public let id: String
    public let windowHandle: String
    public let capabilities: Capabilities
    private var shouldDelete: Bool = true

    public init(webDriver: any WebDriver, desiredCapabilities: Capabilities, requiredCapabilities: Capabilities? = nil) throws {
        self.webDriver = webDriver
        let response = try webDriver.send(Requests.Session(
            desiredCapabilities: desiredCapabilities, requiredCapabilities: requiredCapabilities))
        self.id = response.sessionId
        self.capabilities = response.value
    }

    public init(webDriver: any WebDriver, existingId: String, capabilities: Capabilities = Capabilities(), owned: Bool = false) {
        self.webDriver = webDriver
        self.id = existingId
        self.capabilities = capabilities
        self.shouldDelete = owned
    }

    public init(webDriver: any WebDriver, existingId: String, windowHandle: String, capabilities: Capabilities = Capabilities(), owned: Bool = false) {
        self.webDriver = webDriver
        self.id = existingId
        self.windowHandle = windowHandle
        self.capabilities = capabilities
        self.shouldDelete = owned
    }

    /// A TimeInterval specifying max time to spend retrying operations.
    public var defaultRetryTimeout: TimeInterval = 1.0 {
        willSet { precondition(newValue >= 0) }
    }

    /// The title of this session such as the tab or window text.
    public var title: String {
        get throws {
            try webDriver.send(Requests.SessionTitle(session: id)).value
        }
    }

    /// The current URL of this session.
    public var url: URL {
        get throws {
            guard let result = URL(string: try webDriver.send(Requests.SessionUrl.Get(session: id)).value) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: [Requests.SessionUrl.Get.Response.CodingKeys.value],
                        debugDescription: "Invalid url format."))
            }
            return result
        }
    }

    /// Navigates to a given URL.
    /// This is logically a setter for the 'url' property,
    /// but Swift doesn't support throwing setters.
    public func url(_ url: URL) throws {
        try webDriver.send(Requests.SessionUrl.Post(session: id, url: url.absoluteString))
    }

    /// The active (focused) element.
    public var activeElement: Element? {
        get throws {
            do {
                let response = try webDriver.send(Requests.SessionActiveElement(session: id))
                return Element(session: self, id: response.value.element)
            } catch let error as ErrorResponse where error.status == .noSuchElement {
                return nil
            }
        }
    }

    /// Sets a a timeout value on this session.
    public func setTimeout(type: String, duration: TimeInterval) throws {
        try webDriver.send(
            Requests.SessionTimeouts(session: id, type: type, ms: duration * 1000))
    }

    public func back() throws {
        try webDriver.send(Requests.SessionBack(session: id))
    }

    public func forward() throws {
        try webDriver.send(Requests.SessionForward(session: id))
    }

    public func refresh() throws {
        try webDriver.send(Requests.SessionRefresh(session: id))
    }

    /// Takes a screenshot of the current page.
    /// - Returns: The screenshot data as a PNG file.
    public func screenshot() throws -> Data {
        let base64: String = try webDriver.send(
            Requests.SessionScreenshot(session: id)).value
        guard let data = Data(base64Encoded: base64) else {
            let codingPath = [Requests.SessionScreenshot.Response.CodingKeys.value]
            let description = "Invalid Base64 string while decoding screenshot response."
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: description))
        }
        return data
    }

    /// Finds an element by id, starting from the root.
    /// - Parameter byId: id of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The element that was found, if any.
    public func findElement(byId id: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(startingAt: nil, using: "id", value: id, retryTimeout: retryTimeout)
    }

    /// Finds an element by name, starting from the root.
    /// - Parameter byName: name of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The element that was found, if any.
    public func findElement(byName name: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(startingAt: nil, using: "name", value: name, retryTimeout: retryTimeout)
    }

    /// Finds an element by accessibility id, starting from the root.
    /// - Parameter byAccessibilityId: accessibiilty id of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The element that was found, if any.
    public func findElement(byAccessibilityId id: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(startingAt: nil, using: "accessibility id", value: id, retryTimeout: retryTimeout)
    }

    /// Finds an element by xpath, starting from the root.
    /// - Parameter byXPath: xpath of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The element that was found, if any.
    public func findElement(byXPath xpath: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(startingAt: nil, using: "xpath", value: xpath, retryTimeout: retryTimeout)
    }

    /// Finds an element by class name, starting from the root.
    /// - Parameter byClassName: class name of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The element that was found, if any.
    public func findElement(byClassName className: String, retryTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(startingAt: nil, using: "class name", value: className, retryTimeout: retryTimeout)
    }

    // Helper for findElement functions above.
    internal func findElement(startingAt element: Element?, using: String, value: String, retryTimeout: TimeInterval?) throws -> Element? {
        precondition(element == nil || element?.session === self)

        let request = Requests.SessionElement(session: id, element: element?.id, using: using, value: value)

        let elementId = try poll(timeout: retryTimeout ?? defaultRetryTimeout) {
            let elementId: String?
            do {
                // Allow errors to bubble up unless they are specifically saying that the element was not found.
                elementId = try webDriver.send(request).value.element
            } catch let error as ErrorResponse where error.status == .noSuchElement {
                elementId = nil
            }

            return PollResult(value: elementId, success: elementId != nil)
        }.value

        return elementId.map { Element(session: self, id: $0) }
    }

    /// Finds elements by id, starting from the root.
    /// - Parameter byId: id of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The elements that were found, if any.
    public func findElements(byId id: String, retryTimeout: TimeInterval? = nil) throws -> [Element] {
        try findElements(startingAt: nil, using: "id", value: id, retryTimeout: retryTimeout)
    }

    /// Finds elements by name, starting from the root.
    /// - Parameter byName: name of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The elements that were found, if any.
    public func findElements(byName name: String, retryTimeout: TimeInterval? = nil) throws -> [Element] {
        try findElements(startingAt: nil, using: "name", value: name, retryTimeout: retryTimeout)
    }

    /// Finds elements by accessibility id, starting from the root.
    /// - Parameter byAccessibilityId: accessibiilty id of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The elements that were found, if any.
    public func findElements(byAccessibilityId id: String, retryTimeout: TimeInterval? = nil) throws -> [Element] {
        try findElements(startingAt: nil, using: "accessibility id", value: id, retryTimeout: retryTimeout)
    }

    /// Finds elements by xpath, starting from the root.
    /// - Parameter byXPath: xpath of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The elements that were found, if any.
    public func findElements(byXPath xpath: String, retryTimeout: TimeInterval? = nil) throws -> [Element] {
        try findElements(startingAt: nil, using: "xpath", value: xpath, retryTimeout: retryTimeout)
    }

    /// Finds elements by class name, starting from the root.
    /// - Parameter byClassName: class name of the element to search for.
    /// - Parameter retryTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The elements that were found, if any.
    public func findElements(byClassName className: String, retryTimeout: TimeInterval? = nil) throws -> [Element] {
        try findElements(startingAt: nil, using: "class name", value: className, retryTimeout: retryTimeout)
    }

    // Helper for findElements functions above.
    internal func findElements(startingAt element: Element?, using: String, value: String, retryTimeout: TimeInterval?) throws -> [Element] {
        let request = Requests.SessionElements(session: id, element: element?.id, using: using, value: value)

        return try poll(timeout: retryTimeout ?? defaultRetryTimeout) {
            do {
                // Allow errors to bubble up unless they are specifically saying that the element was not found.
                return PollResult.success(try webDriver.send(request).value.map { Element(session: self, id: $0.element) })
            } catch let error as ErrorResponse where error.status == .noSuchElement {
                // Follow the WebDriver spec and keep polling if no elements are found
                return PollResult.failure([])
            }
        }.value
    }

    /// Moves the pointer to a location relative to the current pointer position or an element.
    /// - Parameter element: if not nil the top left of the element provides the origin.
    /// - Parameter xOffset: x offset from the left of the element.
    /// - Parameter yOffset: y offset from the top of the element.
    public func moveTo(element: Element? = nil, xOffset: Int = 0, yOffset: Int = 0) throws {
        precondition(element?.session == nil || element?.session === self)
        try webDriver.send(Requests.SessionMoveTo(
            session: id, element: element?.id, xOffset: xOffset, yOffset: yOffset))
    }

    /// Presses down one of the mouse buttons.
    /// - Parameter button: The button to be pressed.
    public func buttonDown(button: MouseButton = .left) throws {
        try webDriver.send(Requests.SessionButton(
            session: id, action: .buttonDown, button: button))
    }

    /// Releases one of the mouse buttons.
    /// - Parameter button: The button to be released.
    public func buttonUp(button: MouseButton = .left) throws {
        try webDriver.send(Requests.SessionButton(
            session: id, action: .buttonUp, button: button))
    }

    /// Clicks one of the mouse buttons
    /// - Parameter button: The button to be clicked.
    public func click(button: MouseButton = .left) throws {
        try webDriver.send(Requests.SessionButton(
            session: id, action: .click, button: button))
    }

    /// Double clicks the mouse at the current location.
    public func doubleClick() throws {
        try webDriver.send(Requests.SessionDoubleClick(session: id))
    }

    /// Starts a touch point at a coordinate in this session.
    public func touchDown(x: Int, y: Int) throws {
        try webDriver.send(Requests.SessionTouchAt(session: id, action: .down, x: x, y: y))
    }

    /// Releases a touch point at a coordinate in this session.
    public func touchUp(x: Int, y: Int) throws {
        try webDriver.send(Requests.SessionTouchAt(session: id, action: .up, x: x, y: y))
    }

    /// Moves a touch point at a coordinate in this session.
    public func touchMove(x: Int, y: Int) throws {
        try webDriver.send(Requests.SessionTouchAt(session: id, action: .move, x: x, y: y))
    }

    /// Scrolls via touch.
    /// - Parameter element: The element providing the screen location where the scroll starts.
    /// - Parameter xOffset: The x offset to scroll by, in pixels.
    /// - Parameter yOffset: The y offset to scroll by, in pixels.
    public func touchScroll(element: Element? = nil, xOffset: Int, yOffset: Int) throws {
        precondition(element?.session == nil || element?.session === self)
        try webDriver.send(Requests.SessionTouchScroll(
            session: id, element: element?.id, xOffset: xOffset, yOffset: yOffset))
    }

    /// Sends key presses to this session.
    /// - Parameter keys: An array of key sequences according to the WebDriver spec.
    /// - Parameter releaseModifiers: A boolean indicating whether to release modifier keys at the end of the sequence.
    public func sendKeys(_ keys: [Keys], releaseModifiers: Bool = true) throws {
        var value = keys.map { $0.rawValue }
        if releaseModifiers { value.append(Keys.releaseModifiers.rawValue) }
        try webDriver.send(Requests.SessionKeys(session: id, value: value))
    }

    /// Sends key presses to this session.
    /// - Parameter keys: A key sequence according to the WebDriver spec.
    /// - Parameter releaseModifiers: A boolean indicating whether to release modifier keys at the end of the sequence.
    public func sendKeys(_ keys: Keys, releaseModifiers: Bool = true) throws {
        let value = releaseModifiers ? [keys.rawValue, Keys.releaseModifiers.rawValue] : [keys.rawValue]
        try webDriver.send(Requests.SessionKeys(session: id, value: value))
    }

    /// Change focus to another window
    /// - Parameter window: The window to change focus to
    public func focus(window: String) throws {
        try webDriver.send(Requests.SessionWindow(session: id, name: name))
    }

    /// Change the size of the specified window
    /// - Parameter windowHandle: URL parameter is "current", the currently active window will be resized.
    /// - Parameter width: The new window width.
    /// - Parameter height: The new window height
    public func resize(window: String, width: Int, height: Int) throws {
        try webDriver.send(Requests.SessionWindowHandleSize(session: id, windowHandle: windowHandle, width: width, height: height))
    }

    /// Deletes the current session.
    public func delete() throws {
        guard shouldDelete else { return }
        try webDriver.send(Requests.SessionDelete(session: id))
        shouldDelete = false
    }

    deinit {
        do { try delete() }
        catch let error as ErrorResponse {
            assertionFailure("Error in Session.delete: \(error)")
        } catch {
            assertionFailure("Unexpected error in Session.delete: \(error)")
        }
    }
}
