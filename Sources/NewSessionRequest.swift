struct NewSessionRequest<Caps: Capabilities>: WebDriverRequest {
    public var requiredCapabilities: Caps?
    public var desiredCapabilities: Caps?

    init(requiredCapabilities: Caps? = nil, desiredCapabilities: Caps? = nil) {
        self.requiredCapabilities = requiredCapabilities
        self.desiredCapabilities = desiredCapabilities
    }

    var pathComponents: [String] { ["session"] }
    var method: HTTPMethod { .post }
    var body: Body { .init(requiredCapabilities: requiredCapabilities, desiredCapabilities: desiredCapabilities) }

    struct Body: Codable {
        var requiredCapabilities: Caps?
        var desiredCapabilities: Caps?
    }

    struct Response: Codable {
        public var sessionId: String
        public var value: Caps
    }
}