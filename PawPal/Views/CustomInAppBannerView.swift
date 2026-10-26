//
//  CustomInAppBannerView.swift
//  PawPal - View Layer
//
//  Renders custom code in-app templates (e.g. PetCare_Alert_Banner).
//  Shows banner with title, message, badge tag, CTA button, and close action.
//

import SwiftUI

/// Banner view rendering an active CleverTap Custom Code In-App template.
struct CustomInAppBannerView: View {
    let model: CustomInAppUiModel
    var onDismiss: () -> Void
    var onAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                // Badge Tag
                HStack(spacing: 4) {
                    Image(systemName: "bell.badge.fill")
                        .font(.caption2)
                    Text(model.badgeTag)
                        .font(.caption2.bold())
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.orange.opacity(0.18))
                .foregroundColor(.orange)
                .cornerRadius(6)
                
                Spacer()
                
                // Close button
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary.opacity(0.7))
                }
            }
            
            // Title
            Text(model.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            // Message
            Text(model.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // CTA Action Button
            HStack {
                Spacer()
                Button(action: onAction) {
                    HStack(spacing: 6) {
                        Text(model.ctaLabel)
                            .font(.footnote.bold())
                        Image(systemName: "arrow.right")
                            .font(.caption2.bold())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.cardBackground)
                .shadow(color: Color.orange.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.orange.opacity(0.35), lineWidth: 1.5)
        )
    }
}
