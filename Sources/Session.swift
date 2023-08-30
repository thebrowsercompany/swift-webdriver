import Foundation

/// Represents a Session in the WinAppDriver API.
public class Session {
    let webDriver: any WebDriver
    public let id: String
    public let capabilities: Capabilities

    private var deleted: Bool = false

    init(in webDriver: some WebDriver, id: String, capabilities: Capabilities) {
        self.webDriver = webDriver
        self.id = id
        self.capabilities = capabilities
    }

    /// retryTimeout
    /// A TimeInterval specifying max time to spend retrying operations.
    var defaultRetryTimeout: TimeInterval = 1.0

    /// title - the session title, usually the hwnd title
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidtitle
    public var title: String {
        get throws {
            try webDriver.send(WebDriverRequests.SessionTitle(session: id)).value
        }
    }

    /// screenshot()
    /// Take a screenshot of the current page.
    /// - Returns: The screenshot data as a PNG file.
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidscreenshot
    public func screenshot() throws -> Data {
        let base64: String = try webDriver.send(
            WebDriverRequests.SessionScreenshot(session: id)).value
        guard let data = Data(base64Encoded: base64) else {
            let codingPath = [WebDriverRequests.SessionScreenshot.Response.CodingKeys.value]
            let description = "Invalid Base64 string while decoding screenshot response."
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: description))
        }
        return data
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
        let request = WebDriverRequests.SessionElement(session: id, element: element?.id, using: using, value: value)
        let element = try retryUntil(retryTimeout ?? defaultRetryTimeout) {
            do {
                let responseValue = try webDriver.send(request).value
                return Element(in: self, id: responseValue.element)
            } catch let error as WebDriverError where error.status == .noSuchElement {
                return nil
            }
        }
        return element
    }

    /// Find active (focused) element
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementactive
    public var activeElement: Element? {
        get throws {
            do {
                let response = try webDriver.send(WebDriverRequests.SessionActiveElement(session: id))
                return Element(in: self, id: response.value.element)
            } catch let error as WebDriverError where error.status == .noSuchElement {
                return nil
            }
        }
    }

    /// moveTo(::) - move the pointer to a location relative to the current pointer position or an element
    /// - Parameters:
    ///   - element: if not nil the top left of the element provides the origin
    ///   - xOffset: x offset from the left of the element
    ///   - yOffset: y offset from the top of the element
    public func moveTo(element: Element? = nil, xOffset: Int = 0, yOffset: Int = 0) throws {
        precondition(element?.session == nil || element?.session === self)
        try webDriver.send(WebDriverRequests.SessionMoveTo(
            session: id, element: element?.id, xOffset: xOffset, yOffset: yOffset))
    }

    /// click(:) - click one of the mouse buttons
    /// - Parameter button: see MouseButton enum
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidclick
    public func click(button: MouseButton = .left) throws {
        try webDriver.send(WebDriverRequests.SessionButton(
            session: id, action: .click, button: button))
    }

    /// buttonDown(:) - press down one of the mouse buttons
    /// - Parameter button: see MouseButton enum
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidbuttondown
    public func buttonDown(button: MouseButton = .left) throws {
        try webDriver.send(WebDriverRequests.SessionButton(
            session: id, action: .buttonDown, button: button))
    }

    /// buttonUp(:) - release one of the mouse buttons
    /// - Parameter button: see MouseButton enum
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidbuttonup
    public func buttonUp(button: MouseButton = .left) throws {
        try webDriver.send(WebDriverRequests.SessionButton(
            session: id, action: .buttonUp, button: button))
    }

    /// sendKeys(:) - send key strokes to the session
    /// - Parameter value: key strokes to send
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidkeys
    public func sendKeys(value: [String]) throws {
        try webDriver.send(WebDriverRequests.SessionKeys(session: id, value: value))
    }

    /// Send keys to the session
    /// This overload takes a single string for simplicity
    public func sendKeys(value: String) throws {
        try sendKeys(value: [value])
    }

    /// delete
    /// Attempts to delete the session.
    public func delete() throws {
        guard !deleted else { return }
        try webDriver.send(WebDriverRequests.SessionDelete(sessionId: id))
        deleted = true
    }

    deinit {
        do { try delete() }
        catch let error as WebDriverError {
            assertionFailure("Error in Session.delete: \(error)")
        } catch {
            assertionFailure("Unexpected error in Session.delete: \(error)")
        }
    }
}
