import Foundation

// Represents a Session in the WinAppDriver API
public class Session {
    let webDriver: any WebDriver
    let id: String

    /// maxRetries
    /// Maximum number of retry attempts for auto-retry functionality.
    var maxRetries: Int = 3

    /// retryTimeout
    /// A TimeInterval specifying number of seconds to wait between attempts.
    var retryTimeout: TimeInterval = 1.0

    // Process of the app being tested when launched directly (not through WinAppDriver)
    var appProcess: Process? // TODO: This seems to be unused.

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
