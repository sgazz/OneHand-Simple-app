import UIKit

enum HapticManager {
    // MARK: - Basic Feedback
    
    /// Генерише хаптички одзив за селекцију (нпр. промена селекције, тап на дугме)
    static func playSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    /// Генерише хаптички одзив за удар са одређеним стилом
    /// - Parameter style: Стил удара (.light, .medium, .heavy, .soft, .rigid)
    static func playImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Генерише хаптички одзив за нотификацију
    /// - Parameter type: Тип нотификације (.success, .warning, .error)
    static func playNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    // MARK: - Complex Patterns
    
    /// Генерише хаптички одзив за зумирање
    /// - Parameter zoomIn: Да ли се зумира унутра (true) или напоље (false)
    static func playZoom(zoomIn: Bool) {
        playImpact(style: zoomIn ? .light : .soft)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            playImpact(style: zoomIn ? .rigid : .light)
        }
    }
    
    /// Генерише хаптички одзив за ротацију
    /// - Parameter intensity: Интензитет ротације (0.0 - 1.0)
    static func playRotation(intensity: CGFloat = 1.0) {
        let style: UIImpactFeedbackGenerator.FeedbackStyle = intensity > 0.7 ? .rigid : .soft
        playImpact(style: style)
    }
    
    /// Генерише хаптички одзив за превлачење
    /// - Parameter progress: Прогрес превлачења (0.0 - 1.0)
    static func playDrag(progress: CGFloat) {
        if progress == 0 {
            playImpact(style: .light)
        } else if progress >= 1.0 {
            playImpact(style: .heavy)
        } else if progress.truncatingRemainder(dividingBy: 0.2) < 0.01 {
            playImpact(style: .soft)
        }
    }
    
    /// Генерише хаптички одзив за анимацију
    /// - Parameter duration: Трајање анимације у секундама
    static func playAnimation(duration: TimeInterval = 0.5) {
        let steps = Int(duration / 0.1)
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(i) * 0.1) {
                playImpact(style: .soft)
            }
        }
    }
    
    // MARK: - Success/Error Patterns
    
    /// Генерише хаптички одзив за успех
    static func playSuccess() {
        playNotification(type: .success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            playImpact(style: .light)
        }
    }
    
    /// Генерише хаптички одзив за грешку
    static func playError() {
        playNotification(type: .error)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            playImpact(style: .heavy)
        }
    }
    
    /// Генерише хаптички одзив за упозорење
    static func playWarning() {
        playNotification(type: .warning)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            playImpact(style: .medium)
        }
    }
} 