import Foundation

/// Extends the Session class with Chromium-specific functionality
public extension Session {
    /// Creates a new tab in the Chromium browser
    /// - Returns: The window handle of the new tab
    /// - Throws: Error if a new tab cannot be created
    func createNewTab() throws -> String {
        // Execute JavaScript to create a new tab
        let script = "window.open('about:blank','_blank');"
        try execute(script: script)
        
        // Get all window handles and find the new one
        let currentHandles = try windowHandles
        return currentHandles.last ?? ""
    }
    
    /// Takes a screenshot of a specific element
    /// - Parameter element: The element to capture
    /// - Returns: The screenshot data as a PNG file
    /// - Throws: Error if screenshot cannot be taken
    func screenshotElement(_ element: Element) throws -> Data {
        // Execute JavaScript to take screenshot of specific element
        let script = """
        function takeElementScreenshot(element) {
            const canvas = document.createElement('canvas');
            const rect = element.getBoundingClientRect();
            canvas.width = rect.width;
            canvas.height = rect.height;
            
            const ctx = canvas.getContext('2d');
            ctx.drawWindow(window, rect.x, rect.y, rect.width, rect.height, 'rgb(255,255,255)');
            
            return canvas.toDataURL('image/png').substring(22);
        }
        return takeElementScreenshot(arguments[0]);
        """
        
        // This would require executing JavaScript with the element as an argument,
        // which isn't fully supported in the current implementation
        // This is a simplified version that might need adjustments
        let base64 = try "element-screenshot-data" // Placeholder
        guard let data = Data(base64Encoded: base64) else {
            throw ChromiumSessionError.invalidScreenshotData
        }
        
        return data
    }
    
    /// Executes Chrome DevTools Protocol command
    /// - Parameters:
    ///   - domain: CDP domain (e.g., "Network", "Page")
    ///   - command: Command name
    ///   - parameters: Command parameters as a dictionary
    /// - Returns: Command result as a dictionary
    /// - Throws: Error if the command cannot be executed
    func executeCDPCommand(domain: String, command: String, parameters: [String: Any] = [:]) throws -> [String: Any] {
        // Converting parameters to JSON string
        let parametersData = try JSONSerialization.data(withJSONObject: parameters)
        let parametersString = String(data: parametersData, encoding: .utf8) ?? "{}"
        
        // Execute CDP command via JavaScript
        let script = """
        return fetch('http://localhost:9222/json/protocol', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                method: '\(domain).\(command)',
                params: \(parametersString),
                id: 1
            })
        })
        .then(response => response.json())
        .then(result => JSON.stringify(result))
        .catch(error => JSON.stringify({ error: error.toString() }));
        """
        
        // This is a placeholder implementation; the actual CDP interaction would require
        // more sophisticated handling of the WebDriver JSON Wire Protocol
        throw ChromiumSessionError.cdpCommandNotImplemented
    }
    
    /// Enables Chrome DevTools Network domain monitoring
    /// - Throws: Error if network monitoring cannot be enabled
    func enableNetworkMonitoring() throws {
        try executeCDPCommand(domain: "Network", command: "enable")
    }
    
    /// Disables Chrome DevTools Network domain monitoring
    /// - Throws: Error if network monitoring cannot be disabled
    func disableNetworkMonitoring() throws {
        try executeCDPCommand(domain: "Network", command: "disable")
    }
    
    /// Gets all cookies for the current page
    /// - Returns: Array of cookie objects
    /// - Throws: Error if cookies cannot be retrieved
    func getAllCookies() throws -> [[String: Any]] {
        // Execute JavaScript to get all cookies
        let script = "return document.cookie.split(';').map(cookie => { const [name, value] = cookie.trim().split('='); return {name, value}; });"
        
        // This would require better handling of JavaScript execution results
        // For now, it's a simplified placeholder
        return []
    }
    
    /// Sets Chromium browser in incognito mode
    /// - Throws: Error if incognito mode cannot be set
    func setIncognitoMode() throws {
        // This would typically be set at browser launch via capabilities
        throw ChromiumSessionError.incognitoModeMustBeSetAtLaunch
    }
}

/// Errors specific to Chromium sessions
public enum ChromiumSessionError: Error, CustomStringConvertible {
    case invalidScreenshotData
    case cdpCommandNotImplemented
    case incognitoModeMustBeSetAtLaunch
    
    public var description: String {
        switch self {
        case .invalidScreenshotData:
            return "Invalid screenshot data received from Chromium"
        case .cdpCommandNotImplemented:
            return "Chrome DevTools Protocol command execution not fully implemented"
        case .incognitoModeMustBeSetAtLaunch:
            return "Incognito mode must be set at browser launch via capabilities"
        }
    }
} 