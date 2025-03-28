import SwiftUI

struct WelcomeTitleView: View {
    // MARK: - Properties
    let opacity: Double
    let topPadding: CGFloat
    
    // MARK: - Body
    var body: some View {
        Text(LocalizedStringKey("welcome_screen.title"))
            .font(.custom("SF Pro Display", size: 34, relativeTo: .title))
            .foregroundColor(AppTheme.Colors.textPrimary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, AppTheme.Layout.paddingStandard)
            .padding(.top, topPadding)
            .opacity(opacity)
    }
}

#Preview {
    ZStack {
        Color.black
        
        WelcomeTitleView(
            opacity: 1.0,
            topPadding: 50
        )
    }
} 