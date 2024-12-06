public enum TimeoutType: String, Codable {
    case script
    case implicitWait = "implicit"
    case pageLoad = "page load"
}
