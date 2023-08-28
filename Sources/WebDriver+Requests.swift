extension WebDriver {
    /// status - returns WinAppDriver status
    /// Returns: an instance of the Status type, nil if error
    public var status: WebDriverStatus? {
        get throws {
            let statusRequest = WebDriverStatusRequest()
            return try send(statusRequest)
        }
    }
}

struct WebDriverStatusRequest: WebDriverRequest {
    typealias Response = WebDriverStatus

    var pathComponents: [String] { ["status"] }
    var method: HTTPMethod { .get }
    var body: Body { .init() }
}

public struct WebDriverStatus: Codable {
    // From WebDriver spec
    var ready: Bool?
    var message: String?

    // From Selenium's legacy json protocol
    var build: Build?
    var os: OS?

    struct Build: Codable {
        var revision: String?
        var time: String?
        var version: String?
    }

    struct OS: Codable {
        var arch: String?
        var name: String?
        var version: String?
    }
}
