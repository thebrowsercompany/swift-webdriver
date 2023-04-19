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
}
