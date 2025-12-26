import Foundation

/// Represents a session in the WebDriver protocol,
/// which manages the lifetime of a page or app under UI automation.
public final class Session {
    public let webDriver: any WebDriver
    public let id: String
    public let capabilities: Capabilities
    private var _implicitWaitTimeout: TimeInterval = 0
    internal var emulateImplicitWait: Bool = false  // Set if the session doesn't support implicit waits.
    private var shouldDelete: Bool = true

    public init(
        webDriver: any WebDriver, existingId: String, capabilities: Capabilities = Capabilities(),
        owned: Bool = false
    ) {
        self.webDriver = webDriver
        self.id = existingId
        self.capabilities = capabilities
        if let implicitWaitTimeoutInMilliseconds = capabilities.timeouts?.implicit {
            self._implicitWaitTimeout = Double(implicitWaitTimeoutInMilliseconds) / 1000.0
        }
        self.shouldDelete = owned
    }

    /// Initializer for Legacy Selenium JSON Protocol
    fileprivate convenience init(
        webDriver: any WebDriver, desiredCapabilities: Capabilities,
        requiredCapabilities: Capabilities?
    ) async throws {
        let response = try await webDriver.send(
            Requests.LegacySelenium.Session(
                desiredCapabilities: desiredCapabilities, requiredCapabilities: requiredCapabilities
            ))
        self.init(
            webDriver: webDriver,
            existingId: response.sessionId,
            capabilities: response.value,
            owned: true)
    }

    /// Initializer for W3C Protocol
    fileprivate convenience init(
        webDriver: any WebDriver, alwaysMatch: Capabilities, firstMatch: [Capabilities]
    ) async throws {
        let response = try await webDriver.send(
            Requests.W3C.Session(
                alwaysMatch: alwaysMatch, firstMatch: firstMatch))
        self.init(
            webDriver: webDriver,
            existingId: response.value.sessionId,
            capabilities: response.value.capabilities,
            owned: true)
    }

    public convenience init(webDriver: any WebDriver, capabilities: Capabilities) async throws {
        switch webDriver.wireProtocol {
        case .legacySelenium:
            try await self.init(
                webDriver: webDriver, desiredCapabilities: capabilities,
                requiredCapabilities: capabilities)
        case .w3c:
            try await self.init(webDriver: webDriver, alwaysMatch: capabilities, firstMatch: [])
        }
    }

    public enum LegacySelenium {
        public static func create(
            webDriver: any WebDriver, desiredCapabilities: Capabilities,
            requiredCapabilities: Capabilities? = nil
        ) async throws -> Session {
            try await Session(
                webDriver: webDriver, desiredCapabilities: desiredCapabilities,
                requiredCapabilities: requiredCapabilities)
        }
    }

    public enum W3C {
        public static func create(
            webDriver: any WebDriver, alwaysMatch: Capabilities, firstMatch: [Capabilities] = []
        ) async throws -> Session {
            try await Session(
                webDriver: webDriver, alwaysMatch: alwaysMatch, firstMatch: firstMatch)
        }
    }

    /// The amount of time the driver should implicitly wait when searching for elements.
    /// This functionality is either implemented by the driver, or emulated by swift-webdriver as a fallback.
    public var implicitWaitTimeout: TimeInterval { _implicitWaitTimeout }

    public func setImplicitWaitTimeout(_ newValue: TimeInterval) async throws {
        if newValue == _implicitWaitTimeout { return }
        if !emulateImplicitWait {
            do {
                try await setTimeout(implicit: newValue)
            } catch {
                emulateImplicitWait = true
            }
        }
        _implicitWaitTimeout = newValue
    }

    /// The amount of time interactions should be retried before failing.
    /// This functionality is emulated by swift-webdriver.
    public var implicitInteractionRetryTimeout: TimeInterval = .zero

    /// The title of this session such as the tab or window text.
    public var title: String {
        get async throws {
            try await webDriver.send(Requests.SessionTitle(session: id)).value
        }
    }

    /// The current URL of this session.
    public var url: URL {
        get async throws {
            guard
                let result = URL(
                    string: try await webDriver.send(Requests.SessionUrl.Get(session: id)).value)
            else {
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
    public func url(_ url: URL) async throws {
        try await webDriver.send(Requests.SessionUrl.Post(session: id, url: url.absoluteString))
    }

    /// The active (focused) element.
    public var activeElement: Element? {
        get async throws {
            do {
                let response = try await webDriver.send(Requests.SessionActiveElement(session: id))
                return Element(session: self, id: response.value.element)
            } catch let error as ErrorResponse where error.status == .noSuchElement {
                return nil
            }
        }
    }

    public var location: Location {
        get async throws {
            let response = try await webDriver.send(Requests.SessionLocation.Get(session: id))
            return response.value
        }
    }

    public var orientation: ScreenOrientation {
        get async throws {
            let response = try await webDriver.send(Requests.SessionOrientation.Get(session: id))
            return response.value
        }
    }

    /// Sets a a timeout value on this session.
    public func setTimeout(
        script: TimeInterval? = nil,
        pageLoad: TimeInterval? = nil,
        implicit: TimeInterval? = nil
    )
        async throws
    {
        try await webDriver.send(
            Requests.SessionTimeouts(
                session: id,
                script: script != nil ? script! * 1000 : nil,
                pageLoad: pageLoad != nil ? pageLoad! * 1000 : nil,
                implicit: implicit != nil ? implicit! * 1000 : nil)
        )
        // Keep track of the implicit wait to know when we need to override it.
        if let i = implicit { _implicitWaitTimeout = i }
    }

    @discardableResult
    public func execute<Result: Codable>(script: String, args: [String] = [], async: Bool = false)
        async throws -> Result
    {
        try await webDriver.send(
            Requests.SessionScript<Result>(session: id, script: script, args: args, async: async)
        ).value
    }

    public func back() async throws {
        try await webDriver.send(Requests.SessionBack(session: id))
    }

    public func forward() async throws {
        try await webDriver.send(Requests.SessionForward(session: id))
    }

    public func refresh() async throws {
        try await webDriver.send(Requests.SessionRefresh(session: id))
    }

    /// Takes a screenshot of the current page.
    /// - Returns: The screenshot data as a PNG file.
    public func screenshot() async throws -> Data {
        let base64: String = try await webDriver.send(
            Requests.SessionScreenshot(session: id)
        ).value
        guard let data = Data(base64Encoded: base64) else {
            let codingPath = [Requests.SessionScreenshot.Response.CodingKeys.value]
            let description = "Invalid Base64 string while decoding screenshot response."
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: codingPath, debugDescription: description))
        }
        return data
    }

    /// Finds an element using a given locator, starting from the session root.
    /// - Parameter locator: The locator strategy to use.
    /// - Parameter waitTimeout: The amount of time to wait for element existence. Overrides the implicit wait timeout.
    /// - Returns: The element that was found, if any.
    @discardableResult  // for use as an assertion
    public func findElement(locator: ElementLocator, waitTimeout: TimeInterval? = nil) async throws
        -> Element
    {
        try await findElement(startingAt: nil, locator: locator, waitTimeout: waitTimeout)
    }

    /// Finds elements by id, starting from the root.
    /// - Parameter locator: The locator strategy to use.
    /// - Parameter waitTimeout: The amount of time to wait for element existence. Overrides the implicit wait timeout.
    /// - Returns: The elements that were found, or an empty array.
    public func findElements(locator: ElementLocator, waitTimeout: TimeInterval? = nil) async throws
        -> [Element]
    {
        try await findElements(startingAt: nil, locator: locator, waitTimeout: waitTimeout)
    }

    /// Overrides the implicit wait timeout during a block of code.
    private func withImplicitWaitTimeout<Result>(
        _ value: TimeInterval?, _ block: () async throws -> Result
    ) async throws -> Result {
        if let value, value != _implicitWaitTimeout {
            let previousValue = _implicitWaitTimeout
            try await setImplicitWaitTimeout(value)
            do {
                let result = try await block()
                try await setImplicitWaitTimeout(previousValue)
                return result
            } catch {
                try await setImplicitWaitTimeout(previousValue)
                throw error
            }
        } else {
            return try await block()
        }
    }

    /// Common logic for `Session.findElement` and `Element.findElement`.
    internal func findElement(
        startingAt subtreeRoot: Element?, locator: ElementLocator, waitTimeout: TimeInterval?
    ) async throws -> Element {
        precondition(subtreeRoot == nil || subtreeRoot?.session === self)

        return try await withImplicitWaitTimeout(waitTimeout) {
            let request = Requests.SessionElement(
                session: id, element: subtreeRoot?.id, locator: locator)

            do {
                return try await poll(
                    timeout: emulateImplicitWait
                        ? (waitTimeout ?? _implicitWaitTimeout) : TimeInterval.zero
                ) {
                    do {
                        // Allow errors to bubble up unless they are specifically saying that the element was not found.
                        let elementId = try await webDriver.send(request).value.element
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
    internal func findElements(
        startingAt element: Element?, locator: ElementLocator, waitTimeout: TimeInterval?
    ) async throws -> [Element] {
        try await withImplicitWaitTimeout(waitTimeout) {
            let request = Requests.SessionElements(
                session: id, element: element?.id, locator: locator)

            do {
                return try await poll(
                    timeout: emulateImplicitWait
                        ? (waitTimeout ?? _implicitWaitTimeout) : TimeInterval.zero
                ) {
                    do {
                        // Allow errors to bubble up unless they are specifically saying that the element was not found.
                        return .success(
                            try await webDriver.send(request).value.map {
                                Element(session: self, id: $0.element)
                            })
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
    public func flick(xSpeed: Double, ySpeed: Double) async throws {
        let request = Requests.SessionTouchFlick(session: id, xSpeed: xSpeed, ySpeed: ySpeed)
        try await sendInteraction(request)
    }

    /// Moves the pointer to a location relative to the current pointer position or an element.
    /// - Parameter element: if not nil the top left of the element provides the origin.
    /// - Parameter xOffset: x offset from the left of the element.
    /// - Parameter yOffset: y offset from the top of the element.
    public func moveTo(element: Element? = nil, xOffset: Int = 0, yOffset: Int = 0) async throws {
        precondition(element?.session == nil || element?.session === self)
        try await webDriver.send(
            Requests.SessionMoveTo(
                session: id, element: element?.id, xOffset: xOffset, yOffset: yOffset))
    }

    /// Alters the size and the position of the operating system window corresponding to
    /// session's current top-level browsing context. If x and y are both present, the
    /// window is moved to that location. If width and height are both present, the window
    /// (including all external chrome) is resized as close as possible to those dimensions
    /// (though not larger than the screen, smaller than the smallest possible window size, etc...).
    /// - Parameter x: the screenX attribute of the window object
    /// - Parameter y: the screenY attribute of the window object
    /// - Parameter width: the width of the outer dimensions of the top-level browsing context
    /// - Parameter height: the height of the outer dimensions of the top-level browsing context
    public func setWindowRect(x: Int?, y: Int?, width: Int?, height: Int?) async throws {
        try await webDriver.send(
            Requests.SessionWindowRect(
                session: id, x: x, y: y, width: width, height: height))
    }

    /// Presses down one of the mouse buttons.
    /// - Parameter button: The button to be pressed.
    public func buttonDown(button: MouseButton = .left) async throws {
        try await webDriver.send(
            Requests.SessionButton(
                session: id, action: .buttonDown, button: button))
    }

    /// Releases one of the mouse buttons.
    /// - Parameter button: The button to be released.
    public func buttonUp(button: MouseButton = .left) async throws {
        try await webDriver.send(
            Requests.SessionButton(
                session: id, action: .buttonUp, button: button))
    }

    /// Clicks one of the mouse buttons.
    /// - Parameter button: The button to be clicked.
    public func click(button: MouseButton = .left) async throws {
        try await webDriver.send(
            Requests.SessionButton(
                session: id, action: .click, button: button))
    }

    /// Double clicks the mouse at the current location.
    public func doubleClick() async throws {
        try await webDriver.send(Requests.SessionDoubleClick(session: id))
    }

    /// Starts a touch point at a coordinate in this session.
    public func touchDown(x: Int, y: Int) async throws {
        try await webDriver.send(Requests.SessionTouchAt(session: id, action: .down, x: x, y: y))
    }

    /// Releases a touch point at a coordinate in this session.
    public func touchUp(x: Int, y: Int) async throws {
        try await webDriver.send(Requests.SessionTouchAt(session: id, action: .up, x: x, y: y))
    }

    /// Moves a touch point at a coordinate in this session.
    public func touchMove(x: Int, y: Int) async throws {
        try await webDriver.send(Requests.SessionTouchAt(session: id, action: .move, x: x, y: y))
    }

    /// Scrolls via touch.
    /// - Parameter element: The element providing the screen location where the scroll starts.
    /// - Parameter xOffset: The x offset to scroll by, in pixels.
    /// - Parameter yOffset: The y offset to scroll by, in pixels.
    public func touchScroll(element: Element? = nil, xOffset: Int, yOffset: Int) async throws {
        precondition(element?.session == nil || element?.session === self)
        try await webDriver.send(
            Requests.SessionTouchScroll(
                session: id, element: element?.id, xOffset: xOffset, yOffset: yOffset))
    }

    /// Sends key presses to this session.
    /// - Parameter keys: A key sequence according to the WebDriver spec.
    /// - Parameter releaseModifiers: A boolean indicating whether to release modifier keys at the end of the sequence.
    public func sendKeys(_ keys: Keys, releaseModifiers: Bool = true) async throws {
        let value =
            releaseModifiers ? [keys.rawValue, Keys.releaseModifiers.rawValue] : [keys.rawValue]
        try await webDriver.send(Requests.SessionKeys(session: id, value: value))
    }

    /// Change focus to another window.
    /// - Parameter name: The window to change focus to.
    public func focus(window name: String) async throws {
        try await webDriver.send(Requests.SessionWindow.Post(session: id, name: name))
    }

    /// Close selected window.
    /// - Parameter name: The selected window to close.
    public func close(window name: String) async throws {
        try await webDriver.send(Requests.SessionWindow.Delete(session: id, name: name))
    }

    public func window(handle: String) throws -> Window { .init(session: self, handle: handle) }

    /// - Parameter: Orientation the window will flip to {LANDSCAPE|PORTRAIT}.
    public func setOrientation(_ value: ScreenOrientation) async throws {
        try await webDriver.send(Requests.SessionOrientation.Post(session: id, orientation: value))
    }

    /// Get the current page source.
    public var source: String {
        get async throws {
            try await webDriver.send(Requests.SessionSource(session: id)).value
        }
    }

    /// - Returns: Current window handle.
    public var windowHandle: String {
        get async throws {
            let response = try await webDriver.send(Requests.SessionWindowHandle(session: id))
            return response.value
        }
    }

    /// Set the current geolocation.
    public func setLocation(_ location: Location) async throws {
        try await webDriver.send(Requests.SessionLocation.Post(session: id, location: location))
    }

    public func setLocation(latitude: Double, longitude: Double, altitude: Double) async throws {
        try await setLocation(
            Location(latitude: latitude, longitude: longitude, altitude: altitude))
    }

    /// - Returns: Array of window handles.
    public var windowHandles: [String] {
        get async throws {
            let response = try await webDriver.send(Requests.SessionWindowHandles(session: id))
            return response.value
        }
    }

    /// Deletes the current session.
    public func delete() async throws {
        guard shouldDelete else { return }
        try await webDriver.send(Requests.SessionDelete(session: id))
        shouldDelete = false
    }

    /// Sends an interaction request, retrying until it is conclusive or the timeout elapses.
    internal func sendInteraction<Req: Request>(_ request: Req, retryTimeout: TimeInterval? = nil)
        async throws where Req.Response == CodableNone
    {
        try await poll(timeout: retryTimeout ?? implicitInteractionRetryTimeout) {
            do {
                // Immediately bubble most failures, only retry if inconclusive.
                try await webDriver.send(request)
                return .success(())
            } catch let error as ErrorResponse
                where webDriver.isInconclusiveInteraction(error: error.status ?? .unknownError)
            {
                // Return instead of throwing to indicate that `poll` can retry as needed.
                return .failure(error)
            }
        }
    }

    deinit {
        guard shouldDelete else { return }
        let webDriver = self.webDriver
        let sessionId = self.id
        Task {
            _ = try? await webDriver.send(Requests.SessionDelete(session: sessionId))
        }
    }
}
