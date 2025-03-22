import Foundation
import UIKit
import SwiftUI

struct MotionBoundary {
    // Granice pomeranja
    let minX: CGFloat
    let maxX: CGFloat
    let minY: CGFloat
    let maxY: CGFloat
    
    // Bounce parametri
    let bounceStrength: CGFloat = 0.3  // Srednja jačina bounce-a
    let bounceDuration: TimeInterval = 0.3
    
    init(imageSize: CGSize, viewSize: CGSize, scale: CGFloat) {
        // Računamo granice na osnovu veličine slike i view-a
        let scaledImageWidth = imageSize.width * scale
        let scaledImageHeight = imageSize.height * scale
        
        // Dozvoljavamo pomeranje samo do ivica slike
        minX = min(0, viewSize.width - scaledImageWidth)
        maxX = max(0, scaledImageWidth - viewSize.width)
        minY = min(0, viewSize.height - scaledImageHeight)
        maxY = max(0, scaledImageHeight - viewSize.height)
    }
    
    func applyBounce(to position: CGPoint, velocity: CGPoint) -> (position: CGPoint, shouldBounce: Bool) {
        var newPosition = position
        var shouldBounce = false
        
        // Proveravamo X osu
        if position.x < minX {
            newPosition.x = minX
            shouldBounce = true
        } else if position.x > maxX {
            newPosition.x = maxX
            shouldBounce = true
        }
        
        // Proveravamo Y osu
        if position.y < minY {
            newPosition.y = minY
            shouldBounce = true
        } else if position.y > maxY {
            newPosition.y = maxY
            shouldBounce = true
        }
        
        return (newPosition, shouldBounce)
    }
    
    func createBounceAnimation(from currentPosition: CGPoint) -> (position: CGPoint, animation: Animation) {
        let bouncePosition = CGPoint(
            x: currentPosition.x + (currentPosition.x < minX ? bounceStrength : -bounceStrength),
            y: currentPosition.y + (currentPosition.y < minY ? bounceStrength : -bounceStrength)
        )
        
        return (bouncePosition, .spring(response: 0.3, dampingFraction: 0.6))
    }
} 