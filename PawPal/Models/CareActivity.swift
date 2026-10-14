//
//  CareActivity.swift
//  PawPal - Model Layer
//
//  Represents a logged pet care action (e.g. Walking, Feeding, Medication).
//

import Foundation

/// Defines standard pet care activity types.
enum ActivityType: String, CaseIterable, Identifiable {
    case walking = "Walking"
    case feeding = "Feeding"
    case grooming = "Grooming"
    case medication = "Medication"
    case vetVisit = "Vet Visit"
    case playtime = "Playtime"
    case other = "Other"
    
    var id: String { rawValue }
    
    /// SF Symbol icon associated with this care activity.
    var iconName: String {
        switch self {
        case .walking: return "figure.walk"
        case .feeding: return "fork.knife"
        case .grooming: return "comb.fill"
        case .medication: return "pills.fill"
        case .vetVisit: return "cross.case.fill"
        case .playtime: return "tennisball.fill"
        case .other: return "sparkles"
        }
    }
}

/// Data model representing a logged care activity from SQLite.
struct CareActivity: Identifiable, Codable, Equatable {
    let id: String
    let petId: String
    let activityType: String
    let timestamp: String
    let durationMinutes: Int?
    let notes: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case petId = "pet_id"
        case activityType = "activity_type"
        case timestamp
        case durationMinutes = "duration_minutes"
        case notes
        case createdAt = "created_at"
    }
    
    /// Icon matching the activity type.
    var iconName: String {
        ActivityType(rawValue: activityType)?.iconName ?? "pawprint.fill"
    }
}

/// Payload sent to POST /api/pets/{id}/activities
struct CareActivityCreateRequest: Codable {
    let activityType: String
    let timestamp: String
    let durationMinutes: Int?
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case activityType = "activity_type"
        case timestamp
        case durationMinutes = "duration_minutes"
        case notes
    }
}

