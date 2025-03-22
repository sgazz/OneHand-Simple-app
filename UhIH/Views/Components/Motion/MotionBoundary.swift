import Foundation
import UIKit
import SwiftUI

struct MotionBoundary {
    // Granice pomeranja
    let minX: CGFloat
    let maxX: CGFloat
    let minY: CGFloat
    let maxY: CGFloat
    
    init(imageSize: CGSize, viewSize: CGSize, scale: CGFloat) {
        // Računamo stvarnu veličinu slike nakon skaliranja
        let scaledImageWidth = imageSize.width * scale
        let scaledImageHeight = imageSize.height * scale
        
        // Računamo koliko slika može da se pomeri u svakom smeru
        let maxOffsetX = min((scaledImageWidth - viewSize.width) / 2, viewSize.width / 2)
        let maxOffsetY = min((scaledImageHeight - viewSize.height) / 2, viewSize.height / 2)
        
        // Postavljamo granice pomeranja
        minX = -maxOffsetX
        maxX = maxOffsetX
        minY = -maxOffsetY
        maxY = maxOffsetY
    }
} 