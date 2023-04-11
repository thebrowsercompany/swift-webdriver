struct ElementRequest : WebDriverRequest {
    let sessionId: String
    var pathComponents: [String] { [ "session", sessionId, "element" ] }
    let method: HTTPMethod = .get
    let body: Body

    struct Body : Encodable {
        var using: String
        var value: String
    }

    struct ResponseValue : Decodable {
        var ELEMENT: String
    }
}
