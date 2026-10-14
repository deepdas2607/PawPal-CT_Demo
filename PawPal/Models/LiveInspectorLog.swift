//
//  LiveInspectorLog.swift
//  PawPal - Model Layer
//
//  Represents an entry in the Live Activity & Payload Inspector.
//  Used for inspecting API requests, responses, event triggers, and payloads in real time.
//

import Foundation

/// Defines the category of an inspector event.
enum InspectorLogCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case apiRequest = "Request"
    case apiResponse = "Response"
    case localEvent = "Event"
    case notification = "Notification"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .all: return "line.3.horizontal.decrease.circle"
        case .apiRequest: return "arrow.up.circle.fill"
        case .apiResponse: return "arrow.down.circle.fill"
        case .localEvent: return "bolt.circle.fill"
        case .notification: return "bell.circle.fill"
        }
    }
}

/// Represents a single inspection log entry with formatted payload.
struct LiveInspectorLog: Identifiable, Equatable {
    let id: String = UUID().uuidString
    let timestamp: Date = Date()
    let title: String
    let category: InspectorLogCategory
    let method: String?
    let endpoint: String?
    let statusCode: Int?
    let payloadJSON: String
    let isSuccess: Bool
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: timestamp)
    }
}

