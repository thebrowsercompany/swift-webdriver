import Foundation
import FoundationNetworking

public struct CodableNone: Codable {}

public protocol WebDriverRequest {
    associatedtype Body: Codable = CodableNone
    associatedtype ResponseValue: Codable = CodableNone
    associatedtype Response: Codable = WebDriverResponse<ResponseValue>

    var pathComponents: [String] { get }
    var method: HTTPMethod { get }
    var body: Body { get }
}

extension WebDriverRequest where Body == CodableNone {
    var body: Body { .init() }
}

public enum HTTPMethod: String {
    case get = "GET"
    case delete = "DELETE"
    case post = "POST"
}

// Response to a WebDriver request with a response value.
public struct WebDriverResponse<Value>: Codable where Value: Codable {
    public var value: Value

    enum CodingKeys: String, CodingKey {
        case value
    }
}

// For WebDriver requests whose response lacks a value field.
public struct WebDriverResponseNoValue: Codable {}
