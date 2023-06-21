import XCTest
@testable import WebDriver
import Foundation

class Notepad {
    let session: Session
    var editor: Element?

    init(winAppDriver: WinAppDriver, appArguments: [String] = [], appWorkingDir: String? = nil) {
        let windowsDir = ProcessInfo.processInfo.environment["SystemRoot"]!
        session = winAppDriver.newSession(app: "\(windowsDir)\\System32\\notepad.exe", 
            appArguments: appArguments, appWorkingDir: appWorkingDir)

        // In Notepad Win11, findElement for name "Text Editor" or class "Edit" does not work
        // Instead, grab the editor here as the active element
        editor = session.activeElement
    }

    func dismissNewFileDialog() {
        let dismissButton = session.findElement(byName: "No")
        XCTAssertNotNil(dismissButton, "Dismiss New File dialog: Button \"no\" was not found")
        dismissButton?.click()
    }

    func moveToCenterOf(byName name: String) {
        let element = session.findElement(byName: name)
        XCTAssertNotNil(element)

        let size = element!.size
        XCTAssert(size.width > 0)
        XCTAssert(size.height > 0)

        session.moveTo(element: element, xOffset: size.width/2, yOffset: size.height/2)
    }

    func click(button: MouseButton = .left) {
        session.click(button: button)
    }

    func typeInEditor(keys: [String]) {
        if editor == nil {
            editor = session.findElement(byName: "Text Editor")
            if editor == nil {
                editor = session.findElement(byClassName: "Edit")
            }
        }
        XCTAssertNotNil(editor)
        editor!.sendKeys(value: keys)
    }

    func close() {
        session.findElement(byName: "close")?.click()
    }
}

class NotepadTests : XCTestCase {

    // Use a single WinAppDriver process to avoid incurring the process start/end cost for every test    
    static var winAppDriver: WinAppDriver!

    // Called once before all the tests in this class
    public override class func setUp() {
        winAppDriver = try! WinAppDriver()
    }

    // Called once after all tests in this class have run
    public override class func tearDown() {
        winAppDriver = nil
    }

    // Open notepad passing a new file name and a working directory as arguments and verify that notepad
    // is attempting to create a file by hitting the dismiss button in the confirmation dialog 
    // TODO: implement a way to check that notepad has the correct name and working directory
    // TODO: implement a way to confirm that the dialog was dismissed and notepad exited, 
    // e.g., by attempting to get the window handle from the session
    public func testDismissNewFileDialog() {
        let notepad = Notepad(winAppDriver: Self.winAppDriver, appArguments: [UUID().uuidString], appWorkingDir: NSTemporaryDirectory())
        Thread.sleep(forTimeInterval: 1)  // Needed until WIN-496
        notepad.dismissNewFileDialog()
    }

    public func testOpenFileMenuWithMouse() {
        let notepad = Notepad(winAppDriver: Self.winAppDriver)

        // Check that "New Tab" menu item is not present yet
        XCTAssertNil(notepad.session.findElement(byName: "New Tab")) 

        // Move the mouse to center of "File" menu and click to open menu
        notepad.moveToCenterOf(byName: "File")
        notepad.click()

        // Check that "New Tab" is now present
        XCTAssertNotNil(notepad.session.findElement(byName: "New tab")) 
    }

    public func testTypingTwoLines() {
        let notepad = Notepad(winAppDriver: Self.winAppDriver)
        notepad.typeInEditor(keys: ["T", "y", "p", "ing", "...", KeyCode.enter.rawValue, "Another line"])
        XCTAssertNotNil(notepad.session.findElement(byName: "Typing..."))        
        notepad.typeInEditor(keys: [KeyCode.control.rawValue, "a", KeyCode.control.rawValue, KeyCode.delete.rawValue])
        notepad.close()
    }
}
