public protocol WebDriver {
    /// The protocol supported by the WebDriver server.
    var wireProtocol: WireProtocol { get }

    /// Sends a WebDriver request to the server and returns the response.
    /// - Parameter request: The request to send.
    @discardableResult
    func send<Req: Request>(_ request: Req) throws -> Req.Response

    /// Determines if a given error is inconclusive and should be retried.
    func isInconclusiveInteraction(error: ErrorResponse.Status) -> Bool
}

extension WebDriver {
    /// status - returns WinAppDriver status
    /// Returns: an instance of the Status type
    public var status: WebDriverStatus {
        get throws { try send(Requests.Status()) }
    }

    public func isInconclusiveInteraction(error: ErrorResponse.Status) -> Bool { false }
}