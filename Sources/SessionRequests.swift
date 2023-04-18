// Represents a Session in the WinAppDriver API
class Session {
    let webDriver: WebDriver
    let id: String

    init(in webDriver: WebDriver, id: String){
        self.webDriver = webDriver
        self.id = id
    }

    // title() - get the session title, usually the hwnd title
    func title() -> String {
        let sessionTitleRequest = SessionTitleRequest(self)
        return try! webDriver.send(sessionTitleRequest).value!
    } 

    struct SessionTitleRequest : WebDriverRequest {
        typealias ResponseValue = String

        private let sessionId: String

        init(_ session: Session) {
            sessionId = session.id
        }

        var pathComponents: [String] { [ "session", sessionId, "title" ] }
        var method: HTTPMethod { .get }
        var body: Body { .init() }
    }

    // findElementByName(_ name:)
    //   name - the name of the element in the Inspect tool
    //   (https://learn.microsoft.com/en-us/windows/win32/winauto/inspect-objects)
    func findElementByName(_ name: String) -> Element {
        let elementRequest = ElementRequest(self, using: "name", value: name)
        let value = try! webDriver.send(elementRequest).value
        return Element(in: self, id: value!.ELEMENT)
    } 

    struct ElementRequest : WebDriverRequest {
        let sessionId: String

        init(_ session: Session, using strategy: String, value: String) {
            sessionId = session.id
            body = .init(using: strategy, value: value)
        }

        var pathComponents: [String] { [ "session", sessionId, "element" ] }
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