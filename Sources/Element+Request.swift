extension Element {
    /// click() - simulate clicking this Element
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

    /// text - the element text
    public var text: String {
        let textRequest = TextRequest(element: self)
        return try! webDriver.send(textRequest).value!
    } 

    struct TextRequest : WebDriverRequest {
        typealias ResponseValue = String

        private let element: Element
        
        init(element: Element) {
            self.element = element 
        }

        var pathComponents: [String] { [ "session", element.session.id, "element", element.id, "text"] }
        var method: HTTPMethod { .get }
        var body: Body { .init() }
    }
}
