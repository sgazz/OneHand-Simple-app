import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: ContentViewModel
    @Binding var isPresented: Bool
    @AppStorage("shouldShowWelcomeGuide") private var shouldShowWelcomeGuide = true
    @AppStorage("autoHideUI") private var autoHideUI = true
    @Environment(\.colorScheme) private var colorScheme
    @State private var previousAutoHideState: Bool = true
    
    private let settingsBackgroundColor = Color(red: 0.06, green: 0.11, blue: 0.21)
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                
                // Settings panel
                VStack(spacing: 32) {
                    // Header
                    ZStack {
                        // Done button
                        HStack {
                            if viewModel.selectedHand == .left {
                                Button(action: {
                                    autoHideUI = previousAutoHideState
                                    isPresented = false
                                }) {
                                    Text("Done")
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(settingsBackgroundColor)
                                        .cornerRadius(4)
                                }
                                .padding(.leading, 20)
                                Spacer()
                            } else {
                                Spacer()
                                Button(action: {
                                    autoHideUI = previousAutoHideState
                                    isPresented = false
                                }) {
                                    Text("Done")
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(settingsBackgroundColor)
                                        .cornerRadius(4)
                                }
                                .padding(.trailing, 20)
                            }
                        }
                        
                        // Title
                        Text("Settings")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                    }
                    
                    // Options Group
                    VStack(spacing: 24) {
                        // Handedness Picker
                        VStack(spacing: 0) {
                            Picker("Handedness", selection: $viewModel.selectedHand) {
                                Text("Left-handed")
                                    .font(.body)
                                    .tag(ContentViewModel.Handedness.left)
                                Text("Right-handed")
                                    .font(.body)
                                    .tag(ContentViewModel.Handedness.right)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .tint(settingsBackgroundColor)
                        }
                        .padding(12)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        
                        // Preferences
                        VStack(spacing: 2) {
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
                                Button(action: {
                                    shouldShowWelcomeGuide.toggle()
                                }) {
                                    Text("Show Welcome Guide")
                                        .font(.body)
                                        .foregroundStyle(settingsBackgroundColor)
                                }
                            }
                            .padding(.vertical, 12)
                            
                            Divider()
                                .background(.white.opacity(0.1))
                            
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
                                Button(action: {
                                    autoHideUI.toggle()
                                }) {
                                    Text("Auto-hide Interface")
                                        .font(.body)
                                        .foregroundStyle(settingsBackgroundColor)
                                }
                            }
                            .padding(.vertical, 12)
                        }
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, geometry.safeAreaInsets.bottom + 16)
            }
            .frame(maxWidth: .infinity)
            .background {
                settingsBackgroundColor
                    .opacity(0.85)
                    .background(.thinMaterial)
            }
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .offset(y: isPresented ? 0 : geometry.size.height)
        }
        .ignoresSafeArea()
        .transition(.move(edge: .bottom))
        .onAppear {
            previousAutoHideState = autoHideUI
            autoHideUI = false
        }
        .onDisappear {
            autoHideUI = previousAutoHideState
        }
    }
    
    private func checkboxView(isChecked: Bool) -> some View {
        Image(systemName: isChecked ? "checkmark.square.fill" : "square")
            .foregroundStyle(isChecked ? .blue : .white)
            .font(.system(size: 20))
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