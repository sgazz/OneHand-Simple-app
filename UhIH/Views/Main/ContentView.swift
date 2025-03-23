import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @StateObject private var welcomeGuideViewModel = WelcomeGuideViewModel()
    
    var body: some View {
        ZStack {
            // Gradijentna pozadina
            BackgroundGradientView()
            
            if !viewModel.hasSelectedImage {
                WelcomeScreenView(viewModel: viewModel)
            } else {
                ZStack {
                    ImageDetailView(viewModel: viewModel)
                    
                    // Dodajemo RadialMenuView preko ImageDetailView
                    RadialMenuView(viewModel: viewModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            
            // Welcome Guide
            WelcomeGuideView(viewModel: welcomeGuideViewModel)
        }
        .onChange(of: viewModel.selectedItems) { oldValue, newValue in
            Task {
                await viewModel.handleImageSelection(newValue)
            }
        }
        .onAppear {
            welcomeGuideViewModel.showGuide()
        }
    }
}

#Preview {
    ContentView()
} 