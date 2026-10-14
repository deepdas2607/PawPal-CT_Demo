//
//  PetProfileView.swift
//  PawPal - View Layer
//
//  Displays and allows updating the pet profile details.
//

import SwiftUI

/// Screen displaying pet profile details and editing controls.
struct PetProfileView: View {
    @StateObject private var viewModel: PetProfileViewModel
    @Environment(\.dismiss) private var dismiss
    var onProfileUpdated: (Pet) -> Void
    
    init(pet: Pet, onProfileUpdated: @escaping (Pet) -> Void) {
        _viewModel = StateObject(wrappedValue: PetProfileViewModel(pet: pet))
        self.onProfileUpdated = onProfileUpdated
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Avatar & Profile Header
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.15))
                                    .frame(width: 80, height: 80)
                                Image(systemName: viewModel.avatarSymbol)
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange)
                            }
                            Text(viewModel.name)
                                .font(.title3.bold())
                            Text(viewModel.species)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Editable Fields
                Section(header: Text("Pet Information")) {
                    if viewModel.isEditing {
                        TextField("Name", text: $viewModel.name)
                        
                        Picker("Species", selection: $viewModel.species) {
                            ForEach(viewModel.speciesOptions, id: \.self) {
                                Text($0).tag($0)
                            }
                        }
                        
                        TextField("Breed", text: $viewModel.breed)
                        
                        DatePicker("Date of Birth", selection: $viewModel.dateOfBirth, in: ...Date(), displayedComponents: .date)
                    } else {
                        LabeledContent("Name", value: viewModel.pet.name)
                        LabeledContent("Species", value: viewModel.pet.species)
                        LabeledContent("Breed", value: viewModel.pet.breed ?? "Not specified")
                        if let dob = viewModel.pet.dateOfBirth {
                            LabeledContent("Birthday", value: DateFormatterHelper.formatShortDate(dob))
                        }
                    }
                }
                
                // Avatar Picker (only while editing)
                if viewModel.isEditing {
                    Section(header: Text("Select Avatar")) {
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
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                // Timestamps info
                Section(header: Text("Profile Metadata")) {
                    LabeledContent("Created", value: DateFormatterHelper.formatRelative(viewModel.pet.createdAt))
                    LabeledContent("Last Updated", value: DateFormatterHelper.formatRelative(viewModel.pet.updatedAt))
                }
            }
            .inlineTitle("Pet Profile")
            .toolbar {
                ToolbarItem(placement: .leadingPlacement) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .trailingPlacement) {
                    if viewModel.isEditing {
                        Button(action: {
                            Task {
                                if await viewModel.saveProfile() {
                                    onProfileUpdated(viewModel.pet)
                                }
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("Save")
                                    .bold()
                            }
                        }
                        .disabled(viewModel.isLoading)
                    } else {
                        Button("Edit") {
                            viewModel.isEditing = true
                        }
                    }
                }
            }
            .alert("Profile Updated", isPresented: $viewModel.showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your pet's profile details have been updated successfully.")
            }
        }
    }
}

