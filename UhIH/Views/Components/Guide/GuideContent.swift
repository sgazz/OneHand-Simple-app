import SwiftUI

struct GuideContent: View {
    let title: String
    let content: String
    let slideOffset: CGFloat
    let opacity: Double
    let scale: CGFloat
    
    var body: some View {
        VStack(spacing: AppTheme.Layout.spacingMedium) {
            Text(title)
                .font(.custom("SF Pro Display", size: 22, relativeTo: .headline))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.bottom, AppTheme.Layout.spacingSmall)
            
            Text(content)
                .font(.custom("SF Pro Display", size: 17, relativeTo: .body))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, AppTheme.Layout.paddingStandard * 1.5)
        .padding(.vertical, AppTheme.Layout.spacingMedium)
        .frame(maxWidth: .infinity)
        .offset(x: slideOffset)
        .opacity(opacity)
        .scaleEffect(scale)
    }
}

#Preview {
    GuideContent(
        title: "Welcome",
        content: "This is a sample content for the guide.",
        slideOffset: 0,
        opacity: 1,
        scale: 1
    )
    .background(Color.black)
} 