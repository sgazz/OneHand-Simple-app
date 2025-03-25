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
            GeometryReader { geometry in
                let isLandscape = geometry.size.width > geometry.size.height
                
                ZStack {
                    AppTheme.Colors.overlay
                        .edgesIgnoringSafeArea(.all)
                    
                    if isLandscape {
                        // Landscape layout
                        VStack(spacing: 0) {
                            // Title centered across the entire width
                            Text(LocalizedStringKey("welcome.title"))
                                .font(AppTheme.Typography.titleMedium)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                                .multilineTextAlignment(.center)
                                .padding(.top, AppTheme.Layout.spacingLarge)
                                .padding(.bottom, AppTheme.Layout.spacingMedium)
                                .frame(maxWidth: .infinity)
                            
                            // Content and controls in HStack
                            HStack(spacing: 0) {
                                if viewModel.selectedHand == .right {
                                    // Main content for right-handed users
                                    mainContentWithoutTitle
                                        .frame(width: geometry.size.width * 0.6)
                                    
                                    // Controls for right-handed users
                                    controlsContent
                                        .frame(width: geometry.size.width * 0.4)
                                } else {
                                    // Controls for left-handed users
                                    controlsContent
                                        .frame(width: geometry.size.width * 0.4)
                                    
                                    // Main content for left-handed users
                                    mainContentWithoutTitle
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
                    } else {
                        // Portrait layout - unchanged
                        VStack(spacing: 0) {
                            // Naslov bez animacija
                            Text(LocalizedStringKey("welcome.title"))
                                .font(AppTheme.Typography.titleMedium)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                                .multilineTextAlignment(.center)
                                .padding(.top, AppTheme.Layout.spacingLarge)
                                .padding(.bottom, AppTheme.Layout.spacingMedium)
                                .padding(.horizontal, AppTheme.Layout.paddingStandard)
                            
                            // Sadržaj sekcije
                            VStack(spacing: AppTheme.Layout.spacingMedium) {
                                Text(WelcomeGuideSection.sections[currentSectionIndex].title)
                                    .font(.custom("SF Pro Display", size: 22, relativeTo: .headline))
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, AppTheme.Layout.spacingSmall)
                                
                                Text(WelcomeGuideSection.sections[currentSectionIndex].content)
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
                                    if viewModel.selectedHand == .right {
                                        Text(LocalizedStringKey("welcome.always_show"))
                                            .font(AppTheme.Typography.caption)
                                            .foregroundColor(AppTheme.Colors.textSecondary)
                                        Image(systemName: viewModel.showAlways ? "checkmark.square.fill" : "square")
                                            .font(.system(size: 20))
                                            .foregroundColor(AppTheme.Colors.textPrimary)
                                            .onTapGesture {
                                                viewModel.showAlways.toggle()
                                            }
                                    } else {
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
                        .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 480 : 320, 
                               height: UIDevice.current.userInterfaceIdiom == .pad ? 600 : 400)
                        .background(AppTheme.Gradients.primary)
                        .cornerRadius(AppTheme.Layout.cornerRadiusLarge)
                        .shadow(radius: AppTheme.Shadows.large.radius,
                               x: AppTheme.Shadows.large.x,
                               y: AppTheme.Shadows.large.y)
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            slideOffset = value.translation.width
                            opacity = 1.0 - abs(Double(value.translation.width / 300))
                            scale = 1.0 - abs(value.translation.width / 1000)
                        }
                        .onEnded { value in
                            let threshold: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 75 : 50
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
    
    // Main content without title
    private var mainContentWithoutTitle: some View {
        VStack(spacing: AppTheme.Layout.spacingMedium) {
            // Section content
            VStack(spacing: AppTheme.Layout.spacingMedium) {
                Text(WelcomeGuideSection.sections[currentSectionIndex].title)
                    .font(.custom("SF Pro Display", size: 22, relativeTo: .headline))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, AppTheme.Layout.spacingSmall)
                
                Text(WelcomeGuideSection.sections[currentSectionIndex].content)
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
            
            // Progress indicators
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
        }
    }
    
    // Controls content view
    private var controlsContent: some View {
        VStack {
            Spacer()
            
            // Checkbox for "Always show"
            HStack(spacing: AppTheme.Layout.spacingSmall) {
                if viewModel.selectedHand == .right {
                    Text(LocalizedStringKey("welcome.always_show"))
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    Image(systemName: viewModel.showAlways ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .onTapGesture {
                            viewModel.showAlways.toggle()
                        }
                } else {
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
            }
            .padding(.bottom, AppTheme.Layout.spacingLarge)
            
            // Skip/Got it button
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
            
            Spacer()
        }
        .padding(.horizontal, AppTheme.Layout.paddingStandard)
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