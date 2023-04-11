struct NewSessionRequest : WebDriverRequest {
    typealias ResponseValue = WebDriverNoResponseValue

    let pathComponents: [String] = ["session"]
    var method: HTTPMethod { .post }
    var body: Body

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
    var method: HTTPMethod { .delete }
    var body: Body { .init() }
}

struct SessionTitleRequest : WebDriverRequest {
    typealias ResponseValue = String

    let sessionId: String
    var pathComponents: [String] { [ "session", sessionId, "title" ] }
    var method: HTTPMethod { .get }
    var body: Body { .init() }
}