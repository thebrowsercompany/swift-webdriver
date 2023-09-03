public enum Requests {
    public struct ResponseWithValue<Value>: Codable where Value: Codable {
        public var value: Value

        public init(_ value: Value) {
            self.value = value
        }

        internal enum CodingKeys: String, CodingKey {
            case value
        }
    }

    public struct ElementResponseValue: Codable {
        public var element: String

        enum CodingKeys: String, CodingKey {
            case element = "ELEMENT"
        }
    }

    public struct ElementAttribute: Request {
        public var session: String
        public var element: String
        public var attribute: String

        public var pathComponents: [String] { ["session", session, "element", element, "attribute", attribute] }
        public var method: HTTPMethod { .get }

        public typealias Response = ResponseWithValue<String>
    }

    public struct ElementClick: Request {
        public var session: String
        public var element: String

        public var pathComponents: [String] { ["session", session, "element", element, "click"] }
        public var method: HTTPMethod { .post }
    }

    public struct ElementDisplayed: Request {
        public var session: String
        public var element: String

        public var pathComponents: [String] { ["session", session, "element", element, "displayed"] }
        public var method: HTTPMethod { .get }

        // Override the whole Response struct instead of just ResponseValue
        // because the value is a Bool, which does not conform to Codable.
        public struct Response: Codable {
            public var value: Bool
        }
    }

    public struct ElementValue: Request {
        public var session: String
        public var element: String
        public var value: [String]

        public var pathComponents: [String] { ["session", session, "element", element, "value"] }

        public var method: HTTPMethod { .post }
        public var body: Body { .init(value: value) }

        public struct Body: Codable {
            public var value: [String]
        }
    }

    public struct ElementLocation: Request {
        public var session: String
        public var element: String

        public var pathComponents: [String] { ["session", session, "element", element, "location"] }
        public var method: HTTPMethod { .get }

        public typealias Response = ResponseWithValue<ResponseValue>
        public struct ResponseValue: Codable {
            public var x: Int
            public var y: Int
        }
    }

    public struct ElementSize: Request {
        public var session: String
        public var element: String

        public var pathComponents: [String] { ["session", session, "element", element, "size"] }
        public var method: HTTPMethod { .get }

        public typealias Response = ResponseWithValue<ResponseValue>
        public struct ResponseValue: Codable {
            public var width: Int
            public var height: Int
        }
    }

    public struct ElementText: Request {
        public var session: String
        public var element: String

        public var pathComponents: [String] { ["session", session, "element", element, "text"] }
        public var method: HTTPMethod { .get }

        public typealias Response = ResponseWithValue<String>
    }

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

    public struct SessionActiveElement: Request {
        public var session: String

        public var pathComponents: [String] { ["session", session, "element", "active"] }
        public var method: HTTPMethod { .post }

        public typealias Response = ResponseWithValue<ElementResponseValue>
    }

    public struct SessionButton: Request {
        public var session: String
        public var action: Action
        public var button: MouseButton

        public var pathComponents: [String] { ["session", session, action.rawValue] }
        public var method: HTTPMethod { .post }
        public var body: Body { .init(button: button) }

        public struct Body: Codable {
            public var button: MouseButton
        }

        public enum Action: String {
            case click
            case buttonUp = "buttonup"
            case buttonDown = "buttondown"
        }
    }

    public struct SessionDelete: Request {
        public var sessionId: String

        public var pathComponents: [String] { ["session", sessionId] }
        public var method: HTTPMethod { .delete }
    }

    public struct SessionElement: Request {
        public var session: String
        public var element: String? = nil
        public var using: String
        public var value: String

        public var pathComponents: [String] {
            if let element {
                return ["session", session, "element", element, "element"]
            } else {
                return ["session", session, "element"]
            }
        }

        public var method: HTTPMethod { .post }
        public var body: Body { .init(using: using, value: value) }

        public struct Body: Codable {
            var using: String
            var value: String
        }

        public typealias Response = ResponseWithValue<ElementResponseValue>
    }

    public struct SessionKeys: Request {
        public var session: String
        public var value: [String]

        public var pathComponents: [String] { ["session", session, "keys"] }
        public var method: HTTPMethod { .post }
        public var body: Body { .init(value: value) }

        public struct Body: Codable {
            public var value: [String]
        }
    }

    public struct SessionMoveTo: Request {
        public var session: String
        public var element: String?
        public var xOffset: Int
        public var yOffset: Int

        public var pathComponents: [String] { ["session", session, "moveto"] }
        public var method: HTTPMethod { .post }
        public var body: Body { .init(element: element, xOffset: xOffset, yOffset: yOffset) }

        public struct Body: Codable {
            public var element: String?
            public var xOffset: Int
            public var yOffset: Int

            enum CodingKeys: String, CodingKey {
                case element = "element"
                case xOffset = "xoffset"
                case yOffset = "yoffset"
            }
        }
    }

    public struct SessionScreenshot: Request {
        public var session: String

        public var pathComponents: [String] { ["session", session, "screenshot"] }
        public var method: HTTPMethod { .get }

        public typealias Response = ResponseWithValue<String>
    }

    public struct SessionTimeouts: Request {
        public var session: String
        public var type: String
        public var ms: Double

        public var pathComponents: [String] { ["session", session, "timeouts"] }
        public var method: HTTPMethod { .post }
        public var body: Body { .init(type: type, ms: ms) }

        public struct Body: Codable {
            public var type: String
            public var ms: Double
        }
    }

    public struct SessionTitle: Request {
        public var session: String

        public var pathComponents: [String] { ["session", session, "title"] }
        public var method: HTTPMethod { .get }

        public typealias Response = ResponseWithValue<String>
    }

    public struct Status: Request {
        public var pathComponents: [String] { ["status"] }
        public var method: HTTPMethod { .get }

        public typealias Response = WebDriverStatus
    }
}