import Foundation
import FoundationNetworking

protocol WebDriverRequest {
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
    var query: [String: String] { get { [:] }}
}

struct CodableNone : Codable {}

enum HTTPMethod : String {
    case get = "GET"
    case delete = "DELETE"
    case post = "POST"
}

struct WebDriverResponse<Value> : Decodable where Value : Decodable {
    var sessionId: String
    var status: Int?
    var value: Value
}

struct WebDriverNoResponse : Decodable {
}

struct WebDriverNoResponseValue : Decodable {
    init(from decoder: Decoder) throws { }
}