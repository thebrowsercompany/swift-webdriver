public enum TouchClickKind: String, Codable {
    case single
    case double
    case long

    private enum CodingKeys: String, CodingKey {
        case single = "click"
        case double = "doubleclick"
        case long = "longclick"
    }
}