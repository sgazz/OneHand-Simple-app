import SwiftUI

enum AppTheme {
    // MARK: - Colors
    enum Colors {
        static let primary = Color(red: 0.4, green: 0.2, blue: 0.8)  // Glavna ljubičasta
        static let secondary = Color(red: 0.6, green: 0.3, blue: 0.9)  // Svetlija ljubičasta
        static let accent = Color.blue  // Akcentna boja za dugmad
        static let background = Color(red: 0.1, green: 0.1, blue: 0.2)  // Tamna pozadina
        
        // Button colors
        static let buttonActive = accent
        static let buttonInactive = Color.gray.opacity(0.3)
        static let buttonText = Color.white
        
        // Text colors
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.8)
        
        // Overlay colors
        static let overlay = Color.black.opacity(0.5)
        
        // Progress indicator colors
        static let progressActive = Color.white
        static let progressInactive = Color.white.opacity(0.3)
    }
    
    // MARK: - Layout
    enum Layout {
        // Corner radius
        static let cornerRadiusSmall: CGFloat = 12
        static let cornerRadiusMedium: CGFloat = 15
        static let cornerRadiusLarge: CGFloat = 20
        
        // Button sizes
        static let buttonHeight: CGFloat = 44
        static let buttonWidthStandard: CGFloat = 140
        static let buttonWidthLarge: CGFloat = 200
        
        // Spacing
        static let spacingSmall: CGFloat = 10
        static let spacingMedium: CGFloat = 20
        static let spacingLarge: CGFloat = 30
        
        // Padding
        static let paddingStandard: CGFloat = 25
        
        // Progress indicator
        static let progressIndicatorSize: CGFloat = 8
        static let progressIndicatorSpacing: CGFloat = 12
    }
    
    // MARK: - Typography
    enum Typography {
        static let titleLarge = Font.system(size: 32, weight: .bold)
        static let titleMedium = Font.system(size: 24, weight: .bold)
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 17, weight: .regular)
        static let caption = Font.system(size: 16, weight: .regular)
    }
    
    // MARK: - Shadows
    enum Shadows {
        static let small = Shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        static let medium = Shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        static let large = Shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 8)
    }
    
    // MARK: - Gradients
    enum Gradients {
        static let primary = LinearGradient(
            gradient: Gradient(colors: [Colors.primary, Colors.secondary]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Animations
    enum Animations {
        static let standard = Animation.easeInOut(duration: 0.3)
        static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    }
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
} 