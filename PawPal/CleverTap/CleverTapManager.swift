//
//  CleverTapManager.swift
//  PawPal - CleverTap Integration Layer
//
//  INITIALIZATION & DELEGATE LAYER:
//  Manages the CleverTap iOS SDK lifecycle, auto-integration, push permission primers,
//  In-App notification delegates, URL routing, and App Inbox/Native Display subsystems.
//

import Foundation
import UIKit
import UserNotifications
import CleverTapSDK

/// Central manager for the CleverTap iOS SDK instance and lifecycle in PawPal.
class CleverTapManager: NSObject, CleverTapInAppNotificationDelegate, CleverTapURLDelegate, CleverTapPushPermissionDelegate {
    /// Shared singleton instance
    static let shared = CleverTapManager()
    
    private var isInitialized: Bool = false
    
    private override init() {
        super.init()
    }
    
    /// Initializes the CleverTap iOS SDK with auto-integration, delegates, and subsystem hooks.
    /// Called once in application(_:didFinishLaunchingWithOptions:) during app launch.
    func initialize() {
        guard !isInitialized else { return }
        
        // 1. Register Custom Code In-App Templates BEFORE CleverTap instance initialization
        CleverTapCustomTemplates.shared.registerTemplates()
        
        // 2. Enable DEBUG logging level for testing and troubleshooting in Xcode console
        CleverTap.setDebugLevel(CleverTapLogLevel.debug.rawValue)
        
        // 3. Set credentials explicitly (matches Info.plist and allows config overrides)
        CleverTap.setCredentialsWithAccountID(CleverTapConfig.accountId, token: CleverTapConfig.token, region: CleverTapConfig.region)
        
        // 4. Automatically tracks App Launches, Session start/end, and enables in-apps
        CleverTap.autoIntegrate()
        
        // 5. Register In-App & URL delegates
        CleverTap.sharedInstance()?.setInAppNotificationDelegate(self)
        CleverTap.sharedInstance()?.setUrlDelegate(self)
        CleverTap.sharedInstance()?.setPushPermissionDelegate(self)
        
        // 6. Initialize App Inbox and Native Display subsystems
        CleverTapInboxManager.shared.initializeInbox()
        CleverTapNativeDisplayManager.shared.initialize()
        
        isInitialized = true
        
        // 7. Log to built-in Live Activity & Payload Inspector for CSE testing
        LiveInspectorViewModel.shared.log(
            title: "CleverTap SDK Initialized",
            category: .cleverTap,
            payload: [
                "sdkVersion": "CleverTap-iOS-SDK 7.8.2",
                "accountId": CleverTapConfig.accountId,
                "region": CleverTapConfig.region,
                "autoIntegrate": true,
                "debugLevel": "CleverTapLogLevel.debug",
                "features": [
                    "Push Notifications",
                    "Rich Push (UNNotificationCategory)",
                    "Push Primer (CTLocalInApp)",
                    "In-App Notifications & URL Delegate",
                    "Custom In-App Templates & Functions",
                    "App Inbox (Native & Custom)",
                    "Native Display Units"
                ]
            ]
        )
    }
    
    /// Safely provides the active CleverTap default shared instance.
    var instance: CleverTap? {
        return CleverTap.sharedInstance()
    }
    
    // MARK: - Push Notifications & Push Primer
    
    /// Requests push notification permission using CleverTap Local In-App Push Primer.
    /// - Parameter isAlert: If true, uses .ALERT style; if false, uses .HALF_INTERSTITIAL.
    func promptPushPrimer(isAlert: Bool = true) {
        let inAppType: CTLocalInAppType = isAlert ? .ALERT : .HALF_INTERSTITIAL
        
        let primer = CTLocalInApp(
            inAppType: inAppType,
            titleText: "PawPal Pet Care Alerts",
            messageText: "Enable notifications to receive timely medication reminders, feeding alerts, and vet appointments for your pet.",
            followDeviceOrientation: true,
            positiveBtnText: "Allow",
            negativeBtnText: "Not Now"
        )
        primer.setFallbackToSettings(true)
        primer.setBackgroundColor("#FFFFFF")
        primer.setTitleTextColor("#1E293B")
        primer.setMessageTextColor("#64748B")
        primer.setBtnBackgroundColor("#F97316")
        primer.setBtnTextColor("#FFFFFF")
        primer.setBtnBorderRadius("8")
        
        if let settings = primer.getSettings() as? [String: Any] {
            CleverTap.sharedInstance()?.promptPushPrimer(settings)
            
            LiveInspectorViewModel.shared.log(
                title: "CleverTap: promptPushPrimer",
                category: .cleverTap,
                payload: [
                    "type": isAlert ? "ALERT" : "HALF_INTERSTITIAL",
                    "title": "PawPal Pet Care Alerts",
                    "fallbackToSettings": true
                ]
            )
        }
    }
    
    /// Directly prompts the native iOS push permission dialog (with optional fallback to settings).
    func promptForPushPermission(showFallbackSettings: Bool = true) {
        CleverTap.sharedInstance()?.prompt(forPushPermission: showFallbackSettings)
        
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: promptForPushPermission",
            category: .cleverTap,
            payload: ["showFallbackSettings": showFallbackSettings]
        )
    }
    
    /// Queries the current push permission authorization status from CleverTap.
    func getNotificationPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        CleverTap.sharedInstance()?.getNotificationPermissionStatus(completionHandler: { status in
            DispatchQueue.main.async {
                completion(status)
            }
        })
    }
    
    // MARK: - In-App Notification Controls
    
    /// Temporarily suspends in-app notification popups during sensitive flows.
    func suspendInAppNotifications() {
        CleverTap.sharedInstance()?.suspendInAppNotifications()
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: suspendInAppNotifications",
            category: .cleverTap,
            payload: ["status": "Suspended for active session"]
        )
    }
    
    /// Resumes displaying in-app notifications and shows any queued messages.
    func resumeInAppNotifications() {
        CleverTap.sharedInstance()?.resumeInAppNotifications()
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: resumeInAppNotifications",
            category: .cleverTap,
            payload: ["status": "Resumed displaying in-apps"]
        )
    }
    
    /// Discards pending in-app notifications with optional dismissal of active in-app.
    func discardInAppNotifications(dismissActive: Bool = true) {
        CleverTap.sharedInstance()?.discard(inAppNotifications: dismissActive)
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: discardInAppNotifications",
            category: .cleverTap,
            payload: ["dismissActive": dismissActive]
        )
    }
    
    // MARK: - CleverTapPushPermissionDelegate
    
    func onPushPermissionResponse(_ accepted: Bool) {
        NSLog("[CleverTap] onPushPermissionResponse: accepted = %d", accepted)
        LiveInspectorViewModel.shared.log(
            title: "Push Permission: Response Received",
            category: .cleverTap,
            payload: [
                "permissionAccepted": accepted,
                "timestamp": DateFormatterHelper.toISOString(Date())
            ]
        )
    }
    
    // MARK: - CleverTapInAppNotificationDelegate Callbacks
    
    func shouldShowInAppNotification(withExtras extras: [AnyHashable : Any]!) -> Bool {
        NSLog("[CleverTap] shouldShowInAppNotificationWithExtras: %@", extras ?? [:])
        LiveInspectorViewModel.shared.log(
            title: "In-App: shouldShow Notification",
            category: .cleverTap,
            payload: extras ?? [:]
        )
        // Return true to allow rendering the in-app notification
        return true
    }
    
    func inAppNotificationDidShow(_ notification: [AnyHashable : Any]!) {
        NSLog("[CleverTap] inAppNotificationDidShow: %@", notification ?? [:])
        LiveInspectorViewModel.shared.log(
            title: "In-App: Notification Did Show",
            category: .cleverTap,
            payload: notification ?? [:]
        )
    }
    
    func inAppNotificationDismissed(withExtras extras: [AnyHashable : Any]!, andActionExtras actionExtras: [AnyHashable : Any]!) {
        NSLog("[CleverTap] inAppNotificationDismissed: extras = %@, actionExtras = %@", extras ?? [:], actionExtras ?? [:])
        LiveInspectorViewModel.shared.log(
            title: "In-App: Notification Dismissed",
            category: .cleverTap,
            payload: [
                "extras": extras ?? [:],
                "actionExtras": actionExtras ?? [:]
            ]
        )
    }
    
    func inAppNotificationButtonTapped(withCustomExtras customExtras: [AnyHashable : Any]!) {
        NSLog("[CleverTap] inAppNotificationButtonTapped: %@", customExtras ?? [:])
        LiveInspectorViewModel.shared.log(
            title: "In-App: Button Tapped",
            category: .cleverTap,
            payload: customExtras ?? [:]
        )
    }
    
    // MARK: - CleverTapURLDelegate Callbacks
    
    func shouldHandleCleverTap(_ url: URL?, for channel: CleverTapChannel) -> Bool {
        let channelName: String
        switch channel {
        case .pushNotification: channelName = "Push Notification"
        case .appInbox: channelName = "App Inbox"
        case .inAppNotification: channelName = "In-App Notification"
        @unknown default: channelName = "Unknown Channel"
        }
        
        NSLog("[CleverTap] shouldHandleCleverTap: %@ forChannel: %@", url?.absoluteString ?? "nil", channelName)
        
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: URL Clicked (\(channelName))",
            category: .cleverTap,
            payload: [
                "url": url?.absoluteString ?? "",
                "channel": channelName
            ]
        )
        
        // Return true to let the SDK open the URL, or false to handle it manually in app
        return true
    }
}
