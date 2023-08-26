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
}

public struct WebDriverStatus: Codable {
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
