extension WebDriver {
    /// newSession(app:) - Creates a new WinAppDriver session
    /// - Parameter app: location of the exe for the app to test
    /// - Returns: Session instance
    public func newSession(app: String) -> Session {
        let newSessionRequest = NewSessionRequest(app: app)
        return Session(in: self, id: try! send(newSessionRequest).sessionId!)
    }

    struct NewSessionRequest : WebDriverRequest {
        typealias ResponseValue = WebDriverNoResponseValue

        init(app: String) {
            body.desiredCapabilities = .init(app: app)
        }

        var pathComponents: [String] { ["session"] }
        var method: HTTPMethod { .post }
        var body: Body = .init()

        struct RequiredCapabilities : Encodable {
        }

        struct DesiredCapabilities : Encodable {
            var app: String?
        }

        struct Body : Encodable {
            var requiredCapabilities: RequiredCapabilities?
            var desiredCapabilities: DesiredCapabilities = .init()
        }
    }
}