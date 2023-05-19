struct WebDriverError : Decodable, Error {
    // https://www.selenium.dev/documentation/legacy/json_wire_protocol/#response-status-codes
    enum Status: Int, Decodable {
        case success = 0
        case NoSuchDriver = 6
        case NoSuchElement = 7
        case NoSuchFrame = 8
        case UnknownCommand = 9
        case StaleElementReference = 10
        case ElementNotVisible = 11
        case InvalidElementState = 12
        case UnknownError = 13
        case ElementIsNotSelectable = 15
        case JavaScriptError = 17
        case XPathLookupError = 19
        case Timeout = 21
        case NoSuchWindow = 23
        case InvalidCookieDomain = 24
        case UnableToSetCookie = 25
        case UnexpectedAlertOpen = 26
        case NoAlertOpenError = 27
        case ScriptTimeout = 28
        case InvalidElementCoordinates = 29
        case IMENotAvailable = 30
        case IMEEngineActivationFailed = 31
        case InvalidSelector = 32
        case SessionNotCreatedException = 33
        case MoveTargetOutOfBounds = 34
    }
    
    var status: Status?
    var value: Value

    struct Value : Decodable {
        var error: String
        var message: String
        var stacktrace: String?
    }
}