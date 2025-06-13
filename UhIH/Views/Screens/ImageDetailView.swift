import SwiftUI
import PhotosUI

struct ImageDetailView: View {
    @ObservedObject var viewModel: ContentViewModel
    @State private var imageOpacity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundGradientView()
                
                if let image = viewModel.selectedImage {
                    detailedImageView(image: image, geometry: geometry)
                } else {
                    Text(LocalizedStringKey("image_detail.no_image"))
                        .foregroundColor(.white)
                        .font(.title2)
                }
                
                VStack {
                    Spacer()
                    
                    // Dugme za izbor slike
                    HStack {
                        if viewModel.selectedHand == .right {
                            Spacer()
                            PhotosPicker(selection: $viewModel.selectedItems,
                                       maxSelectionCount: 1,
                                       matching: .images) {
                                Text(LocalizedStringKey("welcome_screen.choose_image"))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 50)
                                    .background(Color.blue)
                                    .cornerRadius(15)
                            }
                            .onTapGesture {
                                HapticManager.playSelection()
                            }
                            .onChange(of: viewModel.selectedItems) { oldValue, newValue in
                                print("selectedItems changed: \(oldValue.count) -> \(newValue.count)")
                                Task {
                                    await viewModel.handleImageSelection(newValue)
                                }
                            }
                            .padding(.trailing, 20)
                        } else {
                            PhotosPicker(selection: $viewModel.selectedItems,
                                       maxSelectionCount: 1,
                                       matching: .images) {
                                Text(LocalizedStringKey("welcome_screen.choose_image"))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 50)
                                    .background(Color.blue)
                                    .cornerRadius(15)
                            }
                            .onTapGesture {
                                HapticManager.playSelection()
                            }
                            .onChange(of: viewModel.selectedItems) { oldValue, newValue in
                                print("selectedItems changed: \(oldValue.count) -> \(newValue.count)")
                                Task {
                                    await viewModel.handleImageSelection(newValue)
                                }
                            }
                            .padding(.leading, 20)
                            Spacer()
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .sheet(isPresented: $viewModel.showProPrompt) {
                ProVersionView(isPresented: $viewModel.showProPrompt) {
                    await viewModel.purchaseProVersion()
                } onRestore: {
                    await viewModel.restorePurchases()
                }
                .presentationDetents([.medium])
            }
        }
        .onChange(of: viewModel.selectedImage) { oldValue, newValue in
            imageOpacity = 0 // Resetujemo opacity na 0
            if newValue != nil {
                withAnimation(.easeIn(duration: 0.8)) {
                    imageOpacity = 1
                }
            }
        }
    }
    
    private func detailedImageView(image: UIImage, geometry: GeometryProxy) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(viewModel.scale)
            .rotationEffect(.degrees(viewModel.rotation))
            .offset(x: viewModel.imageOffset.x, y: viewModel.imageOffset.y)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if let maxOffset = viewModel.calculateMaxOffset(viewSize: geometry.size) {
                            let newX = value.translation.width + viewModel.lastFixedOffset.x
                            let newY = value.translation.height + viewModel.lastFixedOffset.y
                            viewModel.imageOffset = CGPoint(
                                x: max(-maxOffset.x, min(maxOffset.x, newX)),
                                y: max(-maxOffset.y, min(maxOffset.y, newY))
                            )
                        }
                    }
                    .onEnded { _ in
                        viewModel.lastFixedOffset = viewModel.imageOffset
                    }
            )
            .opacity(imageOpacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.8)) {
                    imageOpacity = 1
                }
            }
    }
}

#Preview {
    ImageDetailView(viewModel: ContentViewModel())
} 
