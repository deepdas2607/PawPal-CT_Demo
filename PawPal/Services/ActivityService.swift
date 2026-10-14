//
//  ActivityService.swift
//  PawPal - Service Layer
//
//  Handles network communication for logging and retrieving care activities.
//

import Foundation

/// Service for managing care activities API requests.
class ActivityService {
    static let shared = ActivityService()
    private let client = APIClient.shared
    
    /// Fetches all care activities for a given pet.
    func fetchActivities(petId: String) async throws -> [CareActivity] {
        return try await client.get(endpoint: "/api/pets/\(petId)/activities")
    }
    
    /// Logs a new care activity for a pet.
    func createActivity(
        petId: String,
        activityType: String,
        timestamp: String,
        durationMinutes: Int?,
        notes: String?
    ) async throws -> CareActivity {
        let request = CareActivityCreateRequest(
            activityType: activityType,
            timestamp: timestamp,
            durationMinutes: durationMinutes,
            notes: notes
        )
        return try await client.post(endpoint: "/api/pets/\(petId)/activities", body: request)
    }
}

