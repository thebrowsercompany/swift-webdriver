// Represents an element in the WinAppDriver API
// (https://github.com/microsoft/WinAppDriver/blob/master/Docs/SupportedAPIs.md)
public struct Element {
    var webDriver: WebDriver { session.webDriver }
    let session: Session
    let id: String

    init(in session: Session, id: String) {
        self.session = session
        self.id = id
    }
}
