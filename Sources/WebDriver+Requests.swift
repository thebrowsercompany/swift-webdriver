extension WebDriver {
    /// newSession(app:) - Creates a new WinAppDriver session
    /// - Parameter app: location of the exe for the app to test
    /// - Returns: Session instance
    public func newSession(app: String, appArguments: [String]? = nil, appWorkingDir: String? = nil) -> Session {
        let args = buildArgString(args: appArguments)
        let newSessionRequest = NewSessionRequest(app: app, appArguments: args, appWorkingDir: appWorkingDir)
        return Session(in: self, id: try! send(newSessionRequest).sessionId!)
    }

    struct NewSessionRequest : WebDriverRequest {
        typealias ResponseValue = WebDriverNoResponseValue

        init(app: String, appArguments: String?, appWorkingDir: String?) {
            body.desiredCapabilities = .init(app: app, appArguments: appArguments, appWorkingDir: appWorkingDir)
        }

        var pathComponents: [String] { ["session"] }
        var method: HTTPMethod { .post }
        var body: Body = .init()

        struct RequiredCapabilities : Encodable {
        }

        struct DesiredCapabilities : Encodable {
            var app: String?
            var appArguments: String?
            var appWorkingDir: String?
        }

        struct Body : Encodable {
            var requiredCapabilities: RequiredCapabilities?
            var desiredCapabilities: DesiredCapabilities = .init()
        }
    }
}