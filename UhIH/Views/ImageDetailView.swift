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
                        .offset(viewModel.imageOffset)
                
                    // Compass indikator
                    if viewModel.showCompass {
                        CompassIndicator(
                            pitch: viewModel.motionManager.pitch,
                            roll: viewModel.motionManager.roll,
                            isActive: viewModel.isMotionTrackingEnabled
                        )
                    }
                }
                
                RadialMenuView(viewModel: viewModel)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 100)
            }
        }
    }
} 