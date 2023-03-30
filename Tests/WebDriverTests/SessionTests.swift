import XCTest
@testable import WebDriver

class SessionTests : XCTestCase {
    public func testTitle() {
        let winAppDriver = try! WinAppDriverProcess()
        let webDriver = WebDriver(url: winAppDriver.url)

        var newSessionRequest = NewSessionRequest()
        newSessionRequest.desiredCapabilities = .init(app: "C:\\Windows\\System32\\msinfo32.exe")
        let sessionId = try! webDriver.sendPost(path: "session", request: newSessionRequest).sessionId;

        let title: String = try! webDriver.sendGet(path: "session/\(sessionId)/title").value;
        XCTAssertEqual(title, "System Information")

        try! webDriver.sendDelete(path: "session/\(sessionId)")
    }
}