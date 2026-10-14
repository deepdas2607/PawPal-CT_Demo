//
//  CareReminder.swift
//  PawPal - Model Layer
//
//  Represents a scheduled pet care reminder from the SQLite database.
//

import Foundation

/// Data model representing a care reminder.
struct CareReminder: Identifiable, Codable, Equatable {
    let id: String
    let petId: String
    var title: String
    var notes: String?
    var dueDate: String
    var isCompleted: Bool
    var completedAt: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case petId = "pet_id"
        case title
        case notes
        case dueDate = "due_date"
        case isCompleted = "is_completed"
        case completedAt = "completed_at"
        case createdAt = "created_at"
    }
}

/// Request payload sent to create a new reminder.
struct CareReminderCreateRequest: Codable {
    let title: String
    let notes: String?
    let dueDate: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case notes
        case dueDate = "due_date"
    }
}

/// Request payload sent to update a reminder's state.
struct CareReminderUpdateRequest: Codable {
    let isCompleted: Bool?
    let title: String?
    let notes: String?
    let dueDate: String?
    
    enum CodingKeys: String, CodingKey {
        case isCompleted = "is_completed"
        case title
        case notes
        case dueDate = "due_date"
    }
}

