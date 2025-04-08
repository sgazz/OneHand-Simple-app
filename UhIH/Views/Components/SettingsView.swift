import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: ContentViewModel
    @Binding var isPresented: Bool
    @AppStorage("shouldShowWelcomeGuide") private var shouldShowWelcomeGuide = true
    @AppStorage("autoHideUI") private var autoHideUI = true
    @AppStorage("hideHelp") private var hideHelp = false
    @Environment(\.colorScheme) private var colorScheme
    
    private let settingsBackgroundColor = Color(red: 0.06, green: 0.11, blue: 0.21)
    
    // Font constants
    private let titleFont: Font = .title3.weight(.semibold)
    private let buttonFont: Font = .body.weight(.medium)
    private let textFont: Font = .body
    private let checkboxSize: CGFloat = 20
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let deviceIdiom = UIDevice.current.userInterfaceIdiom
            
            VStack(spacing: 0) {
                Spacer()
                
                // Settings panel
                VStack(spacing: deviceIdiom == .pad ? 40 : 32) {
                    // Header - isti za obe orijentacije
                    ZStack {
                        // Done button
                        HStack {
                            if viewModel.selectedHand == .left {
                                Button(action: {
                                    isPresented = false
                                    HapticManager.playSelection()
                                }) {
                                    Text(LocalizedStringKey("settings.done"))
                                        .font(buttonFont)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(settingsBackgroundColor)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.white.opacity(0.3), lineWidth: 1)
                                        )
                                }
                                .padding(.leading, 20)
                                Spacer()
                            } else {
                                Spacer()
                                Button(action: {
                                    isPresented = false
                                    HapticManager.playSelection()
                                }) {
                                    Text(LocalizedStringKey("settings.done"))
                                        .font(buttonFont)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(settingsBackgroundColor)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.white.opacity(0.3), lineWidth: 1)
                                        )
                                }
                                .padding(.trailing, 20)
                            }
                        }
                        
                        // Title
                        Text(LocalizedStringKey("settings.title"))
                            .font(titleFont)
                            .foregroundStyle(.white)
                            .padding(.top, deviceIdiom == .pad ? 16 : 8)
                    }
                    .padding(.top, deviceIdiom == .pad ? 24 : 16)
                    
                    // Options Group sa uslovnim layoutom
                    if isLandscape {
                        // Landscape layout
                        HStack(spacing: 0) {
                            if viewModel.selectedHand == .right {
                                Spacer()
                                    .frame(width: geometry.size.width * 0.5 - 30)
                            }
                            
                            // Options Group content
                            VStack(spacing: deviceIdiom == .pad ? 32 : 24) {
                                // Handedness Picker
                                VStack(spacing: 0) {
                                    Picker("Handedness", selection: $viewModel.selectedHand) {
                                        Text(LocalizedStringKey("settings.left_handed")).tag(ContentViewModel.Handedness.left)
                                        Text(LocalizedStringKey("settings.right_handed")).tag(ContentViewModel.Handedness.right)
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                                .padding(12)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                                
                                // Options
                                VStack(spacing: 2) {
                                    // Show Welcome Guide
                                    Button(action: {
                                        shouldShowWelcomeGuide.toggle()
                                        HapticManager.playSelection()
                                    }) {
                                        ZStack {
                                            HStack {
                                                if viewModel.selectedHand == .left {
                                                    checkboxView(isChecked: shouldShowWelcomeGuide)
                                                        .padding(.leading, 20)
                                                    Spacer()
                                                } else {
                                                    Spacer()
                                                    checkboxView(isChecked: shouldShowWelcomeGuide)
                                                        .padding(.trailing, 20)
                                                }
                                            }
                                            Text(LocalizedStringKey("settings.show_welcome"))
                                                .font(textFont)
                                                .foregroundStyle(settingsBackgroundColor)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    
                                    Divider()
                                        .background(.white.opacity(0.1))
                                    
                                    // Auto-hide Interface
                                    Button(action: {
                                        autoHideUI.toggle()
                                        HapticManager.playSelection()
                                    }) {
                                        ZStack {
                                            HStack {
                                                if viewModel.selectedHand == .left {
                                                    checkboxView(isChecked: autoHideUI)
                                                        .padding(.leading, 20)
                                                    Spacer()
                                                } else {
                                                    Spacer()
                                                    checkboxView(isChecked: autoHideUI)
                                                        .padding(.trailing, 20)
                                                }
                                            }
                                            Text(LocalizedStringKey("settings.auto_hide"))
                                                .font(textFont)
                                                .foregroundStyle(settingsBackgroundColor)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    
                                    Divider()
                                        .background(.white.opacity(0.1))
                                    
                                    // Hide Help
                                    Button(action: {
                                        hideHelp.toggle()
                                        HapticManager.playSelection()
                                    }) {
                                        ZStack {
                                            HStack {
                                                if viewModel.selectedHand == .left {
                                                    checkboxView(isChecked: hideHelp)
                                                        .padding(.leading, 20)
                                                    Spacer()
                                                } else {
                                                    Spacer()
                                                    checkboxView(isChecked: hideHelp)
                                                        .padding(.trailing, 20)
                                                }
                                            }
                                            Text(LocalizedStringKey("settings.hide_help"))
                                                .font(textFont)
                                                .foregroundStyle(settingsBackgroundColor)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                }
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                            }
                            .frame(width: geometry.size.width * (deviceIdiom == .pad ? 0.4 : 0.35))
                            
                            if viewModel.selectedHand == .left {
                                Spacer()
                                    .frame(width: geometry.size.width * 0.5 - 30)
                            }
                        }
                    } else {
                        // Portrait layout
                        VStack(spacing: deviceIdiom == .pad ? 32 : 24) {
                            // Handedness Picker
                            VStack(spacing: 0) {
                                Picker("Handedness", selection: $viewModel.selectedHand) {
                                    Text(LocalizedStringKey("settings.left_handed"))
                                        .font(textFont)
                                        .tag(ContentViewModel.Handedness.left)
                                    Text(LocalizedStringKey("settings.right_handed"))
                                        .font(textFont)
                                        .tag(ContentViewModel.Handedness.right)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .tint(settingsBackgroundColor)
                            }
                            .padding(12)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                            
                            // Preferences
                            VStack(spacing: 2) {
                                // Show Welcome Guide
                                Button(action: {
                                    shouldShowWelcomeGuide.toggle()
                                    HapticManager.playSelection()
                                }) {
                                    ZStack {
                                        // Checkbox
                                        HStack {
                                            if viewModel.selectedHand == .left {
                                                checkboxView(isChecked: shouldShowWelcomeGuide)
                                                    .padding(.leading, 20)
                                                Spacer()
                                            } else {
                                                Spacer()
                                                checkboxView(isChecked: shouldShowWelcomeGuide)
                                                    .padding(.trailing, 20)
                                            }
                                        }
                                        
                                        // Text
                                        Text(LocalizedStringKey("settings.show_welcome"))
                                            .font(textFont)
                                            .foregroundStyle(settingsBackgroundColor)
                                    }
                                }
                                .padding(.vertical, 12)
                                
                                Divider()
                                    .background(.white.opacity(0.1))
                                
                                // Auto-hide Interface
                                Button(action: {
                                    autoHideUI.toggle()
                                    HapticManager.playSelection()
                                }) {
                                    ZStack {
                                        // Checkbox
                                        HStack {
                                            if viewModel.selectedHand == .left {
                                                checkboxView(isChecked: autoHideUI)
                                                    .padding(.leading, 20)
                                                Spacer()
                                            } else {
                                                Spacer()
                                                checkboxView(isChecked: autoHideUI)
                                                    .padding(.trailing, 20)
                                            }
                                        }
                                        
                                        // Text
                                        Text(LocalizedStringKey("settings.auto_hide"))
                                            .font(textFont)
                                            .foregroundStyle(settingsBackgroundColor)
                                    }
                                }
                                .padding(.vertical, 12)
                                
                                Divider()
                                    .background(.white.opacity(0.1))
                                
                                // Hide Help
                                Button(action: {
                                    hideHelp.toggle()
                                    HapticManager.playSelection()
                                }) {
                                    ZStack {
                                        // Checkbox
                                        HStack {
                                            if viewModel.selectedHand == .left {
                                                checkboxView(isChecked: hideHelp)
                                                    .padding(.leading, 20)
                                                Spacer()
                                            } else {
                                                Spacer()
                                                checkboxView(isChecked: hideHelp)
                                                    .padding(.trailing, 20)
                                            }
                                        }
                                        
                                        // Text
                                        Text(LocalizedStringKey("settings.hide_help"))
                                            .font(textFont)
                                            .foregroundStyle(settingsBackgroundColor)
                                    }
                                }
                                .padding(.vertical, 12)
                            }
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, geometry.safeAreaInsets.bottom + (deviceIdiom == .pad ? 16 : 8) + 75)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                settingsBackgroundColor
                    .opacity(0.85)
                    .background(.ultraThinMaterial)
            }
            .offset(y: isPresented ? 0 : geometry.size.height)
        }
        .ignoresSafeArea()
        .transition(.move(edge: .bottom))
        .onAppear {
            NotificationCenter.default.post(name: NSNotification.Name("SettingsOpened"), object: nil)
        }
        .onDisappear {
            NotificationCenter.default.post(name: NSNotification.Name("SettingsClosed"), object: nil)
        }
    }
    
    private func checkboxView(isChecked: Bool) -> some View {
        Image(systemName: isChecked ? "checkmark.square.fill" : "square")
            .font(.system(size: checkboxSize))
            .foregroundColor(isChecked ? settingsBackgroundColor : .gray)
    }
}

// Extension za zaobljene ivice samo na određenim stranama
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    SettingsView(viewModel: ContentViewModel(), isPresented: .constant(true))
} 