import Foundation
@testable import WebDriver
import XCTest

class Notepad {
    let session: Session
    let editor: Element

    init(winAppDriver: WinAppDriver, arguments: [String] = [], workingDir: String? = nil) throws {
        let capabilities = WinAppDriver.Capabilities.startApp(
            name: "\(WindowsSystemPaths.system32)\\notepad.exe",
            arguments: arguments,
            workingDir: workingDir)
        session = try Session(webDriver: winAppDriver, desiredCapabilities: capabilities, requiredCapabilities: capabilities)

        // In Notepad Win11, findElement for name "Text Editor" or class "Edit" does not work
        // Instead, grab the editor here as the active element
        editor = try XCTUnwrap(
            session.findElement(byName: "Text Editor")
                ?? session.findElement(byClassName: "Edit")
                ?? session.activeElement)
    }

    func dismissNewFileDialog() throws {
        let dismissButton = try XCTUnwrap(session.findElement(byName: "No"), "Dismiss New File dialog: Button \"no\" was not found")
        try dismissButton.click()
    }

    func moveToCenterOf(byName name: String) throws {
        let element = try XCTUnwrap(session.findElement(byName: name), "Can't find element named '\(name)'")
        let size = try element.size
        XCTAssert(size.width > 0)
        XCTAssert(size.height > 0)

        try session.moveTo(element: element, xOffset: size.width / 2, yOffset: size.height / 2)
    }

    func click(button: MouseButton = .left) throws {
        try session.click(button: button)
    }

    func close() throws {
        let closeButton = try XCTUnwrap(session.findElement(byName: "Close"), "Failed to find element named 'Close'")
        try closeButton.click()
    }
}

class NotepadTests: XCTestCase {
    static var winAppDriver: WinAppDriver!
    static var setupError: Error?

    override public class func setUp() {
        do {
            winAppDriver = try WinAppDriver.start()
        } catch {
            setupError = error
        }
    }

    override public func setUpWithError() throws {
        if let setupError = Self.setupError {
            throw setupError
        }
    }

    override public class func tearDown() {
        winAppDriver = nil
    }

    // Open notepad passing a new file name and a working directory as arguments and verify that notepad
    // is attempting to create a file by hitting the dismiss button in the confirmation dialog
    // TODO: implement a way to check that notepad has the correct name and working directory
    // TODO: implement a way to confirm that the dialog was dismissed and notepad exited,
    // e.g., by attempting to get the window handle from the session
    public func testDismissNewFileDialog() throws {
        let notepad = try Notepad(winAppDriver: Self.winAppDriver, arguments: [UUID().uuidString], workingDir: NSTemporaryDirectory())
        try notepad.dismissNewFileDialog()
    }

    public func testOpenFileMenuWithMouse() throws {
        let notepad = try Notepad(winAppDriver: Self.winAppDriver)

        // Check that "New Tab" menu item is not present yet
        XCTAssertNil(try notepad.session.findElement(byName: "New Tab", retryTimeout: 0.0))

        // Move the mouse to center of "File" menu and click to open menu
        try notepad.moveToCenterOf(byName: "File")
        try notepad.click()

        // Check that "New tab" (win11 Notepad) or just "New" (win10 Notepad) is now present
        guard let _ = try notepad.session.findElement(byName: "New tab") else {
            guard let _ = try notepad.session.findElement(byName: "New") else {
                // TODO: this does not pass in Win10 Notepad - Re-enable when moving to Win11 CI runners
                // XCTFail("Neither 'New' or 'New tab' element were found")
                return
            }
            return
        }
    }

    public func testTypingTwoLines() throws {
        let notepad = try Notepad(winAppDriver: Self.winAppDriver)
        try notepad.editor.sendKeys(
            KeyCode.typeTextUsingWindowsAltCodes("Hello")
            + [KeyCode.enter]
            + KeyCode.typeTextUsingWindowsAltCodes("World"))
        try notepad.editor.sendKeys(KeyCode.control(KeyCode.a) + [KeyCode.delete])
        try notepad.close()
    }
}
