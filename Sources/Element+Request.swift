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
            if error.status == .noSuchElement {
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

        struct Body : Codable {
            var using: String
            var value: String
        }

        struct ResponseValue : Codable {
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

    /// location - return x, y location of the element relative to the screen top left corner
    public var location: (x: Int, y: Int) {
        let locationRequest = LocationRequest(element: self)
        let responseValue = try! webDriver.send(locationRequest).value!
        return (responseValue.x, responseValue.y)
    } 

    struct LocationRequest : WebDriverRequest {
        private let element: Element
        
        init(element: Element) {
            self.element = element 
        }

        var pathComponents: [String] { [ "session", element.session.id, "element", element.id, "location"] }
        var method: HTTPMethod { .get }
        var body: Body = .init()

        struct ResponseValue: Codable {
            let x: Int
            let y: Int
        }
    }

    /// size - return width, height of the element
    public var size: (width: Int, height: Int) {
        let sizeRequest = SizeRequest(element: self)
        let response = try! webDriver.send(sizeRequest)
        let responseValue = response.value!
        return (responseValue.width, responseValue.height)
    } 

    struct SizeRequest : WebDriverRequest {
        private let element: Element
        
        init(element: Element) {
            self.element = element 
        }

        var pathComponents: [String] { [ "session", element.session.id, "element", element.id, "size"] }
        var method: HTTPMethod { .get }
        var body: Body { .init() }

        struct ResponseValue: Codable {
            let width: Int
            let height: Int
        }
    }

    /// Send keys to an element
    /// https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidvalue
    public func sendKeys(value: [String]) {
        let keysRequest = KeysRequest(element: self, value: value)
        try! webDriver.send(keysRequest)
    }

    struct KeysRequest : WebDriverRequest {
        typealias ResponseValue = WebDriverNoResponseValue
        
        private let element: Element

        init(element: Element, value: [String]) {
            self.element = element
            body = .init(value: value)
        }

        var pathComponents: [String] { [ "session", element.session.id, "element", element.id, "value"] }
        var method: HTTPMethod { .post }
        var body: Body

        struct Body : Codable {
            var value: [String]
        }
    } 
    
}
