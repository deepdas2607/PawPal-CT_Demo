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
@MainActor
class LiveInspectorViewModel: ObservableObject {
    /// Global shared singleton instance for logging throughout the app
    static let shared = LiveInspectorViewModel()
    
    /// Array of captured inspector log items
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
    
    /// Records a new inspector log entry
    func log(
        title: String,
        category: InspectorLogCategory,
        method: String? = nil,
        endpoint: String? = nil,
        statusCode: Int? = nil,
        payload: Any? = nil,
        isSuccess: Bool = true
    ) {
        var formattedJSON = "No payload"
        
        if let payload = payload {
            if let stringPayload = payload as? String {
                formattedJSON = stringPayload
            } else if let dataPayload = payload as? Data,
                      let jsonObject = try? JSONSerialization.jsonObject(with: dataPayload, options: []),
                      let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
                      let prettyString = String(data: prettyData, encoding: .utf8) {
                formattedJSON = prettyString
            } else if let jsonObject = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted]),
                      let prettyString = String(data: jsonObject, encoding: .utf8) {
                formattedJSON = prettyString
            } else {
                formattedJSON = String(describing: payload)
            }
        }
        
        let entry = LiveInspectorLog(
            title: title,
            category: category,
            method: method,
            endpoint: endpoint,
            statusCode: statusCode,
            payloadJSON: formattedJSON,
            isSuccess: isSuccess
        )
        
        // Insert at beginning so newest appears first
        logs.insert(entry, at: 0)
        
        // Trim if exceeds limit
        if logs.count > maxLogCount {
            logs.removeLast(logs.count - maxLogCount)
        }
    }
    
    /// Clears all captured inspection logs
    func clearLogs() {
        logs.removeAll()
    }
}

