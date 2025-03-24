import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: ContentViewModel
    @Binding var isPresented: Bool
    @AppStorage("shouldShowWelcomeGuide") private var shouldShowWelcomeGuide = true
    @AppStorage("autoHideUI") private var autoHideUI = true
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                
                // Settings panel
                VStack(spacing: 32) {
                    // Header
                    HStack {
                        Text("Settings")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Done")
                                .font(.body.weight(.medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(red: 0.06, green: 0.11, blue: 0.21))
                                .cornerRadius(4)
                        }
                    }
                    
                    // Options Group
                    VStack(spacing: 24) {
                        // Handedness Picker
                        VStack(spacing: 0) {
                            Picker("Handedness", selection: $viewModel.selectedHand) {
                                Text("Left-handed").tag(ContentViewModel.Handedness.left)
                                Text("Right-handed").tag(ContentViewModel.Handedness.right)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .padding(12)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        
                        // Preferences
                        VStack(spacing: 2) {
                            HStack {
                                if viewModel.selectedHand == .left {
                                    checkboxView(isChecked: shouldShowWelcomeGuide)
                                }
                                
                                Button(action: {
                                    shouldShowWelcomeGuide.toggle()
                                }) {
                                    VStack(spacing: 2) {
                                        Text("Welcome Guide")
                                            .foregroundStyle(.white)
                                        Text("Show initial setup guide")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                
                                if viewModel.selectedHand == .right {
                                    checkboxView(isChecked: shouldShowWelcomeGuide)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                            
                            Divider()
                                .background(.white.opacity(0.1))
                            
                            HStack {
                                if viewModel.selectedHand == .left {
                                    checkboxView(isChecked: autoHideUI)
                                }
                                
                                Button(action: {
                                    autoHideUI.toggle()
                                }) {
                                    VStack(spacing: 2) {
                                        Text("Auto-hide Interface")
                                            .foregroundStyle(.white)
                                        Text("Hide controls when inactive")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                
                                if viewModel.selectedHand == .right {
                                    checkboxView(isChecked: autoHideUI)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                        }
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, geometry.safeAreaInsets.bottom + 16)
            }
            .frame(maxWidth: .infinity)
            .background {
                Color(red: 0.06, green: 0.11, blue: 0.21)
                    .opacity(0.85)
                    .background(.thinMaterial)
            }
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .offset(y: isPresented ? 0 : geometry.size.height)
        }
        .ignoresSafeArea()
        .transition(.move(edge: .bottom))
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