import Foundation
import Testing
import TestsCommon
@testable import WebDriver

/// Tests how usage of high-level Session/Element APIs map to lower-level requests
struct APIToRequestMappingTests {
    private typealias ResponseWithValue = Requests.ResponseWithValue

    @Test func testCreateSession() throws {
        let mockWebDriver = MockWebDriver()
        mockWebDriver.expect(path: "session", method: .post, type: Requests.Session.self) {
            let capabilities = Capabilities()
            capabilities.platformName = "myPlatform"
            return Requests.Session.Response(sessionId: "mySession", value: capabilities)
        }
        let session = try Session(webDriver: mockWebDriver, desiredCapabilities: Capabilities())
        #expect(session.id == "mySession")
        #expect(session.capabilities.platformName == "myPlatform")

        // Account for session deinitializer
        mockWebDriver.expect(path: "session/mySession", method: .delete)
    }

    @Test func testSessionTitle() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/title", method: .get) {
            ResponseWithValue("mySession.title")
        }
        #expect(try session.title == "mySession.title")
    }

    @Test func testSessionScreenshot() throws {
        let base64TestImage: String =
            "iVBORw0KGgoAAAANSUhEUgAAAAgAAAAHCAYAAAA1WQxeAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAACXBIWXMAAB2GAAAdhgFdohOBAAAABmJLR0QA/wD/AP+gvaeTAAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDIzLTA3LTEzVDIwOjAxOjQ1KzAwOjAwCWqxhgAAACV0RVh0ZGF0ZTptb2RpZnkAMjAyMy0wNy0xM1QyMDowMTo0NSswMDowMHg3CToAAAC2SURBVBhXY/iPDG7c+///5y8oBwJQFRj4/P9f3QNhn78Appi+fP3LkNfxnIFh43oGBiE+BoYjZxkYHj5iYFi2goHhzVsGpoePfjBMrrzLUNT4jIEh2IaBQZCTgaF1EgODkiIDg4gwA9iKpILL/xnkL/xnkLzyv8UUaIVL2P//Xz5DrGAAgoPzVjDosRxmaG4UZxArjAAa/YGBYfdxkBTEhP37bv9/+eIDWAcYHDsHNOEbkPH/PwCcrZANcnx9SAAAAABJRU5ErkJggg=="

        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/screenshot", method: .get) {
            ResponseWithValue(base64TestImage)
        }
        let data: Data = try session.screenshot()
        #expect(isPNG(data: data))
    }

    @Test func testSessionFindElement() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/element", method: .post, type: Requests.SessionElement.self) {
            #expect($0.using == "name")
            #expect($0.value == "myElement.name")
            return ResponseWithValue(.init(element: "myElement"))
        }
        #expect(try session.findElement(byName: "myElement.name") != nil)

        mockWebDriver.expect(path: "session/mySession/element/active", method: .post, type: Requests.SessionActiveElement.self) {
            ResponseWithValue(.init(element: "myElement"))
        }
        _ = try session.activeElement!
    }

    @Test func testSessionMoveTo() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/moveto", method: .post, type: Requests.SessionMoveTo.self) {
            #expect($0.element == "myElement")
            #expect($0.xOffset == 30)
            #expect($0.yOffset == 0)
            return CodableNone()
        }
        try session.moveTo(element: element, xOffset: 30, yOffset: 0)
    }

    @Test func testSessionClick() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/click", method: .post, type: Requests.SessionButton.self) {
            #expect($0.button == .left)
            return CodableNone()
        }
        try session.click(button: .left)
    }

    @Test func testSessionButton() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/buttondown", method: .post, type: Requests.SessionButton.self) {
            #expect($0.button == .right)
            return CodableNone()
        }
        try session.buttonDown(button: .right)

        mockWebDriver.expect(path: "session/mySession/buttonup", method: .post, type: Requests.SessionButton.self) {
            #expect($0.button == .right)
            return CodableNone()
        }
        try session.buttonUp(button: .right)
    }

    @Test func testSessionOrientation() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/orientation", method: .post)
        try session.setOrientation(.portrait)

        mockWebDriver.expect(path: "session/mySession/orientation", method: .get, type: Requests.SessionOrientation.Get.self) {
            ResponseWithValue(.portrait)
        }
        #expect(try session.orientation == .portrait)

        mockWebDriver.expect(path: "session/mySession/orientation", method: .post)
        try session.setOrientation(.landscape)

        mockWebDriver.expect(path: "session/mySession/orientation", method: .get, type: Requests.SessionOrientation.Get.self) {
            ResponseWithValue(.landscape)
        }
        #expect(try session.orientation == .landscape)
    }

    @Test func testSendKeys() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")

        let keys = [ Keys.a, Keys.b, Keys.c ]
        mockWebDriver.expect(path: "session/mySession/keys", method: .post, type: Requests.SessionKeys.self) {
            #expect($0.value == keys.map { $0.rawValue })
            return CodableNone()
        }
        try session.sendKeys(keys, releaseModifiers: false)

        mockWebDriver.expect(path: "session/mySession/element/myElement/value", method: .post, type: Requests.ElementValue.self) {
            #expect($0.value == keys.map { $0.rawValue })
            return CodableNone()
        }
        try element.sendKeys(keys)
    }

    @Test func testElementText() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/element/myElement/text", method: .get) {
            ResponseWithValue("myElement.text")
        }
        #expect(try element.text == "myElement.text")
    }

    @Test func testElementAttribute() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/element/myElement/attribute/myAttribute.name", method: .get) {
            ResponseWithValue("myAttribute.value")
        }
        #expect(try element.getAttribute(name: "myAttribute.name") == "myAttribute.value")
    }

    @Test func testElementClick() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/element/myElement/click", method: .post)
        try element.click()
    }

    @Test func testElementLocationAndSize() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/element/myElement/location", method: .get, type: Requests.ElementLocation.self) {
            ResponseWithValue(.init(x: 10, y: -20))
        }
        #expect(try element.location == (x: 10, y: -20))

        mockWebDriver.expect(path: "session/mySession/element/myElement/size", method: .get, type: Requests.ElementSize.self) {
            ResponseWithValue(.init(width: 100, height: 200))
        }
        #expect(try element.size == (width: 100, height: 200))
    }

    @Test func testElementEnabled() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/element/myElement/enabled", method: .get) {
            ResponseWithValue(true)
        }
        #expect(try element.enabled == true)
    }

    @Test func testWindowPosition() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/window/myWindow/position", method: .post)
        try session.window(handle: "myWindow").setPosition(x: 9, y: 16)

        mockWebDriver.expect(path: "session/mySession/window/myWindow/position", method: .get, type: Requests.WindowPosition.Get.self) {
            ResponseWithValue(.init(x: 9, y: 16))
        }
        #expect(try session.window(handle: "myWindow").position == (x: 9, y: 16))
    }

    @Test func testSessionScript() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/execute", method: .post)
        try session.execute(script: "return document.body", args: ["script"], async: false)
    }

    @Test func testSessionScriptAsync() throws {
        let mockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/execute_async", method: .post)
        try session.execute(script: "return document.body", args: ["script"], async: true)
    }

    @Test func testSessionTouchScroll() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/touch/scroll", method: .post)
        try session.touchScroll(element: element, xOffset: 9, yOffset: 16)
    }

    @Test func testWindow() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/window", method: .post)
        try session.focus(window: "myWindow")

        mockWebDriver.expect(path: "session/mySession/window", method: .delete)
        try session.close(window: "myWindow")
    }

    @Test func testWindowHandleSize() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/window/myWindow/size", method: .post)
        try session.window(handle: "myWindow").setSize(width: 500, height: 500)

        mockWebDriver.expect(path: "session/mySession/window/myWindow/size", method: .get, type: Requests.WindowSize.Get.self) {
            ResponseWithValue(.init(width: 500, height: 500))
        }
        #expect(try session.window(handle: "myWindow").size == (width: 500, height: 500))
    }

    @Test func testLocation() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let location = Location(latitude: 5, longitude: 20, altitude: 2003)

        mockWebDriver.expect(path: "session/mySession/location", method: .post)
        try session.setLocation(location)

        mockWebDriver.expect(path: "session/mySession/location", method: .get, type: Requests.SessionLocation.Get.self) {
            ResponseWithValue(.init(latitude: 5, longitude: 20, altitude: 2003))
        }
        #expect(try session.location == location)
    }

    @Test func testMaximizeWindow() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session: Session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/window/myWindow/maximize", method: .post)
        try session.window(handle: "myWindow").maximize()
    }

    @Test func testWindowHandle() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")

        mockWebDriver.expect(path: "session/mySession/window_handle", method: .get, type: Requests.SessionWindowHandle.self) {
            ResponseWithValue(.init("myWindow"))
        }
        #expect(try session.windowHandle == "myWindow")
    }

    @Test func testWindowHandles() throws {

        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")

        mockWebDriver.expect(path: "session/mySession/window_handles", method: .get, type: Requests.SessionWindowHandles.self) {
            ResponseWithValue(.init(["myWindow", "myWindow"]))
        }
        #expect(try session.windowHandles == ["myWindow", "myWindow"])
    }

    @Test func testElementDoubleClick() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/touch/doubleclick", method: .post)
        try element.doubleClick()
    }

    @Test func testElementFlick() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        let element = Element(session: session, id: "myElement")
        mockWebDriver.expect(path: "session/mySession/touch/flick", method: .post)
        try element.flick(xOffset: 5, yOffset: 20, speed: 2003)
    }

    @Test func testSessionFlick() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/touch/flick", method: .post)
        try session.flick(xSpeed: 5, ySpeed: 20)
    }

    @Test func testSessionSource() throws {
        let mockWebDriver: MockWebDriver = MockWebDriver()
        let session = Session(webDriver: mockWebDriver, existingId: "mySession")
        mockWebDriver.expect(path: "session/mySession/source", method: .get, type: Requests.SessionSource.self) {
            ResponseWithValue("currentSource")
        }
        #expect(try session.source == "currentSource")
    }
}
