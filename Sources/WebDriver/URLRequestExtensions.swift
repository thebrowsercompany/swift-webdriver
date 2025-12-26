import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

extension URLRequest {
    func send() async throws -> (Int, Data) {
        let (data, response) = try await URLSession.shared.data(for: self)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        return (statusCode: httpResponse.statusCode, data)
    }
}
