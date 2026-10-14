//
//  CleverTapManager.swift
//  PawPal - CleverTap Integration Layer
//
//  INITIALIZATION LAYER:
//  Manages the CleverTap iOS SDK lifecycle, auto-integration, and singleton access.
//

import Foundation
import UIKit
import CleverTapSDK

/// Central manager for the CleverTap iOS SDK instance.
class CleverTapManager {
    /// Shared singleton instance
    static let shared = CleverTapManager()
    
    private var isInitialized: Bool = false
    
    private init() {}
    
    /// Initializes the CleverTap iOS SDK with auto-integration and debug logging.
    /// Called once in application(didFinishLaunchingWithOptions:) during app launch.
    func initialize() {
        guard !isInitialized else { return }
        
        // 1. Enable DEBUG logging level for testing and troubleshooting in Xcode console
        CleverTap.setDebugLevel(CleverTapLogLevel.debug.rawValue)
        
        // 2. Set credentials (matches Info.plist and allows dynamic override)
        CleverTap.setCredentialsWithAccountID(CleverTapConfig.accountId, token: CleverTapConfig.token, region: CleverTapConfig.region)
        
        // 3. Automatically tracks App Launches, Session start/end, and enables in-apps
        CleverTap.autoIntegrate()
        
        isInitialized = true
        
        // 3. Log to our built-in Live Activity & Payload Inspector for CSE testing
        LiveInspectorViewModel.shared.log(
            title: "CleverTap SDK Initialized",
            category: .cleverTap,
            payload: [
                "sdkVersion": "CleverTap-iOS-SDK",
                "accountId": CleverTapConfig.accountId,
                "region": CleverTapConfig.region,
                "autoIntegrate": true,
                "debugLevel": "CleverTapLogLevel.debug"
            ]
        )
    }
    
    /// Safely provides the active CleverTap default shared instance.
    var instance: CleverTap? {
        return CleverTap.sharedInstance()
    }
}
