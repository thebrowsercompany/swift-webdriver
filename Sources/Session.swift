import Foundation

// Represents a Session in the WinAppDriver API.
public class Session {
    let webDriver: any WebDriver
    public let id: String

    private var deleted: Bool = false

    init(in webDriver: some WebDriver, id: String) {
        self.webDriver = webDriver
        self.id = id
    }

    /// retryTimeout
    /// A TimeInterval specifying max time to spend retrying operations.
    var defaultRetryTimeout: TimeInterval = 1.0

    /// delete
    /// Attempts to delete the session.
    public func delete() throws {
        guard !deleted else {
            return
        }

        let deleteSessionRequest = DeleteSessionRequest(sessionId: id)
        try webDriver.send(deleteSessionRequest)
        deleted = true
    }

    deinit {
        do { try delete() } catch let error as WebDriverError {
            assertionFailure("Error in Session.delete: \(error)")
        } catch {
            assertionFailure("Unexpected error in Session.delete: \(error)")
        }
    }

    struct DeleteSessionRequest: WebDriverRequest {
        typealias Response = WebDriverResponseNoValue

        let sessionId: String
        var pathComponents: [String] { ["session", sessionId] }
        var method: HTTPMethod { .delete }
        var body: Body { .init() }
    }
}
