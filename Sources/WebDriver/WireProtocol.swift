public enum WireProtocol {
    /// Identifiers Selenium's Legacy JSON Wire Protocol, 
    /// Documented at: https://www.selenium.dev/documentation/legacy/json_wire_protocol
    case legacySelenium
    /// Identifiers the W3C WebDriver Protocol,
    /// Documented at: https://w3c.github.io/webdriver/webdriver-spec.html
    case w3c
}