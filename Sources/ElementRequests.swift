class Element {
    let webDriver: WebDriver
    let session: Session
    let elementId: String

    init(_ session: Session, elementId: String) {
        self.webDriver = session.webDriver
        self.session = session
        self.elementId = elementId
    }

    func Click() {
        let clickRequest = ClickRequest(element: self)
        let _ = try! webDriver.send(clickRequest).value
    }

    struct ClickRequest : WebDriverRequest {
        private let element: Element
        
        init(element: Element) {
            self.element = element 
            body = .init(id: element.elementId)
        }

        typealias ResponseValue = WebDriverNoResponseValue
        var pathComponents: [String] { [ "session", element.session.sessionId, "element", element.elementId, "click" ] }
        var method: HTTPMethod { .post }
        var body: Body

        struct Body : Encodable {
            let id: String
        }
    }
}
