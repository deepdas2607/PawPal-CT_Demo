//
//  Pet.swift
//  PawPal - Model Layer
//
//  Represents a pet profile matching the backend SQLite 'pets' table schema.
//

import Foundation

/// Data model representing a pet profile.
/// Conforms to `Identifiable` for SwiftUI lists and `Codable` for JSON serialization.
struct Pet: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var species: String
    var breed: String?
    var dateOfBirth: String?
    var avatarSymbol: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case species
        case breed
        case dateOfBirth = "date_of_birth"
        case avatarSymbol = "avatar_symbol"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Request payload sent to the backend when creating a new pet.
struct PetCreateRequest: Codable {
    let name: String
    let species: String
    let breed: String?
    let dateOfBirth: String?
    let avatarSymbol: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case species
        case breed
        case dateOfBirth = "date_of_birth"
        case avatarSymbol = "avatar_symbol"
    }
}

/// Request payload sent to the backend when updating an existing pet.
struct PetUpdateRequest: Codable {
    let name: String?
    let species: String?
    let breed: String?
    let dateOfBirth: String?
    let avatarSymbol: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case species
        case breed
        case dateOfBirth = "date_of_birth"
        case avatarSymbol = "avatar_symbol"
    }
}

