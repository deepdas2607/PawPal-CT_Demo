//
//  NativeDisplayCardView.swift
//  PawPal - View Layer
//
//  Renders CleverTap Native Display Units natively in SwiftUI.
//  Handles automatic impression recording on appear and click tracking on tap.
//

import SwiftUI
import CleverTapSDK

/// View rendering an individual CleverTap Native Display Unit card.
struct NativeDisplayCardView: View {
    let unit: CleverTapDisplayUnit
    
    var body: some View {
        let content = unit.contents?.first
        let title = content?.title ?? "Featured Care Update"
        let message = content?.message ?? ""
        let actionUrl = content?.actionUrl
        
        Button(action: {
            CleverTapNativeDisplayManager.shared.recordUnitClicked(unit)
        }) {
            HStack(spacing: 12) {
                // Icon / Media indicator
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "sparkles")
                        .font(.title3)
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.subheadline.bold())
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text("Sponsored")
                            .font(.system(size: 8, weight: .bold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1.5)
                            .background(Color.secondary.opacity(0.12))
                            .foregroundColor(.secondary)
                            .cornerRadius(3)
                    }
                    
                    if !message.isEmpty {
                        Text(message)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                if actionUrl != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .onAppear {
            CleverTapNativeDisplayManager.shared.recordUnitViewed(unit)
        }
    }
}

