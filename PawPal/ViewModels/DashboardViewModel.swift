//
//  DashboardViewModel.swift
//  PawPal - ViewModel Layer
//
//  Coordinates the main home dashboard screen state.
//  Fetches pet info, today's activities, upcoming reminders, and wellness tips.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel managing data displayed on the Home Dashboard.
@MainActor
class DashboardViewModel: ObservableObject {
    @Published var activePet: Pet? = nil
    @Published var todayActivities: [CareActivity] = []
    @Published var upcomingReminders: [CareReminder] = []
    @Published var featuredTips: [PetTip] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let petService = PetService.shared
    private let activityService = ActivityService.shared
    private let reminderService = ReminderService.shared
    private let tipsService = TipsService.shared
    
    /// Loads all dashboard data from the backend SQLite database.
    func loadDashboardData(pet: Pet? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Resolve active pet profile
            let currentPet: Pet
            if let pet = pet {
                currentPet = pet
            } else if let active = activePet {
                currentPet = active
            } else {
                let pets = try await petService.fetchPets()
                guard let firstPet = pets.first else {
                    isLoading = false
                    return
                }
                currentPet = firstPet
            }
            self.activePet = currentPet
            
            // 2. Fetch care activities in parallel
            async let activitiesTask = activityService.fetchActivities(petId: currentPet.id)
            async let remindersTask = reminderService.fetchReminders(petId: currentPet.id)
            async let tipsTask = tipsService.fetchTips(petId: currentPet.id)
            
            let (activities, reminders, tips) = try await (activitiesTask, remindersTask, tipsTask)
            
            // Filter today's activities
            let calendar = Calendar.current
            self.todayActivities = activities.filter { activity in
                guard let date = DateFormatterHelper.parseISO(activity.timestamp) else { return false }
                return calendar.isDateInToday(date)
            }
            
            // Filter upcoming pending reminders
            self.upcomingReminders = reminders.filter { !$0.isCompleted }
            
            // Take top 3 tips
            self.featuredTips = Array(tips.prefix(3))
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    /// Quick toggles reminder completion directly from dashboard.
    func toggleReminderCompletion(_ reminder: CareReminder) async {
        do {
            let updated = try await reminderService.updateReminder(
                reminderId: reminder.id,
                isCompleted: !reminder.isCompleted
            )
            
            // Cancel notification if completed
            if updated.isCompleted {
                LocalNotificationService.shared.cancelNotification(reminderId: reminder.id)
            }
            
            // Update local list
            if let index = upcomingReminders.firstIndex(where: { $0.id == reminder.id }) {
                if updated.isCompleted {
                    upcomingReminders.remove(at: index)
                } else {
                    upcomingReminders[index] = updated
                }
            }
        } catch {
            errorMessage = "Failed to update reminder: \(error.localizedDescription)"
        }
    }
}

