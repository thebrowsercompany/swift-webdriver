// Represents an element in the WinAppDriver API
// (https://github.com/microsoft/WinAppDriver/blob/master/Docs/SupportedAPIs.md)
class Element {
    let webDriver: WebDriver
    let session: Session
    let id: String

    init(in session: Session, id: String) {
        self.webDriver = session.webDriver
        self.session = session
        self.id = id
    }

    // click() - simulate clicking an Element
    func click() {
        let clickRequest = ClickRequest(element: self)
        let _ = try! webDriver.send(clickRequest)
    }

    struct ClickRequest : WebDriverRequest {
        typealias ResponseValue = WebDriverNoResponseValue

        private let element: Element
        
        init(element: Element) {
            self.element = element 
            body = .init(id: element.id)
        }

        var pathComponents: [String] { [ "session", element.session.id, "element", element.id, "click" ] }
        var method: HTTPMethod { .post }
        var body: Body

        struct Body : Encodable {
            let id: String
        }
    }
}
