extension Requests {
    /// Defines requests and response types specific to the W3C WebDriver protocol.
    public enum W3C {
        public struct Session<Caps: Capabilities>: Request {
            public var alwaysMatch: Caps
            public var firstMatch: [Caps]

            public init(alwaysMatch: Caps, firstMatch: [Caps] = []) {
                self.alwaysMatch = alwaysMatch
                self.firstMatch = firstMatch
            }

            public var pathComponents: [String] { ["session"] }
            public var method: HTTPMethod { .post }
            public var body: Body { .init(capabilities: .init(alwaysMatch: alwaysMatch, firstMatch: firstMatch)) }

            public struct Body: Codable {
                public struct Capabilities: Codable {
                    public var alwaysMatch: Caps
                    public var firstMatch: [Caps]?
                }

                public var capabilities: Capabilities
            }

            public typealias Response = ResponseWithValue<ResponseValue>

            public struct ResponseValue: Codable {
                public var sessionId: String
                public var capabilities: Caps
            }
        }

        public struct Status: Request {
            public var pathComponents: [String] { ["status"] }
            public var method: HTTPMethod { .get }

            public typealias Response = ResponseWithValue<WebDriverStatus>
        }
    }
}
