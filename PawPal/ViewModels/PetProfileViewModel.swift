//
//  PetProfileViewModel.swift
//  PawPal - ViewModel Layer
//
//  Manages the state and updates for viewing and modifying a pet profile.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel for viewing and editing an existing pet profile.
@MainActor
class PetProfileViewModel: ObservableObject {
    @Published var pet: Pet
    @Published var name: String
    @Published var species: String
    @Published var breed: String
    @Published var dateOfBirth: Date
    @Published var avatarSymbol: String
    
    @Published var isEditing: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showSuccessAlert: Bool = false
    
    let speciesOptions = ["Dog", "Cat", "Bird", "Rabbit", "Hamster", "Other"]
    let avatarOptions = [
        "pawprint.fill",
        "dog.fill",
        "cat.fill",
        "bird.fill",
        "hare.fill",
        "tortoise.fill",
        "fish.fill",
        "heart.fill"
    ]
    
    init(pet: Pet) {
        self.pet = pet
        self.name = pet.name
        self.species = pet.species
        self.breed = pet.breed ?? ""
        self.avatarSymbol = pet.avatarSymbol
        self.dateOfBirth = DateFormatterHelper.parseISO(pet.dateOfBirth ?? "") ?? Date()
    }
    
    /// Saves modified pet profile fields to SQLite via API.
    func saveProfile() async -> Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Pet name cannot be blank."
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        let dobString = DateFormatterHelper.toISOString(dateOfBirth)
        let breedValue = breed.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            let updated = try await PetService.shared.updatePet(
                id: pet.id,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                species: species,
                breed: breedValue.isEmpty ? nil : breedValue,
                dateOfBirth: dobString,
                avatarSymbol: avatarSymbol
            )
            
            self.pet = updated
            self.isLoading = false
            self.isEditing = false
            self.showSuccessAlert = true
            
            // Sync updated profile attributes to CleverTap
            PawPalCleverTapBridge.onPetProfileUpdated(pet: updated)
            
            return true
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            return false
        }
    }
}

