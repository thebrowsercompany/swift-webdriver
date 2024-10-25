/// Thrown when findElement fails to locate an element.
public struct NoSuchElementError: Error, CustomStringConvertible {
    /// The locator that was used to search for the element.
    public var locator: ElementLocator

    /// The error that caused the element to not be found.
    public var sourceError: Error

    public init(locator: ElementLocator, sourceError: Error) {
        self.locator = locator
        self.sourceError = sourceError
    }

    /// The error response returned by the WebDriver server, if this was the source of the failure.
    public var errorResponse: ErrorResponse? { sourceError as? ErrorResponse }

    public var description: String {
        "Element not found using locator [\(locator.using)=\(locator.value)]: \(sourceError)"
    }
}
