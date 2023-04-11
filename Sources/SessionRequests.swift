// Left here to facilitate code review
// TODO: consider moving this extension to WebDriver.swift
extension WebDriver {
    func NewSession(app: String) -> Session {
        let newSessionRequest = NewSessionRequest(app: app)
        return Session(in: self, id: try! send(newSessionRequest).sessionId)
    }

    struct NewSessionRequest : WebDriverRequest {
        typealias ResponseValue = WebDriverNoResponseValue

        init(app: String) {
            body.desiredCapabilities = .init(app: app)
        }

        var pathComponents: [String] = ["session"]
        var method: HTTPMethod = .post
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

    func Delete(session: Session) {
        let deleteSessionRequest = DeleteSessionRequest(sessionId: session.id)
        let _ = try? send(deleteSessionRequest)
    }

    struct DeleteSessionRequest : WebDriverRequest {
        let sessionId: String
        typealias ResponseValue = WebDriverNoResponseValue
        var pathComponents: [String] { ["session", sessionId] }
        var method: HTTPMethod = .delete
        var body: Body = .init()
    }
}

class Session {
    let webDriver: WebDriver
    let id: String

    init(in webDriver: WebDriver, id: String){
        self.webDriver = webDriver
        self.id = id
    }

    func Title() -> String {
        let sessionTitleRequest = SessionTitleRequest(self)
        return try! webDriver.send(sessionTitleRequest).value;
    } 

    struct SessionTitleRequest : WebDriverRequest {
        private let sessionId: String

        init(_ session: Session) {
            sessionId = session.id
        }

        typealias ResponseValue = String
        var pathComponents: [String] { [ "session", sessionId, "title" ] }
        var method: HTTPMethod { .get }
        var body: Body = .init()
    }

    func FindElementByName(_ name: String) -> Element {
        let elementRequest = ElementRequest(self, using: "name", value: name)
        let value = try! webDriver.send(elementRequest).value
        return Element(in: self, id: value.ELEMENT)
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