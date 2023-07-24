import Foundation

// Represents a Session in the WinAppDriver API
public class Session {
    let webDriver: any WebDriver
    let id: String

    /// retryTimeout
    /// A TimeInterval specifying max time to spend retrying operations.
    var defaultRetryTimeout: TimeInterval = 1.0

    init(in webDriver: some WebDriver, id: String) {
        self.webDriver = webDriver
        self.id = id
    }

    deinit {
        let deleteSessionRequest = DeleteSessionRequest(sessionId: id)
        try! webDriver.send(deleteSessionRequest)
    }

    struct DeleteSessionRequest: WebDriverRequest {
        typealias ResponseValue = WebDriverNoResponseValue

        let sessionId: String
        var pathComponents: [String] { ["session", sessionId] }
        var method: HTTPMethod { .delete }
        var body: Body { .init() }
    }
}
