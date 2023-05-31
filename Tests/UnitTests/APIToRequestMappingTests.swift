import XCTest
@testable import WebDriver

/// Tests how usage of high-level Session/Element APIs map to lower-level requests
class APIToRequestMappingTests : XCTestCase {
    func testSessionAndElement() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(in: mockWebDriver, id: "mySession")
        XCTAssertEqual(session.id, "mySession")

        mockWebDriver.expect(path: "session/mySession/title", method: .get) { WebDriverResponse(value: "mySession.title") }
        XCTAssertEqual(session.title, "mySession.title")

        mockWebDriver.expect(path: "session/mySession/element", method: .post, type: Session.ElementRequest.self) {
            XCTAssertEqual($0.using, "name")
            XCTAssertEqual($0.value, "myElement.name")
            return WebDriverResponse(value: .init(ELEMENT: "myElement"))
        }
        let element = session.findElement(byName: "myElement.name")!

        mockWebDriver.expect(path: "session/mySession/element/myElement/text", method: .get) { WebDriverResponse(value: "myElement.text") }
        XCTAssertEqual(element.text, "myElement.text")

        mockWebDriver.expect(path: "session/mySession/element/myElement/click", method: .post)
        element.click()

        // Account for session deinitializer
        mockWebDriver.expect(path: "session/mySession", method: .delete)
    }
}