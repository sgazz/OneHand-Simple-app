import SwiftUI
import PhotosUI

struct ImageDetailView: View {
    let image: UIImage
    @ObservedObject var viewModel: ContentViewModel
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                    .scaleEffect(viewModel.scale, anchor: .center)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                viewModel.scale = value.magnitude
                            }
                    )
                
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
                    .padding(.bottom, 20)
                }
            }
        }
    }
} 