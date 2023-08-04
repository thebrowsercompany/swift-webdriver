import Foundation
import FoundationNetworking

public struct CodableNone: Codable {}

public protocol WebDriverRequest {
    associatedtype Body: Codable = CodableNone
    associatedtype ResponseValue: Codable = CodableNone
    associatedtype Response: Codable = WebDriverResponse<ResponseValue>

    var pathComponents: [String] { get }
    var query: [String: String] { get }
    var method: HTTPMethod { get }
    var body: Body { get }
}

// Provide a default for the query part of the request URL
// Saves protocol implementers from having to define if they do not use
// TODO: is there a way to provide a default for body?
extension WebDriverRequest {
    public var query: [String: String] { [:] }
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
public struct WebDriverResponseNoValue: Codable {
    public init(from decoder: Decoder) throws {}
}
