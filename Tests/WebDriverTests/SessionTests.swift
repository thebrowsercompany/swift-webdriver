import XCTest
@testable import WebDriver

class SessionTests : XCTestCase {
    public func testTitle() {
        let winAppDriver = try! WinAppDriverProcess()
        let webDriver = WebDriver(url: winAppDriver.url)

        var newSessionRequest = NewSessionRequest()
        newSessionRequest.body.desiredCapabilities = .init(app: "C:\\Windows\\System32\\msinfo32.exe")
        let sessionId = try! webDriver.send(newSessionRequest).sessionId;

        let sessionTitleRequest = SessionTitleRequest(sessionId: sessionId)
        let title: String = try! webDriver.send(sessionTitleRequest).value;
        XCTAssertEqual(title, "System Information")

        let sessionDeleteRequest = SessionDeleteRequest(sessionId: sessionId)
        let _ = try? webDriver.send(sessionDeleteRequest)
    }
}