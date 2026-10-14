//
//  OnboardingView.swift
//  PawPal - View Layer
//
//  Welcome and initial pet profile setup screen.
//  Displayed when no pet profile exists yet in the database.
//

import SwiftUI

/// Onboarding screen allowing pet parents to configure their companion's initial profile.
struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @ObservedObject private var inspectorVM = LiveInspectorViewModel.shared
    var onProfileCreated: (Pet) -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Banner
                    headerSection
                    
                    // Form Card
                    VStack(spacing: 20) {
                        // Avatar Icon Picker
                        avatarSelectorSection
                        
                        // Pet Details Form
                        petDetailsSection
                    }
                    .padding(20)
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                    
                    // Error Notice (if any)
                    if let error = viewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.red)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // Submit Button
                    Button(action: {
                        Task {
                            if let createdPet = await viewModel.createPetProfile() {
                                onProfileCreated(createdPet)
                            }
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.trailing, 4)
                            }
                            Text(viewModel.isLoading ? "Saving Profile..." : "Create Pet Profile")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(viewModel.isValid ? Color.orange : Color.buttonDisabled)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(!viewModel.isValid || viewModel.isLoading)
                    .padding(.top, 8)
                }
                .padding(20)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .inlineTitle("Welcome to PawPal")
            .toolbar {
                ToolbarItem(placement: .trailingPlacement) {
                    Button(action: {
                        inspectorVM.isInspectorPresented = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text.magnifyingglass")
                            Text("Inspector")
                        }
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                    }
                }
            }
            .sheet(isPresented: $inspectorVM.isInspectorPresented) {
                LiveInspectorView()
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: viewModel.avatarSymbol)
                    .font(.system(size: 38))
                    .foregroundColor(.orange)
            }
            
            Text("Meet Your New Care Companion")
                .font(.title3.weight(.bold))
            
            Text("Tell us about your pet to personalize daily reminders, activity tracking, and care wellness tips.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding(.top, 12)
    }
    
    // MARK: - Avatar Selector
    
    private var avatarSelectorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose an Avatar")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.avatarOptions, id: \.self) { symbol in
                        Button(action: {
                            viewModel.avatarSymbol = symbol
                        }) {
                            ZStack {
                                Circle()
                                    .fill(viewModel.avatarSymbol == symbol ? Color.orange.opacity(0.2) : Color.inputBackground)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(viewModel.avatarSymbol == symbol ? Color.orange : Color.clear, lineWidth: 2)
                                    )
                                Image(systemName: symbol)
                                    .foregroundColor(viewModel.avatarSymbol == symbol ? .orange : .secondary)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Pet Details
    
    private var petDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Pet Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Pet Name *")
                    .font(.subheadline.weight(.semibold))
                TextField("e.g. Milo, Bella, Charlie", text: $viewModel.name)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color.inputBackground)
                    .cornerRadius(10)
            }
            
            // Species
            VStack(alignment: .leading, spacing: 6) {
                Text("Species")
                    .font(.subheadline.weight(.semibold))
                Picker("Species", selection: $viewModel.species) {
                    ForEach(viewModel.speciesOptions, id: \.self) { item in
                        Text(item).tag(item)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Breed (Optional)
            VStack(alignment: .leading, spacing: 6) {
                Text("Breed (Optional)")
                    .font(.subheadline.weight(.semibold))
                TextField("e.g. Golden Retriever, Beagle", text: $viewModel.breed)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color.inputBackground)
                    .cornerRadius(10)
            }
            
            // Date of Birth
            VStack(alignment: .leading, spacing: 6) {
                DatePicker(
                    "Date of Birth (Optional)",
                    selection: $viewModel.dateOfBirth,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .font(.subheadline.weight(.semibold))
            }
        }
    }
}
