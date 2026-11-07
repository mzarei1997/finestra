import Foundation

enum APIRequest {
    case get(path: String, query: [URLQueryItem] = [], headers: [String: String] = [:])
    case post(path: String, body: Data?, headers: [String: String] = [:])
    case put(path: String, body: Data?, headers: [String: String] = [:])
    case delete(path: String, headers: [String: String] = [:])

    var method: String {
        switch self {
        case .get: "GET"
        case .post: "POST"
        case .put: "PUT"
        case .delete: "DELETE"
        }
    }

    var path: String {
        switch self {
        case let .get(path, _, _), let .post(path, _, _), let .put(path, _, _), let .delete(path, _):
            path
        }
    }

    var query: [URLQueryItem] {
        if case let .get(_, query, _) = self { return query }
        return []
    }

    var body: Data? {
        switch self {
        case let .post(_, body, _), let .put(_, body, _): body
        default: nil
        }
    }

    var headers: [String: String] {
        switch self {
        case let .get(_, _, headers), let .post(_, _, headers), let .put(_, _, headers), let .delete(_, headers):
            headers
        }
    }
}

enum APIManagerError: Error {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
}

protocol APIManagerProtocol {
    func send(_ request: APIRequest) async throws -> (Data, HTTPURLResponse)
}

final class APIManager: APIManagerProtocol {
    private let session: URLSession
    private let environment: AppEnvironment

    init(session: URLSession = .shared, environment: AppEnvironment = .live) {
        self.session = session
        self.environment = environment
    }

    func send(_ request: APIRequest) async throws -> (Data, HTTPURLResponse) {
        guard var components = URLComponents(
            url: environment.apiBaseURL.appending(path: request.path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIManagerError.invalidURL
        }
        components.queryItems = request.query.isEmpty ? nil : request.query
        guard let url = components.url else { throw APIManagerError.invalidURL }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        urlRequest.httpBody = request.body
        request.headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }

        let (data, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIManagerError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIManagerError.httpStatus(httpResponse.statusCode)
        }
        return (data, httpResponse)
    }
}
