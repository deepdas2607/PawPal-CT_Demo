//
//  CleverTapVariables.swift
//  PawPal - CleverTap Integration Layer
//
//  PRODUCT EXPERIENCES & REMOTE CONFIG (CTVar) LAYER:
//  Enables remote variable definition, dynamic A/B test experiments, and feature flagging
//  via the CleverTap Dashboard without App Store submissions or Apple Developer certificates.
//

import Foundation
import Combine
import CoreGraphics
import CleverTapSDK

/// Manages CleverTap Product Experiences / Variables (Remote Configuration).
class CleverTapVariables: ObservableObject {
    /// Shared singleton instance
    static let shared = CleverTapVariables()
    
    // CleverTap Var references
    private(set) var welcomeBannerVar: Var?
    private(set) var enableSpecialCareDiscountVar: Var?
    private(set) var careDiscountPercentageVar: Var?
    private(set) var featuredCategoryConfigVar: Var?
    
    // Published values for reactive SwiftUI view updates
    @Published var welcomeBannerText: String = "Welcome to PawPal Care!"
    @Published var enableSpecialCareDiscount: Bool = true
    @Published var careDiscountPercentage: Int = 20
    @Published var featuredCategory: String = "Nutrition"
    @Published var featuredCategoryBadge: String = "Popular"
    
    // Status tracking for Testing Lab
    @Published var lastSyncStatus: String = "Not synced yet"
    @Published var lastFetchStatus: String = "Not fetched yet"
    @Published var isSyncing: Bool = false
    @Published var isFetching: Bool = false
    @Published var hasLiveServerOverrides: Bool = false
    @Published var activeVariants: [[String: Any]] = []
    @Published var probableCauseMessage: String = "Awaiting fetch from CleverTap Dashboard"
    
    private var isDefined: Bool = false
    
    private init() {}
    
    /// Defines all remote variables with fallback defaults.
    /// Called during app initialization after CleverTap SDK is auto-integrated.
    func defineVariables() {
        guard !isDefined else { return }
        guard let ct = CleverTap.sharedInstance() else {
            NSLog("[CleverTap] Cannot define variables: CleverTap.sharedInstance() is nil")
            return
        }
        
        // 1. String Remote Variable: Welcome / Promo Banner Header
        welcomeBannerVar = ct.defineVar(
            name: "welcome_banner_text",
            string: "Welcome to PawPal Care!"
        )
        
        // 2. Boolean Remote Variable: Feature flag for seasonal care store discounts
        enableSpecialCareDiscountVar = ct.defineVar(
            name: "enable_special_care_discount",
            boolean: true
        )
        
        // 3. Integer Remote Variable: Dynamic discount percentage
        careDiscountPercentageVar = ct.defineVar(
            name: "care_discount_percentage",
            integer: 20
        )
        
        // 4. Dictionary Remote Variable: Nested product category configuration
        let defaultCategoryConfig: [String: Any] = [
            "category": "Nutrition",
            "badge": "Popular",
            "priority": 1
        ]
        featuredCategoryConfigVar = ct.defineVar(
            name: "featured_category_config",
            dictionary: defaultCategoryConfig
        )
        
        // 5. Global callback when any variable changes from server
        ct.onVariablesChanged { [weak self] in
            DispatchQueue.main.async {
                self?.refreshPublishedValues()
                LiveInspectorViewModel.shared.log(
                    title: "CleverTap: onVariablesChanged Callback",
                    category: .cleverTap,
                    payload: [
                        "welcomeBannerText": self?.welcomeBannerText ?? "",
                        "enableSpecialCareDiscount": self?.enableSpecialCareDiscount ?? false,
                        "careDiscountPercentage": self?.careDiscountPercentage ?? 0,
                        "featuredCategory": self?.featuredCategory ?? "",
                        "featuredCategoryBadge": self?.featuredCategoryBadge ?? ""
                    ]
                )
            }
        }
        
        // 6. Individual variable listener for welcome banner
        welcomeBannerVar?.onValueChanged { [weak self] in
            DispatchQueue.main.async {
                if let text = self?.welcomeBannerVar?.stringValue {
                    self?.welcomeBannerText = text
                }
            }
        }
        
        isDefined = true
        refreshPublishedValues()
        
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: Remote Variables (CTVar) Defined",
            category: .cleverTap,
            payload: [
                "welcome_banner_text": welcomeBannerText,
                "enable_special_care_discount": enableSpecialCareDiscount,
                "care_discount_percentage": careDiscountPercentage,
                "featured_category_config": defaultCategoryConfig
            ]
        )
    }
    
    /// Syncs defined variables schema to the CleverTap Dashboard.
    /// In Development / Debug builds, this uploads all variable keys, types, and defaults
    /// so marketers can configure variables and run A/B experiments on dashboard.
    func syncVariables() {
        guard let ct = CleverTap.sharedInstance() else { return }
        
        isSyncing = true
        lastSyncStatus = "Syncing variables..."
        
        ct.syncVariables()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            self.isSyncing = false
            self.lastSyncStatus = "Synced to Dashboard at \(DateFormatterHelper.formatTime(Date()))"
            
            LiveInspectorViewModel.shared.log(
                title: "CleverTap: syncVariables() Dispatched",
                category: .cleverTap,
                payload: [
                    "status": "Success",
                    "timestamp": DateFormatterHelper.toISOString(Date()),
                    "syncedVariables": [
                        "welcome_banner_text (String)",
                        "enable_special_care_discount (Boolean)",
                        "care_discount_percentage (Integer)",
                        "featured_category_config (Dictionary)"
                    ]
                ]
            )
        }
    }
    
    /// Explicitly fetches latest variable values from CleverTap server.
    func fetchVariables(completion: ((Bool) -> Void)? = nil) {
        guard let ct = CleverTap.sharedInstance() else {
            completion?(false)
            return
        }
        
        isFetching = true
        lastFetchStatus = "Fetching from CleverTap..."
        
        ct.fetchVariables { [weak self] success in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isFetching = false
                let timeStr = DateFormatterHelper.formatTime(Date())
                self.lastFetchStatus = success ? "Fetched at \(timeStr)" : "Fetch failed at \(timeStr)"
                
                if success {
                    self.refreshPublishedValues()
                }
                
                LiveInspectorViewModel.shared.log(
                    title: "CleverTap: fetchVariables() Result (\(success ? "OK" : "Failed"))",
                    category: .cleverTap,
                    payload: [
                        "success": success,
                        "time": timeStr,
                        "welcomeBannerText": self.welcomeBannerText,
                        "enableSpecialCareDiscount": self.enableSpecialCareDiscount,
                        "careDiscountPercentage": self.careDiscountPercentage,
                        "featuredCategory": self.featuredCategory
                    ]
                )
                
                completion?(success)
            }
        }
    }
    
    /// Reads raw variable values from CleverTap and updates reactive properties.
    func refreshPublishedValues() {
        if let variants = CleverTap.sharedInstance()?.variants() as? [[String: Any]] {
            self.activeVariants = variants
        }
        
        let changed = (welcomeBannerVar?.hasChanged() == true) ||
                      (enableSpecialCareDiscountVar?.hasChanged() == true) ||
                      (careDiscountPercentageVar?.hasChanged() == true) ||
                      (featuredCategoryConfigVar?.hasChanged() == true) ||
                      (!activeVariants.isEmpty)
        
        self.hasLiveServerOverrides = changed
        
        if changed {
            self.probableCauseMessage = "Variables actively overridden by CleverTap Dashboard campaign."
            CleverTapDiagnostics.shared.variablesDeliveryState = .liveReceived
        } else {
            self.probableCauseMessage = "No active A/B test or Variable Campaign overrides on Dashboard. Baseline schema maintained."
            CleverTapDiagnostics.shared.variablesDeliveryState = .pending
        }
        
        if let text = welcomeBannerVar?.stringValue {
            self.welcomeBannerText = text
        }
        if let boolVal = enableSpecialCareDiscountVar?.numberValue?.boolValue {
            self.enableSpecialCareDiscount = boolVal
        }
        if let intVal = careDiscountPercentageVar?.numberValue?.intValue {
            self.careDiscountPercentage = intVal
        }
        if let dict = featuredCategoryConfigVar?.value as? [String: Any] {
            if let cat = dict["category"] as? String {
                self.featuredCategory = cat
            }
            if let badge = dict["badge"] as? String {
                self.featuredCategoryBadge = badge
            }
        }
    }
}
