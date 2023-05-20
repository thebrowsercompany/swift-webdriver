import Foundation

class WinAppDriverProcess {
    static let ip = "127.0.0.1"
    static let port = 4723

    init() throws {

        "Ready..."
            .data(using: .utf8)
            .map(FileHandle.standardError.write)
    }

    var endpoint : URL { URL(string: "http://\(Self.ip):\(Self.port)")! }
}
