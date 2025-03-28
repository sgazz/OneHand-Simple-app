import SwiftUI

struct HandSelectionButton: View {
    // MARK: - Properties
    let title: LocalizedStringKey
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            withAnimation(AppTheme.Animations.spring) {
                isPressed = true
                action()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(AppTheme.Animations.spring) {
                    isPressed = false
                }
            }
        }) {
            buttonContent
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Private Views
    private var buttonContent: some View {
        HStack(spacing: AppTheme.Layout.spacingSmall) {
            if icon.contains("left") {
                iconView
                Text(title)
            } else {
                Text(title)
                iconView
            }
        }
        .font(AppTheme.Typography.headline)
        .foregroundColor(AppTheme.Colors.buttonText)
        .frame(width: AppTheme.Layout.buttonWidthStandard, height: AppTheme.Layout.buttonHeight)
        .background(isSelected ? AppTheme.Colors.buttonActive : AppTheme.Colors.buttonInactive)
        .cornerRadius(AppTheme.Layout.cornerRadiusMedium)
        .shadow(radius: isSelected ? AppTheme.Shadows.medium.radius : AppTheme.Shadows.small.radius,
               x: isSelected ? AppTheme.Shadows.medium.x : AppTheme.Shadows.small.x,
               y: isSelected ? AppTheme.Shadows.medium.y : AppTheme.Shadows.small.y)
        .scaleEffect(isSelected ? 1.05 : (isPressed ? 0.95 : 1.0))
        .overlay(selectionBorder)
    }
    
    private var iconView: some View {
        Image(systemName: icon)
            .font(.system(size: 20))
            .symbolEffect(.bounce, value: isSelected)
    }
    
    private var selectionBorder: some View {
        RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusMedium)
            .stroke(AppTheme.Colors.buttonActive, lineWidth: isSelected ? 2 : 0)
            .opacity(isSelected ? 0.5 : 0)
    }
}

#Preview {
    HStack {
        HandSelectionButton(
            title: "Left Hand",
            icon: "hand.point.left.fill",
            isSelected: true,
            action: {}
        )
        
        HandSelectionButton(
            title: "Right Hand",
            icon: "hand.point.right.fill",
            isSelected: false,
            action: {}
        )
    }
    .padding()
    .background(Color.black)
} 