public protocol WebDriver {
    @discardableResult
    func send<Req: Request>(_ request: Req) throws -> Req.Response

    /// Determines within a given error is inconclusive and should be retried.
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