import WebDriver

extension ErrorResponse.Status {
    // WinAppDriver returns when passing an incorrect window handle to attach to.
    static let winAppDriver_invalidArgument = Self(rawValue: 100)
}
