class Element {
    let webDriver: WebDriver
    let session: Session
    let id: String

    init(in session: Session, id: String) {
        self.webDriver = session.webDriver
        self.session = session
        self.id = id
    }

    func click() {
        let clickRequest = ClickRequest(element: self)
        let _ = try! webDriver.send(clickRequest)
    }

    struct ClickRequest : WebDriverRequest {
        private let element: Element
        
        init(element: Element) {
            self.element = element 
            body = .init(id: element.id)
        }

        typealias ResponseValue = WebDriverNoResponseValue
        var pathComponents: [String] { [ "session", element.session.id, "element", element.id, "click" ] }
        var method: HTTPMethod { .post }
        var body: Body

        struct Body : Encodable {
            let id: String
        }
    }
}
