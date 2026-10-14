//
//  ThemeColors.swift
//  PawPal - Utility Layer
//
//  Semantic color tokens providing consistent light/dark mode and cross-platform support.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

extension Color {
    #if canImport(UIKit)
    static let appBackground = Color(UIColor.systemGroupedBackground)
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let inputBackground = Color(UIColor.systemGray6)
    static let surfaceBackground = Color(UIColor.systemBackground)
    static let chipBackground = Color(UIColor.systemGray5)
    static let buttonDisabled = Color(UIColor.systemGray4)
    static let separatorColor = Color(UIColor.separator)
    #else
    static let appBackground = Color(white: 0.95)
    static let cardBackground = Color.white
    static let inputBackground = Color(white: 0.9)
    static let surfaceBackground = Color.white
    static let chipBackground = Color(white: 0.88)
    static let buttonDisabled = Color(white: 0.8)
    static let separatorColor = Color(white: 0.8)
    #endif
}

