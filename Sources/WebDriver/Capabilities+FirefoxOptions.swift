extension Capabilities {
    /// Firefox-specific capabilities.
    open class FirefoxOptions: BrowserSpecificOptions {
        public var binary: String? = nil

        private enum CodingKeys: String, CodingKey {
            case binary
            case args
        }

        public override func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(binary, forKey: .binary)
            try container.encode(args, forKey: .args)
        }
    }
}
