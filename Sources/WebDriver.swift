import Foundation
import FoundationNetworking

struct WebDriver {
    let rootURL : URL

    init(url: URL) {
        self.rootURL = url
    }

    // Send a WebDriverRequest to the web driver local service 
    // TODO: consider making this function async/awaitable
    func send<Request>(_ request: Request) throws -> Request.Response where Request : WebDriverRequest {
        var error: Error?
        var response: Request.Response?

        // Create urlRequest with proper Url and method
        let url = WebDriver.self.buildURL(base: rootURL, pathComponents: request.pathComponents, query: request.query)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        // Add the body if the WebDriverRequest type defines one
        if Request.self.Body != CodableNone.self {
            urlRequest.addValue("content-encoding", forHTTPHeaderField: "json")
            urlRequest.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "content-type")
            urlRequest.httpBody = try JSONEncoder().encode(request.body)
        }

        // Send the request and decode result or error
        let (status, responseData, networkError) = try urlRequest.send()
        if let responseData: Data = responseData {
            if (status == 200) {
                response  = try JSONDecoder().decode(Request.Response.self, from: responseData)
            }
            else {
                error = try JSONDecoder().decode(WebDriverError.self, from: responseData)
            }
        }
        else if let networkError = networkError {
            error = networkError
        }
        else {
            fatalError("Everything is wrong!")
        }

        if let error = error { throw error }
        return response!
    }

    // Utility function to build a URL from its parts
    // Inpired by GPT4
    private static func buildURL(base: URL, pathComponents: [String], query: [String: String] = [:]) -> URL {
        var url = base

        // Append the path components
        for pathComponent in pathComponents {
            url.appendPathComponent(pathComponent)
        }

        // Get the URL components
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        
        // Convert dictionary to query items
        let queryItems = query.map { key, value in
            URLQueryItem(name: key, value: value)
        }

        // Append query items to URL components
        urlComponents.queryItems = queryItems

        // Get the final URL
        guard let url = urlComponents.url else {
            fatalError("Failed to construct URL")
        }

        return url
    }
}