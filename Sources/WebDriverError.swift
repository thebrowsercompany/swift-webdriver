struct WebDriverError : Decodable, Error {
    var status: Int?
    var value: Value

    struct Value : Decodable {
        var error: String
        var message: String
        var stacktrace: String?
    }
}