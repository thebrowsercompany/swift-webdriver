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

    public struct ResponseWithValueArray<Value>: Codable where Value: Codable {
        public var value: [Value]

        public init(_ value: [Value]) {
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

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidattributename
    public struct ElementAttribute: Request {
        public var session: String
        public var element: String
        public var attribute: String

        public var pathComponents: [String] { ["session", session, "element", element, "attribute", attribute] }
        public var method: HTTPMethod { .get }

        public typealias Response = ResponseWithValue<String>
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidclear
    public struct ElementClear: Request {
        public var session: String
        public var element: String

        public var pathComponents: [String] { ["session", session, "element", element, "clear"] }
        public var method: HTTPMethod { .post }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidclick
    public struct ElementClick: Request {
        public var session: String
        public var element: String

        public var pathComponents: [String] { ["session", session, "element", element, "click"] }
        public var method: HTTPMethod { .post }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementiddisplayed
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

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidenabled
    public struct ElementEnabled: Request {
        public var session: String
        public var element: String

        public var pathComponents: [String] { ["session", session, "element", element, "enabled"] }
        public var method: HTTPMethod { .get }

        // Override the whole Response struct instead of just ResponseValue
        // because the value is a Bool, which does not conform to Codable.
        public struct Response: Codable {
            public var value: Bool
        }
    }

    public struct ElementSelected: Request {
        public var session: String
        public var element: String
        
        public var pathComponents: [String] { ["session", session, "element", element, "selected"] }
        public var method: HTTPMethod { .get }
        
        public struct Response: Codable {
            public var value: Bool
        }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidvalue
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

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidlocation
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

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidsize
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

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidtext
    public struct ElementText: Request {
        public var session: String
        public var element: String

        public var pathComponents: [String] { ["session", session, "element", element, "text"] }
        public var method: HTTPMethod { .get }

        public typealias Response = ResponseWithValue<String>
    }

    public struct Session_Legacy<Caps: Capabilities>: Request {
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

    public struct Session_W3C<Caps: Capabilities>: Request {
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

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementactive
    public struct SessionActiveElement: Request {
        public var session: String

        public var pathComponents: [String] { ["session", session, "element", "active"] }
        public var method: HTTPMethod { .post }

        public typealias Response = ResponseWithValue<ElementResponseValue>
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidback
    public struct SessionBack: Request {
        public var session: String

        public var pathComponents: [String] { ["session", session, "back"] }
        public var method: HTTPMethod { .post }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidbuttondown
    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidbuttonup
    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidclick
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

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionid
    public struct SessionDelete: Request {
        public var session: String

        public var pathComponents: [String] { ["session", session] }
        public var method: HTTPMethod { .delete }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessioniddoubleclick
    public struct SessionDoubleClick: Request {
        public var session: String

        public var pathComponents: [String] { ["session", session, "doubleclick"] }
        public var method: HTTPMethod { .post }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelement
    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidelement
    public struct SessionElement: Request {
        public var session: String
        public var element: String? = nil
        public var locator: ElementLocator

        public var pathComponents: [String] {
            if let element {
                return ["session", session, "element", element, "element"]
            } else {
                return ["session", session, "element"]
            }
        }

        public var method: HTTPMethod { .post }
        public var body: ElementLocator { locator }

        public typealias Response = ResponseWithValue<ElementResponseValue>
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelements
    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidelementidelements
    public struct SessionElements: Request {
        public var session: String
        public var element: String? = nil
        public var locator: ElementLocator

        public var pathComponents: [String] {
            if let element {
                return ["session", session, "element", element, "elements"]
            } else {
                return ["session", session, "elements"]
            }
        }

        public var method: HTTPMethod { .post }
        public var body: ElementLocator { locator }

        public typealias Response = ResponseWithValueArray<ElementResponseValue>
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidforward
    public struct SessionForward: Request {
        public var session: String

        public var pathComponents: [String] { ["session", session, "forward"] }
        public var method: HTTPMethod { .post }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidkeys
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

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidmoveto
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

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidrefresh
    public struct SessionRefresh: Request {
        public var session: String

        public var pathComponents: [String] { ["session", session, "refresh"] }
        public var method: HTTPMethod { .post }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidscreenshot
    public struct SessionScreenshot: Request {
        public var session: String

        public var pathComponents: [String] { ["session", session, "screenshot"] }
        public var method: HTTPMethod { .get }

        public typealias Response = ResponseWithValue<String>
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidtimeouts
    public struct SessionTimeouts: Request {
        public var session: String
        public var type: TimeoutType
        public var ms: Double

        public var pathComponents: [String] { ["session", session, "timeouts"] }
        public var method: HTTPMethod { .post }
        public var body: Body { .init(type: type, ms: ms) }

        public struct Body: Codable {
            public var type: TimeoutType
            public var ms: Double
        }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidtitle
    public struct SessionTitle: Request {
        public var session: String

        public var pathComponents: [String] { ["session", session, "title"] }
        public var method: HTTPMethod { .get }

        public typealias Response = ResponseWithValue<String>
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidtouchmove
    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidtouchdown
    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidtouchup
    public struct SessionTouchAt: Request {
        public var session: String
        public var action: Action
        public var x: Int
        public var y: Int

        public var pathComponents: [String] { ["session", session, "touch", action.rawValue] }
        public var method: HTTPMethod { .post }
        public var body: Body { .init(x: x, y: y) }

        public struct Body: Codable {
            public var x: Int
            public var y: Int
        }

        public enum Action: String, Codable {
            case move
            case down
            case up
        }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidtouchclick
    public struct SessionTouchClick: Request {
        public var session: String
        public var kind: TouchClickKind
        public var element: String

        public var pathComponents: [String] { ["session", session, "touch", kind.rawValue] }
        public var method: HTTPMethod { .post }
        public var body: Body { .init(element: element) }

        public struct Body: Codable {
            public var element: String
        }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidtouchscroll
    public struct SessionTouchScroll: Request {
        public var session: String
        public var element: String?
        public var xOffset: Int
        public var yOffset: Int

        public var pathComponents: [String] { ["session", session, "touch", "scroll"] }
        public var method: HTTPMethod { .post }
        public var body: Body { .init(element: element, xOffset: xOffset, yOffset: yOffset) }

        public struct Body: Codable {
            public var element: String?
            public var xOffset: Int
            public var yOffset: Int

            private enum CodingKeys: String, CodingKey {
                case element = "element"
                case xOffset = "xoffset"
                case yOffset = "yoffset"
            }
        }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidurl
    public enum SessionUrl {
        public struct Get: Request {
            public var session: String

            public var pathComponents: [String] { ["session", session, "url"] }
            public var method: HTTPMethod { .get }

            public typealias Response = ResponseWithValue<String>
        }

        public struct Post: Request {
            public var session: String
            public var url: String

            public var pathComponents: [String] { ["session", session, "url"] }
            public var method: HTTPMethod { .post }
            public var body: Body { .init(url: url) }

            public struct Body: Codable {
                public var url: String
            }
        }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidexecute
    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidexecute_async
    public struct SessionScript: Request {
        public var session: String
        public var script: String
        public var args: [String]
        public var async: Bool

        public var pathComponents: [String] { ["session", session, async ? "execute_async" : "execute"] }
        public var method: HTTPMethod { .post }
        public var body: Body { .init(script: script, args: args) }
        public struct Body: Codable {
            public var script: String
            public var args: [String]
        }
    }
    
    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidwindow
    public enum SessionWindow {
        public struct Post: Request {
            public var session: String
            public var name: String

            public var pathComponents: [String] { ["session", session, "window"] }
            public var method: HTTPMethod { .post }
            public var body: Body { .init(name: name) }

            public struct Body: Codable {
                public var name: String
            }
        }

        public struct Delete: Request {
            public var session: String
            public var name: String

            public var pathComponents: [String] { ["session", session, "window"] }
            public var method: HTTPMethod { .delete }
            public var body: Body { .init(name: name) }

            public struct Body: Codable {
                public var name: String
            }
        }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidwindowwindowhandlesize
    public enum WindowSize {
        public struct Post: Request {
            public var session: String
            public var windowHandle: String
            public var width: Double
            public var height: Double

            public var pathComponents: [String] { ["session", session, "window", windowHandle, "size"] }
            public var method: HTTPMethod { .post }
            public var body: Body { .init(width: width, height: height) }

            public struct Body: Codable {
                public var width: Double
                public var height: Double
            }
        }

        public struct Get: Request {
            public var session: String
            public var windowHandle: String

            public var pathComponents: [String] { ["session", session, "window", windowHandle, "size"] }
            public var method: HTTPMethod { .get }

            public typealias Response = ResponseWithValue<ResponseValue>
            public struct ResponseValue: Codable {
                public var width: Double
                public var height: Double
            }
        }
    }
  
    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidtouchdoubleclick
    public struct SessionTouchDoubleClick: Request {
        public var session: String
        public var element: String 

        public var pathComponents: [String] { ["session", session, "touch", "doubleclick"] }
        public var method: HTTPMethod { .post }
        public var body: Body { .init(element: element) }

        public struct Body: Codable {
            public var element: String
        }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidtouchflick
    public struct SessionTouchFlickElement: Request {
        public var session: String 
        public var element: String
        public var xOffset: Double
        public var yOffset: Double
        public var speed: Double

        public var pathComponents: [String] { ["session", session, "touch", "flick"] }
        public var method: HTTPMethod { .post }
        public var body: Body { .init(xOffset: xOffset, yOffset: yOffset, speed: speed) }

        public struct Body: Codable {
            public var xOffset: Double
            public var yOffset: Double
            public var speed: Double

            private enum CodingKeys: String, CodingKey {
                case xOffset = "xoffset"
                case yOffset = "yoffset"
                case speed = "speed"
            }
        }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidtouchflick-1
    public struct SessionTouchFlick: Request {
        public var session: String 
        public var xSpeed: Double
        public var ySpeed: Double
        
        public var pathComponents: [String] { ["session", session, "touch", "flick"] }
        public var method: HTTPMethod { .post }
        public var body: Body { .init(xSpeed: xSpeed, ySpeed: ySpeed) }
        
        public struct Body: Codable {
            public var xSpeed: Double
            public var ySpeed: Double

            private enum CodingKeys: String, CodingKey {
                case xSpeed = "xspeed"
                case ySpeed = "yspeed"
            }
        }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidlocation
    public enum SessionLocation {
        public struct Post: Request {
            public var session: String
            public var location: Location

            public var pathComponents: [String] { ["session", session, "location"] }
            public var method: HTTPMethod { .post }
            public var body: Location { location }
        }

        public struct Get: Request {
            public var session: String
            
            public var pathComponents: [String] { ["session", session, "location"] }
            public var method: HTTPMethod {.get}

            public typealias Response = ResponseWithValue<Location>
        }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidsource
    public struct SessionSource: Request {
        public var session: String 

        public var pathComponents: [String] { ["session", session, "source"] }
        public var method: HTTPMethod { .get }

        public typealias Response = ResponseWithValue<String>
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#status
    public struct Status: Request {
        public var pathComponents: [String] { ["status"] }
        public var method: HTTPMethod { .get }

        public typealias Response = WebDriverStatus
    }
  
     // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidorientation
    public enum SessionOrientation {
        public struct Post: Request {
            public var session: String
            public var orientation: ScreenOrientation

            public var pathComponents: [String] { ["session", session, "orientation"] }
            public var method: HTTPMethod { .post }
            public var body: Body { .init(orientation: orientation) }

            public struct Body: Codable {
                public var orientation: ScreenOrientation
            }
        }

        public struct Get: Request {
            public var session: String

            public var pathComponents: [String] { ["session", session, "orientation"] }
            public var method: HTTPMethod { .get }

            public typealias Response = ResponseWithValue<ScreenOrientation>
        }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidwindowwindowhandleposition
    public enum WindowPosition {
        public struct Post: Request {
            public var session: String
            public var windowHandle: String
            public var x: Double
            public var y: Double 

            public var pathComponents: [String] { ["session", session, "window", windowHandle, "position"] }
            public var method: HTTPMethod { .post }
            public var body: Body { .init(x: x, y: y) }

            public struct Body: Codable {
                public var x: Double
                public var y: Double
            }
        }

        public struct Get: Request {
            public var session: String
            public var windowHandle: String

            public var pathComponents: [String] { ["session", session, "window", windowHandle, "position"] }
            public var method: HTTPMethod { .get }

            public typealias Response = ResponseWithValue<ResponseValue>
            public struct ResponseValue: Codable {
                public var x: Double
                public var y: Double
            }
        }
    }

    public struct WindowMaximize: Request {
        public var session: String
        public var windowHandle: String 

        public var pathComponents: [String] { ["session", session, "window", windowHandle, "maximize"] }
        public var method: HTTPMethod { .post }
    }

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#sessionsessionidwindow_handle
    public struct SessionWindowHandle: Request {
        public var session: String 

        public var pathComponents: [String] { ["session", session, "window_handle"] }
        public var method: HTTPMethod { .get }

        public typealias Response = ResponseWithValue<String>
    }

    public struct SessionWindowHandles: Request {
        public var session: String 

        public var pathComponents: [String] { ["session", session, "window_handles"] }
        public var method: HTTPMethod { .get }

        public typealias Response = ResponseWithValue<Array<String>>
    }
}
