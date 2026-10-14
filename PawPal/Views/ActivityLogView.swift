//
//  ActivityLogView.swift
//  PawPal - View Layer
//
//  Displays pet activity history and provides form to record new care events.
//

import SwiftUI

/// Screen for viewing care history and recording new activities.
struct ActivityLogView: View {
    let petId: String
    var showOnlyList: Bool = false
    var onActivityLogged: () -> Void
    
    @StateObject private var viewModel: ActivityLogViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(petId: String, showOnlyList: Bool = false, onActivityLogged: @escaping () -> Void) {
        self.petId = petId
        self.showOnlyList = showOnlyList
        self.onActivityLogged = onActivityLogged
        _viewModel = StateObject(wrappedValue: ActivityLogViewModel(petId: petId))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !showOnlyList {
                    // New Activity Form Box
                    newActivityForm
                        .padding()
                        .background(Color.cardBackground)
                    Divider()
                }
                
                // Activity History List
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading activities...")
                    Spacer()
                } else if viewModel.activities.isEmpty {
                    emptyActivitiesView
                } else {
                    activityListView
                }
            }
            .background(Color.appBackground)
            .inlineTitle(showOnlyList ? "Activity History" : "Log Care Activity")
            .toolbar {
                ToolbarItem(placement: .leadingPlacement) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadActivities()
            }
        }
    }
    
    // MARK: - New Activity Form
    
    private var newActivityForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Record an Action")
                .font(.headline)
            
            // Activity Type Grid
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ActivityType.allCases) { type in
                        Button(action: {
                            viewModel.selectedType = type
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: type.iconName)
                                Text(type.rawValue)
                            }
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedType == type ? Color.orange : Color.inputBackground)
                            .foregroundColor(viewModel.selectedType == type ? .white : .primary)
                            .cornerRadius(10)
                        }
                    }
                }
            }
            
            HStack(spacing: 16) {
                // Duration
                HStack {
                    Text("Duration:")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    TextField("30", text: $viewModel.durationMinutesString)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 55)
                    Text("min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Time
                DatePicker("", selection: $viewModel.activityDate, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
            }
            
            // Notes
            TextField("Optional notes (e.g. 2km walk, ate all food)", text: $viewModel.notes)
                .textFieldStyle(.plain)
                .padding(10)
                .background(Color.inputBackground)
                .cornerRadius(8)
                .font(.subheadline)
            
            // Save Button
            Button(action: {
                Task {
                    if await viewModel.submitActivity() {
                        onActivityLogged()
                        if !showOnlyList {
                            dismiss()
                        }
                    }
                }
            }) {
                HStack {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .tint(.white)
                            .padding(.trailing, 4)
                    }
                    Text(viewModel.isSubmitting ? "Logging..." : "Save Activity Record")
                        .font(.subheadline.bold())
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(viewModel.isSubmitting)
        }
    }
    
    // MARK: - History List
    
    private var activityListView: some View {
        List {
            Section(header: Text("Past Care Records")) {
                ForEach(viewModel.activities) { activity in
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.15))
                                .frame(width: 40, height: 40)
                            Image(systemName: activity.iconName)
                                .foregroundColor(.orange)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(activity.activityType)
                                .font(.subheadline.bold())
                            if let notes = activity.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 3) {
                            if let duration = activity.durationMinutes {
                                Text("\(duration) min")
                                    .font(.caption2.bold())
                                    .foregroundColor(.primary)
                            }
                            Text(DateFormatterHelper.formatRelative(activity.timestamp))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .appListStyle()
    }
    
    // MARK: - Empty State
    
    private var emptyActivitiesView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 44))
                .foregroundColor(.secondary)
            Text("No Activities Logged Yet")
                .font(.headline)
            Text("Record your pet's first walk, meal, or medication above.")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
    }
}
