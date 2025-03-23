import SwiftUI
import PhotosUI

struct WelcomeScreenView: View {
    @ObservedObject var viewModel: ContentViewModel
    @ObservedObject var welcomeGuideViewModel: WelcomeGuideViewModel
    @State private var isLogoAnimating = false
    @State private var reverseRotation = 0.0
    @State private var pitchAngle = 0.0
    @State private var rollAngle = 0.0
    @State private var selectedHandScale: CGFloat = 1.0
    @State private var isAnimating = false
    
    private func animateLogo() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // 1. Yaw rotacija u smeru kazaljke (360°)
        withAnimation(Animation.easeInOut(duration: 0.8).repeatCount(1, autoreverses: true)) {
            isLogoAnimating = true
        }
        
        // 2. Pitch nagib napred (50°)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(Animation.easeInOut(duration: 0.8).repeatCount(1, autoreverses: true)) {
                pitchAngle = 50
            }
            
            // 3. Pitch nagib nazad (-50°)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(Animation.easeInOut(duration: 0.8).repeatCount(1, autoreverses: true)) {
                    pitchAngle = -50
                }
                
                // 4. Pitch nagib početni položaj (0°)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    withAnimation(Animation.easeInOut(duration: 0.5)) {
                        pitchAngle = 0
                    }
                    
                    // 5. Roll nagib levo (-50°)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation(Animation.easeInOut(duration: 0.8).repeatCount(1, autoreverses: true)) {
                            rollAngle = -50
                        }
                        
                        // 6. Roll nagib desno (50°)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                            withAnimation(Animation.easeInOut(duration: 0.8).repeatCount(1, autoreverses: true)) {
                                rollAngle = 50
                            }
                            
                            // 7. Roll nagib početni položaj (0°)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                withAnimation(Animation.easeInOut(duration: 0.5)) {
                                    rollAngle = 0
                                }
                                
                                // 8. Yaw rotacija u suprotnom smeru (-360°)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    withAnimation(Animation.easeInOut(duration: 0.8).repeatCount(1, autoreverses: true)) {
                                        reverseRotation = -360
                                    }
                                    
                                    // Resetovanje svih vrednosti na kraju
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                        withAnimation(Animation.easeInOut(duration: 0.3)) {
                                            isLogoAnimating = false
                                            reverseRotation = 0
                                        }
                                        isAnimating = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Gornji deo (non-interactive)
                VStack(spacing: AppTheme.Layout.spacingLarge) {
                    // Naslov
                    Text(LocalizedStringKey("welcome_screen.title"))
                        .font(AppTheme.Typography.titleLarge)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.Layout.paddingStandard)
                        .padding(.top, geometry.size.height * 0.1)
                        .transition(.opacity)
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                // Logo u centru
                ZStack {
                    Circle()
                        .fill(AppTheme.Gradients.primary)
                        .frame(width: 160, height: 160)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        )
                        .shadow(radius: AppTheme.Shadows.medium.radius,
                               x: AppTheme.Shadows.medium.x,
                               y: AppTheme.Shadows.medium.y)
                    
                    Image("OneHandLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isLogoAnimating ? 360 : 0))
                        .rotationEffect(.degrees(reverseRotation))
                        .rotation3DEffect(.degrees(pitchAngle), axis: (x: 1, y: 0, z: 0))
                        .rotation3DEffect(.degrees(rollAngle), axis: (x: 0, y: 1, z: 0))
                }
                .onTapGesture {
                    HapticManager.playSelection()
                    animateLogo()
                }
                .onAppear {
                    if !welcomeGuideViewModel.isShowingGuide {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            animateLogo()
                        }
                    }
                }
                
                Spacer()
                
                // Donji deo (interactive) - Green Thumb Zone
                VStack(spacing: AppTheme.Layout.spacingLarge) {
                    Text(LocalizedStringKey("welcome_screen.select_hand"))
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(.bottom, AppTheme.Layout.spacingMedium)
                        .transition(.opacity)
                    
                    // Dugmad za izbor ruke
                    HStack(spacing: AppTheme.Layout.spacingMedium) {
                        HandSelectionButton(
                            title: LocalizedStringKey("welcome_screen.left_hand"),
                            icon: "hand.point.left.fill",
                            isSelected: viewModel.selectedHand == .left,
                            action: { 
                                withAnimation(AppTheme.Animations.spring) {
                                    viewModel.selectedHand = .left
                                    HapticManager.playSelection()
                                }
                            }
                        )
                        
                        HandSelectionButton(
                            title: LocalizedStringKey("welcome_screen.right_hand"),
                            icon: "hand.point.right.fill",
                            isSelected: viewModel.selectedHand == .right,
                            action: { 
                                withAnimation(AppTheme.Animations.spring) {
                                    viewModel.selectedHand = .right
                                    HapticManager.playSelection()
                                }
                            }
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Dugme za izbor slike
                    PhotosPicker(selection: $viewModel.selectedItems,
                               maxSelectionCount: 1,
                               matching: .images) {
                        Text(LocalizedStringKey("welcome_screen.choose_image"))
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.buttonText)
                            .frame(width: AppTheme.Layout.buttonWidthLarge, height: AppTheme.Layout.buttonHeight)
                            .background(AppTheme.Colors.buttonActive)
                            .cornerRadius(AppTheme.Layout.cornerRadiusMedium)
                            .shadow(radius: AppTheme.Shadows.small.radius,
                                   x: AppTheme.Shadows.small.x,
                                   y: AppTheme.Shadows.small.y)
                    }
                    .disabled(viewModel.selectedHand == nil)
                    .opacity(viewModel.selectedHand == nil ? 0.5 : 1.0)
                    .animation(AppTheme.Animations.spring, value: viewModel.selectedHand)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, AppTheme.Layout.paddingStandard)
                .padding(.bottom, geometry.size.height * 0.15)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct HandSelectionButton: View {
    let title: LocalizedStringKey
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
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
            HStack(spacing: AppTheme.Layout.spacingSmall) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .symbolEffect(.bounce, value: isSelected)
                Text(title)
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
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusMedium)
                    .stroke(AppTheme.Colors.buttonActive, lineWidth: isSelected ? 2 : 0)
                    .opacity(isSelected ? 0.5 : 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
} 