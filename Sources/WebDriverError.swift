struct WebDriverError : Decodable, Error {
    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#response-status-codes
    enum Status: Int, Decodable {
        case success = 0
        case noSuchDriver = 6
        case noSuchElement = 7
        case noSuchFrame = 8
        case unknownCommand = 9
        case staleElementReference = 10
        case elementNotVisible = 11
        case invalidElementState = 12
        case unknownError = 13
        case elementIsNotSelectable = 15
        case javaScriptError = 17
        case xPathLookupError = 19
        case timeout = 21
        case noSuchWindow = 23
        case invalidCookieDomain = 24
        case unableToSetCookie = 25
        case unexpectedAlertOpen = 26
        case noAlertOpenError = 27
        case scriptTimeout = 28
        case invalidElementCoordinates = 29
        case imeNotAvailable = 30
        case imeEngineActivationFailed = 31
        case invalidSelector = 32
        case sessionNotCreatedException = 33
        case moveTargetOutOfBounds = 34
    }
    
    var status: Status?
    var value: Value

    struct Value : Decodable {
        var error: String
        var message: String
        var stacktrace: String?
    }
}