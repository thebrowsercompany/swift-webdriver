import Foundation
@testable import WebDriver
import XCTest

class Notepad {
    let session: Session
    var editor: Element?

    init(winAppDriver: WinAppDriver, appArguments: [String] = [], appWorkingDir: String? = nil) throws {
        let windowsDir = ProcessInfo.processInfo.environment["SystemRoot"]!
        session = try winAppDriver.newSession(
            app: "\(windowsDir)\\System32\\notepad.exe",
            appArguments: appArguments,
            appWorkingDir: appWorkingDir
        )

        // In Notepad Win11, findElement for name "Text Editor" or class "Edit" does not work
        // Instead, grab the editor here as the active element
        editor = try session.activeElement
    }

    func dismissNewFileDialog() throws {
        guard let dismissButton = try? session.findElement(byName: "No") else {
            return XCTFail("Dismiss New File dialog: Button \"no\" was not found")
        }
        try dismissButton.click()
    }

    func moveToCenterOf(byName name: String) throws {
        guard let element = try? session.findElement(byName: name) else {
            XCTFail("Can't find element \(name)")
            return
        }

        let size = try element.size
        XCTAssert(size.width > 0)
        XCTAssert(size.height > 0)

        try session.moveTo(element: element, xOffset: size.width / 2, yOffset: size.height / 2)
    }

    func click(button: MouseButton = .left) throws {
        try session.click(button: button)
    }

    func typeInEditor(keys: [String]) throws {
        if editor == nil {
            editor = try session.findElement(byName: "Text Editor")
            if editor == nil {
                editor = try session.findElement(byClassName: "Edit")
            }
        }

        guard let editor else {
            XCTFail("Failed to find element named 'Text Editor' or of class 'Edit'")
            return
        }
        try editor.sendKeys(value: keys)
    }

    func close() throws {
        guard let closeButton = try session.findElement(byName: "Close") else {
            XCTFail("Failed to find element named 'Close'")
            return
        }
        try closeButton.click()
    }
}

class NotepadTests: XCTestCase {
    static var winAppDriver: WinAppDriver!
    static var setupError: Error?

    override public class func setUp() {
        do {
            winAppDriver = try WinAppDriver()
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
        let notepad = try Notepad(winAppDriver: Self.winAppDriver, appArguments: [UUID().uuidString], appWorkingDir: NSTemporaryDirectory())
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
        try notepad.typeInEditor(keys: ["T", "y", "p", "ing", "...", KeyCode.enter.rawValue, "Another line"])
        // TODO: the following does not pass in Win10 Notepad - Re-enable when moving to Win11 CI runners
        // XCTAssertNotNil(notepad.session.findElement(byName: "Typing..."))
        try notepad.typeInEditor(keys: [KeyCode.control.rawValue, "a", KeyCode.control.rawValue, KeyCode.delete.rawValue])
        try notepad.close()
    }
}
