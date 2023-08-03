struct WebDriverError: Codable, Error {
    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#response-status-codes

    struct Status: Codable, Hashable, RawRepresentable {
        var rawValue: Int

        static let success = Self(rawValue: 0)
        static let noSuchDriver = Self(rawValue: 6)
        static let noSuchElement = Self(rawValue: 7)
        static let noSuchFrame = Self(rawValue: 8)
        static let unknownCommand = Self(rawValue: 9)
        static let staleElementReference = Self(rawValue: 10)
        static let elementNotVisible = Self(rawValue: 11)
        static let invalidElementState = Self(rawValue: 12)
        static let unknownError = Self(rawValue: 13)
        static let elementIsNotSelectable = Self(rawValue: 15)
        static let javaScriptError = Self(rawValue: 17)
        static let xPathLookupError = Self(rawValue: 19)
        static let timeout = Self(rawValue: 21)
        static let noSuchWindow = Self(rawValue: 23)
        static let invalidCookieDomain = Self(rawValue: 24)
        static let unableToSetCookie = Self(rawValue: 25)
        static let unexpectedAlertOpen = Self(rawValue: 26)
        static let noAlertOpenError = Self(rawValue: 27)
        static let scriptTimeout = Self(rawValue: 28)
        static let invalidElementCoordinates = Self(rawValue: 29)
        static let imeNotAvailable = Self(rawValue: 30)
        static let imeEngineActivationFailed = Self(rawValue: 31)
        static let invalidSelector = Self(rawValue: 32)
        static let sessionNotCreatedException = Self(rawValue: 33)
        static let moveTargetOutOfBounds = Self(rawValue: 34)
        static let invalidArgument = Self(rawValue: 100) // WinAppDriver returns when passing an incorrect window handle to attach to.
        static let elementNotInteractable =
            Self(rawValue: 105) // WinAppDriver returns when an element command could not be completed because the element is not pointer- or keyboard interactable.
    }

    struct Value: Codable {
        var error: String
        var message: String
        var stacktrace: String?
    }

    var status: Status
    var value: Value
}
