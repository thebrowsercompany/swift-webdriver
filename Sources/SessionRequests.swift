struct NewSessionRequest : WebDriverRequest {
    typealias ResponseValue = WebDriverNoResponseValue

    var requiredCapabilities: RequiredCapabilities?
    var desiredCapabilities: DesiredCapabilities = .init()

    struct RequiredCapabilities : Encodable {
    }
    
    struct DesiredCapabilities : Encodable {
        var app: String?
    }
}

struct SessionTitleRequest : WebDriverRequest {
    typealias ResponseValue = String
}