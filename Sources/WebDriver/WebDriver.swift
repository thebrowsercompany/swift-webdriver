public protocol WebDriver {
    @discardableResult
    func send<Req: Request>(_ request: Req) throws -> Req.Response
}

extension WebDriver {
    /// status - returns WinAppDriver status
    /// Returns: an instance of the Status type
    public var status: WebDriverStatus {
        get throws { try send(Requests.Status()) }
    }
}