//
//  CleverTapSwiftUI.swift
//  PawPal - CleverTap Integration Layer
//
//  SWIFTUI SUPPORT LAYER:
//  Provides idiomatic SwiftUI ViewModifiers and View extensions for automatic screen view
//  tracking in CleverTap, mimicking `viewDidLoad` behavior in SwiftUI declarative views.
//

import SwiftUI
import CleverTapSDK

/// A SwiftUI ViewModifier that records a screen view event in CleverTap on appear.
public struct CTScreenViewModifier: ViewModifier {
    @State private var hasRecordedView: Bool = false
    let screenName: String
    let properties: [String: Any]?
    
    public init(screenName: String, properties: [String: Any]? = nil) {
        self.screenName = screenName
        self.properties = properties
    }
    
    public func body(content: Content) -> some View {
        content.onAppear {
            if !hasRecordedView {
                hasRecordedView = true
                
                // 1. Record screen event in CleverTap
                var eventProps = properties ?? [:]
                eventProps["Screen Name"] = screenName
                eventProps["Platform"] = "iOS SwiftUI"
                
                CleverTapEvents.logEvent(screenName, properties: eventProps)
                
                // 2. Mirror to Live Inspector
                LiveInspectorViewModel.shared.log(
                    title: "Screen Viewed: \(screenName)",
                    category: .cleverTap,
                    payload: eventProps
                )
            }
        }
    }
}

public extension View {
    /// Records a screen view event to CleverTap when this view appears for the first time.
    /// - Parameters:
    ///   - screenName: The human-readable name of the screen (e.g. "Dashboard Screen").
    ///   - properties: Optional contextual properties.
    func recordScreenView(_ screenName: String, properties: [String: Any]? = nil) -> some View {
        self.modifier(CTScreenViewModifier(screenName: screenName, properties: properties))
    }
}
