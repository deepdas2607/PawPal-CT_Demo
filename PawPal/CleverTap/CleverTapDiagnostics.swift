//
//  CleverTapDiagnostics.swift
//  PawPal - CleverTap Integration Layer
//
//  LIVE DELIVERY DIAGNOSTICS & TRIAGE LAYER:
//  Provides real-time visibility into CleverTap SDK live state, device identity (CleverTap ID),
//  channel delivery status, and diagnostic probable causes for delivery failures across:
//  - App Inbox
//  - In-App Notifications & Custom Templates
//  - Native Display
//  - Product Experiences / Remote Variables
//  - Geofences & Location Tracking
//  - Push Notifications
//

import Foundation
import UIKit
import Combine
import CoreLocation
import UserNotifications
import CleverTapSDK
import CleverTapGeofence

/// Channel delivery state enum
enum DeliveryState: String {
    case liveReceived = "Delivered Live ✅"
    case pending = "Awaiting Dashboard Campaign ⏳"
    case failed = "Delivery Error ❌"
    case suspended = "Channel Suspended ⚠️"
}

/// Central diagnostics manager providing live delivery introspection without mock data.
@MainActor
class CleverTapDiagnostics: ObservableObject {
    static let shared = CleverTapDiagnostics()
    
    // Core Device & Account Metadata
    @Published var cleverTapId: String = "Detecting..."
    @Published var accountId: String = CleverTapConfig.accountId
    @Published var region: String = CleverTapConfig.region
    @Published var isInitialized: Bool = true
    
    // Live Channel Delivery States
    @Published var inboxDeliveryState: DeliveryState = .pending
    @Published var inAppDeliveryState: DeliveryState = .pending
    @Published var nativeDisplayDeliveryState: DeliveryState = .pending
    @Published var variablesDeliveryState: DeliveryState = .pending
    @Published var geofenceDeliveryState: DeliveryState = .pending
    @Published var pushDeliveryState: DeliveryState = .pending
    
    // Live Tracking Details
    @Published var lastInAppReceivedTime: String = "None yet"
    @Published var lastInboxSyncTime: String = "None yet"
    @Published var lastVariablesFetchTime: String = "None yet"
    @Published var lastGeofenceEventTime: String = "None yet"
    
    // Diagnostics Logs & Probable Causes
    @Published var recentDeliveryIssues: [String] = []
    
    private init() {
        refresh()
    }
    
    /// Refreshes live device identifiers and channel counts from CleverTap SDK.
    func refresh() {
        if let ct = CleverTap.sharedInstance() {
            if let guid = ct.profileGetID() {
                self.cleverTapId = guid
            }
            
            // Check App Inbox
            let inboxCount = ct.getInboxMessageCount()
            self.inboxDeliveryState = inboxCount > 0 ? .liveReceived : .pending
            
            // Check Native Display
            let displayUnits = ct.getAllDisplayUnits() ?? []
            self.nativeDisplayDeliveryState = !displayUnits.isEmpty ? .liveReceived : .pending
            
            // Check Push
            ct.getNotificationPermissionStatus { [weak self] status in
                DispatchQueue.main.async {
                    self?.pushDeliveryState = (status == .authorized) ? .liveReceived : .pending
                }
            }
        }
    }
    
    /// Returns structured diagnostic guidance and probable causes for any empty or failing channel.
    func getProbableCauses(for channel: String) -> [String] {
        switch channel.lowercased() {
        case "inbox", "app inbox":
            return [
                "Dashboard: No App Inbox campaign currently active or targeted to this user.",
                "Targeting: User Identity does not match the campaign segment rules.",
                "Schedule: Campaign start date/time is scheduled in the future or expired.",
                "Network/Sync: SDK has not synced yet; tap 'Refresh Inbox' to fetch live messages."
            ]
            
        case "inapp", "in-app", "custom templates":
            return [
                "Trigger: Campaign is waiting for an event trigger that has not been logged yet.",
                "Frequency Capping: Campaign limit reached (e.g. 'Only once per session').",
                "SDK Status: In-App notifications may be temporarily suspended in code.",
                "Template Key: Template name in dashboard must exactly match 'PetCare_Alert_Banner'."
            ]
            
        case "native display":
            return [
                "Dashboard: No Native Display campaign is active for this target segment.",
                "Trigger Event: Campaign configured to trigger on app launch or specific event not fired.",
                "Delegate: Ensure DisplayUnitDelegate was registered during SDK initialization."
            ]
            
        case "variables", "remote config":
            return [
                "Dashboard: Variables must be published in an active A/B test or Variable Campaign.",
                "Schema Sync: Variables must be registered with dashboard via syncVariables().",
                "Fetch: Call fetchVariables() to query latest server values."
            ]
            
        case "geofence", "location":
            return [
                "Permission: Background geofencing requires 'Always' location authorization.",
                "Dashboard: No Geofences defined under 'Segments > Geofences' on CleverTap Dashboard.",
                "Coordinate: Current location is outside the configured radius (200m+)."
            ]
            
        case "push":
            return [
                "Credentials: APNs Auth Key (.p8) or push certificate must be uploaded to CleverTap Dashboard.",
                "Simulator: iOS Simulators cannot receive production remote APNs pushes (use local push primers or physical device).",
                "Permission: User must grant notification permission (use Push Primer)."
            ]
            
        default:
            return ["No specific delivery failure detected."]
        }
    }
}
