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
    @ObservedObject private var variables = CleverTapVariables.shared
    @ObservedObject private var locationManager = CleverTapLocationManager.shared
    @ObservedObject private var diagnostics = CleverTapDiagnostics.shared
    @ObservedObject private var nativeDisplayManager = CleverTapNativeDisplayManager.shared
    
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
    
    // Privacy, offline and network reporting state
    @State private var isOptedOut: Bool = false
    @State private var isOfflineMode: Bool = false
    @State private var networkReportingEnabled: Bool = true
    
    // Feedback alerts
    @State private var purchasedItem: StoreItem? = nil
    @State private var showPurchaseAlert: Bool = false
    @State private var lastTransactionId: String = ""
    @State private var statusAlertMessage: String = ""
    @State private var showStatusAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // 1. CSE Testing Banner
                        testingBanner
                        
                        // 1b. CleverTap Live Connection & Targeting Identifiers
                        liveConnectionDiagnosticsCard
                        
                        // 2. Product Experiences & Remote Config Lab (CTVar)
                        remoteConfigLabSection
                        
                        // 3. OS Push Notifications Lab
                        pushNotificationLabSection
                        
                        // 4. In-App Notification Controls Lab
                        inAppControlsLabSection
                        
                        // 5. Custom Code In-App Templates Lab
                        customTemplatesLabSection
                        
                        // 6. App Inbox Testing Lab
                        appInboxLabSection
                        
                        // 6b. Native Display Testing Lab
                        nativeDisplayLabSection
                        
                        // 7. Care Store Purchases ("Charged" Event)
                        productsSection
                        
                        // 8. Payment Mode Selector
                        paymentModeSection
                        
                        // 9. Communication Preferences (CleverTap DND & Channels)
                        communicationPrefsSection
                        
                        // 10. User Profile Demographics & Multi-Values Lab
                        userProfileAttributesLabSection
                        
                        // 11. Custom Events & Data Types Lab
                        customEventsLabSection
                        
                        // 12. Geo-Location & Privacy Controls Lab
                        geoLocationAndPrivacyLabSection
                        
                        // 13. User Profile Switcher (onUserLogin testing)
                        userProfileSwitcherSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 60)
                }
                .scrollIndicators(.visible)
            }
            .inlineTitle("CleverTap Testing Lab")
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
            .recordScreenView("Care Store & Lab Screen")
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
    
    // MARK: - Live Connection & Targeting Identifiers
    
    private var liveConnectionDiagnosticsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("CleverTap Live Device Connection")
                    .font(.caption.bold())
                Spacer()
                Text("Region: \(CleverTapConfig.region)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.12))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 3) {
                Text("Device CleverTap ID (for Dashboard targeting):")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                Text(CleverTap.sharedInstance()?.profileGetID() ?? "Generating...")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.primary)
                    .textSelection(.enabled)
            }
            
            HStack(spacing: 6) {
                diagnosticChannelBadge(title: "In-App", active: diagnostics.inAppDeliveryState == .liveReceived)
                diagnosticChannelBadge(title: "Inbox", active: inboxManager.totalCount > 0)
                diagnosticChannelBadge(title: "Display", active: !CleverTapNativeDisplayManager.shared.activeDisplayUnits.isEmpty)
                diagnosticChannelBadge(title: "Geofence", active: locationManager.isGeofenceMonitoringActive)
            }
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    private func diagnosticChannelBadge(title: String, active: Bool) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(active ? Color.green : Color.gray.opacity(0.4))
                .frame(width: 6, height: 6)
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(active ? .primary : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .background(Color.appBackground)
        .cornerRadius(6)
    }
    
    // MARK: - Product Experiences & Remote Variables Lab (CTVar)
    
    private var remoteConfigLabSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.indigo)
                Text("Product Experiences & Remote Config")
                    .font(.headline)
            }
            
            Text("Define and control dynamic app variables (CTVar) from CleverTap Dashboard for real-time feature flags, text updates, and A/B tests without app store builds.")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // Variable Cards
            VStack(spacing: 8) {
                // 1. String Var
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("welcome_banner_text (String)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.secondary)
                        Text(variables.welcomeBannerText)
                            .font(.caption.bold())
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Text("String")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.indigo.opacity(0.12))
                        .foregroundColor(.indigo)
                        .cornerRadius(4)
                }
                .padding(10)
                .background(Color.appBackground)
                .cornerRadius(8)
                
                // 2. Boolean Var & Integer Var
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("enable_special_care_discount")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.secondary)
                        HStack(spacing: 4) {
                            Circle()
                                .fill(variables.enableSpecialCareDiscount ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            Text(variables.enableSpecialCareDiscount ? "TRUE (Enabled)" : "FALSE (Disabled)")
                                .font(.caption.bold())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.appBackground)
                    .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("care_discount_percentage")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.secondary)
                        Text("\(variables.careDiscountPercentage)% OFF")
                            .font(.caption.bold())
                            .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.appBackground)
                    .cornerRadius(8)
                }
                
                // 3. Dictionary Var
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("featured_category_config (Dictionary)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.secondary)
                        Text("Category: \(variables.featuredCategory) • Badge: \(variables.featuredCategoryBadge)")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Text("Dict")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.purple.opacity(0.12))
                        .foregroundColor(.purple)
                        .cornerRadius(4)
                }
                .padding(10)
                .background(Color.appBackground)
                .cornerRadius(8)
            }
            
            // Action Buttons
            HStack(spacing: 8) {
                Button(action: {
                    variables.syncVariables()
                    statusAlertMessage = "Dispatched syncVariables() to CleverTap Dashboard. Variable definitions are synced for remote configuration."
                    showStatusAlert = true
                }) {
                    HStack(spacing: 6) {
                        if variables.isSyncing {
                            ProgressView().scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                        Text("Sync to Dashboard")
                    }
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.indigo.opacity(0.15))
                    .foregroundColor(.indigo)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    variables.fetchVariables { success in
                        statusAlertMessage = success ? "Variables fetched successfully from CleverTap!" : "Variable fetch completed."
                        showStatusAlert = true
                    }
                }) {
                    HStack(spacing: 6) {
                        if variables.isFetching {
                            ProgressView().scaleEffect(0.8)
                        } else {
                            Image(systemName: "icloud.and.arrow.down")
                        }
                        Text("Fetch Variables")
                    }
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.teal.opacity(0.15))
                    .foregroundColor(.teal)
                    .cornerRadius(8)
                }
            }
            
            // Status footer with live vs baseline indicator
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Circle()
                        .fill(variables.hasLiveServerOverrides ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(variables.hasLiveServerOverrides ? "Live CleverTap Override Active ✅" : "Baseline Schema (No Live Campaign Overrides)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(variables.hasLiveServerOverrides ? .green : .orange)
                    Spacer()
                    Text("Sync: \(variables.lastSyncStatus)")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                
                Text("• Diagnostic: \(variables.probableCauseMessage)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(10)
            .background(Color.appBackground)
            .cornerRadius(8)
        }
        .padding(14)
        .background(Color.cardBackground)
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "wand.and.stars")
                    .foregroundColor(.purple)
                Text("Custom Code In-App Templates")
                    .font(.headline)
                Spacer()
                if customTemplates.deliveryCount > 0 {
                    Text("\(customTemplates.deliveryCount) Live Delivered")
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                }
            }
            
            Text("Visual template ('PetCare_Alert_Banner') and function ('PetCare_Haptic_Alert') only render when delivered live by CleverTap campaigns.")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // Live Status Card
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Live Delivery:")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(customTemplates.lastDeliveryTimestamp)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                
                Button(action: {
                    customTemplates.syncTemplatesWithDashboard()
                    statusAlertMessage = "Template schema dispatched to CleverTap Dashboard! Marketers can now select 'PetCare_Alert_Banner' in In-App campaigns."
                    showStatusAlert = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Sync Templates Schema to Dashboard")
                    }
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.purple.opacity(0.15))
                    .foregroundColor(.purple)
                    .cornerRadius(8)
                }
            }
            .padding(10)
            .background(Color.appBackground)
            .cornerRadius(8)
            
            // Probable Cause Diagnostics if none delivered
            if customTemplates.deliveryCount == 0 {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 11))
                            .foregroundColor(.orange)
                        Text("Delivery Diagnosis & Probable Causes")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    Text("• Dashboard: Create an In-App campaign on CleverTap and select 'Custom Code Template: PetCare_Alert_Banner'.\n• Trigger: Ensure the trigger event matches (e.g., App Launch or 'Care Feature Explored').\n• Queue: Verify in-apps are not suspended in the controls above.")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                }
                .padding(10)
                .background(Color.orange.opacity(0.06))
                .cornerRadius(8)
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
    
    // MARK: - Native Display Testing Lab
    
    private var nativeDisplayLabSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "rectangle.stack.badge.play.fill")
                    .foregroundColor(.cyan)
                Text("Native Display Units")
                    .font(.headline)
                Spacer()
                Text(nativeDisplayManager.activeDisplayUnits.isEmpty ? "0 Units" : "\(nativeDisplayManager.activeDisplayUnits.count) Live Units")
                    .font(.caption2.bold())
                    .foregroundColor(nativeDisplayManager.activeDisplayUnits.isEmpty ? .secondary : .green)
            }
            
            Text("Native Display allows delivering custom JSON/visual banner cards dynamically targeted to users on CleverTap Dashboard.")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if !nativeDisplayManager.activeDisplayUnits.isEmpty {
                VStack(spacing: 8) {
                    ForEach(nativeDisplayManager.activeDisplayUnits, id: \.unitID) { unit in
                        NativeDisplayCardView(unit: unit)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 11))
                            .foregroundColor(.orange)
                        Text("Delivery Diagnosis & Probable Causes")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    Text("• Dashboard: Create a Native Display campaign under Campaigns > Native Display.\n• Targeting: Ensure the segment includes this device's CleverTap ID.\n• Trigger: If set to trigger on an event, trigger that event from the lab below.")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                }
                .padding(10)
                .background(Color.appBackground)
                .cornerRadius(8)
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
    
    // MARK: - User Profile Demographics & Multi-Values Lab
    
    private var userProfileAttributesLabSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.text.rectangle.fill")
                    .foregroundColor(.indigo)
                Text("User Profile & Multi-Value Lab")
                    .font(.headline)
            }
            
            Text("Enrich profile with Predefined fields (DOB, Gender), Multi-Value arrays (Allergies), and Counters.")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // 1. Predefined Demographics Button
            Button(action: {
                // Creates DOB: 1994-06-15 (NSDate/Date object)
                var components = DateComponents()
                components.year = 1994
                components.month = 6
                components.day = 15
                let dob = Calendar.current.date(from: components) ?? Date()
                
                CleverTapProfile.pushRichDemographics(
                    name: "Jack Montana",
                    email: "jack.montana@pawpal.local",
                    phone: "+14155551234",
                    gender: "M",
                    dateOfBirth: dob,
                    photoUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb",
                    education: "Graduate",
                    married: "Y",
                    customerType: "Gold VIP"
                )
                statusAlertMessage = "Pushed Predefined Demographics (Name, Email, Phone, Gender: M, DOB: 1994, Education: Graduate, Photo)."
                showStatusAlert = true
            }) {
                HStack {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                    Text("Push Predefined Demographics (DOB, Gender, Phone)")
                    Spacer()
                    Image(systemName: "arrow.up.circle.fill").font(.caption)
                }
                .font(.caption.bold())
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color.indigo.opacity(0.12))
                .foregroundColor(.indigo)
                .cornerRadius(8)
            }
            
            // 2. Multi-Values Operations
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Button(action: {
                        CleverTapProfile.setMultiValues(["Grain-Free", "Hypoallergenic", "Low-Fat"], forKey: "Dietary Needs")
                        statusAlertMessage = "Set Multi-Values for 'Dietary Needs': [Grain-Free, Hypoallergenic, Low-Fat]."
                        showStatusAlert = true
                    }) {
                        Text("Set Multi: Dietary Needs")
                            .font(.system(size: 11, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.12))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        CleverTapProfile.addMultiValue("Raw-Diet", forKey: "Dietary Needs")
                        statusAlertMessage = "Added Multi-Value 'Raw-Diet' to 'Dietary Needs'."
                        showStatusAlert = true
                    }) {
                        Text("+ Add 'Raw-Diet'")
                            .font(.system(size: 11, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.12))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                    }
                }
                
                HStack(spacing: 8) {
                    Button(action: {
                        CleverTapProfile.removeMultiValue("Low-Fat", forKey: "Dietary Needs")
                        statusAlertMessage = "Removed Multi-Value 'Low-Fat' from 'Dietary Needs'."
                        showStatusAlert = true
                    }) {
                        Text("- Remove 'Low-Fat'")
                            .font(.system(size: 11, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.orange.opacity(0.12))
                            .foregroundColor(.orange)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        CleverTapProfile.removeValueForKey("Dietary Needs")
                        statusAlertMessage = "Removed entire profile key 'Dietary Needs'."
                        showStatusAlert = true
                    }) {
                        Text("Clear Key")
                            .font(.system(size: 11, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.12))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                    }
                }
            }
            
            // 3. Increment & Decrement Counters
            HStack(spacing: 8) {
                Button(action: {
                    CleverTapProfile.incrementProfileValue(key: "Care Score", by: 15)
                    statusAlertMessage = "Incremented 'Care Score' by +15 on user profile."
                    showStatusAlert = true
                }) {
                    Text("Score +15")
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    CleverTapProfile.decrementProfileValue(key: "Care Score", by: 5)
                    statusAlertMessage = "Decremented 'Care Score' by -5 on user profile."
                    showStatusAlert = true
                }) {
                    Text("Score -5")
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.pink.opacity(0.15))
                        .foregroundColor(.pink)
                        .cornerRadius(8)
                }
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Custom Events & Data Types Lab
    
    private var customEventsLabSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "bolt.badge.clock.fill")
                    .foregroundColor(.cyan)
                Text("Custom Events & Property Types Lab")
                    .font(.headline)
            }
            
            Text("Track events with String, Number, Boolean, and NSDate property types.")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                // Simple event without properties
                Button(action: {
                    CleverTapEvents.logEvent("Care Feature Explored")
                    statusAlertMessage = "Dispatched simple event: 'Care Feature Explored' (no properties)."
                    showStatusAlert = true
                }) {
                    Text("Simple Event")
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(Color.cyan.opacity(0.15))
                        .foregroundColor(.cyan)
                        .cornerRadius(8)
                }
                
                // Rich event with full property types
                Button(action: {
                    let eventProps: [String: Any] = [
                        "Feature Name": "Pet Wellness Scan",
                        "Completion Percentage": 100,
                        "Health Score": 96.5,
                        "Is Recommended Vaccinated": true,
                        "Next Appointment Date": Date().addingTimeInterval(86400 * 7), // NSDate 7 days ahead
                        "Tags": "wellness, routine, vet-verified"
                    ]
                    CleverTapEvents.logEvent("Wellness Assessment Completed", properties: eventProps)
                    statusAlertMessage = "Dispatched rich event: 'Wellness Assessment Completed' with String, Int, Double, Bool, and NSDate."
                    showStatusAlert = true
                }) {
                    Text("Rich Event (Props)")
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(Color.teal.opacity(0.15))
                        .foregroundColor(.teal)
                        .cornerRadius(8)
                }
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Geo-Location & Privacy Controls Lab
    
    private var geoLocationAndPrivacyLabSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(.blue)
                Text("Geo-Location, Geofencing & Privacy")
                    .font(.headline)
            }
            
            Text("Test CleverTap Geofence SDK region monitoring, location reporting, and privacy controls (GDPR opt-out, offline queuing, device network info).")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // 1. Geofence SDK Region Monitoring Section
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("CleverTap Geofence Monitoring")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(locationManager.isGeofenceMonitoringActive ? "Active" : "Stopped")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(locationManager.isGeofenceMonitoringActive ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
                        .foregroundColor(locationManager.isGeofenceMonitoringActive ? .green : .gray)
                        .cornerRadius(4)
                }
                
                HStack(spacing: 8) {
                    Button(action: {
                        locationManager.requestWhenInUsePermission()
                    }) {
                        Text("Req Location Perm")
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.12))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    
                    if locationManager.isGeofenceMonitoringActive {
                        Button(action: {
                            locationManager.stopGeofencing()
                            statusAlertMessage = "Stopped CleverTap Geofence region monitoring."
                            showStatusAlert = true
                        }) {
                            Text("Stop Geofence")
                                .font(.caption.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.red.opacity(0.12))
                                .foregroundColor(.red)
                                .cornerRadius(8)
                        }
                    } else {
                        Button(action: {
                            locationManager.startGeofencing()
                            statusAlertMessage = "Started CleverTap Geofence region monitoring."
                            showStatusAlert = true
                        }) {
                            Text("Start Geofence")
                                .font(.caption.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.green.opacity(0.12))
                                .foregroundColor(.green)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            Divider()
            
            // 2. Geo-Location Simulator Buttons
            VStack(alignment: .leading, spacing: 6) {
                Text("Simulate Location (CleverTap.setLocation)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Button(action: {
                        locationManager.recordManualLocation(latitude: 37.7749, longitude: -122.4194, label: "San Francisco")
                        statusAlertMessage = "Set CleverTap Location to San Francisco, CA (37.7749, -122.4194)."
                        showStatusAlert = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                            Text("San Francisco")
                        }
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.12))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        locationManager.recordManualLocation(latitude: 40.7128, longitude: -74.0060, label: "New York")
                        statusAlertMessage = "Set CleverTap Location to New York, NY (40.7128, -74.0060)."
                        showStatusAlert = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                            Text("New York")
                        }
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.purple.opacity(0.12))
                        .foregroundColor(.purple)
                        .cornerRadius(8)
                    }
                }
            }
            
            Divider()
            
            // 3. Privacy, Offline & Network Toggles
            VStack(spacing: 10) {
                Toggle(isOn: $isOptedOut) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("GDPR User Opt-Out")
                            .font(.caption.bold())
                        Text("setOptOut(\(isOptedOut ? "true" : "false")): Pauses event tracking.")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                .tint(.red)
                .onChange(of: isOptedOut) { newValue in
                    CleverTapManager.shared.setOptOut(enabled: newValue)
                }
                
                Toggle(isOn: $isOfflineMode) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Offline Queueing Mode")
                            .font(.caption.bold())
                        Text("setOffline(\(isOfflineMode ? "true" : "false")): Queues SDK events locally.")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                .tint(.orange)
                .onChange(of: isOfflineMode) { newValue in
                    CleverTapManager.shared.setOffline(offline: newValue)
                }
                
                Toggle(isOn: $networkReportingEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Network Info Reporting")
                            .font(.caption.bold())
                        Text("enableDeviceNetworkInfoReporting: IP, Carrier & WiFi.")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                .tint(.green)
                .onChange(of: networkReportingEnabled) { newValue in
                    CleverTapManager.shared.enableDeviceNetworkInfoReporting(enabled: newValue)
                }
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
