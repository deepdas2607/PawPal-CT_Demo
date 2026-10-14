//
//  PetTip.swift
//  PawPal - Model Layer
//
//  Represents a pet care wellness tip from the backend database.
//

import Foundation

/// Data model representing a pet care tip.
struct PetTip: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let content: String
    let category: String
    let iconName: String
    var isSaved: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case category
        case iconName = "icon_name"
        case isSaved = "is_saved"
    }
}

