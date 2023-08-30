import Foundation
import FoundationNetworking

public struct CodableNone: Codable {}

public protocol WebDriverRequest {
    associatedtype Body: Codable = CodableNone
    associatedtype Response: Codable = CodableNone

    var pathComponents: [String] { get }
    var method: HTTPMethod { get }
    var body: Body { get }
}

extension WebDriverRequest where Body == CodableNone {
    public var body: Body { .init() }
}

public enum HTTPMethod: String {
    case get = "GET"
    case delete = "DELETE"
    case post = "POST"
}
