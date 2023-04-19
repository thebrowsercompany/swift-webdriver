// Represents an element in the WinAppDriver API
// (https://github.com/microsoft/WinAppDriver/blob/master/Docs/SupportedAPIs.md)
public class Element {
    var webDriver: WebDriver { session.webDriver }
    let session: Session
    let id: String

    init(in session: Session, id: String) {
        self.session = session
        self.id = id
    }

    // click() - simulate clicking an Element
    public func click() {
        let clickRequest = ClickRequest(element: self)
        try! webDriver.send(clickRequest)
    }

    struct ClickRequest : WebDriverRequest {
        typealias ResponseValue = WebDriverNoResponseValue

        private let element: Element
        
        init(element: Element) {
            self.element = element 
        }

        var pathComponents: [String] { [ "session", element.session.id, "element", element.id, "click" ] }
        var method: HTTPMethod { .post }
        var body: Body { .init() }
    }
}
