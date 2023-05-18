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

    /// findElement(byName:) 
    /// Search for an element by name, starting from this element.
    /// - Parameter byName: name of the element to search for
    ///  (https://learn.microsoft.com/en-us/windows/win32/winauto/inspect-objects)
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error    
    public func findElement(byName name: String) -> Element? {
        return findElement(using: "name", value: name)
    }

    /// findElement(byAccessibilityId:)
    /// Search for an element in the accessibility tree, starting from this element
    /// - Parameter byAccessiblityId: accessibiilty id of the element to search for
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error    
    public func findElement(byAccessibilityId id: String) -> Element? {
        return findElement(using: "accessibility id", value: id)
    } 

    /// findElement(byXPath:)
    /// Search for an element by xpath, starting from this element
    /// - Parameter byXPath: xpath of the element to search for
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error    
    public func findElement(byXPath xpath: String) -> Element? {
        return findElement(using: "xpath", value: xpath)
    } 

    /// findElement(byClassName:)
    /// Search for an element by class name, starting from this element
    /// - Parameter byClassName: class name of the element to search for 
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error    
    public func findElement(byClassName className: String) -> Element? {
        return findElement(using: "class name", value: className)
    } 

    // Helper for findElement functions above
    private func findElement(using: String, value: String) -> Element? {
        let elementRequest = ElementRequest(self, using: using, value: value)
        var value: Element.ElementRequest.ResponseValue?
        do {
            value = try webDriver.send(elementRequest).value
        } catch let error as WebDriverError {
            if error.status == 404 {
                return nil
            } else {
                fatalError()
            }
        } catch {
            fatalError()
        }
        return Element(in: session, id: value!.ELEMENT)
    } 

    struct ElementRequest : WebDriverRequest {
        let element: Element

        init(_ element: Element, using strategy: String, value: String) {
            self.element = element
            body = .init(using: strategy, value: value)
        }

        var pathComponents: [String] { [ "session", element.session.id, "element", element.id, "element" ] }
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

    /// getAttribute(name:)
    /// Return a specific attribute of an element
    /// - Parameter name: the attribute name as given by inspect.exe
    /// - Returns: the attribute value string
    /// - calls fatalError for any other error    
    public func getAttribute(name: String) -> String {
        let attributeRequest = AttributeRequest(self, name: name)
        return try! webDriver.send(attributeRequest).value!
    }

    struct AttributeRequest : WebDriverRequest {
        typealias ResponseValue = String
        
        let element: Element
        let name: String

        init(_ element: Element, name: String) {
            self.element = element
            self.name = name
        }

        var pathComponents: [String] { [ "session", element.session.id, "element", element.id, "attribute", name ] }
        var method: HTTPMethod { .get }
        var body: Body = .init()
    }     
}
