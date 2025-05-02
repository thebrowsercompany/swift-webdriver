import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Thrown if we fail to detect the protocol a webdriver server uses.
public struct ProtocolDetectionError: Error {}

/// A connection to a WebDriver server over HTTP.
public struct HTTPWebDriver: WebDriver {
    private let serverURL: URL
    public let wireProtocol: WireProtocol

    public static let defaultRequestTimeout: TimeInterval = 5 // seconds

    public init(endpoint: URL, wireProtocol: WireProtocol) {
        serverURL = endpoint
        self.wireProtocol = wireProtocol
    }

    public static func createWithDetectedProtocol(serverURL: URL) throws -> HTTPWebDriver {
        .init(endpoint: serverURL, wireProtocol: try detectProtocol(serverURL: serverURL))
    }

    public static func detectProtocol(serverURL: URL) throws -> WireProtocol {
        // The status request is the same for the Selenium Legacy JSON protocol and W3C,
        // but the response format is different.
        let urlRequest = try Self.buildURLRequest(serverURL: serverURL, Requests.LegacySelenium.Status())

        // Send the request and decode result or error
        let (status, responseData) = try urlRequest.send()
        guard status == 200 else {
            throw try JSONDecoder().decode(ErrorResponse.self, from: responseData)
        }

        if let _ = try? JSONDecoder().decode(Requests.LegacySelenium.Status.Response.self, from: responseData) {
            return .legacySelenium
        } else if let _ = try? JSONDecoder().decode(Requests.W3C.Status.Response.self, from: responseData) {
            return .w3c
        } else {
            throw ProtocolDetectionError()
        }
    }

    @discardableResult
    public func send<Req: Request>(_ request: Req) throws -> Req.Response {
        let urlRequest = try Self.buildURLRequest(serverURL: self.serverURL, request)

        // Send the request and decode result or error
        let (status, responseData) = try urlRequest.send()
        guard status == 200 else {
            throw try JSONDecoder().decode(ErrorResponse.self, from: responseData)
        }

        return try JSONDecoder().decode(Req.Response.self, from: responseData)
    }

    private static func buildURLRequest<Req: Request>(serverURL: URL, _ request: Req) throws -> URLRequest {
        var url = serverURL
        for (index, pathComponent) in request.pathComponents.enumerated() {
            let last = index == request.pathComponents.count - 1
            url.appendPathComponent(pathComponent, isDirectory: !last)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        // TODO(#40): Setting timeoutInterval causes a crash when sending the request on the CI machines.
        // urlRequest.timeoutInterval = Self.defaultRequestTimeout

        // Add the body if the Request type defines one
        if Req.Body.self != CodableNone.self {
            urlRequest.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "content-type")
            urlRequest.httpBody = try JSONEncoder().encode(request.body)
        }

        return urlRequest
    }
}
