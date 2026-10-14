//
//  PetService.swift
//  PawPal - Service Layer
//
//  Handles network communication for pet profiles.
//

import Foundation

/// Service for managing pet profile API requests.
class PetService {
    static let shared = PetService()
    private let client = APIClient.shared
    
    /// Fetches all pets from the backend.
    func fetchPets() async throws -> [Pet] {
        return try await client.get(endpoint: "/api/pets")
    }
    
    /// Creates a new pet profile.
    func createPet(name: String, species: String, breed: String?, dateOfBirth: String?, avatarSymbol: String) async throws -> Pet {
        let request = PetCreateRequest(
            name: name,
            species: species,
            breed: breed,
            dateOfBirth: dateOfBirth,
            avatarSymbol: avatarSymbol
        )
        return try await client.post(endpoint: "/api/pets", body: request)
    }
    
    /// Fetches an individual pet profile by ID.
    func getPet(id: String) async throws -> Pet {
        return try await client.get(endpoint: "/api/pets/\(id)")
    }
    
    /// Updates details of an existing pet profile.
    func updatePet(id: String, name: String?, species: String?, breed: String?, dateOfBirth: String?, avatarSymbol: String?) async throws -> Pet {
        let request = PetUpdateRequest(
            name: name,
            species: species,
            breed: breed,
            dateOfBirth: dateOfBirth,
            avatarSymbol: avatarSymbol
        )
        return try await client.put(endpoint: "/api/pets/\(id)", body: request)
    }
}

