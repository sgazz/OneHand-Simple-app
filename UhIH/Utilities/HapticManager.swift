import UIKit

enum HapticManager {
    static func playSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    static func playImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    static func playNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
} 