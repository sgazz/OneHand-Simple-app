import SwiftUI

struct WelcomeGuideView: View {
    @ObservedObject var viewModel: WelcomeGuideViewModel
    @State private var currentSectionIndex = 0
    @State private var slideOffset: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 1
    @State private var progressScale: CGFloat = 1
    
    var body: some View {
        if viewModel.isShowingGuide {
            ZStack {
                AppTheme.Colors.overlay
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Naslov bez animacija
                    Text(LocalizedStringKey("welcome.title"))
                        .font(AppTheme.Typography.titleMedium)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .padding(.top, AppTheme.Layout.spacingLarge)
                        .padding(.bottom, AppTheme.Layout.spacingMedium)
                        .padding(.horizontal, AppTheme.Layout.paddingStandard)
                    
                    // Sadržaj sekcije
                    VStack(spacing: AppTheme.Layout.spacingMedium) {
                        Text(WelcomeGuideSection.sections[currentSectionIndex].title)
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, AppTheme.Layout.spacingSmall)
                        
                        Text(WelcomeGuideSection.sections[currentSectionIndex].content)
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, AppTheme.Layout.paddingStandard)
                    .frame(maxWidth: .infinity)
                    .offset(x: slideOffset)
                    .opacity(opacity)
                    .scaleEffect(scale)
                    
                    Spacer()
                    
                    // Progress Indicator sa animacijom
                    HStack(spacing: AppTheme.Layout.progressIndicatorSpacing) {
                        ForEach(0..<WelcomeGuideSection.sections.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentSectionIndex ? 
                                      AppTheme.Colors.progressActive : 
                                      AppTheme.Colors.progressInactive)
                                .frame(width: AppTheme.Layout.progressIndicatorSize, 
                                       height: AppTheme.Layout.progressIndicatorSize)
                                .scaleEffect(index == currentSectionIndex ? progressScale : 1)
                                .animation(Animation.spring(
                                    response: 0.3,
                                    dampingFraction: 0.5,
                                    blendDuration: 0
                                ).repeatCount(1), value: progressScale)
                                .onTapGesture {
                                    navigateToSection(index, direction: index < currentSectionIndex ? .right : .left)
                                }
                        }
                    }
                    .padding(.vertical, AppTheme.Layout.spacingLarge)
                    
                    // Dugmad
                    VStack(spacing: AppTheme.Layout.spacingMedium) {
                        // Checkbox za "Always show"
                        HStack(spacing: AppTheme.Layout.spacingSmall) {
                            Image(systemName: viewModel.showAlways ? "checkmark.square.fill" : "square")
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                                .onTapGesture {
                                    viewModel.showAlways.toggle()
                                }
                            Text(LocalizedStringKey("welcome.always_show"))
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Dugme za preskakanje/završetak
                        Button(currentSectionIndex == WelcomeGuideSection.sections.count - 1 ?
                              LocalizedStringKey("welcome.got_it") :
                              LocalizedStringKey("welcome.skip")) {
                            if currentSectionIndex == WelcomeGuideSection.sections.count - 1 {
                                HapticManager.playNotification(type: .success)
                            }
                            viewModel.dismissGuide()
                        }
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .frame(width: AppTheme.Layout.buttonWidthLarge, height: AppTheme.Layout.buttonHeight)
                        .background(currentSectionIndex == WelcomeGuideSection.sections.count - 1 ?
                                  AppTheme.Colors.buttonActive :
                                  AppTheme.Colors.buttonInactive)
                        .cornerRadius(AppTheme.Layout.cornerRadiusMedium)
                        .shadow(radius: AppTheme.Shadows.small.radius,
                               x: AppTheme.Shadows.small.x,
                               y: AppTheme.Shadows.small.y)
                    }
                    .padding(.horizontal, AppTheme.Layout.paddingStandard)
                    .padding(.bottom, AppTheme.Layout.spacingLarge)
                }
                .frame(width: 320, height: 400)
                .background(AppTheme.Gradients.primary)
                .cornerRadius(AppTheme.Layout.cornerRadiusLarge)
                .shadow(radius: AppTheme.Shadows.large.radius,
                       x: AppTheme.Shadows.large.x,
                       y: AppTheme.Shadows.large.y)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            slideOffset = value.translation.width
                            opacity = 1.0 - abs(Double(value.translation.width / 300))
                            scale = 1.0 - abs(value.translation.width / 1000)
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            if value.translation.width > threshold && currentSectionIndex > 0 {
                                navigateToSection(currentSectionIndex - 1, direction: .right)
                            } else if value.translation.width < -threshold && 
                                      currentSectionIndex < WelcomeGuideSection.sections.count - 1 {
                                navigateToSection(currentSectionIndex + 1, direction: .left)
                            } else {
                                withAnimation(AppTheme.Animations.spring) {
                                    slideOffset = 0
                                    opacity = 1
                                    scale = 1
                                }
                            }
                        }
                )
            }
            .transition(.opacity)
        }
    }
    
    private enum NavigationDirection {
        case left, right
    }
    
    private func navigateToSection(_ index: Int, direction: NavigationDirection = .left) {
        HapticManager.playSelection()
        
        // Animiramo izlaz trenutne sekcije
        withAnimation(Animation.easeOut(duration: 0.3)) {
            opacity = 0
            scale = 0.8
            slideOffset = direction == .left ? -50 : 50
        }
        
        // Postavljamo novu sekciju
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentSectionIndex = index
            
            // Animiramo progress indikator
            progressScale = 1.2
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                progressScale = 1.0
            }
            
            // Postavljamo početno stanje za novu sekciju
            opacity = 0
            scale = 0.8
            slideOffset = direction == .left ? 50 : -50
            
            // Animiramo ulaz nove sekcije
            withAnimation(Animation.spring(
                response: 0.5,
                dampingFraction: 0.8,
                blendDuration: 0
            )) {
                opacity = 1
                scale = 1
                slideOffset = 0
            }
        }
    }
} 