import Foundation
import FoundationNetworking

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

public struct CodableNone: Codable {}

public enum HTTPMethod: String {
    case get = "GET"
    case delete = "DELETE"
    case post = "POST"
}

// Response to a WebDriver request
// All fields are optional because the response returned by WebDriver might be missing them, e.g.,
// - deleteSession request returns no sessionId and no value
// - element click request returns a sessionId but no value
// - etc.
public struct WebDriverResponse<Value>: Codable where Value: Codable {
    public var sessionId: String?
    public var status: Int?
    public var value: Value?
}

public struct WebDriverNoResponse: Codable {}

public struct WebDriverNoResponseValue: Codable {
    public init(from decoder: Decoder) throws {}
}
