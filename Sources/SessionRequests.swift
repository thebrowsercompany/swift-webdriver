struct NewSessionRequest : WebDriverRequest {
    typealias ResponseValue = WebDriverNoResponseValue

    let pathComponents: [String] = ["session"]
    let method: HTTPMethod = .post
    let body: Body = .init()

    struct RequiredCapabilities : Encodable {
    }

    struct DesiredCapabilities : Encodable {
        var app: String?
    }

    struct Body : Encodable {
        var requiredCapabilities: RequiredCapabilities?
        var desiredCapabilities: DesiredCapabilities = .init()
    }
}

struct SessionDeleteRequest : WebDriverRequest {
    typealias ResponseValue = WebDriverNoResponseValue

    let sessionId: String
    var pathComponents: [String] { ["session", sessionId] }
    let method: HTTPMethod = .delete
    let body: Body = .init()
}

struct SessionTitleRequest : WebDriverRequest {
    typealias ResponseValue = String

    let sessionId: String
    var pathComponents: [String] { [ "session", sessionId, "title" ] }
    let method: HTTPMethod = .get
    let body: Body = .init()
}