//
//  LocalNotificationService.swift
//  PawPal - Service Layer
//
//  Manages Apple UserNotifications for scheduling local pet care alerts.
//  Handles permission checks, scheduling, and cancelling notification requests.
//

import Foundation
import UserNotifications

/// Service for managing local on-device care reminder notifications.
class LocalNotificationService {
    static let shared = LocalNotificationService()
    private let center = UNUserNotificationCenter.current()
    
    /// Requests user permission to display alert and sound notifications.
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await LiveInspectorViewModel.shared.log(
                title: "Notification Permission Requested",
                category: .notification,
                payload: "Granted: \(granted)"
            )
            return granted
        } catch {
            await LiveInspectorViewModel.shared.log(
                title: "Notification Permission Error",
                category: .notification,
                payload: error.localizedDescription,
                isSuccess: false
            )
            return false
        }
    }
    
    /// Checks the current notification authorization status.
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
    
    /// Schedules a local notification for a reminder if the due date is in the future.
    func scheduleReminderNotification(reminderId: String, title: String, notes: String?, dueDate: Date) async {
        let status = await checkAuthorizationStatus()
        
        // If not yet determined, prompt user
        if status == .notDetermined {
            let granted = await requestAuthorization()
            if !granted { return }
        } else if status == .denied {
            // Cannot schedule if explicitly denied by user
            return
        }
        
        // Ensure due date is in the future
        guard dueDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🐾 PawPal Reminder: \(title)"
        content.body = notes?.isEmpty == false ? notes! : "Time to take care of your pet!"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: "reminder-\(reminderId)", content: content, trigger: trigger)
        
        do {
            try await center.add(request)
            await LiveInspectorViewModel.shared.log(
                title: "Local Notification Scheduled",
                category: .notification,
                payload: [
                    "reminderId": reminderId,
                    "title": title,
                    "dueDate": DateFormatterHelper.toISOString(dueDate)
                ]
            )
        } catch {
            await LiveInspectorViewModel.shared.log(
                title: "Notification Schedule Failed",
                category: .notification,
                payload: error.localizedDescription,
                isSuccess: false
            )
        }
    }
    
    /// Cancels a pending notification when a reminder is deleted or completed.
    func cancelNotification(reminderId: String) {
        let identifier = "reminder-\(reminderId)"
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        Task {
            await LiveInspectorViewModel.shared.log(
                title: "Notification Cancelled",
                category: .notification,
                payload: "Cancelled notification ID: \(identifier)"
            )
        }
    }
}

