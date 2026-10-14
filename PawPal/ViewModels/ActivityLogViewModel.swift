//
//  ActivityLogViewModel.swift
//  PawPal - ViewModel Layer
//
//  Manages logging new pet care actions and viewing activity history.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel managing the activity log screen and activity submission.
@MainActor
class ActivityLogViewModel: ObservableObject {
    let petId: String
    
    @Published var activities: [CareActivity] = []
    @Published var selectedType: ActivityType = .walking
    @Published var activityDate: Date = Date()
    @Published var durationMinutesString: String = "30"
    @Published var notes: String = ""
    
    @Published var isLoading: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isLogSheetPresented: Bool = false
    
    private let activityService = ActivityService.shared
    
    init(petId: String) {
        self.petId = petId
    }
    
    /// Fetches all logged activities for this pet.
    func loadActivities() async {
        isLoading = true
        errorMessage = nil
        do {
            self.activities = try await activityService.fetchActivities(petId: petId)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    /// Submits a newly logged activity to the backend.
    func submitActivity() async -> Bool {
        isSubmitting = true
        errorMessage = nil
        
        let duration = Int(durationMinutesString)
        let timestamp = DateFormatterHelper.toISOString(activityDate)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            let newActivity = try await activityService.createActivity(
                petId: petId,
                activityType: selectedType.rawValue,
                timestamp: timestamp,
                durationMinutes: duration,
                notes: trimmedNotes.isEmpty ? nil : trimmedNotes
            )
            
            // Prepend new activity
            activities.insert(newActivity, at: 0)
            
            // Log local event to inspector for debugging
            LiveInspectorViewModel.shared.log(
                title: "Care Activity Logged: \(selectedType.rawValue)",
                category: .localEvent,
                payload: [
                    "activityId": newActivity.id,
                    "type": newActivity.activityType,
                    "duration": newActivity.durationMinutes ?? 0,
                    "notes": newActivity.notes ?? ""
                ]
            )
            
            // Reset form
            notes = ""
            durationMinutesString = "30"
            isSubmitting = false
            isLogSheetPresented = false
            return true
        } catch {
            isSubmitting = false
            errorMessage = error.localizedDescription
            return false
        }
    }
}

