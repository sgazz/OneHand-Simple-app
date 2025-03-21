import SwiftUI
import PhotosUI

struct ImageDetailView: View {
    let image: UIImage
    @ObservedObject var viewModel: ContentViewModel
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    ScrollView([.horizontal, .vertical]) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * scale)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = value.magnitude
                                    }
                            )
                    }
                    
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
                    .padding(.bottom, 20)
                }
            }
        }
    }
} 