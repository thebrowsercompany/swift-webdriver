import WebDriver

extension ElementLocator {
    /// Matches an element whose accessibility ID matches the search value.
    public static func accessibilityId(_ value: String) -> Self {
        Self(using: "accessibility id", value: value)
    }
}