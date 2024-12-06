import Foundation

/// Represents a session in the WebDriver protocol,
/// which manages the lifetime of a page or app under UI automation.
public class Session {
    public let webDriver: any WebDriver
    public let id: String
    public let capabilities: Capabilities
    private var _implicitWaitTimeout: TimeInterval = 0
    internal var emulateImplicitWait: Bool = false // Set if the session doesn't support implicit waits.
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
                } catch {
                    emulateImplicitWait = true
                }
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

    /// Finds an element using a given locator, starting from the session root.
    /// - Parameter locator: The locator strategy to use.
    /// - Parameter waitTimeout: The amount of time to wait for element existence. Overrides the implicit wait timeout.
    /// - Returns: The element that was found, if any.
    @discardableResult // for use as an assertion
    public func findElement(locator: ElementLocator, waitTimeout: TimeInterval? = nil) throws -> Element {
        try findElement(startingAt: nil, locator: locator, waitTimeout: waitTimeout)
    }

    /// Finds elements by id, starting from the root.
    /// - Parameter locator: The locator strategy to use.
    /// - Parameter waitTimeout: The amount of time to wait for element existence. Overrides the implicit wait timeout.
    /// - Returns: The elements that were found, or an empty array.
    public func findElements(locator: ElementLocator, waitTimeout: TimeInterval? = nil) throws -> [Element] {
        try findElements(startingAt: nil, locator: locator, waitTimeout: waitTimeout)
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

    /// Common logic for `Session.findElement` and `Element.findElement`.
    internal func findElement(startingAt subtreeRoot: Element?, locator: ElementLocator, waitTimeout: TimeInterval?) throws -> Element {
        precondition(subtreeRoot == nil || subtreeRoot?.session === self)

        return try withImplicitWaitTimeout(waitTimeout) {
            let request = Requests.SessionElement(session: id, element: subtreeRoot?.id, locator: locator)

            do {
                return try poll(timeout: emulateImplicitWait ? (waitTimeout ?? _implicitWaitTimeout) : TimeInterval.zero) {
                    do {
                        // Allow errors to bubble up unless they are specifically saying that the element was not found.
                        let elementId = try webDriver.send(request).value.element
                        return .success(Element(session: self, id: elementId))
                    } catch let error as ErrorResponse where error.status == .noSuchElement {
                        // Return instead of throwing to indicate that `poll` can retry as needed.
                        return .failure(error)
                    }
                }
            } catch {
                throw NoSuchElementError(locator: locator, sourceError: error)
            }
        }
    }

    /// Common logic for `Session.findElements` and `Element.findElements`.
    internal func findElements(startingAt element: Element?, locator: ElementLocator, waitTimeout: TimeInterval?) throws -> [Element] {
        try withImplicitWaitTimeout(waitTimeout) {
            let request = Requests.SessionElements(session: id, element: element?.id, locator: locator)

            do {
                return try poll(timeout: emulateImplicitWait ? (waitTimeout ?? _implicitWaitTimeout) : TimeInterval.zero) {
                    do {
                        // Allow errors to bubble up unless they are specifically saying that the element was not found.
                        return .success(try webDriver.send(request).value.map { Element(session: self, id: $0.element) })
                    } catch let error as ErrorResponse where error.status == .noSuchElement {
                        // Follow the WebDriver spec and keep polling if no elements are found.
                        // Return instead of throwing to indicate that `poll` can retry as needed.
                        return .failure(error)
                    }
                }
            } catch let error as ErrorResponse where error.status == .noSuchElement {
                return []
            }
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

    /// Clicks one of the mouse buttons.
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
    /// - Parameter keys: A key sequence according to the WebDriver spec.
    /// - Parameter releaseModifiers: A boolean indicating whether to release modifier keys at the end of the sequence.
    public func sendKeys(_ keys: Keys, releaseModifiers: Bool = true) throws {
        let value = releaseModifiers ? [keys.rawValue, Keys.releaseModifiers.rawValue] : [keys.rawValue]
        try webDriver.send(Requests.SessionKeys(session: id, value: value))
    }

    /// Change focus to another window.
    /// - Parameter name: The window to change focus to.
    public func focus(window name: String) throws {
        try webDriver.send(Requests.SessionWindow.Post(session: id, name: name))
    }

    /// Close selected window.
    /// - Parameter name: The selected window to close.
    public func close(window name: String) throws {
        try webDriver.send(Requests.SessionWindow.Delete(session: id, name: name))
    }

    public func window(handle: String) throws -> Window { .init(session: self, handle: handle) }

    /// - Parameter: Orientation the window will flip to {LANDSCAPE|PORTRAIT}.
    public func setOrientation(_ value: ScreenOrientation) throws {
        try webDriver.send(Requests.SessionOrientation.Post(session: id, orientation: value))
    }

    /// Get the current page source.
    public var source: String {
        get throws {
            try webDriver.send(Requests.SessionSource(session: id)).value
        }
    }

    /// - Returns: Current window handle.
    public var windowHandle: String {
        get throws {
            let response = try webDriver.send(Requests.SessionWindowHandle(session: id))
            return response.value
        }
    }

    /// Set the current geolocation.
    public func setLocation(_ location: Location) throws {
        try webDriver.send(Requests.SessionLocation.Post(session: id, location: location))
    }

    public func setLocation(latitude: Double, longitude: Double, altitude: Double) throws {
        try setLocation(Location(latitude: latitude, longitude: longitude, altitude: altitude))
    }

    /// - Returns: Array of window handles.
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
        try poll(timeout: retryTimeout ?? implicitInteractionRetryTimeout) {
            do {
                // Immediately bubble most failures, only retry if inconclusive.
                try webDriver.send(request)
                return .success(())
            } catch let error as ErrorResponse where webDriver.isInconclusiveInteraction(error: error.status) {
                // Return instead of throwing to indicate that `poll` can retry as needed.
                return .failure(error)
            }
        }
    }

    deinit {
        try? delete() // Call `delete` directly to handle errors.
    }
}
