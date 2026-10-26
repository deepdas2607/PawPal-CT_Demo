//
//  CleverTapInboxManager.swift
//  PawPal - CleverTap Integration Layer
//
//  APP INBOX LAYER:
//  Manages the CleverTap App Inbox lifecycle, custom styling, message queries,
//  unread counter synchronization, and delegate callbacks.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import CleverTapSDK

/// Central manager for CleverTap App Inbox functionality in PawPal.
@MainActor
class CleverTapInboxManager: NSObject, ObservableObject, CleverTapInboxViewControllerDelegate {
    static let shared = CleverTapInboxManager()
    
    @Published var unreadCount: Int = 0
    @Published var totalCount: Int = 0
    @Published var messages: [CleverTapInboxMessage] = []
    @Published var isInboxInitialized: Bool = false
    
    private override init() {
        super.init()
    }
    
    /// Initializes the CleverTap App Inbox and sets up update observation.
    func initializeInbox() {
        guard let cleverTap = CleverTap.sharedInstance() else {
            NSLog("[CleverTap] App Inbox initialization failed: CleverTap instance is nil")
            return
        }
        
        cleverTap.initializeInbox(callback: { [weak self] success in
            NSLog("[CleverTap] initializeInbox callback: success = %d", success)
            Task { @MainActor [weak self] in
                self?.isInboxInitialized = success
                self?.refreshInbox()
            }
        })
        
        // Register callback for anytime an inbox message is updated, deleted, or read
        cleverTap.registerInboxUpdatedBlock { [weak self] in
            NSLog("[CleverTap] App Inbox updated block triggered")
            Task { @MainActor [weak self] in
                self?.refreshInbox()
            }
        }
    }
    
    /// Synchronizes current inbox messages and badge counters with CleverTap SDK.
    func refreshInbox() {
        guard let cleverTap = CleverTap.sharedInstance() else { return }
        
        self.unreadCount = cleverTap.getInboxMessageUnreadCount()
        self.totalCount = cleverTap.getInboxMessageCount()
        self.messages = cleverTap.getAllInboxMessages()
        
        NSLog("[CleverTap] App Inbox refreshed: %ld total, %ld unread", totalCount, unreadCount)
    }
    
    /// Builds the standard PawPal-themed style config for CleverTap App Inbox.
    func createStyleConfig() -> CleverTapInboxStyleConfig {
        let style = CleverTapInboxStyleConfig()
        style.title = "PawPal Care Inbox"
        style.backgroundColor = .systemBackground
        style.navigationBarTintColor = .systemOrange
        style.navigationTintColor = .white
        style.tabSelectedTextColor = .systemOrange
        style.tabSelectedBgColor = UIColor.systemOrange.withAlphaComponent(0.12)
        style.tabUnSelectedTextColor = .secondaryLabel
        style.firstTabTitle = "All Updates"
        style.noMessageViewText = "No notifications in your pet care inbox yet."
        style.noMessageViewTextColor = .secondaryLabel
        return style
    }
    
    /// Presents the official CleverTap Inbox ViewController configured with PawPal theme.
    func showCleverTapInbox() {
        guard let cleverTap = CleverTap.sharedInstance() else { return }
        
        let style = createStyleConfig()
        guard let inboxController = cleverTap.newInboxViewController(with: style, andDelegate: self) else {
            NSLog("[CleverTap] Failed to create CleverTapInboxViewController")
            return
        }
        
        let navController = UINavigationController(rootViewController: inboxController)
        navController.modalPresentationStyle = .pageSheet
        
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first,
              let rootVC = window.rootViewController else {
            NSLog("[CleverTap] Could not find window rootViewController")
            return
        }
        
        // Find topmost view controller that is NOT currently being dismissed
        var topVC = rootVC
        while let presented = topVC.presentedViewController, !presented.isBeingDismissed {
            topVC = presented
        }
        
        topVC.present(navController, animated: true)
        
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: Show App Inbox",
            category: .cleverTap,
            payload: [
                "style": "PawPal Orange Theme",
                "totalMessages": totalCount,
                "unreadMessages": unreadCount
            ]
        )
    }
    
    /// Marks an individual inbox message as read.
    func markAsRead(_ message: CleverTapInboxMessage) {
        guard let cleverTap = CleverTap.sharedInstance() else { return }
        cleverTap.markRead(message)
        refreshInbox()
        
        if let msgId = message.messageId {
            recordMessageViewed(messageId: msgId)
        }
    }
    
    /// Deletes an inbox message from the user's inbox.
    func deleteMessage(_ message: CleverTapInboxMessage) {
        guard let cleverTap = CleverTap.sharedInstance() else { return }
        cleverTap.delete(message)
        refreshInbox()
    }
    
    /// Records Notification Viewed event for an inbox message.
    func recordMessageViewed(messageId: String) {
        CleverTap.sharedInstance()?.recordInboxNotificationViewedEvent(forID: messageId)
        LiveInspectorViewModel.shared.log(
            title: "App Inbox: Message Viewed",
            category: .cleverTap,
            payload: ["messageId": messageId]
        )
    }
    
    /// Records Notification Clicked event for an inbox message.
    func recordMessageClicked(messageId: String) {
        CleverTap.sharedInstance()?.recordInboxNotificationClickedEvent(forID: messageId)
        LiveInspectorViewModel.shared.log(
            title: "App Inbox: Message Clicked",
            category: .cleverTap,
            payload: ["messageId": messageId]
        )
    }
    
    // MARK: - CleverTapInboxViewControllerDelegate Callbacks
    
    nonisolated func messageDidSelect(_ message: CleverTapInboxMessage, at index: Int32, withButtonIndex buttonIndex: Int32) {
        NSLog("[CleverTap] messageDidSelect: messageId = %@, index = %d, button = %d", message.messageId ?? "", index, buttonIndex)
        
        Task { @MainActor in
            LiveInspectorViewModel.shared.log(
                title: "App Inbox: Item Selected",
                category: .cleverTap,
                payload: [
                    "messageId": message.messageId ?? "",
                    "contentIndex": index,
                    "buttonIndex": buttonIndex,
                    "type": message.type ?? "simple"
                ]
            )
            CleverTapInboxManager.shared.refreshInbox()
        }
    }
    
    nonisolated func messageButtonTapped(withCustomExtras customExtras: [AnyHashable : Any]?) {
        NSLog("[CleverTap] messageButtonTappedWithCustomExtras: %@", customExtras ?? [:])
        
        Task { @MainActor in
            LiveInspectorViewModel.shared.log(
                title: "App Inbox: Button Tapped",
                category: .cleverTap,
                payload: customExtras ?? [:]
            )
        }
    }
}

/// SwiftUI wrapper to present the official CleverTap Inbox ViewController cleanly in a SwiftUI sheet.
struct CleverTapInboxSheet: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let manager = CleverTapInboxManager.shared
        let style = manager.createStyleConfig()
        
        if let cleverTap = CleverTap.sharedInstance(),
           let controller = cleverTap.newInboxViewController(with: style, andDelegate: manager) {
            let navController = UINavigationController(rootViewController: controller)
            return navController
        }
        
        let emptyVC = UIViewController()
        emptyVC.title = "Care Inbox"
        return UINavigationController(rootViewController: emptyVC)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

