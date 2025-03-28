import SwiftUI
import PhotosUI

struct WelcomeScreenView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: ContentViewModel
    @ObservedObject var welcomeGuideViewModel: WelcomeGuideViewModel
    @StateObject private var animationManager = WelcomeAnimationManager()
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            if isLandscape {
                landscapeLayout(geometry: geometry)
            } else {
                portraitLayout(geometry: geometry)
            }
        }
        .onAppear {
            animationManager.animateEntrance()
        }
    }
    
    // MARK: - Layout Views
    private func landscapeLayout(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            WelcomeTitleView(
                opacity: animationManager.titleOpacity,
                topPadding: geometry.size.height * 0.05
            )
            
            Spacer()
            
            ZStack {
                VStack(spacing: AppTheme.Layout.spacingMedium) {
                    WelcomeLogoView(
                        size: 120,
                        opacity: animationManager.logoOpacity,
                        isAnimating: animationManager.isLogoAnimating,
                        rotation: animationManager.rotation,
                        pitchAngle: animationManager.pitchAngle,
                        rollAngle: animationManager.rollAngle,
                        onTap: animationManager.animateLogo
                    )
                    
                    Text(LocalizedStringKey("welcome_screen.select_hand"))
                        .font(.custom("SF Pro Display", size: 20, relativeTo: .headline))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
                .opacity(animationManager.logoOpacity)
                
                handSelectionButtons(geometry: geometry)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Spacer()
            
            chooseImageButton(geometry: geometry)
                .padding(.bottom, geometry.size.height * 0.05)
        }
    }
    
    private func portraitLayout(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            WelcomeTitleView(
                opacity: animationManager.titleOpacity,
                topPadding: geometry.size.height * 0.1
            )
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            let logoSize: CGFloat = geometry.size.height < 500 ? 120 : (geometry.size.width < 400 ? 160 : 200)
            WelcomeLogoView(
                size: logoSize,
                opacity: animationManager.logoOpacity,
                isAnimating: animationManager.isLogoAnimating,
                rotation: animationManager.rotation,
                pitchAngle: animationManager.pitchAngle,
                rollAngle: animationManager.rollAngle,
                onTap: animationManager.animateLogo
            )
            .onAppear {
                if !welcomeGuideViewModel.isShowingGuide {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        animationManager.animateLogo()
                    }
                }
            }
            
            Spacer()
                .frame(height: geometry.size.height < 500 ? 10 : AppTheme.Layout.spacingLarge)
            
            controlsSection(geometry: geometry)
        }
    }
    
    // MARK: - Helper Views
    private func handSelectionButtons(geometry: GeometryProxy) -> some View {
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
        .opacity(animationManager.controlsOpacity)
    }
    
    private func chooseImageButton(geometry: GeometryProxy) -> some View {
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
        .opacity(animationManager.controlsOpacity)
        .frame(maxWidth: .infinity, alignment: viewModel.selectedHand == nil ? .center : (viewModel.selectedHand == .left ? .leading : .trailing))
        .padding(.horizontal, geometry.size.width * 0.1)
    }
    
    private func controlsSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height < 500 ? AppTheme.Layout.spacingSmall : AppTheme.Layout.spacingLarge) {
            Text(LocalizedStringKey("welcome_screen.select_hand"))
                .font(.custom("SF Pro Display", size: 20, relativeTo: .headline))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .padding(.bottom, geometry.size.height < 500 ? 5 : AppTheme.Layout.spacingMedium)
            
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
            
            chooseImageButton(geometry: geometry)
        }
        .opacity(animationManager.controlsOpacity)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, AppTheme.Layout.paddingStandard)
        .padding(.bottom, geometry.size.height < 500 ? geometry.size.height * 0.08 : geometry.size.height * 0.15)
    }
} 