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

    /// findElement(byName:)
    /// - Parameter byName: name of the element to find 
    ///  (https://learn.microsoft.com/en-us/windows/win32/winauto/inspect-objects)
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error    
    public func findElement(byName name: String) -> Element? {
        let elementRequest = ElementRequest(self, using: "name", value: name)
        var value: Session.ElementRequest.ResponseValue?
        do {
            value = try webDriver.send(elementRequest).value
        } catch {
            fatalError()
        }
        return value != nil ? Element(in: self, id: value!.ELEMENT) : nil
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