//
//  TipsService.swift
//  PawPal - Service Layer
//
//  Handles network communication for pet care wellness tips and saved favorites.
//

import Foundation

/// Service for managing pet care tips API requests.
class TipsService {
    static let shared = TipsService()
    private let client = APIClient.shared
    
    /// Fetches all tips, marking those saved by the given pet.
    func fetchTips(petId: String?) async throws -> [PetTip] {
        var allTips: [PetTip] = try await client.get(endpoint: "/api/tips")
        
        if let petId = petId {
            let savedIds: [String] = (try? await client.get(endpoint: "/api/pets/\(petId)/saved-tips")) ?? []
            let savedSet = Set(savedIds)
            
            allTips = allTips.map { tip in
                var mutableTip = tip
                mutableTip.isSaved = savedSet.contains(tip.id)
                return mutableTip
            }
        }
        
        return allTips
    }
    
    /// Saves a tip for a pet profile.
    func saveTip(petId: String, tipId: String) async throws {
        let _: SimpleMessageResponse = try await client.put(endpoint: "/api/pets/\(petId)/saved-tips/\(tipId)")
    }
    
    /// Removes a tip from saved favorites for a pet profile.
    func unsaveTip(petId: String, tipId: String) async throws {
        let _: SimpleMessageResponse = try await client.delete(endpoint: "/api/pets/\(petId)/saved-tips/\(tipId)")
    }
}

