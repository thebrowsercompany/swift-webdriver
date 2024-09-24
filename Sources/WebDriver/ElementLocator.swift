/// A locator strategy to use when searching for an element.
public struct ElementLocator: Codable, Hashable {
    /// The locator strategy to use.
    public var using: String
    /// The search target.
    public var value: String

    public init(using: String, value: String) {
        self.using = using
        self.value = value
    }

    /// Matches an element whose class name contains the search value; compound class names are not permitted.
    public static func className(_ value: String) -> Self {
        Self(using: "class name", value: value)
    }

    /// Matches an element matching a CSS selector.
    public static func cssSelector(_ value: String) -> Self {
        Self(using: "css selector", value: value)
    }

    /// Matches an element whose ID attribute matches the search value.
    public static func id(_ value: String) -> Self {
        Self(using: "id", value: value)
    }

    /// Matches an element whose NAME attribute matches the search value.
    public static func name(_ value: String) -> Self {
        Self(using: "name", value: value)
    }

    /// Matches an anchor element whose visible text matches the search value.
    public static func linkText(_ value: String) -> Self {
        Self(using: "link text", value: value)
    }

    /// Returns an anchor element whose visible text partially matches the search value.
    public static func partialLinkText(_ value: String) -> Self {
        Self(using: "partial link text", value: value)
    }

    /// Returns an element whose tag name matches the search value.
    public static func tagName(_ value: String) -> Self {
        Self(using: "tag name", value: value)
    }

    /// Returns an element matching an XPath expression.
    public static func xpath(_ value: String) -> Self {
        Self(using: "xpath", value: value)
    }
}