import SwiftUI
import PhotosUI

struct ImageDetailView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundGradientView()
                
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(viewModel.scale)
                        .rotationEffect(.degrees(viewModel.rotation))
                        .offset(x: viewModel.imageOffset.x, y: viewModel.imageOffset.y)
                }
                
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
