import Foundation

// Represents a Session in the WinAppDriver API.
public class Session {
    let webDriver: any WebDriver
    public let id: String

    private var valid: Bool

    init(in webDriver: some WebDriver, id: String) {
        self.webDriver = webDriver
        self.id = id
        valid = true
    }

    /// retryTimeout
    /// A TimeInterval specifying max time to spend retrying operations.
    var defaultRetryTimeout: TimeInterval = 1.0

    /// delete
    /// Attempts to delete the session.
    public func delete() throws {
        guard valid else {
            return
        }

        let deleteSessionRequest = DeleteSessionRequest(sessionId: id)
        try webDriver.send(deleteSessionRequest)
        valid = false
    }

    deinit {
        do { try delete() } catch let error as WebDriverError {
            assertionFailure("Error in Session.delete: \(error)")
        } catch {
            assertionFailure("Unknown error in Session.delete.")
        }
    }

    struct DeleteSessionRequest: WebDriverRequest {
        typealias ResponseValue = WebDriverResponseNoValue

        let sessionId: String
        var pathComponents: [String] { ["session", sessionId] }
        var method: HTTPMethod { .delete }
        var body: Body { .init() }
    }
}
