public struct WebDriverStatus: Codable {
    // From WebDriver spec
    public var ready: Bool?
    public var message: String?

    // From Selenium's legacy json protocol
    public var build: Build?
    public var os: OS?

    public struct Build: Codable {
        public var revision: String?
        public var time: String?
        public var version: String?
    }

    public struct OS: Codable {
        public var arch: String?
        public var name: String?
        public var version: String?
    }
}
