/// Exposes window-specific webdriver operations
public struct Window {
    var webDriver: WebDriver { session.webDriver }
    public let session: Session
    public let handle: String

    public init(session: Session, handle: String) {
        self.session = session
        self.handle = handle
    }

    public var position: (x: Double, y: Double) {
        get throws {
            let responseValue = try webDriver.send(Requests.WindowPosition.Get(
                session: session.id, windowHandle: handle)).value
            return (responseValue.x, responseValue.y)
        }
    }

    public var size: (width: Double, height: Double) {
        get throws {
            let responseValue = try webDriver.send(Requests.WindowSize.Get(
                session: session.id, windowHandle: handle)).value
            return (responseValue.width, responseValue.height)
        }
    }

    /// - Parameters:
    ///   - width: The new window width
    ///   - height: The new window height
    public func setSize(width: Double, height: Double) throws {
        try webDriver.send(Requests.WindowSize.Post(session: session.id, windowHandle: handle, width: width, height: height))
    }

    /// - Parameters:
    ///   - x: Position in the top left corner of the x coordinate
    ///   - y: Position in the top left corner of the y coordinate
    public func setPosition(x: Double, y: Double) throws {
        try webDriver.send(Requests.WindowPosition.Post(session: session.id, windowHandle: handle, x: x, y: y))
    }

    /// Maximize specific window if :windowHandle is "current" the current window will be maximized
    public func maximize() throws {
        try webDriver.send(Requests.WindowMaximize(session: session.id, windowHandle: handle))
    }
}