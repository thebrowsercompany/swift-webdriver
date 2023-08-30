public protocol WebDriver {
    @discardableResult
    func send<Request: WebDriverRequest>(_ request: Request) throws -> Request.Response
}

extension WebDriver {
    /// status - returns WinAppDriver status
    /// Returns: an instance of the Status type
    public var status: WebDriverStatus {
        get throws { try send(WebDriverRequests.Status()) }
    }
}