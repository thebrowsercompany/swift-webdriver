// This file is for debugging purposes only. It allows to experiement with testing Arc 
// before moving this functionality to the Arc repo. It will eventually be removed. 

import XCTest
@testable import WebDriver

class Arc {
    let session: Session
    init(webDriver: WebDriver, app: String, appArguments: [String]?, appWorkingDir: String? = nil) {
        session = webDriver.newAttachedSession(app: app, appArguments: appArguments, appWorkingDir: appWorkingDir)
    }

    func createNewTab() {
        session.findElement(byName: "New Tab")?.click()
    }

    func close() {
        print("Closing Arc")
        session.findElement(byName: "Close")?.click()
    }
}

class ArcTests : XCTestCase {
    // Use a single WinAppDriver process to avoid incurring the process start/end cost for every test    
    static var winAppDriver: WinAppDriverProcess!

    // Called once before all the tests in this class
    public override class func setUp() {
        winAppDriver = try! WinAppDriverProcess()
    }

    // Called once after all tests in this class have run
    public override class func tearDown() {
        winAppDriver = nil
    }

    func testStartAndClose() {
        let arc = Arc(
            webDriver: WebDriver(endpoint: Self.winAppDriver.endpoint),
            app: "c:\\BCNY\\arc\\Apps\\BrowserWin\\build\\bin\\Arc.exe",
            appArguments: ["--no-sandbox", "--user-data-dir=c:\\temp\\Chromium"])
        arc.close()
    }
}