struct ElementRequest : WebDriverRequest {
    var using: String
    var value: String
    
    struct ResponseValue : Decodable {
        var ELEMENT: String
    }
}

struct ElementTextRequest : WebDriverRequest {
    typealias ResponseValue = String
}
