//
//  AppConfig.swift
//  PawPal - Utility Layer
//
//  Centralized application configuration settings.
//  Controls backend base URL and environment properties.
//

import Foundation

/// Central configuration for the PawPal app.
/// Change `baseURL` here if testing against a physical device on local Wi-Fi.
struct AppConfig {
    /// Development API base URL.
    /// In iOS Simulator, `http://127.0.0.1:8000` reaches the host Mac directly.
    /// If running on a physical iPhone on the same Wi-Fi, change this to your Mac's LAN IP (e.g. http://192.168.1.50:8000).
    static let baseURL: String = "http://127.0.0.1:8000"
    
    /// Default network timeout duration in seconds.
    static let requestTimeout: TimeInterval = 10.0
}

