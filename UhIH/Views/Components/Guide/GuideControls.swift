import SwiftUI

struct GuideControls: View {
    let isLastSection: Bool
    let showAlways: Bool
    let selectedHand: ContentViewModel.Handedness?
    let onShowAlwaysToggle: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: AppTheme.Layout.spacingMedium) {
            // Checkbox за "Always show"
            HStack(spacing: AppTheme.Layout.spacingSmall) {
                if selectedHand == .right {
                    Text(LocalizedStringKey("welcome.always_show"))
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    Image(systemName: showAlways ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .onTapGesture {
                            HapticManager.playSelection()
                            onShowAlwaysToggle()
                        }
                } else {
                    Image(systemName: showAlways ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .onTapGesture {
                            HapticManager.playSelection()
                            onShowAlwaysToggle()
                        }
                    Text(LocalizedStringKey("welcome.always_show"))
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            // Дугме за прескакање/завршетак
            Button(action: {
                if isLastSection {
                    HapticManager.playSuccess()
                } else {
                    HapticManager.playImpact(style: .medium)
                }
                onDismiss()
            }) {
                Text(isLastSection ?
                     LocalizedStringKey("welcome.got_it") :
                     LocalizedStringKey("welcome.skip"))
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(width: AppTheme.Layout.buttonWidthLarge, height: AppTheme.Layout.buttonHeight)
                    .background(isLastSection ?
                              AppTheme.Colors.buttonActive :
                              AppTheme.Colors.buttonInactive)
                    .cornerRadius(AppTheme.Layout.cornerRadiusMedium)
                    .shadow(radius: AppTheme.Shadows.small.radius,
                           x: AppTheme.Shadows.small.x,
                           y: AppTheme.Shadows.small.y)
            }
        }
        .padding(.horizontal, AppTheme.Layout.paddingStandard)
        .padding(.bottom, AppTheme.Layout.spacingLarge)
    }
}

#Preview {
    GuideControls(
        isLastSection: false,
        showAlways: true,
        selectedHand: .right,
        onShowAlwaysToggle: {},
        onDismiss: {}
    )
    .background(Color.black)
} 