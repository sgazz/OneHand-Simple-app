import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @StateObject private var welcomeGuideViewModel: WelcomeGuideViewModel
    @State private var isUIHidden = false
    @State private var hideUITimer: Timer?
    @State private var showHelp = false
    @AppStorage("autoHideUI") private var autoHideUI = true
    @AppStorage("shouldShowWelcomeGuide") private var shouldShowWelcomeGuide = true
    @AppStorage("hideHelp") private var hideHelp = false
    
    init() {
        let contentViewModel = ContentViewModel()
        _viewModel = StateObject(wrappedValue: contentViewModel)
        _welcomeGuideViewModel = StateObject(wrappedValue: WelcomeGuideViewModel(contentViewModel: contentViewModel))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            ZStack {
                // Gradijentna pozadina
                BackgroundGradientView()
                
                if !viewModel.hasSelectedImage {
                    if welcomeGuideViewModel.isShowingGuide {
                        // Kada je guide aktivan
                        if isLandscape {
                            // U landscape modu prikazujemo WelcomeScreenView samo ako ruka nije izabrana
                            if viewModel.selectedHand == nil {
                                WelcomeScreenView(viewModel: viewModel, welcomeGuideViewModel: welcomeGuideViewModel)
                            }
                        }
                    } else {
                        // Kada guide nije aktivan, uvek prikazujemo WelcomeScreenView
                        WelcomeScreenView(viewModel: viewModel, welcomeGuideViewModel: welcomeGuideViewModel)
                    }
                }
                
                if welcomeGuideViewModel.isShowingGuide {
                    if isLandscape {
                        // U landscape modu prikazujemo guide samo ako je izabrana ruka
                        if viewModel.selectedHand != nil {
                            WelcomeGuideView(viewModel: welcomeGuideViewModel)
                        }
                    } else {
                        // U portrait modu uvek prikazujemo guide
                        WelcomeGuideView(viewModel: welcomeGuideViewModel)
                    }
                }
                
                if viewModel.hasSelectedImage {
                    ZStack {
                        ImageDetailView(viewModel: viewModel)
                        
                        // UI elementi koji se sakrivaju
                        VStack {
                            Spacer()
                            
                            // Help dugme
                            GeometryReader { geometry in
                                if !hideHelp {
                                    Button(action: {
                                        withAnimation {
                                            showHelp = true
                                        }
                                    }) {
                                        Image(systemName: "questionmark.circle.fill")
                                            .font(.system(size: 15))
                                            .foregroundColor(.white)
                                            .frame(width: 25, height: 25)
                                            .background(Color(red: 0.8, green: 0.2, blue: 0.4))
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white.opacity(0.6), lineWidth: 0.5)
                                            )
                                            .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 1.5)
                                    }
                                    .onTapGesture {
                                        showUI()
                                    }
                                    .position(
                                        x: UIDevice.current.orientation.isLandscape ?
                                            (viewModel.selectedHand == .left ? 140 : geometry.size.width - 140) :
                                            geometry.size.width / 2,
                                        y: geometry.size.height - 75
                                    )
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
        .overlay {
            if showHelp {
                HelpView(isPresented: $showHelp, viewModel: viewModel)
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