extension WebDriverError.Status {
    // WinAppDriver returns when passing an incorrect window handle to attach to.
    static let winAppDriver_invalidArgument = Self(rawValue: 100)

    // WinAppDriver returns when an element command could not be completed because the element is not pointer- or keyboard interactable.
    static let winAppDriver_elementNotInteractable = Self(rawValue: 105)
}
