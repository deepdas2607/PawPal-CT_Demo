//
//  CareStoreView.swift
//  PawPal - View Layer
//
//  Comprehensive CleverTap Testing Hub & Care Store.
//  Enables Customer Success Engineers and developers to test:
//  - "Charged" purchase events with order details and items
//  - OS Push Notifications (Direct Prompt, Push Primer Alert & Half-Interstitial, Permission Status)
//  - In-App Controls (Suspend, Resume, Discard)
//  - Custom Code In-App Templates (Banner Template & Haptic Function)
//  - App Inbox (Official CleverTap Controller & Sync)
//  - User Identity switching (onUserLogin) and Communication Preferences (MSG-push, MSG-email, DND)
//

import SwiftUI
import UserNotifications
import CleverTapSDK

/// Care Store & CleverTap test bench view.
struct CareStoreView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var inspectorVM = LiveInspectorViewModel.shared
    @ObservedObject private var inboxManager = CleverTapInboxManager.shared
    @ObservedObject private var customTemplates = CleverTapCustomTemplates.shared
    
    // Store items available for purchase
    struct StoreItem: Identifiable {
        let id = UUID()
        let name: String
        let category: String
        let price: Double
        let iconName: String
        let description: String
    }
    
    let items: [StoreItem] = [
        StoreItem(
            name: "Wellness & Nutrition Pack",
            category: "Nutrition",
            price: 24.99,
            iconName: "leaf.fill",
            description: "Omega-3 salmon oil, probiotic chews, and multivitamin bites."
        ),
        StoreItem(
            name: "Annual Vet Care Pass",
            category: "Healthcare",
            price: 49.99,
            iconName: "cross.case.fill",
            description: "Unlimited virtual vet chats and annual vaccination reminder shield."
        ),
        StoreItem(
            name: "Dental Hygiene Chew Kit",
            category: "Supplies",
            price: 14.99,
            iconName: "sparkles",
            description: "30 enzymatic dental chews for plaque prevention and fresh breath."
        ),
        StoreItem(
            name: "Enrichment Toy & Play Bundle",
            category: "Toys",
            price: 19.99,
            iconName: "pawprint.fill",
            description: "Interactive puzzle feeder and durable braided rope toys."
        )
    ]
    
    @State private var selectedPaymentMode: String = "Apple Pay"
    let paymentModes = ["Apple Pay", "Credit Card", "Google Pay", "PayPal"]
    
    // Communication preferences state
    @State private var pushNotificationsEnabled: Bool = true
    @State private var emailMarketingEnabled: Bool = true
    @State private var phoneDndEnabled: Bool = false
    
    // Feedback alerts
    @State private var purchasedItem: StoreItem? = nil
    @State private var showPurchaseAlert: Bool = false
    @State private var lastTransactionId: String = ""
    @State private var statusAlertMessage: String = ""
    @State private var showStatusAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // 1. CSE Testing Banner
                    testingBanner
                    
                    // 2. OS Push Notifications Lab
                    pushNotificationLabSection
                    
                    // 3. In-App Notification Controls Lab
                    inAppControlsLabSection
                    
                    // 4. Custom Code In-App Templates Lab
                    customTemplatesLabSection
                    
                    // 5. App Inbox Testing Lab
                    appInboxLabSection
                    
                    // 6. Care Store Purchases ("Charged" Event)
                    productsSection
                    
                    // 7. Payment Mode Selector
                    paymentModeSection
                    
                    // 8. Communication Preferences (CleverTap DND & Channels)
                    communicationPrefsSection
                    
                    // 9. User Profile Switcher (onUserLogin testing)
                    userProfileSwitcherSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .inlineTitle("CleverTap Testing Lab")
            .toolbar {
                ToolbarItem(placement: .leadingPlacement) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .trailingPlacement) {
                    Button(action: {
                        inspectorVM.isInspectorPresented = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text.magnifyingglass")
                            Text("Inspector")
                        }
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .cornerRadius(6)
                    }
                }
            }
            .alert("Order Placed Successfully! 🎉", isPresented: $showPurchaseAlert) {
                Button("View in Inspector") {
                    inspectorVM.isInspectorPresented = true
                }
                Button("Done", role: .cancel) { }
            } message: {
                if let item = purchasedItem {
                    Text("Charged $\(String(format: "%.2f", item.price)) for '\(item.name)' via \(selectedPaymentMode).\n\nTransaction ID: \(lastTransactionId)\nSpecial CleverTap 'Charged' event dispatched.")
                }
            }
            .alert("CleverTap Status", isPresented: $showStatusAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(statusAlertMessage)
            }
        }
    }
    
    // MARK: - Banner
    
    private var testingBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 36))
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 3) {
                Text("Enterprise CleverTap Test Lab")
                    .font(.subheadline.bold())
                Text("Test real SDK interactions: Push Primers, In-App controls, Custom Code Templates, App Inbox, and 'Charged' purchase events live.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Push Notifications Lab
    
    private var pushNotificationLabSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "bell.badge.fill")
                    .foregroundColor(.orange)
                Text("OS Push Notifications & Primer")
                    .font(.headline)
            }
            
            VStack(spacing: 8) {
                Button(action: {
                    CleverTapManager.shared.promptPushPrimer(isAlert: true)
                }) {
                    HStack {
                        Image(systemName: "exclamationmark.bubble.fill")
                        Text("Prompt Push Primer (Alert Style)")
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption)
                    }
                    .font(.caption.bold())
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.opacity(0.12))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    CleverTapManager.shared.promptPushPrimer(isAlert: false)
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.forward")
                        Text("Prompt Push Primer (Half-Interstitial)")
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption)
                    }
                    .font(.caption.bold())
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.12))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                
                HStack(spacing: 8) {
                    Button(action: {
                        CleverTapManager.shared.promptForPushPermission(showFallbackSettings: true)
                    }) {
                        Text("Direct OS Prompt")
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.purple.opacity(0.12))
                            .foregroundColor(.purple)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        checkPermissionStatus()
                    }) {
                        Text("Check Status")
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.secondary.opacity(0.12))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - In-App Controls Lab
    
    private var inAppControlsLabSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.blue)
                Text("In-App Notification Controls")
                    .font(.headline)
            }
            
            HStack(spacing: 8) {
                Button(action: {
                    CleverTapManager.shared.suspendInAppNotifications()
                    statusAlertMessage = "In-App notifications suspended for current session."
                    showStatusAlert = true
                }) {
                    Text("Suspend")
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.yellow.opacity(0.18))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    CleverTapManager.shared.resumeInAppNotifications()
                    statusAlertMessage = "In-App notifications resumed."
                    showStatusAlert = true
                }) {
                    Text("Resume")
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.green.opacity(0.18))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    CleverTapManager.shared.discardInAppNotifications(dismissActive: true)
                    statusAlertMessage = "In-App queue discarded."
                    showStatusAlert = true
                }) {
                    Text("Discard")
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.18))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                }
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Custom Code In-App Templates Lab
    
    private var customTemplatesLabSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "wand.and.stars")
                    .foregroundColor(.purple)
                Text("Custom Code In-App Templates")
                    .font(.headline)
            }
            
            Text("Test visual templates (PetCare_Alert_Banner) and non-visual functions (PetCare_Haptic_Alert) registered with CleverTap.")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Button(action: {
                    dismiss()
                    customTemplates.simulateBanner()
                }) {
                    HStack {
                        Image(systemName: "viewfinder")
                        Text("Trigger Custom Banner Template")
                        Spacer()
                        Image(systemName: "play.fill").font(.caption2)
                    }
                    .font(.caption.bold())
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color.purple.opacity(0.12))
                    .foregroundColor(.purple)
                    .cornerRadius(8)
                }
                
                HStack(spacing: 8) {
                    Button(action: {
                        customTemplates.simulateHaptic()
                        statusAlertMessage = "Haptic turn alert function executed."
                        showStatusAlert = true
                    }) {
                        Text("Trigger Haptic Function")
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.blue.opacity(0.12))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        customTemplates.syncTemplatesWithDashboard()
                        statusAlertMessage = "Templates synced with CleverTap Dashboard!"
                        showStatusAlert = true
                    }) {
                        Text("Sync to Dashboard")
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.orange.opacity(0.12))
                            .foregroundColor(.orange)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - App Inbox Lab
    
    private var appInboxLabSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "tray.full.fill")
                    .foregroundColor(.green)
                Text("App Inbox Controls")
                    .font(.headline)
                Spacer()
                Text("\(inboxManager.unreadCount) unread")
                    .font(.caption2.bold())
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 8) {
                Button(action: {
                    inboxManager.showCleverTapInbox()
                }) {
                    Text("Launch Official CT Inbox")
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    inboxManager.refreshInbox()
                    statusAlertMessage = "App Inbox refreshed: \(inboxManager.totalCount) total, \(inboxManager.unreadCount) unread."
                    showStatusAlert = true
                }) {
                    Text("Sync Messages")
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.secondary.opacity(0.12))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Products List ("Charged" Event)
    
    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured Care Packages (Charged Event)")
                .font(.headline)
            
            ForEach(items) { item in
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: item.iconName)
                            .font(.title3)
                            .foregroundColor(.orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.subheadline.bold())
                        Text(item.description)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("$\(String(format: "%.2f", item.price))")
                            .font(.subheadline.bold())
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            simulatePurchase(item: item)
                        }) {
                            Text("Buy")
                                .font(.caption.bold())
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(12)
                .background(Color.cardBackground)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Payment Mode
    
    private var paymentModeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Payment Method (Sent in 'Charged' Event)")
                .font(.caption.bold())
                .foregroundColor(.secondary)
            
            Picker("Payment Method", selection: $selectedPaymentMode) {
                ForEach(paymentModes, id: \.self) { mode in
                    Text(mode).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Communication Preferences
    
    private var communicationPrefsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Communication Preferences (MSG-push / MSG-email / DND)")
                .font(.caption.bold())
                .foregroundColor(.secondary)
            
            Toggle("Push Notifications (MSG-push)", isOn: $pushNotificationsEnabled)
                .font(.subheadline)
                .onChange(of: pushNotificationsEnabled) { _ in
                    syncCommunicationPreferences()
                }
            
            Divider()
            
            Toggle("Marketing Emails (MSG-email)", isOn: $emailMarketingEnabled)
                .font(.subheadline)
                .onChange(of: emailMarketingEnabled) { _ in
                    syncCommunicationPreferences()
                }
            
            Divider()
            
            Toggle("Phone DND (MSG-dndPhone)", isOn: $phoneDndEnabled)
                .font(.subheadline)
                .onChange(of: phoneDndEnabled) { _ in
                    syncCommunicationPreferences()
                }
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - User Switcher
    
    private var userProfileSwitcherSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Simulate User Login (CleverTap onUserLogin)")
                .font(.caption.bold())
                .foregroundColor(.secondary)
            
            HStack(spacing: 10) {
                Button(action: {
                    CleverTapIdentity.onUserLogin(
                        userId: "user-sarah-jenkins",
                        name: "Sarah Jenkins",
                        email: "sarah.j@example.com",
                        phone: "+14155552671",
                        petName: "Luna",
                        species: "Dog",
                        breed: "Golden Retriever"
                    )
                    statusAlertMessage = "Logged in as Sarah Jenkins (Luna - Golden Retriever)."
                    showStatusAlert = true
                }) {
                    Text("Login as Sarah")
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.12))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    CleverTapIdentity.onUserLogin(
                        userId: "user-alex-chen",
                        name: "Alex Chen",
                        email: "alex.chen@example.com",
                        phone: "+14155559812",
                        petName: "Mochi",
                        species: "Cat",
                        breed: "Scottish Fold"
                    )
                    statusAlertMessage = "Logged in as Alex Chen (Mochi - Scottish Fold)."
                    showStatusAlert = true
                }) {
                    Text("Login as Alex")
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.purple.opacity(0.12))
                        .foregroundColor(.purple)
                        .cornerRadius(8)
                }
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Actions
    
    private func simulatePurchase(item: StoreItem) {
        let txnId = "TXN-\(Int.random(in: 100000...999999))"
        lastTransactionId = txnId
        purchasedItem = item
        
        // Trigger CleverTap Charged event through Bridge
        PawPalCleverTapBridge.onCarePurchase(
            itemName: item.name,
            itemCategory: item.category,
            amount: item.price,
            paymentMode: selectedPaymentMode
        )
        
        showPurchaseAlert = true
    }
    
    private func syncCommunicationPreferences() {
        CleverTapProfile.updateCommunicationPreferences(
            pushEnabled: pushNotificationsEnabled,
            emailEnabled: emailMarketingEnabled,
            dndPhone: phoneDndEnabled,
            dndEmail: !emailMarketingEnabled
        )
    }
    
    private func checkPermissionStatus() {
        CleverTapManager.shared.getNotificationPermissionStatus { status in
            let statusText: String
            switch status {
            case .authorized: statusText = "Authorized ✅"
            case .denied: statusText = "Denied ❌"
            case .notDetermined: statusText = "Not Determined ⏳"
            case .provisional: statusText = "Provisional ⚠️"
            case .ephemeral: statusText = "Ephemeral ⏱️"
            @unknown default: statusText = "Unknown"
            }
            statusAlertMessage = "Current Push Notification Permission Status: \(statusText)"
            showStatusAlert = true
        }
    }
}
