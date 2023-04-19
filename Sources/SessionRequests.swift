// Represents a Session in the WinAppDriver API
public class Session {
    let webDriver: WebDriver
    let id: String

    init(in webDriver: WebDriver, id: String){
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

    // title - the session title, usually the hwnd title
    public var title: String {
        let sessionTitleRequest = TitleRequest(self)
        return try! webDriver.send(sessionTitleRequest).value!
    } 

    struct TitleRequest : WebDriverRequest {
        typealias ResponseValue = String

        private let session: Session

        init(_ session: Session) {
            self.session = session
        }

        var pathComponents: [String] { [ "session", session.id, "title" ] }
        var method: HTTPMethod { .get }
        var body: Body { .init() }
    }

    // findElementByName(_ name:)
    //   name - the name of the element in the Inspect tool
    //   (https://learn.microsoft.com/en-us/windows/win32/winauto/inspect-objects)
    public func findElementByName(_ name: String) -> Element? {
        let elementRequest = ElementRequest(self, using: "name", value: name)
        let value = try! webDriver.send(elementRequest).value
        return Element(in: self, id: value!.ELEMENT)
    } 

    struct ElementRequest : WebDriverRequest {
        let session: Session

        init(_ session: Session, using strategy: String, value: String) {
            self.session = session
            body = .init(using: strategy, value: value)
        }

        var pathComponents: [String] { [ "session", session.id, "element" ] }
        var method: HTTPMethod { .post }
        var body: Body

        struct Body : Encodable {
            var using: String
            var value: String
        }

        struct ResponseValue : Decodable {
            var ELEMENT: String
        }
    }
}