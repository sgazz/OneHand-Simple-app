import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @StateObject private var welcomeGuideViewModel = WelcomeGuideViewModel()
    @State private var isUIHidden = false
    @State private var hideUITimer: Timer?
    @AppStorage("autoHideUI") private var autoHideUI = true
    
    var body: some View {
        ZStack {
            // Gradijentna pozadina
            BackgroundGradientView()
            
            if welcomeGuideViewModel.isShowingGuide {
                WelcomeGuideView(viewModel: welcomeGuideViewModel)
            } else {
                if !viewModel.hasSelectedImage {
                    WelcomeScreenView(viewModel: viewModel, welcomeGuideViewModel: welcomeGuideViewModel)
                        .id(welcomeGuideViewModel.isShowingGuide)
                } else {
                    ZStack {
                        // Slika ostaje vidljiva
                        if let image = viewModel.selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(viewModel.scale)
                                .rotationEffect(.degrees(viewModel.rotation))
                                .offset(x: viewModel.imageOffset.x, y: viewModel.imageOffset.y)
                        }
                        
                        // UI elementi koji se sakrivaju
                        VStack {
                            // Informacije o pomeranju i veličini
                            VStack(alignment: .leading, spacing: 8) {
                                Text(viewModel.getImageSizeInfo())
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(8)
                                
                                Text(viewModel.getOffsetInfo())
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(8)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                            
                            // Dugme za izbor slike
                            GeometryReader { geometry in
                                PhotosPicker(selection: $viewModel.selectedItems,
                                           maxSelectionCount: 1,
                                           matching: .images) {
                                    Text("Choose Image")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 200, height: 50)
                                        .background(Color.blue)
                                        .cornerRadius(15)
                                }
                                .position(
                                    x: UIDevice.current.orientation.isLandscape ?
                                        (viewModel.selectedHand == .left ? 140 : geometry.size.width - 140) :
                                        geometry.size.width / 2,
                                    y: geometry.size.height - 75
                                )
                                .onTapGesture {
                                    showUI()
                                }
                            }
                            .frame(height: 100)
                        }
                        .opacity(isUIHidden ? 0 : 1)
                        .animation(.easeOut(duration: 0.3), value: isUIHidden)
                        
                        // RadialMenuView
                        RadialMenuView(viewModel: viewModel)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .opacity(isUIHidden ? 0 : 1)
                            .animation(.easeOut(duration: 0.3), value: isUIHidden)
                            .onTapGesture {
                                showUI()
                            }
                    }
                }
            }
        }
        .onChange(of: viewModel.selectedItems) { oldValue, newValue in
            Task {
                await viewModel.handleImageSelection(newValue)
            }
        }
        .onChange(of: viewModel.hasSelectedImage) { oldValue, newValue in
            if newValue {
                // Kada se pojavi slika, pokrećemo timer za sakrivanje UI-a
                startHideUITimer()
            }
        }
        .onAppear {
            welcomeGuideViewModel.showGuide()
            // Dodajemo observer za ResetUITimer notifikaciju
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("ResetUITimer"),
                object: nil,
                queue: .main
            ) { _ in
                showUI()
            }
            
            // Dodajemo observer za Settings notifikacije
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("SettingsOpened"),
                object: nil,
                queue: .main
            ) { _ in
                hideUITimer?.invalidate()
                hideUITimer = nil
            }
            
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("SettingsClosed"),
                object: nil,
                queue: .main
            ) { _ in
                startHideUITimer()
            }
        }
        .contentShape(Rectangle()) // Ovo omogućava da tap radi na celom ekranu
        .onTapGesture {
            showUI()
        }
    }
    
    private func startHideUITimer() {
        hideUITimer?.invalidate()
        if autoHideUI {
            hideUITimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
                withAnimation {
                    isUIHidden = true
                }
            }
        }
    }
    
    private func showUI() {
        withAnimation {
            isUIHidden = false
        }
        if autoHideUI {
            startHideUITimer()
        }
    }
}

#Preview {
    ContentView()
} 