extension Capabilities {
    /// Appium-specific capabilities. See https://appium.io/docs/en/2.0/guides/caps
    open class AppiumOptions: Codable {
        public var app: String? = nil
        public var appArguments: [String]? = nil
        public var appWorkingDir: String? = nil
        public var automationName: String? = nil
        public var deviceName: String? = nil
        public var eventTimings: Bool? = nil
        public var fullReset: Bool? = nil
        public var newCommandTimeout: Double? = nil
        public var noReset: Bool? = nil
        public var platformVersion: String? = nil
        public var printPageSourceOnFindFailure: Bool? = nil

        public init() {}

        private enum CodingKeys: String, CodingKey {
            case app
            case appArguments
            case appWorkingDir
            case automationName
            case deviceName
            case eventTimings
            case fullReset
            case newCommandTimeout
            case noReset
            case platformVersion
            case printPageSourceOnFindFailure
        }
    }
}