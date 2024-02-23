import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLSession {
    func dataTask(
        with request: URLRequest,
        _ completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void
    )
        -> URLSessionDataTask {
        dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
            } else if let data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                fatalError("Unexpected result from URLSessionDataTask.")
            }
        }
    }
}

extension URLRequest {
    func send() throws -> (Int, Data) {
        var result: Result<(Data, HTTPURLResponse), Error> =
            .failure(NSError(domain: NSURLErrorDomain, code: URLError.unknown.rawValue))
        let semaphore: DispatchSemaphore = .init(value: 0)
        let task = URLSession.shared.dataTask(with: self) {
            result = $0
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()

        switch result {
        case let .failure(error):
            throw error
        case let .success((data, response)):
            return (statusCode: response.statusCode, data)
        }
    }
}
