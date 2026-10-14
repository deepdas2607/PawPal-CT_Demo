//
//  CleverTapProfile.swift
//  PawPal - CleverTap Integration Layer
//
//  PROFILE LAYER:
//  Manages user profile properties (demographics, communication DND flags, and counters).
//  Dispatches updates via CleverTap.profilePush() and profileIncrementValue().
//

import Foundation
import CleverTapSDK

/// Manages CleverTap User Profile attributes, communication preferences, and counters.
struct CleverTapProfile {
    
    /// Updates custom profile properties using CleverTap's profilePush() method.
    static func pushProfile(properties: [String: Any]) {
        guard CleverTapConfig.isAnalyticsConsentGiven else { return }
        
        // 1. Send to CleverTap SDK
        CleverTap.sharedInstance()?.profilePush(properties)
        
        // 2. Mirror to Live Inspector
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: profilePush",
            category: .cleverTap,
            payload: properties
        )
    }
    
    /// Increments a numerical profile property (e.g., "Activities Logged", "Reminders Completed").
    static func incrementProfileValue(key: String, by value: Int = 1) {
        guard CleverTapConfig.isAnalyticsConsentGiven else { return }
        
        // 1. Send increment to CleverTap SDK
        CleverTap.sharedInstance()?.profileIncrementValue(by: NSNumber(value: value), forKey: key)
        
        // 2. Mirror to Live Inspector
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: profileIncrementValue (+\(value))",
            category: .cleverTap,
            payload: ["key": key, "incrementBy": value]
        )
    }
    
    /// Decrements a numerical profile property.
    static func decrementProfileValue(key: String, by value: Int = 1) {
        guard CleverTapConfig.isAnalyticsConsentGiven else { return }
        
        CleverTap.sharedInstance()?.profileDecrementValue(by: NSNumber(value: value), forKey: key)
        
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: profileDecrementValue (-\(value))",
            category: .cleverTap,
            payload: ["key": key, "decrementBy": value]
        )
    }
    
    /// Updates communication and Do-Not-Disturb (DND) channel opt-outs in CleverTap.
    static func updateCommunicationPreferences(
        pushEnabled: Bool,
        emailEnabled: Bool,
        dndPhone: Bool = false,
        dndEmail: Bool = false
    ) {
        let prefs: [String: Any] = [
            "MSG-push": pushEnabled,
            "MSG-email": emailEnabled,
            "MSG-dndPhone": dndPhone,
            "MSG-dndEmail": dndEmail
        ]
        pushProfile(properties: prefs)
    }
    
    /// Convenience helper to increment lifetime care activities count on user profile.
    static func incrementActivitiesLogged() {
        incrementProfileValue(key: "Activities Logged", by: 1)
    }
    
    /// Convenience helper to increment lifetime completed reminders on user profile.
    static func incrementRemindersCompleted() {
        incrementProfileValue(key: "Reminders Completed", by: 1)
    }
    
    /// Updates pet details on CleverTap profile.
    static func updatePetDetails(petName: String, species: String, breed: String?, dateOfBirth: String?) {
        var props: [String: Any] = [
            "Pet Name": petName,
            "Pet Species": species
        ]
        if let breed = breed, !breed.isEmpty {
            props["Pet Breed"] = breed
        }
        if let dob = dateOfBirth, let date = DateFormatterHelper.parseISO(dob) {
            props["Pet Birthday"] = date
        }
        pushProfile(properties: props)
    }
    
    /// Convenience helper to increment lifetime spend on user profile.
    static func incrementLifetimeSpend(amount: Double) {
        incrementProfileValue(key: "Lifetime Spend", by: Int(amount))
    }
}
