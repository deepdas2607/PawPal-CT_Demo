//
//  TipsView.swift
//  PawPal - View Layer
//
//  Displays pet wellness tips and advice, with category filters and favorite saving.
//

import SwiftUI

/// Screen displaying curated pet care tips.
struct TipsView: View {
    let petId: String?
    @StateObject private var viewModel: TipsViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(petId: String?) {
        self.petId = petId
        _viewModel = StateObject(wrappedValue: TipsViewModel(petId: petId))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Filter Bar
                categoryFilterBar
                
                // Tips List
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading tips...")
                    Spacer()
                } else if viewModel.filteredTips.isEmpty {
                    emptyTipsView
                } else {
                    tipsListView
                }
            }
            .background(Color.appBackground)
            .inlineTitle("Pet Care Tips")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.cardBackground.opacity(0.85), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .leadingPlacement) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .trailingPlacement) {
                    Button(action: {
                        viewModel.showFavoritesOnly.toggle()
                    }) {
                        Image(systemName: viewModel.showFavoritesOnly ? "heart.fill" : "heart")
                            .foregroundColor(.orange)
                    }
                }
            }
            .task {
                await viewModel.loadTips()
            }
        }
    }
    
    // MARK: - Filter Bar
    
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.categories, id: \.self) { cat in
                    Button(action: {
                        viewModel.selectedCategory = cat
                    }) {
                        Text(cat)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(viewModel.selectedCategory == cat ? Color.orange : Color.inputBackground)
                            .foregroundColor(viewModel.selectedCategory == cat ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color.cardBackground)
        .overlay(Divider(), alignment: .bottom)
    }
    
    // MARK: - Tips List
    
    private var tipsListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredTips) { tip in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.15))
                                    .frame(width: 38, height: 38)
                                Image(systemName: tip.iconName)
                                    .foregroundColor(.orange)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(tip.title)
                                    .font(.subheadline.bold())
                                Text(tip.category)
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.12))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                            
                            Spacer()
                            
                            // Favorite Button
                            Button(action: {
                                Task { await viewModel.toggleFavorite(tip) }
                            }) {
                                Image(systemName: tip.isSaved ? "heart.fill" : "heart")
                                    .foregroundColor(tip.isSaved ? .red : .secondary)
                                    .font(.title3)
                            }
                            .buttonStyle(.borderless)
                        }
                        
                        Text(tip.content)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .lineSpacing(3)
                    }
                    .padding(14)
                    .background(Color.cardBackground)
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 60)
        }
        .scrollIndicators(.visible)
    }
    
    // MARK: - Empty State
    
    private var emptyTipsView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "lightbulb.slash")
                .font(.system(size: 44))
                .foregroundColor(.secondary)
            Text(viewModel.showFavoritesOnly ? "No Favorite Tips Saved" : "No Tips Found")
                .font(.headline)
            Text(viewModel.showFavoritesOnly ? "Tap the heart icon on any tip to save it here for easy reference." : "Try selecting a different category.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }
}
