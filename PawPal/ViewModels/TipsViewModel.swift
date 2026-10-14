//
//  TipsViewModel.swift
//  PawPal - ViewModel Layer
//
//  Manages the pet wellness tips catalog, category filters, and saved favorites.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel managing pet care tips and favorites.
@MainActor
class TipsViewModel: ObservableObject {
    let petId: String?
    
    @Published var tips: [PetTip] = []
    @Published var selectedCategory: String = "All"
    @Published var showFavoritesOnly: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    let categories = ["All", "Nutrition", "Exercise", "Care", "Wellness"]
    
    private let tipsService = TipsService.shared
    
    init(petId: String?) {
        self.petId = petId
    }
    
    /// Filtered list of tips based on active category and favorite toggle
    var filteredTips: [PetTip] {
        tips.filter { tip in
            let matchesCategory = (selectedCategory == "All") || (tip.category == selectedCategory)
            let matchesFavorite = !showFavoritesOnly || tip.isSaved
            return matchesCategory && matchesFavorite
        }
    }
    
    /// Fetches all tips from the backend.
    func loadTips() async {
        isLoading = true
        errorMessage = nil
        do {
            self.tips = try await tipsService.fetchTips(petId: petId)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    /// Toggles the favorite / saved status of a tip.
    func toggleFavorite(_ tip: PetTip) async {
        guard let petId = petId else { return }
        
        let newSavedState = !tip.isSaved
        
        // Optimistic update
        if let index = tips.firstIndex(where: { $0.id == tip.id }) {
            tips[index].isSaved = newSavedState
        }
        
        do {
            if newSavedState {
                try await tipsService.saveTip(petId: petId, tipId: tip.id)
                LiveInspectorViewModel.shared.log(
                    title: "Pet Tip Favorited: \(tip.title)",
                    category: .localEvent,
                    payload: ["tipId": tip.id, "title": tip.title]
                )
            } else {
                try await tipsService.unsaveTip(petId: petId, tipId: tip.id)
                LiveInspectorViewModel.shared.log(
                    title: "Pet Tip Unfavorited: \(tip.title)",
                    category: .localEvent,
                    payload: ["tipId": tip.id]
                )
            }
        } catch {
            // Revert on error
            if let index = tips.firstIndex(where: { $0.id == tip.id }) {
                tips[index].isSaved = !newSavedState
            }
            errorMessage = error.localizedDescription
        }
    }
}

