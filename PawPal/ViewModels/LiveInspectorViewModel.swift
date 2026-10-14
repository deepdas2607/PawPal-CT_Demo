//
//  LiveInspectorViewModel.swift
//  PawPal - ViewModel Layer
//
//  Manages the Live Activity & Payload Inspector logs in real time.
//  Provides methods to append logs, filter by category, and copy JSON payloads.
//

import Foundation
import SwiftUI
import Combine

/// Shared ViewModel providing real-time activity and payload inspection.
class LiveInspectorViewModel: ObservableObject {
    /// Global shared singleton instance for logging throughout the app
    static let shared = LiveInspectorViewModel()
    
    /// Array of captured inspector log items (published on MainActor)
    @Published var logs: [LiveInspectorLog] = []
    
    /// Active category filter
    @Published var selectedCategory: InspectorLogCategory = .all
    
    /// Controls presentation of the inspector sheet in views
    @Published var isInspectorPresented: Bool = false
    
    /// Maximum number of logs kept in memory
    private let maxLogCount = 100
    
    /// Filtered logs according to current category selection
    var filteredLogs: [LiveInspectorLog] {
        if selectedCategory == .all {
            return logs
        }
        return logs.filter { $0.category == selectedCategory }
    }
    
    /// Records a new inspector log entry safely from any thread or async context
    func log(
        title: String,
        category: InspectorLogCategory,
        method: String? = nil,
        endpoint: String? = nil,
        statusCode: Int? = nil,
        payload: Any? = nil,
        isSuccess: Bool = true
    ) {
        let formattedJSON = formatPayload(payload)
        
        let entry = LiveInspectorLog(
            title: title,
            category: category,
            method: method,
            endpoint: endpoint,
            statusCode: statusCode,
            payloadJSON: formattedJSON,
            isSuccess: isSuccess
        )
        
        Task { @MainActor in
            self.logs.insert(entry, at: 0)
            if self.logs.count > self.maxLogCount {
                self.logs.removeLast(self.logs.count - self.maxLogCount)
            }
        }
    }
    
    /// Safely formats any payload into a pretty-printed JSON string or readable text
    private func formatPayload(_ payload: Any?) -> String {
        guard let payload = payload else {
            return "No payload"
        }
        
        // 1. Already a String
        if let stringPayload = payload as? String {
            return stringPayload
        }
        
        // 2. Raw Data (e.g. HTTP request / response bodies)
        if let dataPayload = payload as? Data {
            // Check if it's valid JSON bytes
            if let jsonObject = try? JSONSerialization.jsonObject(with: dataPayload, options: []),
               JSONSerialization.isValidJSONObject(jsonObject),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                return prettyString
            }
            // Check if it's UTF-8 plain text (e.g. error message from backend)
            if let plainString = String(data: dataPayload, encoding: .utf8), !plainString.isEmpty {
                return plainString
            }
            return "\(dataPayload.count) bytes binary data"
        }
        
        // 3. Dictionary or Array JSON objects
        if JSONSerialization.isValidJSONObject(payload),
           let prettyData = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return prettyString
        }
        
        // 4. Fallback description
        return String(describing: payload)
    }
    
    /// Clears all captured inspection logs
    @MainActor
    func clearLogs() {
        logs.removeAll()
    }
}
