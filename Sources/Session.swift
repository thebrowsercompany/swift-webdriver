import Foundation

// Represents a Session in the WinAppDriver API
public class Session {
    let webDriver: any WebDriver
    let id: String

    // Process of the app being tested when launched directly (not through WinAppDriver)
    var appProcess : Process?

    init(in webDriver: some WebDriver, id: String){
        self.webDriver = webDriver
        self.id = id
    }

    deinit {
        let deleteSessionRequest = DeleteSessionRequest(sessionId: id)
        try! webDriver.send(deleteSessionRequest)
    }

    struct DeleteSessionRequest : WebDriverRequest {
        typealias ResponseValue = WebDriverNoResponseValue

        let sessionId: String
        var pathComponents: [String] { ["session", sessionId] }
        var method: HTTPMethod { .delete }
        var body: Body { .init() }
    }
}