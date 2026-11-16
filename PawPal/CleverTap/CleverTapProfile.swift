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
    
    // MARK: - Multi-Value Profile Attributes (Arbitrary Multi-Value API)
    
    /// Sets a multi-value string property on the user profile (e.g., Allergies, Dietary Needs).
    static func setMultiValues(_ values: [String], forKey key: String) {
        guard CleverTapConfig.isAnalyticsConsentGiven else { return }
        
        CleverTap.sharedInstance()?.profileSetMultiValues(values, forKey: key)
        
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: profileSetMultiValues (\(key))",
            category: .cleverTap,
            payload: [
                "key": key,
                "values": values
            ]
        )
    }
    
    /// Adds a single value to an existing multi-value profile property.
    static func addMultiValue(_ value: String, forKey key: String) {
        guard CleverTapConfig.isAnalyticsConsentGiven else { return }
        
        CleverTap.sharedInstance()?.profileAddMultiValue(value, forKey: key)
        
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: profileAddMultiValue (+\(value))",
            category: .cleverTap,
            payload: [
                "key": key,
                "addedValue": value
            ]
        )
    }
    
    /// Adds multiple values to an existing multi-value profile property.
    static func addMultiValues(_ values: [String], forKey key: String) {
        guard CleverTapConfig.isAnalyticsConsentGiven else { return }
        
        CleverTap.sharedInstance()?.profileAddMultiValues(values, forKey: key)
        
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: profileAddMultiValues (\(key))",
            category: .cleverTap,
            payload: [
                "key": key,
                "addedValues": values
            ]
        )
    }
    
    /// Removes a single value from a multi-value profile property.
    static func removeMultiValue(_ value: String, forKey key: String) {
        guard CleverTapConfig.isAnalyticsConsentGiven else { return }
        
        CleverTap.sharedInstance()?.profileRemoveMultiValue(value, forKey: key)
        
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: profileRemoveMultiValue (-\(value))",
            category: .cleverTap,
            payload: [
                "key": key,
                "removedValue": value
            ]
        )
    }
    
    /// Removes multiple values from a multi-value profile property.
    static func removeMultiValues(_ values: [String], forKey key: String) {
        guard CleverTapConfig.isAnalyticsConsentGiven else { return }
        
        CleverTap.sharedInstance()?.profileRemoveMultiValues(values, forKey: key)
        
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: profileRemoveMultiValues (\(key))",
            category: .cleverTap,
            payload: [
                "key": key,
                "removedValues": values
            ]
        )
    }
    
    /// Completely removes a profile property (scalar or multi-value) from the profile.
    static func removeValueForKey(_ key: String) {
        guard CleverTapConfig.isAnalyticsConsentGiven else { return }
        
        CleverTap.sharedInstance()?.profileRemoveValue(forKey: key)
        
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: profileRemoveValue(forKey: \"\(key)\")",
            category: .cleverTap,
            payload: [
                "removedKey": key
            ]
        )
    }
    
    // MARK: - Rich Predefined Demographics
    
    /// Pushes comprehensive standard predefined CleverTap demographic profile properties.
    static func pushRichDemographics(
        name: String,
        email: String,
        phone: String,
        gender: String,
        dateOfBirth: Date,
        photoUrl: String? = nil,
        education: String? = "Graduate",
        married: String? = "Y",
        customerType: String = "Premium"
    ) {
        var profile: [String: Any] = [
            "Name": name,
            "Email": email,
            "Phone": phone,
            "Gender": gender, // "M" or "F"
            "DOB": dateOfBirth, // NSDate object for automatic Age calculation
            "Customer Type": customerType,
            "MSG-push": true,
            "MSG-email": true,
            "MSG-sms": false,
            "MSG-dndPhone": false,
            "MSG-dndEmail": false
        ]
        
        if let photo = photoUrl, !photo.isEmpty {
            profile["Photo"] = photo
        }
        if let edu = education {
            profile["Education"] = edu
        }
        if let mar = married {
            profile["Married"] = mar
        }
        
        pushProfile(properties: profile)
    }
}
