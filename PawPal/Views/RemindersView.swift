//
//  RemindersView.swift
//  PawPal - View Layer
//
//  Displays full list of upcoming and completed pet care reminders.
//

import SwiftUI

/// Screen for managing care reminders, checking them off, or deleting.
struct RemindersView: View {
    let petId: String
    @StateObject private var viewModel: RemindersViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isAddSheetPresented: Bool = false
    
    init(petId: String) {
        self.petId = petId
        _viewModel = StateObject(wrappedValue: RemindersViewModel(petId: petId))
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Upcoming Section
                Section(header: Text("Upcoming Reminders")) {
                    if viewModel.upcomingReminders.isEmpty {
                        Text("No pending reminders.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.upcomingReminders) { reminder in
                            reminderRow(reminder)
                        }
                        .onDelete(perform: deleteUpcoming)
                    }
                }
                
                // Completed Section
                if !viewModel.completedReminders.isEmpty {
                    Section(header: Text("Completed")) {
                        ForEach(viewModel.completedReminders) { reminder in
                            reminderRow(reminder)
                        }
                        .onDelete(perform: deleteCompleted)
                    }
                }
            }
            .appListStyle()
            .inlineTitle("Care Reminders")
            .toolbar {
                ToolbarItem(placement: .leadingPlacement) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .trailingPlacement) {
                    Button(action: {
                        isAddSheetPresented = true
                    }) {
                        Image(systemName: "plus")
                            .bold()
                    }
                }
            }
            .task {
                await viewModel.loadReminders()
            }
            .sheet(isPresented: $isAddSheetPresented) {
                AddReminderView(petId: petId, onReminderAdded: {
                    Task { await viewModel.loadReminders() }
                })
            }
        }
    }
    
    // MARK: - Row View
    
    private func reminderRow(_ reminder: CareReminder) -> some View {
        HStack(spacing: 12) {
            Button(action: {
                Task { await viewModel.toggleCompletion(reminder) }
            }) {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(reminder.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.borderless)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(reminder.title)
                    .font(.subheadline.weight(.semibold))
                    .strikethrough(reminder.isCompleted, color: .secondary)
                    .foregroundColor(reminder.isCompleted ? .secondary : .primary)
                
                if let notes = reminder.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(DateFormatterHelper.formatRelative(reminder.dueDate))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func deleteUpcoming(at offsets: IndexSet) {
        for index in offsets {
            let reminder = viewModel.upcomingReminders[index]
            Task { await viewModel.deleteReminder(reminder) }
        }
    }
    
    private func deleteCompleted(at offsets: IndexSet) {
        for index in offsets {
            let reminder = viewModel.completedReminders[index]
            Task { await viewModel.deleteReminder(reminder) }
        }
    }
}

