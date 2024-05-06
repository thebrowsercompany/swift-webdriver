import WebDriver

extension ErrorResponse.Status {
    // WinAppDriver returns when passing an incorrect window handle to attach to.
    static let winAppDriver_invalidArgument = Self(rawValue: 100)

    /// Indicates that a request could not be completed because the element is not pointer- or keyboard interactable.
    static let winAppDriver_elementNotInteractable = Self(rawValue: 105)
}
