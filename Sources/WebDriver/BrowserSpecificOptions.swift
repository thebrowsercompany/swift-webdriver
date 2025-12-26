import Foundation

open class BrowserSpecificOptions: Codable {
    public init() {}

    /// Creates a BrowserSpecificOptions instance from JSON args array.
    /// - Parameter args: A JSON array representing the args list.
    public static func create(with args: [Any]) throws -> BrowserSpecificOptions {
        // We expect args to be an array of strings, convert it to JSON dictionary with key "args".
        let dict: [String: Any] = ["args": args]

        // Serialize to JSON Data
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])

        // Decode JSON into the concrete subclass using JSONDecoder.
        // Because we cannot instantiate 'Self' here (static method),
        // call decode on BrowserSpecificOptions by default, then cast or override in subclass if needed.
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: jsonData)
    }

    /// The list of command-line arguments for the browser.
    public var args: [String] = []

    private enum CodingKeys: String, CodingKey {
        case args
    }

    // Required for Codable to decode `args`
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.args = try container.decode([String].self, forKey: .args)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(args, forKey: .args)
    }
}
