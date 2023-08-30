public enum WireProtocol {
    /// The Selenium legacy wire protocol,
    /// as described at https://www.selenium.dev/documentation/legacy/json_wire_protocol
    case SeleniumLegacy
    /// The W3C-standard WebDriver protocol,
    /// as described at https://www.w3.org/TR/webdriver1
    case WebDriver
}