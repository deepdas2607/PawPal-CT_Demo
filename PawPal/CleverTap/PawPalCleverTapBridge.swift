//
//  PawPalCleverTapBridge.swift
//  PawPal - CleverTap Integration Layer
//
//  BRIDGE LAYER:
//  Connects PawPal UI interactions and ViewModel actions directly to CleverTap analytics.
//  Keeps business logic decoupled from raw SDK tracking calls.
//

import Foundation

/// Bridge connecting PawPal user actions to CleverTap tracking workflows.
struct PawPalCleverTapBridge {
    
    // MARK: - Pet Profile & Onboarding
    
    /// Called when a pet profile is first created during Onboarding.
    static func onPetProfileCreated(pet: Pet) {
        // 1. Identify user profile on CleverTap
        CleverTapIdentity.onUserLogin(
            userId: "user-\(pet.id)",
            name: "\(pet.name)'s Pet Parent",
            email: "\(pet.name.lowercased())@pawpal.local",
            petName: pet.name,
            species: pet.species,
            breed: pet.breed,
            dateOfBirth: pet.dateOfBirth
        )
        
        // 2. Track custom event
        CleverTapEvents.logEvent(
            CleverTapEvents.Names.PET_PROFILE_CREATED,
            properties: [
                "petId": pet.id,
                "petName": pet.name,
                "species": pet.species,
                "breed": pet.breed ?? "Unknown",
                "avatar": pet.avatarSymbol
            ]
        )
    }
    
    /// Called when an existing pet profile details are modified and saved.
    static func onPetProfileUpdated(pet: Pet) {
        CleverTapProfile.updatePetDetails(
            petName: pet.name,
            species: pet.species,
            breed: pet.breed,
            dateOfBirth: pet.dateOfBirth
        )
        CleverTapEvents.logEvent(
            "Pet Profile Updated",
            properties: [
                "petId": pet.id,
                "petName": pet.name,
                "species": pet.species,
                "breed": pet.breed ?? "Unknown"
            ]
        )
    }
    
    // MARK: - Daily Care Activities
    
    /// Called when an activity (walk, meal, medicine, grooming) is logged.
    static func onActivityLogged(activity: CareActivity, petName: String?) {
        CleverTapEvents.logEvent(
            CleverTapEvents.Names.ACTIVITY_LOGGED,
            properties: [
                "activityId": activity.id,
                "petId": activity.petId,
                "petName": petName ?? "My Pet",
                "activityType": activity.activityType,
                "durationMinutes": activity.durationMinutes ?? 0,
                "hasNotes": activity.notes?.isEmpty == false
            ]
        )
        
        // Increment lifetime counter on profile
        CleverTapProfile.incrementActivitiesLogged()
    }
    
    // MARK: - Care Reminders
    
    /// Called when a new reminder is scheduled.
    static func onReminderScheduled(reminder: CareReminder, petName: String?) {
        CleverTapEvents.logEvent(
            CleverTapEvents.Names.REMINDER_SCHEDULED,
            properties: [
                "reminderId": reminder.id,
                "petId": reminder.petId,
                "petName": petName ?? "My Pet",
                "title": reminder.title,
                "dueDate": reminder.dueDate
            ]
        )
    }
    
    /// Called when a reminder is marked as completed.
    static func onReminderCompleted(reminder: CareReminder, petName: String?) {
        CleverTapEvents.logEvent(
            CleverTapEvents.Names.REMINDER_COMPLETED,
            properties: [
                "reminderId": reminder.id,
                "petId": reminder.petId,
                "petName": petName ?? "My Pet",
                "title": reminder.title
            ]
        )
        
        // Increment lifetime counter on profile
        CleverTapProfile.incrementRemindersCompleted()
    }
    
    // MARK: - Wellness Tips
    
    /// Called when a pet wellness tip is saved or unsaved.
    static func onTipFavoriteToggled(tip: PetTip, isSaved: Bool, petId: String?) {
        let eventName = isSaved ? CleverTapEvents.Names.TIP_FAVORITED : CleverTapEvents.Names.TIP_UNFAVORITED
        CleverTapEvents.logEvent(
            eventName,
            properties: [
                "tipId": tip.id,
                "title": tip.title,
                "category": tip.category,
                "petId": petId ?? ""
            ]
        )
    }
    
    // MARK: - Special "Charged" Purchase Event
    
    /// Records a purchase of pet care supplies, premium plans, or vet consultation.
    static func onCarePurchase(
        itemName: String,
        itemCategory: String = "Pet Care",
        amount: Double = 24.99,
        paymentMode: String = "Apple Pay"
    ) {
        let txnId = "TXN-\(Int(Date().timeIntervalSince1970) % 1000000)"
        let item: [String: Any] = [
            "Item": itemName,
            "Product category": itemCategory,
            "Quantity": 1,
            "Price": amount
        ]
        
        CleverTapEvents.recordChargedEvent(
            amount: amount,
            paymentMode: paymentMode,
            transactionId: txnId,
            items: [item]
        )
        
        // Update user profile total spend
        CleverTapProfile.incrementLifetimeSpend(amount: amount)
    }
}
