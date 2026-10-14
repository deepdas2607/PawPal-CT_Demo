//
//  DashboardView.swift
//  PawPal - View Layer
//
//  Home dashboard displaying pet profile overview, today's activities,
//  upcoming care reminders, quick actions, and featured wellness tips.
//

import SwiftUI

/// Main home dashboard screen for PawPal.
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @ObservedObject private var inspectorVM = LiveInspectorViewModel.shared
    
    // Navigation / sheet states
    @State private var isLogActivityPresented: Bool = false
    @State private var isAddReminderPresented: Bool = false
    @State private var isProfilePresented: Bool = false
    @State private var isRemindersListPresented: Bool = false
    @State private var isTipsListPresented: Bool = false
    @State private var isActivityHistoryPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. Connection Error Notice (if backend is offline)
                    if let error = viewModel.errorMessage {
                        errorBannerView(error)
                    }
                    
                    // 2. Pet Hero Card
                    if let pet = viewModel.activePet {
                        petHeaderCard(pet)
                    }
                    
                    // 3. Quick Action Grid
                    quickActionsSection
                    
                    // 4. Today's Care Activity Section
                    todayActivitySection
                    
                    // 5. Upcoming Reminders Section
                    upcomingRemindersSection
                    
                    // 6. Featured Tips Section
                    featuredTipsSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .inlineTitle("PawPal")
            .toolbar {
                ToolbarItem(placement: .leadingPlacement) {
                    // Live Activity & Payload Inspector Button
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
                
                ToolbarItem(placement: .trailingPlacement) {
                    Button(action: {
                        isProfilePresented = true
                    }) {
                        Image(systemName: "person.crop.circle")
                            .font(.title3)
                            .foregroundColor(.orange)
                    }
                }
            }
            .refreshable {
                await viewModel.loadDashboardData()
            }
            .task {
                await viewModel.loadDashboardData()
            }
            // Sheets
            .sheet(isPresented: $inspectorVM.isInspectorPresented) {
                LiveInspectorView()
            }
            .sheet(isPresented: $isLogActivityPresented) {
                if let pet = viewModel.activePet {
                    ActivityLogView(petId: pet.id, onActivityLogged: {
                        Task { await viewModel.loadDashboardData() }
                    })
                }
            }
            .sheet(isPresented: $isAddReminderPresented) {
                if let pet = viewModel.activePet {
                    AddReminderView(petId: pet.id, onReminderAdded: {
                        Task { await viewModel.loadDashboardData() }
                    })
                }
            }
            .sheet(isPresented: $isProfilePresented) {
                if let pet = viewModel.activePet {
                    PetProfileView(pet: pet, onProfileUpdated: { updatedPet in
                        viewModel.activePet = updatedPet
                    })
                }
            }
            .sheet(isPresented: $isRemindersListPresented) {
                if let pet = viewModel.activePet {
                    RemindersView(petId: pet.id)
                }
            }
            .sheet(isPresented: $isTipsListPresented) {
                TipsView(petId: viewModel.activePet?.id)
            }
            .sheet(isPresented: $isActivityHistoryPresented) {
                if let pet = viewModel.activePet {
                    ActivityLogView(petId: pet.id, showOnlyList: true, onActivityLogged: {})
                }
            }
        }
    }
    
    // MARK: - Error Banner
    
    private func errorBannerView(_ error: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.title3)
                .foregroundColor(.red)
            VStack(alignment: .leading, spacing: 2) {
                Text("Backend Connection Issue")
                    .font(.footnote.bold())
                    .foregroundColor(.red)
                Text(error)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button("Retry") {
                Task { await viewModel.loadDashboardData() }
            }
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(6)
        }
        .padding(12)
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Pet Hero Card
    
    private func petHeaderCard(_ pet: Pet) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 64, height: 64)
                Image(systemName: pet.avatarSymbol)
                    .font(.system(size: 32))
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(pet.name)
                    .font(.title2.bold())
                
                HStack(spacing: 6) {
                    Text(pet.species)
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .cornerRadius(6)
                    
                    if let breed = pet.breed, !breed.isEmpty {
                        Text(breed)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                isProfilePresented = true
            }) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
    
    // MARK: - Quick Action Grid
    
    private var quickActionsSection: some View {
        HStack(spacing: 12) {
            actionButton(title: "Log Care", icon: "plus.circle.fill", color: .orange) {
                isLogActivityPresented = true
            }
            
            actionButton(title: "Reminder", icon: "bell.badge.fill", color: .blue) {
                isAddReminderPresented = true
            }
            
            actionButton(title: "Schedule", icon: "calendar", color: .purple) {
                isRemindersListPresented = true
            }
            
            actionButton(title: "Care Tips", icon: "lightbulb.fill", color: .green) {
                isTipsListPresented = true
            }
        }
    }
    
    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                Text(title)
                    .font(.caption2.weight(.medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Today's Care Activities
    
    private var todayActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Activities")
                    .font(.headline)
                Spacer()
                Button("View All") {
                    isActivityHistoryPresented = true
                }
                .font(.footnote.weight(.semibold))
                .foregroundColor(.orange)
            }
            
            if viewModel.todayActivities.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "figure.walk")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("No activities logged today yet")
                            .font(.subheadline.weight(.medium))
                        Text("Tap 'Log Care' to record walks, meals, or medications.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color.cardBackground)
                .cornerRadius(12)
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.todayActivities) { activity in
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange.opacity(0.12))
                                    .frame(width: 36, height: 36)
                                Image(systemName: activity.iconName)
                                    .foregroundColor(.orange)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(activity.activityType)
                                    .font(.subheadline.bold())
                                if let notes = activity.notes, !notes.isEmpty {
                                    Text(notes)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                if let duration = activity.durationMinutes {
                                    Text("\(duration) min")
                                        .font(.caption2.bold())
                                        .foregroundColor(.secondary)
                                }
                                Text(DateFormatterHelper.formatRelative(activity.timestamp))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(12)
                        .background(Color.cardBackground)
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    // MARK: - Upcoming Reminders
    
    private var upcomingRemindersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming Reminders")
                    .font(.headline)
                Spacer()
                Button("Manage") {
                    isRemindersListPresented = true
                }
                .font(.footnote.weight(.semibold))
                .foregroundColor(.orange)
            }
            
            if viewModel.upcomingReminders.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    Text("All reminders completed! Nothing pending.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color.cardBackground)
                .cornerRadius(12)
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.upcomingReminders) { reminder in
                        HStack(spacing: 12) {
                            Button(action: {
                                Task { await viewModel.toggleReminderCompletion(reminder) }
                            }) {
                                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundColor(reminder.isCompleted ? .green : .secondary)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(reminder.title)
                                    .font(.subheadline.weight(.semibold))
                                if let notes = reminder.notes, !notes.isEmpty {
                                    Text(notes)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            Text(DateFormatterHelper.formatRelative(reminder.dueDate))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(12)
                        .background(Color.cardBackground)
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    // MARK: - Featured Tips
    
    private var featuredTipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily Pet Care Tips")
                    .font(.headline)
                Spacer()
                Button("All Tips") {
                    isTipsListPresented = true
                }
                .font(.footnote.weight(.semibold))
                .foregroundColor(.orange)
            }
            
            VStack(spacing: 10) {
                ForEach(viewModel.featuredTips) { tip in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: tip.iconName)
                            .font(.title3)
                            .foregroundColor(.orange)
                            .padding(.top, 2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(tip.title)
                                    .font(.subheadline.bold())
                                Spacer()
                                Text(tip.category)
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                            Text(tip.content)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(12)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                }
            }
        }
    }
}
