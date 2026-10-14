//
//  CareStoreView.swift
//  PawPal - View Layer
//
//  Demo Care Store & CleverTap Testing Hub.
//  Enables Customer Success Engineers and developers to test:
//  - "Charged" purchase events with order details and items
//  - Profile attribute updates (MSG-push, MSG-email, DND settings)
//  - User identity switching via onUserLogin
//

import SwiftUI

/// Care Store & CleverTap test bench view.
struct CareStoreView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var inspectorVM = LiveInspectorViewModel.shared
    
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // 1. CSE Testing Banner
                    testingBanner
                    
                    // 2. Products Section
                    productsSection
                    
                    // 3. Payment Mode Selector
                    paymentModeSection
                    
                    // 4. Communication Preferences (CleverTap DND & Channels)
                    communicationPrefsSection
                    
                    // 5. User Profile Switcher (onUserLogin testing)
                    userProfileSwitcherSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .inlineTitle("Care Store & Lab")
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
        }
    }
    
    // MARK: - Banner
    
    private var testingBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "creditcard.circle.fill")
                .font(.system(size: 36))
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 3) {
                Text("CleverTap Purchase & Profile Lab")
                    .font(.subheadline.bold())
                Text("Tap any item below to trigger a CleverTap 'Charged' transaction with full items array and payment details.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Products List
    
    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured Care Packages")
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
}

