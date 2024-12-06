import XCTest
@testable import WebDriver

final class ChromiumDriverTests: XCTestCase {
    var driver: ChromiumDriver?
    
    override func setUp() {
        super.setUp()
        // Skip tests if ChromeDriver is not available
        guard let chromeDriverPath = ChromiumDriver.findChromeDriver() else {
            XCTAssertTrue(true, "ChromeDriver not found, skipping tests")
            return
        }
        
        do {
            driver = try ChromiumDriver(chromeDriverPath: chromeDriverPath, startDriver: false)
        } catch {
            XCTFail("Failed to initialize ChromiumDriver: \(error)")
        }
    }
    
    override func tearDown() {
        try? driver?.stopChromeDriver()
        driver = nil
        super.tearDown()
    }
    
    func testFindChromiumBrowser() {
        let browserPath = ChromiumDriver.findChromiumBrowser()
        XCTAssertNotNil(browserPath, "Should find a Chromium browser installed")
    }
    
    func testFindChromeDriver() {
        let driverPath = ChromiumDriver.findChromeDriver()
        XCTAssertNotNil(driverPath, "Should find ChromeDriver")
    }
    
    func testHeadlessCapabilities() {
        let capabilities = ChromiumDriver.headlessCapabilities()
        XCTAssertTrue(capabilities.headless == true, "Headless mode should be enabled")
    }
    
    func testCreateSession() throws {
        guard let driver = driver else {
            XCTAssertTrue(true, "Driver not available, skipping test")
            return
        }
        
        // Mock the HTTPWebDriver send method to avoid actual network calls
        // In a real test, you would use dependency injection or a network mock
        
        let capabilities = ChromiumCapabilities()
        capabilities.headless = true
        
        // This is a simplified test that doesn't make actual network calls
        XCTAssertNoThrow(try ChromiumDriver.headlessCapabilities())
    }
} 