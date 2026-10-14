//
//  CleverTapConfig.swift
//  PawPal - CleverTap Integration Layer
//
//  CONFIGURATION LAYER:
//  Holds CleverTap project credentials, region codes, and analytics consent state.
//  Used by CleverTapManager to initialize and configure the CleverTap iOS SDK.
//

import Foundation

/// Central configuration for CleverTap iOS SDK.
struct CleverTapConfig {
    /// CleverTap Project ID / Account ID (from CleverTap Dashboard > Settings > Project)
    static var accountId: String = "587-878-Z97Z"
    
    /// CleverTap Account Token (from CleverTap Dashboard > Settings > Project)
    static var token: String = "bab-ab5"
    
    /// CleverTap Region Code (supported: "in1", "us1", "eu1", "sg1")
    static var region: String = "eu1"
    
    /// User privacy / GDPR tracking consent.
    /// When set to false, event recording and profile updates are safely paused.
    static var isAnalyticsConsentGiven: Bool = true
}

