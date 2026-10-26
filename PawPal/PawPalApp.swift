//
//  PawPalApp.swift
//  PawPal
//
//  Main application entry point.
//  Configures the AppDelegate to initialize CleverTap iOS SDK, APNs Push Notifications,
//  UNUserNotificationCenterDelegate, Rich Push categories, and In-App delegates.
//

import SwiftUI
import UIKit
import UserNotifications
import CleverTapSDK

/// Application delegate integrating the CleverTap iOS SDK and APNs lifecycle methods.
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, CleverTapPushNotificationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // 1. Initialize CleverTap SDK (registers custom templates, sets credentials, auto-integrates)
        CleverTapManager.shared.initialize()
        
        // 2. Set Push Notification delegate for custom extras callback
        CleverTap.sharedInstance()?.setPushNotificationDelegate(self)
        
        // 3. Register UNUserNotificationCenterDelegate
        UNUserNotificationCenter.current().delegate = self
        
        // 4. Configure Rich Push Notification Categories (Single Image, Carousel, Action Buttons)
        registerNotificationCategories()
        
        // 5. Register with Apple Push Notification Service (APNs)
        registerForPush()
        
        return true
    }
    
    // MARK: - Push Notifications Registration
    
    /// Requests push notification authorization and registers with APNs.
    func registerForPush() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert]) { granted, error in
            NSLog("[Push] APNs authorization granted: %d", granted)
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            if let error = error {
                NSLog("[Push] APNs authorization error: %@", error.localizedDescription)
            }
        }
    }
    
    /// Registers notification categories required for Rich Push notifications & CTNotificationContent.
    private func registerNotificationCategories() {
        let action1 = UNNotificationAction(identifier: "action_1", title: "Back", options: [])
        let action2 = UNNotificationAction(identifier: "action_2", title: "Next", options: [])
        let action3 = UNNotificationAction(identifier: "action_3", title: "View In App", options: [.foreground])
        
        let ctCategory = UNNotificationCategory(
            identifier: "CTNotification",
            actions: [action1, action2, action3],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([ctCategory])
        NSLog("[Push] CTNotification category registered with actions: action_1, action_2, action_3")
    }
    
    // MARK: - APNs Device Token Lifecycle
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Send device token to CleverTap
        CleverTap.sharedInstance()?.setPushToken(deviceToken)
        
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        NSLog("[Push] Registered with APNs device token: %@", tokenString)
        
        LiveInspectorViewModel.shared.log(
            title: "Push: APNs Token Registered",
            category: .cleverTap,
            payload: [
                "deviceToken": tokenString,
                "status": "Transmitted to CleverTap setPushToken"
            ]
        )
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("[Push] Failed to register for remote notifications: %@", error.localizedDescription)
        
        LiveInspectorViewModel.shared.log(
            title: "Push: APNs Registration Failed",
            category: .cleverTap,
            payload: [
                "error": error.localizedDescription,
                "note": "Remote notifications require a physical iOS device with valid APNs certificate/key"
            ]
        )
    }
    
    // MARK: - UNUserNotificationCenterDelegate Callbacks
    
    /// Called when a push notification is delivered while the app is in the FOREGROUND.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        NSLog("[Push] willPresent notification: %@", userInfo)
        
        // Record push impression on CleverTap
        CleverTap.sharedInstance()?.recordNotificationViewedEvent(withData: userInfo)
        
        LiveInspectorViewModel.shared.log(
            title: "Push: Foreground Notification Delivered",
            category: .cleverTap,
            payload: userInfo
        )
        
        completionHandler([.badge, .sound, .banner, .list])
    }
    
    /// Called when the user TAPS or interacts with an action on a push notification.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        NSLog("[Push] didReceive notification response: %@", userInfo)
        
        // If notification is from CleverTap, let CleverTap record click and handle deep links
        if CleverTap.sharedInstance()?.isCleverTapNotification(userInfo) == true {
            CleverTap.sharedInstance()?.handleNotification(withData: userInfo, openDeepLinksInForeground: true)
            CleverTap.sharedInstance()?.recordNotificationClickedEvent(withData: userInfo)
        }
        
        LiveInspectorViewModel.shared.log(
            title: "Push: Notification Interacted / Clicked",
            category: .cleverTap,
            payload: [
                "actionIdentifier": response.actionIdentifier,
                "userInfo": userInfo
            ]
        )
        
        completionHandler()
    }
    
    /// Background remote notification delivery.
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        NSLog("[Push] didReceiveRemoteNotification completionHandler: %@", userInfo)
        
        if CleverTap.sharedInstance()?.isCleverTapNotification(userInfo) == true {
            CleverTap.sharedInstance()?.handleNotification(withData: userInfo, openDeepLinksInForeground: false)
        }
        
        completionHandler(.noData)
    }
    
    // MARK: - CleverTapPushNotificationDelegate Callbacks
    
    func pushNotificationTapped(withCustomExtras customExtras: [AnyHashable : Any]!) {
        NSLog("[Push] pushNotificationTapped withCustomExtras: %@", customExtras ?? [:])
        
        LiveInspectorViewModel.shared.log(
            title: "Push: Custom Extras Tapped",
            category: .cleverTap,
            payload: customExtras ?? [:]
        )
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
