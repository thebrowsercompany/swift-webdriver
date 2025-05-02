extension Requests {
    /// Defines requests and response types specific to the legacy selenium json wire protocol.
    public enum LegacySelenium {
        // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#session
        public struct Session<Caps: Capabilities>: Request {
            public var desiredCapabilities: Caps
            public var requiredCapabilities: Caps?

            public init(desiredCapabilities: Caps, requiredCapabilities: Caps? = nil) {
                self.requiredCapabilities = requiredCapabilities
                self.desiredCapabilities = desiredCapabilities
            }

            public var pathComponents: [String] { ["session"] }
            public var method: HTTPMethod { .post }
            public var body: Body { .init(desiredCapabilities: desiredCapabilities, requiredCapabilities: requiredCapabilities) }

            public struct Body: Codable {
                public var desiredCapabilities: Caps
                public var requiredCapabilities: Caps?
            }

            public struct Response: Codable {
                public var sessionId: String
                public var value: Caps
            }
        }

        // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#status
        public struct Status: Request {
            public var pathComponents: [String] { ["status"] }
            public var method: HTTPMethod { .get }

            public typealias Response = WebDriverStatus
        }
    }
}
