//
//  CareInboxView.swift
//  PawPal - View Layer
//
//  App Inbox screen displaying messages and notifications delivered from CleverTap.
//  Provides actions to view details, mark as read, delete, and launch the native CleverTap controller.
//

import SwiftUI
import CleverTapSDK

/// Screen displaying the user's App Inbox messages.
struct CareInboxView: View {
    @ObservedObject private var inboxManager = CleverTapInboxManager.shared
    @ObservedObject private var inspectorVM = LiveInspectorViewModel.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isOfficialInboxPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Official CleverTap Inbox Launcher Banner
                    officialInboxBanner
                    
                    // Messages List or Empty State
                    if inboxManager.messages.isEmpty {
                        emptyInboxView
                    } else {
                        messagesSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .inlineTitle("Care Inbox")
            .toolbar {
                ToolbarItem(placement: .leadingPlacement) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .trailingPlacement) {
                    Button(action: {
                        inboxManager.refreshInbox()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.subheadline)
                    }
                }
            }
            .sheet(isPresented: $isOfficialInboxPresented) {
                CleverTapInboxSheet()
            }
            .onAppear {
                inboxManager.refreshInbox()
            }
        }
    }
    
    // MARK: - Official CleverTap Inbox Launcher
    
    private var officialInboxBanner: some View {
        Button(action: {
            isOfficialInboxPresented = true
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.18))
                        .frame(width: 44, height: 44)
                    Image(systemName: "envelope.open.fill")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Launch Official CleverTap Inbox")
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    Text("Displays the full native CleverTap UI with tab filters, carousels, and media")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right.square.fill")
                    .font(.title3)
                    .foregroundColor(.orange)
            }
            .padding(12)
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Messages Section
    
    private var messagesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Messages (\(inboxManager.messages.count))")
                    .font(.headline)
                Spacer()
                if inboxManager.unreadCount > 0 {
                    Text("\(inboxManager.unreadCount) Unread")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .cornerRadius(6)
                }
            }
            
            ForEach(inboxManager.messages, id: \.messageId) { message in
                inboxMessageCard(message)
            }
        }
    }
    
    private func inboxMessageCard(_ message: CleverTapInboxMessage) -> some View {
        let content = message.content?.first
        let title = content?.title ?? "Notification"
        let body = content?.message ?? ""
        let isRead = message.isRead
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(isRead ? Color.clear : Color.orange)
                    .frame(width: 8, height: 8)
                
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let relativeDate = message.relativeDate {
                    Text(relativeDate)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            if !body.isEmpty {
                Text(body)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            HStack(spacing: 12) {
                Spacer()
                
                if !isRead {
                    Button(action: {
                        inboxManager.markAsRead(message)
                    }) {
                        Text("Mark Read")
                            .font(.caption2.bold())
                            .foregroundColor(.orange)
                    }
                }
                
                Button(action: {
                    inboxManager.deleteMessage(message)
                }) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.8))
                }
            }
        }
        .padding(12)
        .background(isRead ? Color.cardBackground : Color.orange.opacity(0.04))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isRead ? Color.clear : Color.orange.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            if let msgId = message.messageId {
                inboxManager.recordMessageViewed(messageId: msgId)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyInboxView: some View {
        VStack(spacing: 14) {
            Image(systemName: "tray.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
                .padding(.top, 30)
            
            Text("No Messages in Inbox")
                .font(.headline)
            
            Text("Campaign messages sent from the CleverTap dashboard to your App Inbox will appear here.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

