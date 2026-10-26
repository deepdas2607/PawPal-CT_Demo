//
//  CleverTapCustomTemplates.swift
//  PawPal - CleverTap Integration Layer
//
//  CUSTOM IN-APP TEMPLATES & FUNCTIONS:
//  Defines, registers, and presents custom code in-app templates and functions.
//  Matches enterprise architecture for custom in-app campaigns.
//

import Foundation
import UIKit
import Combine
import CleverTapSDK

/// Data model representing the custom code in-app template for SwiftUI rendering.
struct CustomInAppUiModel: Identifiable {
    let id = UUID()
    let templateName: String
    let title: String
    let message: String
    let ctaLabel: String
    let badgeTag: String
    let contextRef: CTTemplateContext?
}

/// Presenter for the visual "PetCare_Alert_Banner" custom in-app template.
class PetCareBannerPresenter: NSObject, CTTemplatePresenter {
    func onPresent(context: CTTemplateContext) {
        let title = context.string(name: "title") ?? "PawPal Care Notice"
        let message = context.string(name: "message") ?? "Your pet care schedule has an upcoming event."
        let ctaLabel = context.string(name: "cta_label") ?? "View Details"
        let badgeTag = context.string(name: "badge_tag") ?? "Care Notice"
        
        NSLog("[CleverTap] Custom Template onPresent: %@ - %@", title, message)
        
        // Notify CleverTap that template is displayed to the user
        context.presented()
        
        Task { @MainActor in
            CleverTapCustomTemplates.shared.activeCustomTemplate = CustomInAppUiModel(
                templateName: context.name(),
                title: title,
                message: message,
                ctaLabel: ctaLabel,
                badgeTag: badgeTag,
                contextRef: context
            )
        }
        
        LiveInspectorViewModel.shared.log(
            title: "Custom In-App: Template Presented",
            category: .cleverTap,
            payload: [
                "template": context.name(),
                "title": title,
                "message": message,
                "cta_label": ctaLabel,
                "badge_tag": badgeTag
            ]
        )
    }
    
    func onCloseClicked(context: CTTemplateContext) {
        NSLog("[CleverTap] Custom Template onCloseClicked: %@", context.name())
        context.dismissed()
        Task { @MainActor in
            if CleverTapCustomTemplates.shared.activeCustomTemplate?.templateName == context.name() {
                CleverTapCustomTemplates.shared.activeCustomTemplate = nil
            }
        }
    }
}

/// Presenter for the non-visual "PetCare_Haptic_Alert" custom function.
class PetCareHapticPresenter: NSObject, CTTemplatePresenter {
    func onPresent(context: CTTemplateContext) {
        let durationMs = context.number(name: "vibrate_duration_ms")?.intValue ?? 400
        NSLog("[CleverTap] Custom Function onPresent: Haptic Alert (%d ms)", durationMs)
        
        // Trigger device haptic feedback
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        
        // Non-visual functions notify presented & dismissed immediately
        context.presented()
        context.dismissed()
        
        LiveInspectorViewModel.shared.log(
            title: "Custom In-App: Haptic Function Executed",
            category: .cleverTap,
            payload: [
                "function": context.name(),
                "vibrate_duration_ms": durationMs
            ]
        )
    }
    
    func onCloseClicked(context: CTTemplateContext) {
        context.dismissed()
    }
}

/// Template producer defining all custom templates and functions for the CleverTap instance.
class PawPalTemplateProducer: NSObject, CTTemplateProducer {
    func defineTemplates(_ instanceConfig: CleverTapInstanceConfig) -> Set<CTCustomTemplate> {
        var templates = Set<CTCustomTemplate>()
        
        // 1. Visual Custom Code Template: Pet Care Alert Banner
        let bannerBuilder = CTInAppTemplateBuilder()
        bannerBuilder.setName("PetCare_Alert_Banner")
        bannerBuilder.setPresenter(CleverTapCustomTemplates.shared.bannerPresenter)
        bannerBuilder.addArgument("title", string: "PawPal Care Notice")
        bannerBuilder.addArgument("message", string: "Your pet care schedule has an upcoming event.")
        bannerBuilder.addArgument("cta_label", string: "View Details")
        bannerBuilder.addArgument("badge_tag", string: "Care Notice")
        bannerBuilder.addActionArgument("on_click_action")
        templates.insert(bannerBuilder.build())
        
        // 2. Non-Visual App Function: Pet Care Haptic Alert
        let functionBuilder = CTAppFunctionBuilder(isVisual: false)
        functionBuilder.setName("PetCare_Haptic_Alert")
        functionBuilder.setPresenter(CleverTapCustomTemplates.shared.hapticPresenter)
        functionBuilder.addArgument("vibrate_duration_ms", number: 400)
        templates.insert(functionBuilder.build())
        
        NSLog("[CleverTap] PawPalTemplateProducer: %ld templates defined", templates.count)
        return templates
    }
}

/// Central manager and observable state for Custom Code In-App Templates in PawPal.
@MainActor
class CleverTapCustomTemplates: ObservableObject {
    static let shared = CleverTapCustomTemplates()
    
    @Published var activeCustomTemplate: CustomInAppUiModel? = nil
    
    let bannerPresenter = PetCareBannerPresenter()
    let hapticPresenter = PetCareHapticPresenter()
    private let producer = PawPalTemplateProducer()
    
    private init() {}
    
    /// Registers custom template producer with CleverTap SDK before SDK initialization.
    func registerTemplates() {
        CTCustomTemplatesManager.register(producer)
        NSLog("[CleverTap] Custom In-App Templates successfully registered")
    }
    
    /// Syncs registered templates with the CleverTap dashboard.
    /// Should be called during development to make templates selectable in campaigns.
    func syncTemplatesWithDashboard() {
        CleverTap.sharedInstance()?.syncCustomTemplates()
        NSLog("[CleverTap] syncCustomTemplates invoked")
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: syncCustomTemplates",
            category: .cleverTap,
            payload: [
                "templates": ["PetCare_Alert_Banner", "PetCare_Haptic_Alert"],
                "status": "Synced with Dashboard"
            ]
        )
    }
    
    /// Dismisses the active custom template and releases the CleverTap in-app queue.
    func dismissActiveTemplate() {
        guard let model = activeCustomTemplate else { return }
        model.contextRef?.dismissed()
        activeCustomTemplate = nil
    }
    
    /// Triggers the action argument associated with the template and dismisses it.
    func triggerAction() {
        guard let model = activeCustomTemplate else { return }
        model.contextRef?.triggerAction(name: "on_click_action")
        model.contextRef?.dismissed()
        activeCustomTemplate = nil
    }
    
    /// Simulates template presentation for local interactive testing and demo purposes.
    func simulateBanner(
        title: String = "Upcoming Vet Vaccination",
        message: String = "Charlie's Rabies booster shot is due in 3 days. Book an appointment early!",
        ctaLabel: String = "Book Appointment",
        badgeTag: String = "Healthcare Alert"
    ) {
        activeCustomTemplate = CustomInAppUiModel(
            templateName: "PetCare_Alert_Banner",
            title: title,
            message: message,
            ctaLabel: ctaLabel,
            badgeTag: badgeTag,
            contextRef: nil
        )
        
        LiveInspectorViewModel.shared.log(
            title: "Custom In-App: Simulated Banner",
            category: .cleverTap,
            payload: [
                "template": "PetCare_Alert_Banner",
                "title": title,
                "message": message,
                "cta_label": ctaLabel,
                "badge_tag": badgeTag
            ]
        )
    }
    
    /// Simulates the haptic alert function.
    func simulateHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        LiveInspectorViewModel.shared.log(
            title: "Custom In-App: Simulated Haptic Alert",
            category: .cleverTap,
            payload: [
                "function": "PetCare_Haptic_Alert",
                "durationMs": 400
            ]
        )
    }
}
