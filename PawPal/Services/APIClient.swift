//
//  APIClient.swift
//  PawPal - Service Layer
//
//  Centralized HTTP networking client using URLSession with async/await.
//  Handles JSON encoding/decoding, network errors, and logs to Live Activity & Payload Inspector.
//

import Foundation

/// Possible networking and API errors
enum APIError: LocalizedError, Equatable {
    case invalidURL(String)
    case networkConnectionFailed(String)
    case serverError(statusCode: Int, message: String)
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .networkConnectionFailed(let reason):
            return "Cannot connect to server. Is the backend running? (\(reason))"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message)"
        case .decodingError(let detail):
            return "Failed to parse server response: \(detail)"
        }
    }
}

/// Generic response message for operations that return status messages
struct SimpleMessageResponse: Codable {
    let message: String
    let id: String?
}

/// Central HTTP networking singleton.
class APIClient {
    static let shared = APIClient()
    
    private let session: URLSession
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = AppConfig.requestTimeout
        self.session = URLSession(configuration: configuration)
        self.jsonDecoder = JSONDecoder()
        self.jsonEncoder = JSONEncoder()
    }
    
    // MARK: - Generic HTTP Methods
    
    /// Executes a GET request and decodes the JSON response into type `T`.
    func get<T: Decodable>(endpoint: String) async throws -> T {
        return try await performRequest(endpoint: endpoint, method: "GET", bodyData: nil)
    }
    
    /// Executes a POST request with an Encodable request body, returning decoded response `T`.
    func post<Req: Encodable, Res: Decodable>(endpoint: String, body: Req) async throws -> Res {
        let data = try jsonEncoder.encode(body)
        return try await performRequest(endpoint: endpoint, method: "POST", bodyData: data)
    }
    
    /// Executes a PUT request with an Encodable body.
    func put<Req: Encodable, Res: Decodable>(endpoint: String, body: Req) async throws -> Res {
        let data = try jsonEncoder.encode(body)
        return try await performRequest(endpoint: endpoint, method: "PUT", bodyData: data)
    }
    
    /// Executes a PUT request without body data.
    func put<Res: Decodable>(endpoint: String) async throws -> Res {
        return try await performRequest(endpoint: endpoint, method: "PUT", bodyData: nil)
    }
    
    /// Executes a PATCH request with an Encodable request body.
    func patch<Req: Encodable, Res: Decodable>(endpoint: String, body: Req) async throws -> Res {
        let data = try jsonEncoder.encode(body)
        return try await performRequest(endpoint: endpoint, method: "PATCH", bodyData: data)
    }
    
    /// Executes a DELETE request and decodes the confirmation response.
    func delete<Res: Decodable>(endpoint: String) async throws -> Res {
        return try await performRequest(endpoint: endpoint, method: "DELETE", bodyData: nil)
    }
    
    // MARK: - Core Request Pipeline
    
    private func performRequest<T: Decodable>(endpoint: String, method: String, bodyData: Data?) async throws -> T {
        guard let url = URL(string: "\(AppConfig.baseURL)\(endpoint)") else {
            throw APIError.invalidURL("\(AppConfig.baseURL)\(endpoint)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = bodyData
        
        // Log outgoing request to the Live Activity & Payload Inspector
        await LiveInspectorViewModel.shared.log(
            title: "\(method) \(endpoint)",
            category: .apiRequest,
            method: method,
            endpoint: endpoint,
            payload: bodyData
        )
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            // Log failed connection
            await LiveInspectorViewModel.shared.log(
                title: "Failed: \(method) \(endpoint)",
                category: .apiResponse,
                method: method,
                endpoint: endpoint,
                payload: error.localizedDescription,
                isSuccess: false
            )
            throw APIError.networkConnectionFailed(error.localizedDescription)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkConnectionFailed("Invalid HTTP response")
        }
        
        // Log response received
        let isSuccess = (200...299).contains(httpResponse.statusCode)
        await LiveInspectorViewModel.shared.log(
            title: "[\(httpResponse.statusCode)] \(method) \(endpoint)",
            category: .apiResponse,
            method: method,
            endpoint: endpoint,
            statusCode: httpResponse.statusCode,
            payload: data,
            isSuccess: isSuccess
        )
        
        // Check for non-2xx status codes
        if !isSuccess {
            var errorMessage = "HTTP \(httpResponse.statusCode)"
            if let serverJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let detail = serverJson["detail"] as? String {
                errorMessage = detail
            } else if let rawString = String(data: data, encoding: .utf8), !rawString.isEmpty {
                errorMessage = rawString
            }
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        // Decode JSON into requested model
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }
}

