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

    /// - Parameter windowHandle: Name of current window
    /// - Returns: Current window position in form of {x,y} where x and y are the upper left corner of the screen
    public func position(windowHandle: String) throws -> (x: Int, y: Int) {
        let response = try webDriver.send(Requests.WindowPosition.Get(session: id, windowHandle: windowHandle))
        return (x: response.value.x, y: response.value.y)
    }

    /// - Parameters:
    ///   - windowHandle: Name of te current window
    ///   - width: The new window width
    ///   - height: The new window height
    public func setSize(windowHandle: String, width: Double, height: Double) throws {
        try webDriver.send(Requests.WindowSize.Post(session: id, windowHandle: windowHandle, width: width, height: height))
    }

    /// - Parameters:
    ///   - windowHandle: Name of current window
    ///   - x: Position in the top left corner of the x coordinate
    ///   - y: Position in the top left corner of the y coordinate
    public func setPosition(windowHandle: String, x: Double, y: Double) throws {
        try webDriver.send(Requests.WindowPosition.Post(session: id, windowHandle: windowHandle, x: x, y: y))
    }

    /// Maximize specific window if :windowHandle is "current" the current window will be maximized
    public func maximize(windowHandle: String) throws {
        try webDriver.send(Requests.SessionMaximize(session: id, windowHandle: windowHandle))
    }
}