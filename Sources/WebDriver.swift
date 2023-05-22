public protocol WebDriver {
    @discardableResult
    func send<Request: WebDriverRequest>(_ request: Request) throws -> Request.Response
}