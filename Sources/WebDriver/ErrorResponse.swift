public struct ErrorResponse: Codable, Error {
    public var status: Status
    public var value: Value

    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#response-status-codes
    public struct Status: Codable, Hashable, RawRepresentable {
        public var rawValue: Int

        public static let success = Self(rawValue: 0)
        public static let noSuchDriver = Self(rawValue: 6)
        public static let noSuchElement = Self(rawValue: 7)
        public static let noSuchFrame = Self(rawValue: 8)
        public static let unknownCommand = Self(rawValue: 9)
        public static let staleElementReference = Self(rawValue: 10)
        public static let elementNotVisible = Self(rawValue: 11)
        public static let invalidElementState = Self(rawValue: 12)
        public static let unknownError = Self(rawValue: 13)
        public static let elementIsNotSelectable = Self(rawValue: 15)
        public static let javaScriptError = Self(rawValue: 17)
        public static let xPathLookupError = Self(rawValue: 19)
        public static let timeout = Self(rawValue: 21)
        public static let noSuchWindow = Self(rawValue: 23)
        public static let invalidCookieDomain = Self(rawValue: 24)
        public static let unableToSetCookie = Self(rawValue: 25)
        public static let unexpectedAlertOpen = Self(rawValue: 26)
        public static let noAlertOpenError = Self(rawValue: 27)
        public static let scriptTimeout = Self(rawValue: 28)
        public static let invalidElementCoordinates = Self(rawValue: 29)
        public static let imeNotAvailable = Self(rawValue: 30)
        public static let imeEngineActivationFailed = Self(rawValue: 31)
        public static let invalidSelector = Self(rawValue: 32)
        public static let sessionNotCreatedException = Self(rawValue: 33)
        public static let moveTargetOutOfBounds = Self(rawValue: 34)

        // WinAppDriver-specific, but we need it in this module,
        // as we use it when polling for element clickability.
        /// Indicates that an request could not be completed because the element is not pointer- or keyboard interactable.
        static let winAppDriver_elementNotInteractable = Self(rawValue: 105)

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    public struct Value: Codable {
        public var error: String
        public var message: String
        public var stacktrace: String?
    }
}
