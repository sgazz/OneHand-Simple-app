import SwiftUI
import PhotosUI

struct ImageDetailView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(uiColor: .systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(viewModel.scale)
                        .rotationEffect(.degrees(viewModel.rotation))
                        .offset(x: viewModel.imageOffset.x, y: viewModel.imageOffset.y)
                }
                
                // Dugme za izbor slike
                VStack {
                    Spacer()
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
                    .padding(.bottom, 50)
                }
            }
        }
    }
} 
