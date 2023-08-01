import Foundation

// Represents a Session in the WinAppDriver API.
public class Session {
    let webDriver: any WebDriver
    let id: String

    init(in webDriver: some WebDriver, id: String) {
        self.webDriver = webDriver
        self.id = id
    }

    /// delete
    /// Attempts to delete the session.
    func delete() throws {
        let deleteSessionRequest = DeleteSessionRequest(sessionId: id)
        try webDriver.send(deleteSessionRequest)
    }

    deinit {
        // TODO: Get rid of this deinit and make callers use Session.delete
        // and handle/propegate exceptions. For now this is challenging to
        // untangle, and unlikely to actually throw.
        do { try delete() } catch let error as WebDriverError {
            fatalError("Error in Session.delete: \(error)")
        } catch {
            fatalError("Unknown error in Session.delete.")
        }
    }

    struct DeleteSessionRequest: WebDriverRequest {
        typealias ResponseValue = WebDriverNoResponseValue

        let sessionId: String
        var pathComponents: [String] { ["session", sessionId] }
        var method: HTTPMethod { .delete }
        var body: Body { .init() }
    }
}
