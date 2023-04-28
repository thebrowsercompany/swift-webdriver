import Foundation
import FoundationNetworking

public struct WebDriver {
    let rootURL : URL

    init(url: URL) {
        self.rootURL = url
    }

    // Send a WebDriverRequest to the web driver local service 
    // TODO: consider making this function async/awaitable
    @discardableResult
    func send<Request>(_ request: Request) throws -> Request.Response where Request : WebDriverRequest {
        // Create urlRequest with proper Url and method
        let url = Self.buildURL(base: rootURL, pathComponents: request.pathComponents, query: request.query)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        // Add the body if the WebDriverRequest type defines one
        if Request.Body.self != CodableNone.self {
            urlRequest.addValue("content-encoding", forHTTPHeaderField: "json")
            urlRequest.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "content-type")
            urlRequest.httpBody = try! JSONEncoder().encode(request.body)
        }

        // Send the request and decode result or error
        let (status, responseData) = try urlRequest.send()
        guard status == 200 else {
            var error = try JSONDecoder().decode(WebDriverError.self, from: responseData)
            error.status = status
            throw error
        }
        let res = try JSONDecoder().decode(Request.Response.self, from: responseData)
        return res
    }

    // Utility function to build a URL from its parts
    // Inpired by GPT4
    private static func buildURL(base: URL, pathComponents: [String], query: [String: String] = [:]) -> URL {
        var url = base

        // Append the path components
        for pathComponent in pathComponents {
            url.appendPathComponent(pathComponent)
        }

        if !query.isEmpty {
            // Get the URL components
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            
            // Convert dictionary to query items
            let queryItems = query.map { key, value in
                URLQueryItem(name: key, value: value)
            }

            // Append query items to URL components
            urlComponents.queryItems = queryItems

            // Get the final URL
            url = urlComponents.url!
        }

        return url
    }
}