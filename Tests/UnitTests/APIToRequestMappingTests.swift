import XCTest
@testable import WebDriver

/// Tests how usage of high-level Session/Element APIs map to lower-level requests
class APIToRequestMappingTests : XCTestCase {
    func testSessionAndElement() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(in: mockWebDriver, id: "mySession")
        XCTAssertEqual(session.id, "mySession")

        mockWebDriver.expect(path: "session/mySession/title", method: .get) { "mySession.title" }
        XCTAssertEqual(session.title, "mySession.title")

        struct ElementResponseValue : Encodable {
            var ELEMENT: String
        }

        // TODO: assert that the request has expected values 
        mockWebDriver.expect(path: "session/mySession/element", method: .post) { ElementResponseValue(ELEMENT: "myElement") }
        let element = session.findElement(byName: "myElement.name")!

        mockWebDriver.expect(path: "session/mySession/element/myElement/text", method: .get) { "myElement.text" }
        XCTAssertEqual(element.text, "myElement.text")

        mockWebDriver.expect(path: "session/mySession/element/myElement/click", method: .post)
        element.click()

        // Account for session deinitializer
        mockWebDriver.expect(path: "session/mySession", method: .delete)
    }
}