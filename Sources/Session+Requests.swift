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
        return findElement(using: "name", value: name)
    }

    /// findElement(byAccessibilityId:)
    /// - Parameter byAccessiblityId: accessibiilty id of the element to find
    /// - Returns: a new instance of Element wrapping the found element, nil if not found
    /// - calls fatalError for any other error    
    public func findElement(byAccessibilityId id: String) -> Element? {
        return findElement(using: "accessibility id", value: id)
    } 

    // Helper for findElement APIs above
    private func findElement(using: String, value: String) -> Element? {
        let elementRequest = ElementRequest(self, using: using, value: value)
        var value: Session.ElementRequest.ResponseValue?
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

        struct ResponseValue : Decodable {
            var ELEMENT: String
        }
    }
}