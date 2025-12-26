public protocol WebDriver: Sendable {
    /// The protocol supported by the WebDriver server.
    var wireProtocol: WireProtocol { get }

    /// Sends a WebDriver request to the server and returns the response.
    /// - Parameter request: The request to send.
    @discardableResult
    func send<Req: Request>(_ request: Req) async throws -> Req.Response

    /// Determines if a given error is inconclusive and should be retried.
    func isInconclusiveInteraction(error: ErrorResponse.Status) -> Bool
}

extension WebDriver {
    /// status - returns WinAppDriver status
    /// Returns: an instance of the WebDriverStatus type
    public var status: WebDriverStatus {
        get async throws {
            switch wireProtocol {
            case .legacySelenium: return try await send(Requests.LegacySelenium.Status())
            case .w3c: return try await send(Requests.W3C.Status()).value
            }
        }
    }

    public func isInconclusiveInteraction(error: ErrorResponse.Status) -> Bool { false }
}
