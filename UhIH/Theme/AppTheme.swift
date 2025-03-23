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
    }
    
    // MARK: - Typography
    enum Typography {
        static let titleLarge = Font.system(size: 32, weight: .bold)
        static let titleMedium = Font.system(size: 24, weight: .bold)
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 17, weight: .regular)
        static let caption = Font.system(size: 16, weight: .regular)
    }
    
    // MARK: - Gradients
    enum Gradients {
        static let primary = LinearGradient(
            gradient: Gradient(colors: [Colors.primary, Colors.secondary]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
} 