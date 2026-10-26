//
//  CleverTapNativeDisplayManager.swift
//  PawPal - CleverTap Integration Layer
//
//  NATIVE DISPLAY LAYER:
//  Manages CleverTap Native Display Units (DisplayUnitDelegate, impressions,
//  clicks, and in-app banner rendering).
//

import Foundation
import UIKit
import Combine
import CleverTapSDK

/// Central manager for CleverTap Native Display Units in PawPal.
@MainActor
class CleverTapNativeDisplayManager: NSObject, ObservableObject, CleverTapDisplayUnitDelegate {
    static let shared = CleverTapNativeDisplayManager()
    
    @Published var activeDisplayUnits: [CleverTapDisplayUnit] = []
    
    private var viewedUnitIds = Set<String>()
    
    private override init() {
        super.init()
    }
    
    /// Initializes Native Display delegate and retrieves any pre-cached display units.
    func initialize() {
        guard let cleverTap = CleverTap.sharedInstance() else { return }
        
        cleverTap.setDisplayUnitDelegate(self)
        NSLog("[CleverTap] DisplayUnitDelegate registered")
        
        // Load pre-cached display units from previous syncs/sessions
        if let cachedUnits = cleverTap.getAllDisplayUnits(), !cachedUnits.isEmpty {
            self.activeDisplayUnits = cachedUnits
            NSLog("[CleverTap] Loaded %ld pre-cached display units", cachedUnits.count)
        }
    }
    
    /// Records the Notification Viewed event when a Native Display unit appears on screen.
    func recordUnitViewed(_ unit: CleverTapDisplayUnit) {
        guard let unitId = unit.unitID, !viewedUnitIds.contains(unitId) else { return }
        viewedUnitIds.insert(unitId)
        
        CleverTap.sharedInstance()?.recordDisplayUnitViewedEvent(forID: unitId)
        NSLog("[CleverTap] recordDisplayUnitViewedEventForID: %@", unitId)
        
        let content = unit.contents?.first
        LiveInspectorViewModel.shared.log(
            title: "Native Display: Impression Recorded",
            category: .cleverTap,
            payload: [
                "unitId": unitId,
                "title": content?.title ?? "Untitled",
                "message": content?.message ?? "",
                "type": unit.type ?? "banner"
            ]
        )
    }
    
    /// Records the Notification Clicked event when a user taps a Native Display card.
    func recordUnitClicked(_ unit: CleverTapDisplayUnit) {
        guard let unitId = unit.unitID else { return }
        
        CleverTap.sharedInstance()?.recordDisplayUnitClickedEvent(forID: unitId)
        NSLog("[CleverTap] recordDisplayUnitClickedEventForID: %@", unitId)
        
        let content = unit.contents?.first
        let actionUrl = content?.actionUrl
        
        LiveInspectorViewModel.shared.log(
            title: "Native Display: Card Clicked",
            category: .cleverTap,
            payload: [
                "unitId": unitId,
                "title": content?.title ?? "Untitled",
                "actionUrl": actionUrl ?? "None"
            ]
        )
        
        // If an action URL exists, open it via system
        if let urlStr = actionUrl, let url = URL(string: urlStr) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - CleverTapDisplayUnitDelegate Callbacks
    
    nonisolated func displayUnitsUpdated(_ displayUnits: [CleverTapDisplayUnit]) {
        NSLog("[CleverTap] displayUnitsUpdated callback: received %ld units", displayUnits.count)
        
        Task { @MainActor in
            self.activeDisplayUnits = displayUnits
            
            for unit in displayUnits {
                let content = unit.contents?.first
                LiveInspectorViewModel.shared.log(
                    title: "Native Display: Units Updated",
                    category: .cleverTap,
                    payload: [
                        "unitId": unit.unitID ?? "",
                        "title": content?.title ?? "",
                        "message": content?.message ?? "",
                        "actionUrl": content?.actionUrl ?? "",
                        "bgColor": unit.bgColor ?? "#FFFFFF"
                    ]
                )
            }
        }
    }
}

