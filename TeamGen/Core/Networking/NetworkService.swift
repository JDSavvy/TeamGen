import Foundation
import OSLog

// MARK: - Network Error
public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case networkUnavailable

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .networkUnavailable:
            return "Network unavailable"
        }
    }
}

// MARK: - HTTP Method
public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - Network Request Protocol
public protocol NetworkRequest {
    var url: URL { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

// MARK: - Network Service Protocol
public protocol NetworkServiceProtocol {
    func request<T: Codable>(_ request: NetworkRequest, responseType: T.Type) async throws -> T
    func request(_ request: NetworkRequest) async throws -> Data
}

// MARK: - iOS Network Service Implementation
@MainActor
public final class iOSNetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let logger = Logger(subsystem: "com.teamgen.networking", category: "Network")

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func request<T: Codable>(_ request: NetworkRequest, responseType: T.Type) async throws -> T {
        let data = try await self.request(request)

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(responseType, from: data)
        } catch {
            logger.error("Decoding error: \(error.localizedDescription)")
            throw NetworkError.decodingError
        }
    }

    public func request(_ request: NetworkRequest) async throws -> Data {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body

        for (key, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        logger.info("Network Request: \(request.method.rawValue) \(request.url)")

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.serverError(0)
            }

            logger.info("Network Response: \(httpResponse.statusCode)")

            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.serverError(httpResponse.statusCode)
            }

            return data
        } catch {
            logger.error("Network error: \(error.localizedDescription)")
            throw NetworkError.networkUnavailable
        }
    }
}