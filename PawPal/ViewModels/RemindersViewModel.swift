//
//  RemindersViewModel.swift
//  PawPal - ViewModel Layer
//
//  Manages the schedule of care reminders, completion states, and local notification triggers.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel managing reminders view, creation, and deletion.
@MainActor
class RemindersViewModel: ObservableObject {
    let petId: String
    
    @Published var reminders: [CareReminder] = []
    @Published var isAddReminderPresented: Bool = false
    
    // Add reminder form state
    @Published var title: String = ""
    @Published var notes: String = ""
    @Published var dueDate: Date = Date().addingTimeInterval(3600) // Default 1 hour from now
    
    @Published var isLoading: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String? = nil
    
    private let reminderService = ReminderService.shared
    private let notificationService = LocalNotificationService.shared
    
    init(petId: String) {
        self.petId = petId
    }
    
    /// Upcoming reminders (not yet completed)
    var upcomingReminders: [CareReminder] {
        reminders.filter { !$0.isCompleted }
    }
    
    /// Completed reminders
    var completedReminders: [CareReminder] {
        reminders.filter { $0.isCompleted }
    }
    
    /// Fetches all reminders for this pet.
    func loadReminders() async {
        isLoading = true
        errorMessage = nil
        do {
            self.reminders = try await reminderService.fetchReminders(petId: petId)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    /// Adds a new reminder and schedules a local iOS alert.
    func addReminder() async -> Bool {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a reminder title."
            return false
        }
        
        isSubmitting = true
        errorMessage = nil
        
        let dueIso = DateFormatterHelper.toISOString(dueDate)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            let reminder = try await reminderService.createReminder(
                petId: petId,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
                dueDate: dueIso
            )
            
            // Schedule local system notification
            await notificationService.scheduleReminderNotification(
                reminderId: reminder.id,
                title: reminder.title,
                notes: reminder.notes,
                dueDate: dueDate
            )
            
            // Log local event to inspector
            LiveInspectorViewModel.shared.log(
                title: "Reminder Scheduled",
                category: .localEvent,
                payload: [
                    "reminderId": reminder.id,
                    "title": reminder.title,
                    "dueDate": reminder.dueDate
                ]
            )
            
            // Track via CleverTap Bridge
            PawPalCleverTapBridge.onReminderScheduled(reminder: reminder, petName: "My Pet")
            
            reminders.insert(reminder, at: 0)
            
            // Reset form
            title = ""
            notes = ""
            dueDate = Date().addingTimeInterval(3600)
            isSubmitting = false
            isAddReminderPresented = false
            return true
        } catch {
            isSubmitting = false
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    /// Toggles a reminder's completion state.
    func toggleCompletion(_ reminder: CareReminder) async {
        do {
            let updated = try await reminderService.updateReminder(
                reminderId: reminder.id,
                isCompleted: !reminder.isCompleted
            )
            
            if updated.isCompleted {
                notificationService.cancelNotification(reminderId: reminder.id)
                // Track completed reminder via CleverTap Bridge
                PawPalCleverTapBridge.onReminderCompleted(reminder: updated, petName: "My Pet")
            }
            
            if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
                reminders[index] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Deletes a reminder and cancels any pending notifications.
    func deleteReminder(_ reminder: CareReminder) async {
        do {
            try await reminderService.deleteReminder(reminderId: reminder.id)
            notificationService.cancelNotification(reminderId: reminder.id)
            reminders.removeAll { $0.id == reminder.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

