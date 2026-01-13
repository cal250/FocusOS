import UIKit
import SwiftUI

@MainActor
class HapticManager {
    static let shared = HapticManager()
    
    // Storing generators to reduce latency and improve reliability
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let notifications = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()
    
    private init() {
        print("HapticManager: Initializing generators...")
        impactLight.prepare()
        impactMedium.prepare()
        notifications.prepare()
        selection.prepare()
    }
    
    private var hapticsEnabled: Bool {
        // AppStorage key fallback
        if UserDefaults.standard.object(forKey: "hapticsEnabled") == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: "hapticsEnabled")
    }
    
    func playImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard hapticsEnabled else { return }
        print("HapticManager: Play Impact (\(style))")
        
        switch style {
        case .light:
            impactLight.impactOccurred()
            impactLight.prepare() // Prepare for next time
        case .medium:
            impactMedium.impactOccurred()
            impactMedium.prepare()
        default:
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    }
    
    func playNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard hapticsEnabled else { return }
        print("HapticManager: Play Notification (\(type))")
        notifications.notificationOccurred(type)
        notifications.prepare()
    }
    
    func playSelection() {
        guard hapticsEnabled else { return }
        print("HapticManager: Play Selection")
        selection.selectionChanged()
        selection.prepare()
    }
}
