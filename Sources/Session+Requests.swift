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
    /// Search for an element by name, starting from the root.
    /// - Parameter byName: name of the element to search for
    ///  (https://learn.microsoft.com/en-us/windows/win32/winauto/inspect-objects)
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error    
    public func findElement(byName name: String) -> Element? {
        return findElement(using: "name", value: name)
    }

    /// findElement(byAccessibilityId:)
    /// Search for an element in the accessibility tree, starting from the root.
    /// - Parameter byAccessiblityId: accessibiilty id of the element to search for
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error    
    public func findElement(byAccessibilityId id: String) -> Element? {
        return findElement(using: "accessibility id", value: id)
    } 

    /// findElement(byXPath:)
    /// Search for an element by xpath, starting from the root.
    /// - Parameter byXPath: xpath of the element to search for
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error    
    public func findElement(byXPath xpath: String) -> Element? {
        return findElement(using: "xpath", value: xpath)
    } 

    /// findElement(byClassName:)
    /// Search for an element by class name, starting from the root.
    /// - Parameter byClassName: class name of the element to search for
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error    
    public func findElement(byClassName className: String) -> Element? {
        return findElement(using: "class name", value: className)
    } 

    // Helper for findElement functions above
    private func findElement(using: String, value: String) -> Element? {
        let elementRequest = ElementRequest(self, using: using, value: value)
        var value: Session.ElementRequest.ResponseValue?
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

        struct ResponseValue : Codable {
            var ELEMENT: String
        }
    }
}