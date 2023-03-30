protocol WebDriverRequest : Encodable {
    associatedtype ResponseValue : Decodable
    typealias Response = WebDriverResponse<ResponseValue>
}

struct WebDriverResponse<Value> : Decodable where Value : Decodable {
    var sessionId: String
    var status: Int?
    var value: Value
}

struct WebDriverNoResponseValue : Decodable {
    init(from decoder: Decoder) throws { }
}