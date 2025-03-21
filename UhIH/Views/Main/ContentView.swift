import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        ZStack {
            // Gradijentna pozadina
            BackgroundGradientView()
            
            if !viewModel.hasSelectedImage {
                WelcomeScreenView(viewModel: viewModel)
            } else if let image = viewModel.selectedImage {
                ImageDetailView(image: image, viewModel: viewModel)
            }
        }
        .onChange(of: viewModel.selectedItems) { oldValue, newValue in
            Task {
                await viewModel.handleImageSelection(newValue)
            }
        }
    }
}

#Preview {
    ContentView()
} 