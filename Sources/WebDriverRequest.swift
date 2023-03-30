protocol WebDriverRequest : Encodable {
    associatedtype ResponseValue : Decodable
    typealias Response = WebDriverResponse<ResponseValue>
}

struct WebDriverResponse<Value> : Decodable where Value : Decodable {
    var sessionId: String
    var status: Int?
    var value: Value

    // init(from decoder: Decoder) throws {
    //     let values = try decoder.container(keyedBy: CodingKeys.self)
    //     sessionId = try values.decode(String.self, forKey: .sessionId)
    //     status = try? values.decode(Int.self, forKey: .status)
    //     value = try? values.decode(Value.self, forKey: .value)
    // }

    // enum CodingKeys: String, CodingKey {
    //     case sessionId
    //     case status
    //     case value
    // }
}

struct WebDriverNoResponseValue : Decodable {
    init(from decoder: Decoder) throws { }
}