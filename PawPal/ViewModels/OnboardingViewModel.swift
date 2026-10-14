//
//  OnboardingViewModel.swift
//  PawPal - ViewModel Layer
//
//  Manages the state and user input validation during initial pet profile setup.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel handling initial pet creation onboarding.
@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var species: String = "Dog"
    @Published var breed: String = ""
    @Published var dateOfBirth: Date = Date()
    @Published var avatarSymbol: String = "pawprint.fill"
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    /// Species options available in picker
    let speciesOptions = ["Dog", "Cat", "Bird", "Rabbit", "Hamster", "Other"]
    
    /// Avatar SF Symbol choices
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
    
    /// Validation rule: name must not be blank
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Submits the new pet profile to the FastAPI backend.
    func createPetProfile() async -> Pet? {
        guard isValid else {
            errorMessage = "Please enter your pet's name."
            return nil
        }
        
        isLoading = true
        errorMessage = nil
        
        let dobString = DateFormatterHelper.toISOString(dateOfBirth)
        let breedValue = breed.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            let pet = try await PetService.shared.createPet(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                species: species,
                breed: breedValue.isEmpty ? nil : breedValue,
                dateOfBirth: dobString,
                avatarSymbol: avatarSymbol
            )
            
            // Log local event to inspector for debugging
            LiveInspectorViewModel.shared.log(
                title: "Pet Profile Created",
                category: .localEvent,
                payload: [
                    "petId": pet.id,
                    "name": pet.name,
                    "species": pet.species
                ]
            )
            
            isLoading = false
            return pet
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return nil
        }
    }
}

