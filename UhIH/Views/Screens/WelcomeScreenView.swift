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
    
    // Fade in animacije
    @State private var titleOpacity: Double = 0
    @State private var logoOpacity: Double = 0
    @State private var controlsOpacity: Double = 0
    
    private func animateEntrance() {
        withAnimation(.easeOut(duration: 0.8)) {
            titleOpacity = 1
        }
        
        withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
            logoOpacity = 1
        }
        
        withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
            controlsOpacity = 1
        }
    }
    
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
            let isLandscape = geometry.size.width > geometry.size.height
            
            if isLandscape {
                // Landscape layout
                VStack(spacing: 0) {
                    // Naslov na vrhu
                    Text(LocalizedStringKey("welcome_screen.title"))
                        .font(.custom("SF Pro Display", size: 34, relativeTo: .title))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.Layout.paddingStandard)
                        .padding(.top, geometry.size.height * 0.05)
                        .opacity(titleOpacity)
                    
                    Spacer()
                    
                    // Centralni deo sa logom i dugmadima
                    ZStack {
                        // Logo i tekst u centru
                        VStack(spacing: AppTheme.Layout.spacingMedium) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.Gradients.primary)
                                    .frame(width: 120, height: 120)
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
                                    .frame(width: 80, height: 80)
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
                            
                            Text(LocalizedStringKey("welcome_screen.select_hand"))
                                .font(.custom("SF Pro Display", size: 20, relativeTo: .headline))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                        }
                        .opacity(logoOpacity)
                        
                        // Dugmad za izbor ruke
                        HStack {
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
                            .padding(.leading, geometry.size.width * 0.1)
                            
                            Spacer()
                            
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
                            .padding(.trailing, geometry.size.width * 0.1)
                        }
                        .opacity(controlsOpacity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Spacer()
                    
                    // Choose Image dugme na dnu
                    PhotosPicker(selection: $viewModel.selectedItems,
                               maxSelectionCount: 1,
                               matching: .images) {
                        Text(LocalizedStringKey("welcome_screen.choose_image"))
                            .font(.custom("SF Pro Display", size: 17, relativeTo: .headline))
                            .foregroundColor(AppTheme.Colors.buttonText)
                            .frame(width: AppTheme.Layout.buttonWidthLarge,
                                   height: 44)
                            .background(AppTheme.Colors.buttonActive)
                            .cornerRadius(AppTheme.Layout.cornerRadiusMedium)
                            .shadow(radius: AppTheme.Shadows.small.radius,
                                   x: AppTheme.Shadows.small.x,
                                   y: AppTheme.Shadows.small.y)
                    }
                    .disabled(viewModel.selectedHand == nil)
                    .opacity(viewModel.selectedHand == nil ? 0.5 : 1.0)
                    .animation(AppTheme.Animations.spring, value: viewModel.selectedHand)
                    .opacity(controlsOpacity)
                    .frame(maxWidth: .infinity, alignment: viewModel.selectedHand == nil ? .center : (viewModel.selectedHand == .left ? .leading : .trailing))
                    .padding(.horizontal, geometry.size.width * 0.1)
                    .padding(.bottom, geometry.size.height * 0.05)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Portrait layout
                VStack(spacing: 0) {
                    // Gornji deo (non-interactive)
                    VStack(spacing: AppTheme.Layout.spacingLarge) {
                        // Naslov
                        Text(LocalizedStringKey("welcome_screen.title"))
                            .font(.custom("SF Pro Display", size: 34, relativeTo: .title))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Layout.paddingStandard)
                            .padding(.top, geometry.size.height * 0.1)
                            .opacity(titleOpacity)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    // Logo u centru
                    ZStack {
                        Circle()
                            .fill(AppTheme.Gradients.primary)
                            .frame(width: geometry.size.height < 500 ? 120 : (geometry.size.width < 400 ? 160 : 200),
                                   height: geometry.size.height < 500 ? 120 : (geometry.size.width < 400 ? 160 : 200))
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
                            .frame(width: geometry.size.height < 500 ? 80 : (geometry.size.width < 400 ? 110 : 140),
                                   height: geometry.size.height < 500 ? 80 : (geometry.size.width < 400 ? 110 : 140))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(isLogoAnimating ? 360 : 0))
                            .rotationEffect(.degrees(reverseRotation))
                            .rotation3DEffect(.degrees(pitchAngle), axis: (x: 1, y: 0, z: 0))
                            .rotation3DEffect(.degrees(rollAngle), axis: (x: 0, y: 1, z: 0))
                    }
                    .opacity(logoOpacity)
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
                        .frame(height: geometry.size.height < 500 ? 10 : AppTheme.Layout.spacingLarge)
                    
                    // Donji deo (interactive) - Green Thumb Zone
                    VStack(spacing: geometry.size.height < 500 ? AppTheme.Layout.spacingSmall : AppTheme.Layout.spacingLarge) {
                        Text(LocalizedStringKey("welcome_screen.select_hand"))
                            .font(.custom("SF Pro Display", size: 20, relativeTo: .headline))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .padding(.bottom, geometry.size.height < 500 ? 5 : AppTheme.Layout.spacingMedium)
                        
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
                                .font(.custom("SF Pro Display", size: 17, relativeTo: .headline))
                                .foregroundColor(AppTheme.Colors.buttonText)
                                .frame(width: geometry.size.width < 400 ? AppTheme.Layout.buttonWidthLarge : AppTheme.Layout.buttonWidthLarge * 1.3, 
                                       height: geometry.size.height < 500 ? 44 : AppTheme.Layout.buttonHeight)
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
                    .opacity(controlsOpacity)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, AppTheme.Layout.paddingStandard)
                    .padding(.bottom, geometry.size.height < 500 ? geometry.size.height * 0.08 : geometry.size.height * 0.15)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            animateEntrance()
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
                if icon.contains("left") {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .symbolEffect(.bounce, value: isSelected)
                    Text(title)
                } else {
                    Text(title)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .symbolEffect(.bounce, value: isSelected)
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
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusMedium)
                    .stroke(AppTheme.Colors.buttonActive, lineWidth: isSelected ? 2 : 0)
                    .opacity(isSelected ? 0.5 : 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
} 