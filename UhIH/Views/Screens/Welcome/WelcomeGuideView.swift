import SwiftUI

struct WelcomeGuideView: View {
    @ObservedObject var viewModel: WelcomeGuideViewModel
    @StateObject private var animationManager = GuideAnimationManager()
    @State private var currentSectionIndex = 0
    
    var body: some View {
        if viewModel.isShowingGuide {
            GeometryReader { geometry in
                let isLandscape = geometry.size.width > geometry.size.height
                
                ZStack {
                    AppTheme.Colors.overlay
                        .edgesIgnoringSafeArea(.all)
                    
                    if isLandscape {
                        landscapeLayout(geometry: geometry)
                    } else {
                        portraitLayout(geometry: geometry)
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            animationManager.handleDragGesture(value: value)
                        }
                        .onEnded { value in
                            animationManager.handleDragEnd(
                                value: value,
                                currentIndex: currentSectionIndex,
                                totalSections: WelcomeGuideSection.count
                            ) { index, direction in
                                navigateToSection(index, direction: direction)
                            }
                        }
                )
            }
            .transition(.opacity)
            .onAppear {
                HapticManager.playAnimation(duration: 0.3)
            }
        }
    }
    
    // MARK: - Layout Views
    private func landscapeLayout(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Text(LocalizedStringKey("welcome.title"))
                .font(AppTheme.Typography.titleMedium)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, AppTheme.Layout.spacingLarge)
                .padding(.bottom, AppTheme.Layout.spacingMedium)
                .frame(maxWidth: .infinity)
            
            HStack(spacing: 0) {
                if viewModel.selectedHand == .right {
                    mainContent()
                        .frame(width: geometry.size.width * 0.6)
                    
                    controlsSection
                        .frame(width: geometry.size.width * 0.4)
                } else {
                    controlsSection
                        .frame(width: geometry.size.width * 0.4)
                    
                    mainContent()
                        .frame(width: geometry.size.width * 0.6)
                }
            }
        }
        .frame(width: geometry.size.width * 0.95, height: geometry.size.height * 0.8)
        .background(AppTheme.Gradients.primary)
        .cornerRadius(AppTheme.Layout.cornerRadiusLarge)
        .shadow(radius: AppTheme.Shadows.large.radius,
               x: AppTheme.Shadows.large.x,
               y: AppTheme.Shadows.large.y)
    }
    
    private func portraitLayout(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Text(LocalizedStringKey("welcome.title"))
                .font(AppTheme.Typography.titleMedium)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, AppTheme.Layout.spacingLarge)
                .padding(.bottom, AppTheme.Layout.spacingMedium)
                .padding(.horizontal, AppTheme.Layout.paddingStandard)
            
            if let currentSection = WelcomeGuideSection.section(at: currentSectionIndex) {
                mainContent(section: currentSection)
            }
            
            Spacer()
            
            controlsSection
        }
        .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 480 : 320,
               height: UIDevice.current.userInterfaceIdiom == .pad ? 600 : 400)
        .background(AppTheme.Gradients.primary)
        .cornerRadius(AppTheme.Layout.cornerRadiusLarge)
        .shadow(radius: AppTheme.Shadows.large.radius,
               x: AppTheme.Shadows.large.x,
               y: AppTheme.Shadows.large.y)
    }
    
    // MARK: - Content Views
    private func mainContent(section: WelcomeGuideSection? = nil) -> some View {
        let currentSection = section ?? WelcomeGuideSection.section(at: currentSectionIndex) ?? WelcomeGuideSection.sections[0]
        
        return VStack {
            GuideContent(
                title: currentSection.title,
                content: currentSection.content,
                slideOffset: animationManager.slideOffset,
                opacity: animationManager.opacity,
                scale: animationManager.scale
            )
            
            GuideProgressIndicator(
                currentIndex: currentSectionIndex,
                totalSections: WelcomeGuideSection.count
            ) { index in
                navigateToSection(index, direction: index < currentSectionIndex ? .right : .left)
            }
        }
    }
    
    private var controlsSection: some View {
        GuideControls(
            isLastSection: currentSectionIndex == WelcomeGuideSection.count - 1,
            showAlways: viewModel.showAlways,
            selectedHand: viewModel.selectedHand,
            onShowAlwaysToggle: { viewModel.showAlways.toggle() },
            onDismiss: viewModel.dismissGuide
        )
    }
    
    // MARK: - Navigation
    private func navigateToSection(_ index: Int, direction: NavigationDirection) {
        guard index >= 0 && index < WelcomeGuideSection.count else { return }
        
        // Различити хаптички одзиви за различите ситуације
        if index == WelcomeGuideSection.count - 1 {
            // Последња секција
            HapticManager.playSuccess()
        } else if index == 0 && direction == .right {
            // Враћање на прву секцију
            HapticManager.playImpact(style: .rigid)
        } else {
            // Стандардна промена секције
            HapticManager.playSelection()
        }
        
        animationManager.animateTransition(to: direction) {
            currentSectionIndex = index
        }
    }
}

#Preview {
    WelcomeGuideView(
        viewModel: WelcomeGuideViewModel(
            contentViewModel: ContentViewModel()
        )
    )
} 