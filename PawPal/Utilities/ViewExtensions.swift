//
//  ViewExtensions.swift
//  PawPal - Utility Layer
//
//  View extensions providing cross-platform navigation and toolbar ergonomics.
//

import SwiftUI

extension View {
    /// Applies inline navigation title on iOS while remaining compatible with macOS.
    @ViewBuilder
    func inlineTitle(_ title: String) -> some View {
        #if os(iOS)
        self.navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        #else
        self.navigationTitle(title)
        #endif
    }
    
    /// Applies insetGrouped list style on iOS and automatic on macOS.
    @ViewBuilder
    func appListStyle() -> some View {
        #if os(iOS)
        self.listStyle(.insetGrouped)
        #else
        self.listStyle(.automatic)
        #endif
    }
}

extension ToolbarItemPlacement {
    /// Safe leading toolbar placement that maps to navigation on macOS and topBarLeading on iOS.
    static var leadingPlacement: ToolbarItemPlacement {
        #if os(iOS)
        return .topBarLeading
        #else
        return .navigation
        #endif
    }
    
    /// Safe trailing toolbar placement that maps to primaryAction on macOS and topBarTrailing on iOS.
    static var trailingPlacement: ToolbarItemPlacement {
        #if os(iOS)
        return .topBarTrailing
        #else
        return .primaryAction
        #endif
    }
}
