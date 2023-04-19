extension Session {
   
    /// title - the session title, usually the hwnd title
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

    /// findElementByName
    /// - Parameter name: name of the element to find 
    ///  (https://learn.microsoft.com/en-us/windows/win32/winauto/inspect-objects)
    /// - Returns: a new instance of Element
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