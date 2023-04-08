struct NewSessionRequest : WebDriverRequest {
    typealias ResponseValue = WebDriverNoResponseValue

    var pathComponents: [String] = ["session"]
    var method: HTTPMethod = .post
    var body: Body = Body()

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
    let sessionId: String
    typealias ResponseValue = WebDriverNoResponseValue
    var pathComponents: [String] { ["session", sessionId] }
     var method: HTTPMethod = .delete
    var body: Body = Body()
}

struct SessionTitleRequest : WebDriverRequest {
    let sessionId: String
    typealias ResponseValue = String
    var pathComponents: [String] { [ "session", sessionId, "title" ] }
    var method: HTTPMethod { .get }
    var body: Body = Body()
}