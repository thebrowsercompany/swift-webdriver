import Foundation

/// Represents a session in the WebDriver protocol,
/// which manages the lifetime of a page or app under UI automation.
public class Session {
    public let webDriver: any WebDriver
    public let id: String
    public let capabilities: Capabilities
    private var _implicitWaitTimeout: TimeInterval = 0
    private var emulateImplicitWait: Bool = false // Set if the session doesn't support implicit waits.
    private var shouldDelete: Bool = true

    public init(webDriver: any WebDriver, existingId: String, capabilities: Capabilities = Capabilities(), owned: Bool = false) {
        self.webDriver = webDriver
        self.id = existingId
        self.capabilities = capabilities
        if let implicitWaitTimeoutInMilliseconds = capabilities.timeouts?.implicit {
            self.implicitWaitTimeout = Double(implicitWaitTimeoutInMilliseconds) / 1000.0
        }
        self.shouldDelete = owned
    }

    public convenience init(webDriver: any WebDriver, desiredCapabilities: Capabilities, requiredCapabilities: Capabilities? = nil) throws {
        let response = try webDriver.send(Requests.Session(
            desiredCapabilities: desiredCapabilities, requiredCapabilities: requiredCapabilities))
        self.init(webDriver: webDriver, existingId: response.sessionId, capabilities: response.value, owned: true)
    }

    /// The amount of time the driver should implicitly wait when searching for elements.
    /// This functionality is either implemented by the driver, or emulated by swift-webdriver as a fallback.
    public var implicitWaitTimeout: TimeInterval {
        get { _implicitWaitTimeout }
        set {
            if newValue == _implicitWaitTimeout { return }
            if !emulateImplicitWait {
                do {
                    try setTimeout(type: TimeoutType.implicitWait, duration: newValue)
                    emulateImplicitWait = true
                } catch {}
            }
            _implicitWaitTimeout = newValue
        }
    }

    /// The amount of time interactions should be retried before failing.
    /// This functionality is emulated by swift-webdriver.
    public var implicitInteractionRetryTimeout: TimeInterval = .zero

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
    
    public var location: Location {
        get throws {
            let response = try webDriver.send(Requests.SessionLocation.Get(session: id))
            return response.value
        }
    }

    public var orientation: ScreenOrientation {
        get throws {
            let response = try webDriver.send(Requests.SessionOrientation.Get(session: id))
            return response.value
        }
    }

    /// Sets a a timeout value on this session.
    public func setTimeout(type: String, duration: TimeInterval) throws {
        try webDriver.send(
            Requests.SessionTimeouts(session: id, type: type, ms: duration * 1000))
        // Keep track of the implicit wait to know when we need to override it.
        if type == TimeoutType.implicitWait { _implicitWaitTimeout = duration }
    }

    public func execute(script: String, args: [String] = [], async: Bool = false) throws {
        try webDriver.send(Requests.SessionScript(session: id, script: script, args: args, async: async))
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
    /// - Parameter wait: Optional value to override the implicit wait timeout.
    /// - Returns: The element that was found, if any.
    public func findElement(byId id: String, waitTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(startingAt: nil, using: "id", value: id, waitTimeout: waitTimeout)
    }

    /// Finds an element by name, starting from the root.
    /// - Parameter byName: name of the element to search for.
    /// - Parameter waitTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The element that was found, if any.
    public func findElement(byName name: String, waitTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(startingAt: nil, using: "name", value: name, waitTimeout: waitTimeout)
    }

    /// Finds an element by accessibility id, starting from the root.
    /// - Parameter byAccessibilityId: accessibiilty id of the element to search for.
    /// - Parameter waitTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The element that was found, if any.
    public func findElement(byAccessibilityId id: String, waitTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(startingAt: nil, using: "accessibility id", value: id, waitTimeout: waitTimeout)
    }

    /// Finds an element by xpath, starting from the root.
    /// - Parameter byXPath: xpath of the element to search for.
    /// - Parameter waitTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The element that was found, if any.
    public func findElement(byXPath xpath: String, waitTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(startingAt: nil, using: "xpath", value: xpath, waitTimeout: waitTimeout)
    }

    /// Finds an element by class name, starting from the root.
    /// - Parameter byClassName: class name of the element to search for.
    /// - Parameter waitTimeout: Optional value to override defaultRetryTimeout.
    /// - Returns: The element that was found, if any.
    public func findElement(byClassName className: String, waitTimeout: TimeInterval? = nil) throws -> Element? {
        try findElement(startingAt: nil, using: "class name", value: className, waitTimeout: waitTimeout)
    }

    /// Overrides the implicit wait timeout during a block of code.
    private func withImplicitWaitTimeout<Result>(_ value: TimeInterval?, _ block: () throws -> Result) rethrows -> Result {
        if let value, value != _implicitWaitTimeout {
            let previousValue = _implicitWaitTimeout
            implicitWaitTimeout = value
            defer { implicitWaitTimeout = previousValue }
            return try block()
        }
        else {
            return try block()
        }
    }

    // Helper for findElement functions above.
    internal func findElement(startingAt element: Element?, using: String, value: String, waitTimeout: TimeInterval?) throws -> Element? {
        precondition(element == nil || element?.session === self)

        return try withImplicitWaitTimeout(waitTimeout) {
            let request = Requests.SessionElement(session: id, element: element?.id, using: using, value: value)

            let elementId = try poll(timeout: emulateImplicitWait ? (waitTimeout ?? _implicitWaitTimeout) : TimeInterval.zero) {
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
    }

    /// Finds elements by id, starting from the root.
    /// - Parameter byId: id of the element to search for.
    /// - Parameter waitTimeout: The amount of time to wait for element existence. Overrides the implicit wait timeout.
    /// - Returns: The elements that were found, if any.
    public func findElements(byId id: String, waitTimeout: TimeInterval? = nil) throws -> [Element] {
        try findElements(startingAt: nil, using: "id", value: id, waitTimeout: waitTimeout)
    }

    /// Finds elements by name, starting from the root.
    /// - Parameter byName: name of the element to search for.
    /// - Parameter waitTimeout: The amount of time to wait for element existence. Overrides the implicit wait timeout.
    /// - Returns: The elements that were found, if any.
    public func findElements(byName name: String, waitTimeout: TimeInterval? = nil) throws -> [Element] {
        try findElements(startingAt: nil, using: "name", value: name, waitTimeout: waitTimeout)
    }

    /// Finds elements by accessibility id, starting from the root.
    /// - Parameter byAccessibilityId: accessibiilty id of the element to search for.
    /// - Parameter waitTimeout: The amount of time to wait for element existence. Overrides the implicit wait timeout.
    /// - Returns: The elements that were found, if any.
    public func findElements(byAccessibilityId id: String, waitTimeout: TimeInterval? = nil) throws -> [Element] {
        try findElements(startingAt: nil, using: "accessibility id", value: id, waitTimeout: waitTimeout)
    }

    /// Finds elements by xpath, starting from the root.
    /// - Parameter byXPath: xpath of the element to search for.
    /// - Parameter waitTimeout: The amount of time to wait for element existence. Overrides the implicit wait timeout.
    /// - Returns: The elements that were found, if any.
    public func findElements(byXPath xpath: String, waitTimeout: TimeInterval? = nil) throws -> [Element] {
        try findElements(startingAt: nil, using: "xpath", value: xpath, waitTimeout: waitTimeout)
    }

    /// Finds elements by class name, starting from the root.
    /// - Parameter byClassName: class name of the element to search for.
    /// - Parameter waitTimeout: Optional value to override the implicit wait timeout.
    /// - Returns: The elements that were found, if any.
    public func findElements(byClassName className: String, waitTimeout: TimeInterval? = nil) throws -> [Element] {
        try findElements(startingAt: nil, using: "class name", value: className, waitTimeout: waitTimeout)
    }

    // Helper for findElements functions above.
    internal func findElements(startingAt element: Element?, using: String, value: String, waitTimeout: TimeInterval?) throws -> [Element] {
        try withImplicitWaitTimeout(waitTimeout) {
            let request = Requests.SessionElements(session: id, element: element?.id, using: using, value: value)

            return try poll(timeout: emulateImplicitWait ? (waitTimeout ?? _implicitWaitTimeout) : TimeInterval.zero) {
                do {
                    // Allow errors to bubble up unless they are specifically saying that the element was not found.
                    return PollResult.success(try webDriver.send(request).value.map { Element(session: self, id: $0.element) })
                } catch let error as ErrorResponse where error.status == .noSuchElement {
                    // Follow the WebDriver spec and keep polling if no elements are found
                    return PollResult.failure([])
                }
            }.value
        }
    }

    /// - Parameters:
    ///   - waitTimeout: Optional value to override defaultRetryTimeout.
    ///   - xSpeed: The x speed in pixels per second.
    ///   - ySpeed: The y speed in pixels per second.
    public func flick(xSpeed: Double, ySpeed: Double) throws {
        try webDriver.send(Requests.SessionTouchFlick(session: id, xSpeed: xSpeed, ySpeed: ySpeed))
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
    /// - Parameter name: The window to change focus to
    public func focus(window name: String) throws {
        try webDriver.send(Requests.SessionWindow.Post(session: id, name: name))
    }

    /// Close selected window
    /// - Parameter name: The selected window to close
    public func close(window name: String) throws {
        try webDriver.send(Requests.SessionWindow.Delete(session: id, name: name))
    }

    public func window(handle: String) throws -> Window { .init(session: self, handle: handle) }

    /// - Prarmeter: Orientation the window will flip to {LANDSCAPE|PORTRAIT}
    public func setOrientation(_ value: ScreenOrientation) throws {
        try webDriver.send(Requests.SessionOrientation.Post(session: id, orientation: value))
    }

    /// Get the current page source
    public var source: String {
        get throws {
            try webDriver.send(Requests.SessionSource(session: id)).value
        }
    }
 
    /// - Returns: Current window handle
    public var windowHandle: String {
        get throws {
            let response = try webDriver.send(Requests.SessionWindowHandle(session: id))
            return response.value
        }
    }

    /// Set the current geolocation 
    public func setLocation(_ location: Location) throws {
        try webDriver.send(Requests.SessionLocation.Post(session: id, location: location))
    }

    public func setLocation(latitude: Double, longitude: Double, altitude: Double) throws { 
        try setLocation(Location(latitude: latitude, longitude: longitude, altitude: altitude)) 
    }

    /// - Returns: Array of window handles
    public var windowHandles: [String] {
        get throws {
            let response = try webDriver.send(Requests.SessionWindowHandles(session: id))
            return response.value
        }
    }

    /// Deletes the current session.
    public func delete() throws {
        guard shouldDelete else { return }
        try webDriver.send(Requests.SessionDelete(session: id))
        shouldDelete = false
    }

    /// Sends an interaction request, retrying until it is conclusive or the timeout elapses.
    internal func sendInteraction<Req: Request>(_ request: Req, retryTimeout: TimeInterval? = nil) throws where Req.Response == CodableNone {
        let result = try poll(timeout: retryTimeout ?? implicitInteractionRetryTimeout) {
            do {
                // Immediately bubble most failures, only retry if inconclusive.
                try webDriver.send(request)
                return PollResult.success(nil as ErrorResponse?)
            } catch let error as ErrorResponse where webDriver.isInconclusiveInteraction(error: error.status) {
                return PollResult.failure(error)
            }
        }

        if let error = result.value { throw error }
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
