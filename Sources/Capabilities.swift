public class Capabilities: Codable {
    // From https://www.w3.org/TR/webdriver1/#dfn-capability
    public var platformName: String?
    public var setWindowRect: Bool?
    public var timeouts: Timeouts?

    // From https://www.selenium.dev/documentation/legacy/json_wire_protocol/#capabilities-json-object
    public var takesScreenshot: Bool?
    public var nativeEvents: Bool?

    // See https://www.w3.org/TR/webdriver1/#dfn-table-of-session-timeouts
    public struct Timeouts: Codable {
        public var script: Int?
        public var pageLoad: Int?
        public var implicit: Int?
    }

    private enum CodingKeys: String, CodingKey {
        case platformName
        case setWindowRect
        case timeouts

        case takesScreenshot
        case nativeEvents
    }
}

// Unfortunate workaround to allow the WinAppDriver.Capabilities name,
// where we can't resolve the global scope Capabilities using WebDriver.Capabilities
// because that is a protocol in addition to the module name.
public typealias BaseCapabilities = Capabilities