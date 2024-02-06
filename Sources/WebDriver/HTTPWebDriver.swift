import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct HTTPWebDriver: WebDriver {
    let rootURL: URL

    public static let defaultTimeout: TimeInterval = 5 // seconds

    public init(endpoint: URL) {
        rootURL = endpoint
    }

    // Send a Request to the web driver local service
    // TODO: consider making this function async/awaitable
    @discardableResult
    public func send<Req: Request>(_ request: Req) throws -> Req.Response {
        let urlRequest = try buildURLRequest(request)

        // Send the request and decode result or error
        let (status, responseData) = try urlRequest.send()
        guard status == 200 else {
            throw try JSONDecoder().decode(ErrorResponse.self, from: responseData)
        }
        return try JSONDecoder().decode(Req.Response.self, from: responseData)
    }

    private func buildURLRequest<Req: Request>(_ request: Req) throws -> URLRequest {
        var url = rootURL
        for (index, pathComponent) in request.pathComponents.enumerated() {
            let last = index == request.pathComponents.count - 1
            url.appendPathComponent(pathComponent, isDirectory: !last)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        // TODO(#40): Setting timeoutInterval causes a crash when sending the request on the CI machines.
        // urlRequest.timeoutInterval = Self.defaultTimeout

        // Add the body if the Request type defines one
        if Req.Body.self != CodableNone.self {
            urlRequest.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "content-type")
            urlRequest.httpBody = try JSONEncoder().encode(request.body)
        }

        return urlRequest
    }
}
