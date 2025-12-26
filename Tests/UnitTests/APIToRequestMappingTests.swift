import TestsCommon

@testable import WebDriver

/// Tests how usage of high-level Session/Element APIs map to lower-level requests
@MainActor
final class APIToRequestMappingTests: XCTestCase {
    private typealias ResponseWithValue = Requests.ResponseWithValue

    func testCreateSession() async throws {
        let mockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        mockWebDriver.expect(
            path: "session", method: .post, type: Requests.LegacySelenium.Session.self
        ) {
            let capabilities = Capabilities()
            capabilities.platformName = "myPlatform"
            return Requests.LegacySelenium.Session.Response(
                sessionId: "mySession", value: capabilities)
        }
        let session = try await Session(webDriver: mockWebDriver, capabilities: Capabilities())
        XCTAssertEqual(session.id, "mySession")
        XCTAssertEqual(session.capabilities.platformName, "myPlatform")

        // Account for session deinitializer
        mockWebDriver.expect(path: "session/mySession", method: .delete)
        try await session.delete()
    }

    func testStatus_legacySelenium() async throws {
        let mockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        mockWebDriver.expect(
            path: "status", method: .get, type: Requests.LegacySelenium.Status.self
        ) {
            var status = WebDriverStatus()
            status.ready = true
            return status
        }

        XCTAssertEqual(try await mockWebDriver.status.ready, true)
    }

    func testStatus_w3c() async throws {
        let mockWebDriver = MockWebDriver(wireProtocol: .w3c)
        mockWebDriver.expect(path: "status", method: .get, type: Requests.W3C.Status.self) {
            var status = WebDriverStatus()
            status.ready = true
            return Requests.W3C.Status.Response(status)
        }

        XCTAssertEqual(try await mockWebDriver.status.ready, true)
    }

    func testSessionTitle() async throws {
        let mockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/title", method: .get) {
            ResponseWithValue("mySession.title")
        }
        XCTAssertEqual(try await session.title, "mySession.title")
    }

    func testSessionScreenshot() async throws {
        let base64TestImage: String =
            "iVBORw0KGgoAAAANSUhEUgAAAAgAAAAHCAYAAAA1WQxeAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAACXBIWXMAAB2GAAAdhgFdohOBAAAABmJLR0QA/wD/AP+gvaeTAAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDIzLTA3LTEzVDIwOjAxOjQ1KzAwOjAwCWqxhgAAACV0RVh0ZGF0ZTptb2RpZnkAMjAyMy0wNy0xM1QyMDowMTo0NSswMDowMHg3CToAAAC2SURBVBhXY/iPDG7c+///5y8oBwJQFRj4/P9f3QNhn78Appi+fP3LkNfxnIFh43oGBiE+BoYjZxkYHj5iYFi2goHhzVsGpoePfjBMrrzLUNT4jIEh2IaBQZCTgaF1EgODkiIDg4gwA9iKpILL/xnkL/xnkLzyv8UUaIVL2P//Xz5DrGAAgoPzVjDosRxmaG4UZxArjAAa/YGBYfdxkBTEhP37bv9/+eIDWAcYHDsHNOEbkPH/PwCcrZANcnx9SAAAAABJRU5ErkJggg=="

        let mockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/screenshot", method: .get) {
            ResponseWithValue(base64TestImage)
        }
        let data: Data = try await session.screenshot()
        XCTAssert(isPNG(data: data))
    }

    func testSessionFindElement() async throws {
        let mockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(
            path: "session/mySession/element", method: .post, type: Requests.SessionElement.self
        ) {
            XCTAssertEqual($0.using, "name")
            XCTAssertEqual($0.value, "myElement.name")
            return ResponseWithValue(.init(element: "myElement"))
        }
        _ = try await session.findElement(locator: .name("myElement.name"))

        mockWebDriver.expect(
            path: "session/mySession/element/active", method: .post,
            type: Requests.SessionActiveElement.self
        ) {
            ResponseWithValue(.init(element: "myElement"))
        }
        _ = try await session.activeElement!
    }

    func testSessionMoveTo() async throws {
        let mockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(
            path: "session/mySession/moveto", method: .post, type: Requests.SessionMoveTo.self
        ) {
            XCTAssertEqual($0.element, "myElement")
            XCTAssertEqual($0.xOffset, 30)
            XCTAssertEqual($0.yOffset, 0)
            return CodableNone()
        }
        try await session.moveTo(element: element, xOffset: 30, yOffset: 0)
    }

    func testSessionClick() async throws {
        let mockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(
            path: "session/mySession/click", method: .post, type: Requests.SessionButton.self
        ) {
            XCTAssertEqual($0.button, .left)
            return CodableNone()
        }
        try await session.click(button: .left)
    }

    func testSessionButton() async throws {
        let mockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(
            path: "session/mySession/buttondown", method: .post, type: Requests.SessionButton.self
        ) {
            XCTAssertEqual($0.button, .right)
            return CodableNone()
        }
        try await session.buttonDown(button: .right)

        mockWebDriver.expect(
            path: "session/mySession/buttonup", method: .post, type: Requests.SessionButton.self
        ) {
            XCTAssertEqual($0.button, .right)
            return CodableNone()
        }
        try await session.buttonUp(button: .right)
    }

    func testSessionOrientation() async throws {
        let mockWebDriver: MockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/orientation", method: .post)
        try await session.setOrientation(.portrait)

        mockWebDriver.expect(
            path: "session/mySession/orientation", method: .get,
            type: Requests.SessionOrientation.Get.self
        ) {
            ResponseWithValue(.portrait)
        }
        XCTAssertEqual(try await session.orientation, .portrait)

        mockWebDriver.expect(path: "session/mySession/orientation", method: .post)
        try await session.setOrientation(.landscape)

        mockWebDriver.expect(
            path: "session/mySession/orientation", method: .get,
            type: Requests.SessionOrientation.Get.self
        ) {
            ResponseWithValue(.landscape)
        }
        XCTAssertEqual(try await session.orientation, .landscape)
    }

    func testSendKeys() async throws {
        let mockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")

        let keys = Keys.sequence(.a, .b, .c)
        mockWebDriver.expect(
            path: "session/mySession/keys", method: .post, type: Requests.SessionKeys.self
        ) {
            XCTAssertEqual($0.value.first, keys.rawValue)
            return CodableNone()
        }
        try await session.sendKeys(keys, releaseModifiers: false)

        mockWebDriver.expect(
            path: "session/mySession/element/myElement/value", method: .post,
            type: Requests.ElementValue.self
        ) {
            XCTAssertEqual($0.value.first, keys.rawValue)
            return CodableNone()
        }
        try await element.sendKeys(keys)
    }

    func testElementText() async throws {
        let mockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/element/myElement/text", method: .get) {
            ResponseWithValue("myElement.text")
        }
        XCTAssertEqual(try await element.text, "myElement.text")
    }

    func testElementAttribute() async throws {
        let mockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(
            path: "session/mySession/element/myElement/attribute/myAttribute.name", method: .get
        ) {
            ResponseWithValue("myAttribute.value")
        }
        XCTAssertEqual(
            try await element.getAttribute(name: "myAttribute.name"), "myAttribute.value")
    }

    func testElementClick() async throws {
        let mockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/element/myElement/click", method: .post)
        try await element.click()
    }

    func testElementLocationAndSize() async throws {
        let mockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(
            path: "session/mySession/element/myElement/location", method: .get,
            type: Requests.ElementLocation.self
        ) {
            ResponseWithValue(.init(x: 10, y: -20))
        }
        let location = try await element.location
        XCTAssert(location == (x: 10, y: -20))

        mockWebDriver.expect(
            path: "session/mySession/element/myElement/size", method: .get,
            type: Requests.ElementSize.self
        ) {
            ResponseWithValue(.init(width: 100, height: 200))
        }
        let size = try await element.size
        XCTAssert(size == (width: 100, height: 200))
    }

    func testElementEnabled() async throws {
        let mockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/element/myElement/enabled", method: .get) {
            ResponseWithValue(true)
        }
        XCTAssertEqual(try await element.enabled, true)
    }

    func testElementSelected() async throws {
        let mockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/element/myElement/selected", method: .get) {
            ResponseWithValue(true)
        }
        XCTAssertEqual(try await element.selected, true)
    }

    func testWindowPosition() async throws {
        let mockWebDriver: MockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/window/myWindow/position", method: .post)
        try await session.window(handle: "myWindow").setPosition(x: 9, y: 16)

        mockWebDriver.expect(
            path: "session/mySession/window/myWindow/position", method: .get,
            type: Requests.WindowPosition.Get.self
        ) {
            ResponseWithValue(.init(x: 9, y: 16))
        }
        let position = try await session.window(handle: "myWindow").position
        XCTAssert(position == (x: 9, y: 16))
    }

    func testSessionScript() async throws {
        let mockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/execute", method: .post)
        try await session.execute(script: "return document.body", args: ["script"], async: false)
    }

    func testSessionScriptAsync() async throws {
        let mockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/execute/async", method: .post)
        try await session.execute(script: "return document.body", args: ["script"], async: true)
    }

    func testSessionTouchScroll() async throws {
        let mockWebDriver: MockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/touch/scroll", method: .post)
        try await session.touchScroll(element: element, xOffset: 9, yOffset: 16)
    }

    func testWindow() async throws {
        let mockWebDriver: MockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/window", method: .post)
        try await session.focus(window: "myWindow")

        mockWebDriver.expect(path: "session/mySession/window", method: .delete)
        try await session.close(window: "myWindow")
    }

    func testWindowHandleSize() async throws {
        let mockWebDriver: MockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/window/myWindow/size", method: .post)
        try await session.window(handle: "myWindow").setSize(width: 500, height: 500)

        mockWebDriver.expect(
            path: "session/mySession/window/myWindow/size", method: .get,
            type: Requests.WindowSize.Get.self
        ) {
            ResponseWithValue(.init(width: 500, height: 500))
        }
        let size = try await session.window(handle: "myWindow").size
        XCTAssert(size == (width: 500, height: 500))
    }

    func testLocation() async throws {
        let mockWebDriver: MockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let location = Location(latitude: 5, longitude: 20, altitude: 2003)

        mockWebDriver.expect(path: "session/mySession/location", method: .post)
        try await session.setLocation(location)

        mockWebDriver.expect(
            path: "session/mySession/location", method: .get,
            type: Requests.SessionLocation.Get.self
        ) {
            ResponseWithValue(.init(latitude: 5, longitude: 20, altitude: 2003))
        }
        XCTAssertEqual(try await session.location, location)
    }

    func testMaximizeWindow() async throws {
        let mockWebDriver: MockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session: Session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/window/myWindow/maximize", method: .post)
        try await session.window(handle: "myWindow").maximize()
    }

    func testWindowHandle() async throws {
        let mockWebDriver: MockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")

        mockWebDriver.expect(
            path: "session/mySession/window", method: .get, type: Requests.SessionWindowHandle.self
        ) {
            ResponseWithValue(.init("myWindow"))
        }
        XCTAssertEqual(try await session.windowHandle, "myWindow")
    }

    func testWindowHandles() async throws {

        let mockWebDriver: MockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")

        mockWebDriver.expect(
            path: "session/mySession/window/handles", method: .get,
            type: Requests.SessionWindowHandles.self
        ) {
            ResponseWithValue(.init(["myWindow", "myWindow"]))
        }
        XCTAssertEqual(try await session.windowHandles, ["myWindow", "myWindow"])
    }

    func testElementDoubleClick() async throws {
        let mockWebDriver: MockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/touch/doubleclick", method: .post)
        try await element.doubleClick()
    }

    func testElementFlick() async throws {
        let mockWebDriver: MockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/touch/flick", method: .post)
        try await element.flick(xOffset: 5, yOffset: 20, speed: 2003)
    }

    func testSessionFlick() async throws {
        let mockWebDriver: MockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/touch/flick", method: .post)
        try await session.flick(xSpeed: 5, ySpeed: 20)
    }

    func testSessionSource() async throws {
        let mockWebDriver: MockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(
            path: "session/mySession/source", method: .get, type: Requests.SessionSource.self
        ) {
            ResponseWithValue("currentSource")
        }
        XCTAssertEqual(try await session.source, "currentSource")
    }

    func testSessionTimeouts() async throws {
        let mockWebDriver: MockWebDriver = MockWebDriver(wireProtocol: .legacySelenium)
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/timeouts", method: .post)
        try await session.setTimeout(implicit: 5)
        XCTAssert(session.implicitWaitTimeout == 5.0)
    }
}
