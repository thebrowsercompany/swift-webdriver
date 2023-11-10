public protocol Request {
    associatedtype Body: Codable = CodableNone
    associatedtype Response: Codable = CodableNone

    var pathComponents: [String] { get }
    var method: HTTPMethod { get }
    var body: Body { get }
}

extension Request where Body == CodableNone {
    public var body: Body { .init() }
}

public struct CodableNone: Codable {}

public enum HTTPMethod: String {
    case get = "GET"
    case delete = "DELETE"
    case post = "POST"
}
