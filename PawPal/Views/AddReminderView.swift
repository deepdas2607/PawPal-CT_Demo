//
//  AddReminderView.swift
//  PawPal - View Layer
//
//  Form to create and schedule a new care reminder.
//

import SwiftUI

/// Modal sheet for scheduling a new pet care reminder.
struct AddReminderView: View {
    let petId: String
    var onReminderAdded: () -> Void
    
    @StateObject private var viewModel: RemindersViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(petId: String, onReminderAdded: @escaping () -> Void) {
        self.petId = petId
        self.onReminderAdded = onReminderAdded
        _viewModel = StateObject(wrappedValue: RemindersViewModel(petId: petId))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Reminder Details")) {
                    TextField("Title (e.g. Give Flea Medicine)", text: $viewModel.title)
                    
                    TextField("Notes (optional)", text: $viewModel.notes)
                    
                    DatePicker("Due Date & Time", selection: $viewModel.dueDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(footer: Text("PawPal will schedule a local notification alert on this device at the selected due time.")) {
                    HStack(spacing: 8) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.blue)
                        Text("Local Notification Alert")
                            .font(.footnote)
                    }
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
            }
            .inlineTitle("New Reminder")
            .toolbar {
                ToolbarItem(placement: .leadingPlacement) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .trailingPlacement) {
                    Button(action: {
                        Task {
                            if await viewModel.addReminder() {
                                onReminderAdded()
                                dismiss()
                            }
                        }
                    }) {
                        if viewModel.isSubmitting {
                            ProgressView()
                        } else {
                            Text("Schedule")
                                .bold()
                        }
                    }
                    .disabled(viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSubmitting)
                }
            }
        }
    }
}

