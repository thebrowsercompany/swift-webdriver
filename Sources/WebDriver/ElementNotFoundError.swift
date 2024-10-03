public struct ElementNotFoundError: Error {
    /// The locator that was used to search for the element.
    public var locator: ElementLocator

    /// A human-readable description of the element.
    public var description: String?

    /// The error that caused the element to not be found.
    public var sourceError: Error

    public init(locator: ElementLocator, description: String? = nil, sourceError: Error) {
        self.locator = locator
        self.description = description
        self.sourceError = sourceError
    }

    /// The error response returned by the WebDriver server, if this was the source of the failure.
    public var errorResponse: ErrorResponse? { sourceError as? ErrorResponse }
}