import TestsCommon
@testable import WebDriver
import XCTest

let base64TestImage: String =
    "iVBORw0KGgoAAAANSUhEUgAAAAgAAAAHCAYAAAA1WQxeAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAACXBIWXMAAB2GAAAdhgFdohOBAAAABmJLR0QA/wD/AP+gvaeTAAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDIzLTA3LTEzVDIwOjAxOjQ1KzAwOjAwCWqxhgAAACV0RVh0ZGF0ZTptb2RpZnkAMjAyMy0wNy0xM1QyMDowMTo0NSswMDowMHg3CToAAAC2SURBVBhXY/iPDG7c+///5y8oBwJQFRj4/P9f3QNhn78Appi+fP3LkNfxnIFh43oGBiE+BoYjZxkYHj5iYFi2goHhzVsGpoePfjBMrrzLUNT4jIEh2IaBQZCTgaF1EgODkiIDg4gwA9iKpILL/xnkL/xnkLzyv8UUaIVL2P//Xz5DrGAAgoPzVjDosRxmaG4UZxArjAAa/YGBYfdxkBTEhP37bv9/+eIDWAcYHDsHNOEbkPH/PwCcrZANcnx9SAAAAABJRU5ErkJggg=="

/// Tests how usage of high-level Session/Element APIs map to lower-level requests
class APIToRequestMappingTests: XCTestCase {
    private typealias ResponseWithValue = Requests.ResponseWithValue

    func testSessionAndElement() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(in: mockWebDriver, id: "mySession", capabilities: Capabilities())
        XCTAssertEqual(session.id, "mySession")

        // Session requests unit-tests
        mockWebDriver.expect(path: "session/mySession/title", method: .get) {
            ResponseWithValue("mySession.title")
        }
        XCTAssertEqual(try session.title, "mySession.title")

        mockWebDriver.expect(path: "session/mySession/screenshot", method: .get) {
            ResponseWithValue(base64TestImage)
        }
        let data: Data = try session.screenshot()
        XCTAssert(isPNG(data: data))

        mockWebDriver.expect(path: "session/mySession/element", method: .post, type: Requests.SessionElement.self) {
            XCTAssertEqual($0.using, "name")
            XCTAssertEqual($0.value, "myElement.name")
            return ResponseWithValue(.init(element: "myElement"))
        }
        let element = try session.findElement(byName: "myElement.name")!

        mockWebDriver.expect(path: "session/mySession/element/active", method: .post, type: Requests.SessionActiveElement.self) {
            ResponseWithValue(.init(element: "myElement"))
        }
        _ = try session.activeElement!

        mockWebDriver.expect(path: "session/mySession/moveto", method: .post, type: Requests.SessionMoveTo.self) {
            XCTAssertEqual($0.element, "myElement")
            XCTAssertEqual($0.xOffset, 30)
            XCTAssertEqual($0.yOffset, 0)
            return CodableNone()
        }
        try session.moveTo(element: element, xOffset: 30, yOffset: 0)

        mockWebDriver.expect(path: "session/mySession/click", method: .post, type: Requests.SessionButton.self) {
            XCTAssertEqual($0.button, .left)
            return CodableNone()
        }
        try session.click(button: .left)

        mockWebDriver.expect(path: "session/mySession/buttondown", method: .post, type: Requests.SessionButton.self) {
            XCTAssertEqual($0.button, .right)
            return CodableNone()
        }
        try session.buttonDown(button: .right)

        mockWebDriver.expect(path: "session/mySession/buttonup", method: .post, type: Requests.SessionButton.self) {
            XCTAssertEqual($0.button, .right)
            return CodableNone()
        }
        try session.buttonUp(button: .right)

        // Element requests unit-tests

        mockWebDriver.expect(path: "session/mySession/element/myElement/text", method: .get) {
            ResponseWithValue("myElement.text")
        }
        XCTAssertEqual(try element.text, "myElement.text")

        mockWebDriver.expect(path: "session/mySession/element/myElement/attribute/myAttribute.name", method: .get) {
            ResponseWithValue("myAttribute.value")
        }
        XCTAssertEqual(try element.getAttribute(name: "myAttribute.name"), "myAttribute.value")

        mockWebDriver.expect(path: "session/mySession/element/myElement/click", method: .post)
        try element.click()

        mockWebDriver.expect(path: "session/mySession/element/myElement/location", method: .get, type: Requests.ElementLocation.self) {
            ResponseWithValue(.init(x: 10, y: -20))
        }
        XCTAssert(try element.location == (x: 10, y: -20))

        mockWebDriver.expect(path: "session/mySession/element/myElement/size", method: .get, type: Requests.ElementSize.self) {
            ResponseWithValue(.init(width: 100, height: 200))
        }
        XCTAssert(try element.size == (width: 100, height: 200))

        let keys = ["a", "b", "c"]
        mockWebDriver.expect(path: "session/mySession/element/myElement/value", method: .post, type: Requests.ElementValue.self) {
            XCTAssertEqual($0.value, keys)
            return CodableNone()
        }
        try element.sendKeys(value: keys)

        mockWebDriver.expect(path: "session/mySession/keys", method: .post, type: Requests.SessionKeys.self) {
            XCTAssertEqual($0.value, keys)
            return CodableNone()
        }
        try session.sendKeys(value: keys)

        // Account for session deinitializer
        mockWebDriver.expect(path: "session/mySession", method: .delete)
    }
}
