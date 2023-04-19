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
            throw try JSONDecoder().decode(WebDriverError.self, from: responseData)
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

    // WinAppDriver REST protocol request wrappers

    // newSession(app: ) - Creates a new WinAppDriver session
    //   app - location of the app to test
    public func newSession(app: String) -> Session {
        let NewSessionRequest = NewSessionRequest(app: app)
        return Session(in: self, id: try! send(NewSessionRequest).sessionId!)
    }

    struct NewSessionRequest : WebDriverRequest {
        typealias ResponseValue = WebDriverNoResponseValue

        init(app: String) {
            body.desiredCapabilities = .init(app: app)
        }

        var pathComponents: [String] { ["session"] }
        var method: HTTPMethod { .post }
        var body: Body = .init()

        struct RequiredCapabilities : Encodable {
        }

        struct DesiredCapabilities : Encodable {
            var app: String?
        }

        struct Body : Encodable {
            var requiredCapabilities: RequiredCapabilities?
            var desiredCapabilities: DesiredCapabilities = .init()
        }
    }
}