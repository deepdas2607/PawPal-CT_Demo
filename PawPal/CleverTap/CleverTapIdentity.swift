//
//  CleverTapIdentity.swift
//  PawPal - CleverTap Integration Layer
//
//  IDENTITY LAYER:
//  Manages CleverTap onUserLogin, identifying anonymous users into known pet parent profiles.
//

import Foundation
import CleverTapSDK

/// Handles user identification and session management with CleverTap.
struct CleverTapIdentity {
    
    /// Identifies the pet parent and their companion profile in CleverTap using onUserLogin().
    /// Merges any prior anonymous events (e.g. browsing tips) with this permanent user profile.
    static func onUserLogin(
        userId: String,
        name: String,
        email: String,
        phone: String? = nil,
        petName: String? = nil,
        species: String? = nil,
        breed: String? = nil,
        dateOfBirth: String? = nil
    ) {
        guard CleverTapConfig.isAnalyticsConsentGiven else { return }
        
        var profile: [String: Any] = [
            // Standard pre-defined CleverTap profile identifiers
            "Identity": userId,
            "Name": name,
            "Email": email,
            "MSG-push": true,
            "MSG-email": true,
            "MSG-sms": false,
            "MSG-dndPhone": false,
            "MSG-dndEmail": false
        ]
        
        // Optional phone number
        if let phone = phone, !phone.isEmpty {
            profile["Phone"] = phone
        }
        
        // Custom pet-care properties per CleverTap data model
        if let petName = petName, !petName.isEmpty {
            profile["Pet Name"] = petName
        }
        if let species = species, !species.isEmpty {
            profile["Pet Species"] = species
        }
        if let breed = breed, !breed.isEmpty {
            profile["Pet Breed"] = breed
        }
        if let dateOfBirth = dateOfBirth, !dateOfBirth.isEmpty {
            profile["Pet DOB"] = dateOfBirth
        }
        
        // 1. Dispatch to CleverTap iOS SDK
        CleverTap.sharedInstance()?.onUserLogin(profile)
        
        // 2. Mirror to Live Activity & Payload Inspector for immediate testing
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: onUserLogin (\(name))",
            category: .cleverTap,
            payload: profile
        )
    }
    
    /// Re-identifies the user session when the app launches with an existing pet profile in cache.
    static func restoreSession(pet: Pet) {
        onUserLogin(
            userId: "user-\(pet.id)",
            name: "\(pet.name)'s Guardian",
            email: "\(pet.name.lowercased())-parent@pawpal.local",
            petName: pet.name,
            species: pet.species,
            breed: pet.breed,
            dateOfBirth: pet.dateOfBirth
        )
    }
    
    /// Records user sign-out event in CleverTap.
    static func onUserLogout() {
        CleverTapEvents.logEvent(CleverTapEvents.Names.USER_LOGGED_OUT)
    }
}

