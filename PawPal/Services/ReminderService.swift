//
//  ReminderService.swift
//  PawPal - Service Layer
//
//  Handles network communication for pet care reminders.
//

import Foundation

/// Service for managing care reminders API requests.
class ReminderService {
    static let shared = ReminderService()
    private let client = APIClient.shared
    
    /// Fetches all reminders for a given pet.
    func fetchReminders(petId: String) async throws -> [CareReminder] {
        return try await client.get(endpoint: "/api/pets/\(petId)/reminders")
    }
    
    /// Creates a new reminder for a pet.
    func createReminder(petId: String, title: String, notes: String?, dueDate: String) async throws -> CareReminder {
        let request = CareReminderCreateRequest(title: title, notes: notes, dueDate: dueDate)
        return try await client.post(endpoint: "/api/pets/\(petId)/reminders", body: request)
    }
    
    /// Updates an existing reminder (e.g. toggles completion).
    func updateReminder(reminderId: String, isCompleted: Bool?, title: String? = nil, notes: String? = nil, dueDate: String? = nil) async throws -> CareReminder {
        let request = CareReminderUpdateRequest(isCompleted: isCompleted, title: title, notes: notes, dueDate: dueDate)
        return try await client.patch(endpoint: "/api/reminders/\(reminderId)", body: request)
    }
    
    /// Deletes a reminder by ID.
    func deleteReminder(reminderId: String) async throws {
        let _: SimpleMessageResponse = try await client.delete(endpoint: "/api/reminders/\(reminderId)")
    }
}

