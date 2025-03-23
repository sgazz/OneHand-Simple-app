import SwiftUI
import PhotosUI

struct WelcomeScreenView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Gornji deo (non-interactive)
                VStack(spacing: AppTheme.Layout.spacingLarge) {
                    // Naslov
                    Text("OneHand Simple app")
                        .font(AppTheme.Typography.titleLarge)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.Layout.paddingStandard)
                        .padding(.top, geometry.size.height * 0.1)
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                // Logo u centru
                ZStack {
                    Circle()
                        .fill(AppTheme.Gradients.primary)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    Image("OneHandLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Donji deo (interactive) - Green Thumb Zone
                VStack(spacing: AppTheme.Layout.spacingLarge) {
                    Text("Select your handedness")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(.bottom, AppTheme.Layout.spacingMedium)
                    
                    // Dugmad za izbor ruke
                    HStack(spacing: AppTheme.Layout.spacingMedium) {
                        HandSelectionButton(
                            title: "Left hand",
                            icon: "hand.point.left.fill",
                            isSelected: viewModel.selectedHand == .left,
                            action: { 
                                HapticManager.playSelection()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.selectedHand = .left
                                }
                            }
                        )
                        
                        HandSelectionButton(
                            title: "Right hand",
                            icon: "hand.point.right.fill",
                            isSelected: viewModel.selectedHand == .right,
                            action: { 
                                HapticManager.playSelection()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.selectedHand = .right
                                }
                            }
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Dugme za izbor slike
                    PhotosPicker(selection: $viewModel.selectedItems,
                               maxSelectionCount: 1,
                               matching: .images) {
                        Text("Choose Image")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.buttonText)
                            .frame(width: AppTheme.Layout.buttonWidthLarge, height: AppTheme.Layout.buttonHeight)
                            .background(AppTheme.Colors.buttonActive)
                            .cornerRadius(AppTheme.Layout.cornerRadiusMedium)
                    }
                    .disabled(viewModel.selectedHand == nil)
                    .opacity(viewModel.selectedHand == nil ? 0.5 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.selectedHand)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, AppTheme.Layout.paddingStandard)
                .padding(.bottom, geometry.size.height * 0.15) // 15% od dna
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct HandSelectionButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Layout.spacingSmall) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
            }
            .font(AppTheme.Typography.headline)
            .foregroundColor(AppTheme.Colors.buttonText)
            .frame(width: AppTheme.Layout.buttonWidthStandard, height: AppTheme.Layout.buttonHeight)
            .background(isSelected ? AppTheme.Colors.buttonActive : AppTheme.Colors.buttonInactive)
            .cornerRadius(AppTheme.Layout.cornerRadiusMedium)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.2), value: isSelected)
        }
    }
} 