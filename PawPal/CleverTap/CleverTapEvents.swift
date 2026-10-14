//
//  CleverTapEvents.swift
//  PawPal - CleverTap Integration Layer
//
//  EVENTS LAYER:
//  Tracks custom behavioral user events, screen views, and the special "Charged" purchase event.
//

import Foundation
import CleverTapSDK

/// Manages dispatching custom events and transactions to CleverTap.
struct CleverTapEvents {
    
    /// Standardized event name taxonomy for PawPal pet care workflows
    struct Names {
        static let USER_LOGGED_IN = "User Logged In"
        static let USER_LOGGED_OUT = "User Logged Out"
        static let PET_PROFILE_CREATED = "Pet Profile Created"
        static let PET_PROFILE_UPDATED = "Pet Profile Updated"
        static let ACTIVITY_LOGGED = "Activity Logged"
        static let REMINDER_SCHEDULED = "Reminder Scheduled"
        static let REMINDER_COMPLETED = "Reminder Completed"
        static let REMINDER_DELETED = "Reminder Deleted"
        static let TIP_VIEWED = "Tip Viewed"
        static let TIP_FAVORITED = "Tip Favorited"
        static let TIP_UNFAVORITED = "Tip Unfavorited"
        static let CHARGED = "Charged"
    }
    
    /// Records a custom event with key-value properties to CleverTap SDK.
    static func logEvent(_ eventName: String, properties: [String: Any] = [:]) {
        guard CleverTapConfig.isAnalyticsConsentGiven else { return }
        
        var eventProps = properties
        // Ensure timestamp is attached
        if eventProps["Date"] == nil && eventProps["timestamp"] == nil {
            eventProps["timestamp"] = DateFormatterHelper.toISOString(Date())
        }
        
        // 1. Dispatch to CleverTap iOS SDK
        if eventProps.isEmpty {
            CleverTap.sharedInstance()?.recordEvent(eventName)
        } else {
            CleverTap.sharedInstance()?.recordEvent(eventName, withProps: eventProps)
        }
        
        // 2. Mirror to Live Activity & Payload Inspector
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: \(eventName)",
            category: .cleverTap,
            payload: eventProps.isEmpty ? ["event": eventName] : eventProps
        )
    }
    
    /// Records a screen transition event in CleverTap.
    static func recordScreen(_ screenName: String) {
        guard CleverTapConfig.isAnalyticsConsentGiven else { return }
        
        CleverTap.sharedInstance()?.recordScreenView(screenName)
        
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: Screen Viewed (\(screenName))",
            category: .cleverTap,
            payload: ["screenName": screenName]
        )
    }
    
    /// Records an in-app transaction or care subscription using CleverTap's special "Charged" event.
    static func recordChargedEvent(
        amount: Double,
        paymentMode: String,
        transactionId: String,
        items: [[String: Any]]
    ) {
        guard CleverTapConfig.isAnalyticsConsentGiven else { return }
        
        let chargeDetails: [String: Any] = [
            "Amount": amount,
            "Payment mode": paymentMode,
            "Charged ID": transactionId,
            "Date": Date()
        ]
        
        // 1. Send special Charged event to CleverTap SDK
        CleverTap.sharedInstance()?.recordChargedEvent(withDetails: chargeDetails, andItems: items)
        
        // 2. Mirror to Live Activity & Payload Inspector
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: Charged ($\(String(format: "%.2f", amount)))",
            category: .cleverTap,
            payload: [
                "chargeDetails": chargeDetails,
                "items": items
            ]
        )
    }
}

