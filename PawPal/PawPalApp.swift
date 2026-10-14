//
//  PawPalApp.swift
//  PawPal
//
//  Main application entry point.
//  Configures the AppDelegate to initialize the CleverTap iOS SDK on startup.
//

import SwiftUI
import UIKit
import CleverTapSDK

/// Application delegate integrating the CleverTap iOS SDK lifecycle methods.
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Initialize CleverTap SDK with autoIntegrate and debug mode
        CleverTapManager.shared.initialize()
        return true
    }
}

@main
struct PawPalApp: App {
    /// Adapts UIKit AppDelegate into SwiftUI App lifecycle
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
