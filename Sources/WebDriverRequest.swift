import Foundation
import FoundationNetworking

public protocol WebDriverRequest {
    associatedtype Body : Encodable = CodableNone
    associatedtype ResponseValue : Decodable = CodableNone
    typealias Response = WebDriverResponse<ResponseValue>

    var pathComponents: [String] { get }
    var query: [String: String] { get }
    var method: HTTPMethod { get }
    var body: Body { get }
}

// Provide a default for the query part of the request URL
// Saves protocol implementers from having to define if they do not use 
// TODO: is there a way to provide a default for body?
extension WebDriverRequest {
    public var query: [String: String] { get { [:] }}
}

public struct CodableNone : Codable {}

public enum HTTPMethod : String {
    case get = "GET"
    case delete = "DELETE"
    case post = "POST"
}

// Response to a WebDriver request
// All fields are optional because the response returned by WebDriver might be missing them, e.g., 
// - deleteSession request returns no sessionId and no value
// - element click request returns a sessionId but no value
// - etc.
public struct WebDriverResponse<Value> : Decodable where Value : Decodable {
    public var sessionId: String?
    public var status: Int?
    public var value: Value?
}

public struct WebDriverNoResponse : Decodable {
}

public struct WebDriverNoResponseValue : Decodable {
    public init(from decoder: Decoder) throws { }
}