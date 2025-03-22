import SwiftUI
import PhotosUI

class ContentViewModel: ObservableObject {
    @Published var selectedHand: Handedness?
    @Published var selectedItems: [PhotosPickerItem] = []
    @Published var images: [UIImage] = []
    @Published var selectedImage: UIImage?
    @Published var hasSelectedImage = false
    @Published var scale: CGFloat = 1.0
    
    enum Handedness {
        case left
        case right
    }
    
    func zoomIn() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            scale = min(scale * 1.2, 3.0)
        }
    }
    
    func zoomOut() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            scale = max(scale / 1.2, 0.5)
        }
    }
    
    func handleImageSelection(_ items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    images.append(image)
                    selectedImage = image
                    hasSelectedImage = true
                }
            }
        }
    }
} 