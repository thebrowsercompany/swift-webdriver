import TestsCommon
@testable import WebDriver
import XCTest

/// Tests how usage of high-level Session/Element APIs map to lower-level requests
class APIToRequestMappingTests: XCTestCase {
    private typealias ResponseWithValue = Requests.ResponseWithValue

    func testCreateSession() throws {
        let mockWebDriver = MockWebDriver()
        mockWebDriver.expect(path: "session", method: .post, type: Requests.Session.self) {
            let capabilities = Capabilities()
            capabilities.platformName = "myPlatform"
            return Requests.Session.Response(sessionId: "mySession", value: capabilities)
        }
        let session = try Session(webDriver: mockWebDriver, desiredCapabilities: Capabilities())
        XCTAssertEqual(session.id, "mySession")
        XCTAssertEqual(session.capabilities.platformName, "myPlatform")

        // Account for session deinitializer
        mockWebDriver.expect(path: "session/mySession", method: .delete)
    }

    func testSessionTitle() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/title", method: .get) {
            ResponseWithValue("mySession.title")
        }
        XCTAssertEqual(try session.title, "mySession.title")
    }

    func testSessionScreenshot() throws {
        let base64TestImage: String =
            "iVBORw0KGgoAAAANSUhEUgAAAAgAAAAHCAYAAAA1WQxeAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAACXBIWXMAAB2GAAAdhgFdohOBAAAABmJLR0QA/wD/AP+gvaeTAAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDIzLTA3LTEzVDIwOjAxOjQ1KzAwOjAwCWqxhgAAACV0RVh0ZGF0ZTptb2RpZnkAMjAyMy0wNy0xM1QyMDowMTo0NSswMDowMHg3CToAAAC2SURBVBhXY/iPDG7c+///5y8oBwJQFRj4/P9f3QNhn78Appi+fP3LkNfxnIFh43oGBiE+BoYjZxkYHj5iYFi2goHhzVsGpoePfjBMrrzLUNT4jIEh2IaBQZCTgaF1EgODkiIDg4gwA9iKpILL/xnkL/xnkLzyv8UUaIVL2P//Xz5DrGAAgoPzVjDosRxmaG4UZxArjAAa/YGBYfdxkBTEhP37bv9/+eIDWAcYHDsHNOEbkPH/PwCcrZANcnx9SAAAAABJRU5ErkJggg=="

        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/screenshot", method: .get) {
            ResponseWithValue(base64TestImage)
        }
        let data: Data = try session.screenshot()
        XCTAssert(isPNG(data: data))
    }

    func testSessionFindElement() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/element", method: .post, type: Requests.SessionElement.self) {
            XCTAssertEqual($0.using, "name")
            XCTAssertEqual($0.value, "myElement.name")
            return ResponseWithValue(.init(element: "myElement"))
        }
        try session.requireElement(locator: .name("myElement.name"))

        mockWebDriver.expect(path: "session/mySession/element/active", method: .post, type: Requests.SessionActiveElement.self) {
            ResponseWithValue(.init(element: "myElement"))
        }
        _ = try session.activeElement!
    }

    func testSessionMoveTo() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/moveto", method: .post, type: Requests.SessionMoveTo.self) {
            XCTAssertEqual($0.element, "myElement")
            XCTAssertEqual($0.xOffset, 30)
            XCTAssertEqual($0.yOffset, 0)
            return CodableNone()
        }
        try session.moveTo(element: element, xOffset: 30, yOffset: 0)
    }

    func testSessionClick() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/click", method: .post, type: Requests.SessionButton.self) {
            XCTAssertEqual($0.button, .left)
            return CodableNone()
        }
        try session.click(button: .left)
    }

    func testSessionButton() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
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
    }
 
    func testSessionOrientation() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/orientation", method: .post)
        try session.setOrientation(.portrait)

        mockWebDriver.expect(path: "session/mySession/orientation", method: .get, type: Requests.SessionOrientation.Get.self) {
            ResponseWithValue(.portrait)
        }
        XCTAssert(try session.orientation == .portrait)

        mockWebDriver.expect(path: "session/mySession/orientation", method: .post)
        try session.setOrientation(.landscape)

        mockWebDriver.expect(path: "session/mySession/orientation", method: .get, type: Requests.SessionOrientation.Get.self) {
            ResponseWithValue(.landscape)
        }
        XCTAssert(try session.orientation == .landscape)
    }

    func testSendKeys() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")

        let keys = [ Keys.a, Keys.b, Keys.c ]
        mockWebDriver.expect(path: "session/mySession/keys", method: .post, type: Requests.SessionKeys.self) {
            XCTAssertEqual($0.value, keys.map { $0.rawValue })
            return CodableNone()
        }
        try session.sendKeys(keys, releaseModifiers: false)

        mockWebDriver.expect(path: "session/mySession/element/myElement/value", method: .post, type: Requests.ElementValue.self) {
            XCTAssertEqual($0.value, keys.map { $0.rawValue })
            return CodableNone()
        }
        try element.sendKeys(keys)
    }

    func testElementText() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/element/myElement/text", method: .get) {
            ResponseWithValue("myElement.text")
        }
        XCTAssertEqual(try element.text, "myElement.text")
    }

    func testElementAttribute() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/element/myElement/attribute/myAttribute.name", method: .get) {
            ResponseWithValue("myAttribute.value")
        }
        XCTAssertEqual(try element.getAttribute(name: "myAttribute.name"), "myAttribute.value")
    }

    func testElementClick() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/element/myElement/click", method: .post)
        try element.click()
    }

    func testElementLocationAndSize() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/element/myElement/location", method: .get, type: Requests.ElementLocation.self) {
            ResponseWithValue(.init(x: 10, y: -20))
        }
        XCTAssert(try element.location == (x: 10, y: -20))

        mockWebDriver.expect(path: "session/mySession/element/myElement/size", method: .get, type: Requests.ElementSize.self) {
            ResponseWithValue(.init(width: 100, height: 200))
        }
        XCTAssert(try element.size == (width: 100, height: 200))
    }

    func testElementEnabled() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/element/myElement/enabled", method: .get) {
            ResponseWithValue(true)
        }
        XCTAssert(try element.enabled == true)
    }

    func testWindowPosition() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/window/myWindow/position", method: .post)
        try session.window(handle: "myWindow").setPosition(x: 9, y: 16)

        mockWebDriver.expect(path: "session/mySession/window/myWindow/position", method: .get, type: Requests.WindowPosition.Get.self) {
            ResponseWithValue(.init(x: 9, y: 16))
        }
        XCTAssert(try session.window(handle: "myWindow").position == (x: 9, y: 16))
    }

    func testSessionScript() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/execute", method: .post)
        XCTAssertNotNil(try session.execute(script: "return document.body", args: ["script"], async: false))
    }

    func testSessionScriptAsync() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/execute_async", method: .post)
        XCTAssertNotNil(try session.execute(script: "return document.body", args: ["script"], async: true))
    }

    func testSessionTouchScroll() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/touch/scroll", method: .post)
        try session.touchScroll(element: element, xOffset: 9, yOffset: 16)
    }

    func testWindow() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/window", method: .post)
        try session.focus(window: "myWindow")

        mockWebDriver.expect(path: "session/mySession/window", method: .delete)
        try session.close(window: "myWindow")
    }

    func testWindowHandleSize() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/window/myWindow/size", method: .post)
        try session.window(handle: "myWindow").setSize(width: 500, height: 500)

        mockWebDriver.expect(path: "session/mySession/window/myWindow/size", method: .get, type: Requests.WindowSize.Get.self) {
            ResponseWithValue(.init(width: 500, height: 500))
        }
        XCTAssert(try session.window(handle: "myWindow").size == (width: 500, height: 500))
    }

    func testLocation() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let location = Location(latitude: 5, longitude: 20, altitude: 2003)
        
        mockWebDriver.expect(path: "session/mySession/location", method: .post)
        try session.setLocation(location)
        
        mockWebDriver.expect(path: "session/mySession/location", method: .get, type: Requests.SessionLocation.Get.self) {
            ResponseWithValue(.init(latitude: 5, longitude: 20, altitude: 2003))
        }
        XCTAssert(try session.location == location)
    }

    func testMaximizeWindow() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session: Session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/window/myWindow/maximize", method: .post)
        try session.window(handle: "myWindow").maximize()
    }

    func testWindowHandle() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")

        mockWebDriver.expect(path: "session/mySession/window_handle", method: .get, type: Requests.SessionWindowHandle.self) {
            ResponseWithValue(.init("myWindow"))
        }
        XCTAssert(try session.windowHandle == "myWindow")
    }

    func testWindowHandles() throws {

        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        
        mockWebDriver.expect(path: "session/mySession/window_handles", method: .get, type: Requests.SessionWindowHandles.self) {
            ResponseWithValue(.init(["myWindow", "myWindow"]))
        }
        XCTAssert(try session.windowHandles == ["myWindow", "myWindow"])
    }


    func testElementDoubleClick() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/touch/doubleclick", method: .post)
        XCTAssertNotNil(try element.doubleClick())
    }

    func testElementFlick() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/touch/flick", method: .post)
        XCTAssertNotNil(try element.flick(xOffset: 5, yOffset: 20, speed: 2003))
    }

    func testSessionFlick() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/touch/flick", method: .post)
        XCTAssertNotNil(try session.flick(xSpeed: 5, ySpeed: 20))
    }

    func testSessionSource() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/source", method: .get, type: Requests.SessionSource.self) {
            ResponseWithValue("currentSource")
        }
        XCTAssert(try session.source == "currentSource")
    }
}
