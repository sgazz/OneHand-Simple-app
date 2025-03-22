import SwiftUI
import PhotosUI

class ContentViewModel: ObservableObject {
    @Published var selectedHand: Handedness?
    @Published var selectedItems: [PhotosPickerItem] = []
    @Published var images: [UIImage] = []
    @Published var selectedImage: UIImage?
    @Published var hasSelectedImage = false
    @Published var scale: CGFloat = 1.0
    @Published var isZooming = false
    @Published var rotation: Double = 0.0
    @Published var isRotating = false
    
    private var displayLink: CADisplayLink?
    private var currentZoomSpeed: CGFloat = 0.02
    private var lastUpdateTime: TimeInterval = 0
    private let rotationSpeed: Double = 180.0 // Konstantna brzina rotacije
    
    let minScale: CGFloat = 1.0  // Početna veličina
    let maxScale: CGFloat = 10.0  // Maksimalni zoom
    let baseZoomSpeed: CGFloat = 0.02 // Bazna brzina kontinuiranog zooma
    let maxZoomSpeed: CGFloat = 0.15 // Maksimalna brzina zooma
    let accelerationFactor: CGFloat = 1.2 // Faktor ubrzanja
    
    enum Handedness {
        case left
        case right
    }
    
    func startContinuousZoomIn() {
        isZooming = true
        currentZoomSpeed = baseZoomSpeed
        lastUpdateTime = CACurrentMediaTime()
        
        displayLink = CADisplayLink(target: self, selector: #selector(handleZoomIn))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func startContinuousZoomOut() {
        isZooming = true
        currentZoomSpeed = baseZoomSpeed
        lastUpdateTime = CACurrentMediaTime()
        
        displayLink = CADisplayLink(target: self, selector: #selector(handleZoomOut))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func handleZoomIn() {
        guard isZooming else { return }
        
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        scale = min(scale + currentZoomSpeed * CGFloat(deltaTime * 60), maxScale)
        currentZoomSpeed = min(currentZoomSpeed * accelerationFactor, maxZoomSpeed)
    }
    
    @objc private func handleZoomOut() {
        guard isZooming else { return }
        
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        scale = max(scale - currentZoomSpeed * CGFloat(deltaTime * 60), minScale)
        currentZoomSpeed = min(currentZoomSpeed * accelerationFactor, maxZoomSpeed)
    }
    
    func stopZooming() {
        isZooming = false
        displayLink?.invalidate()
        displayLink = nil
    }
    
    func zoomToMax() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
            scale = maxScale
        }
    }
    
    func zoomToMin() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            scale = minScale
        }
    }
    
    func zoomIn() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            scale = min(scale * 1.2, maxScale)
        }
    }
    
    func zoomOut() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            scale = max(scale * 0.8, minScale)
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
                    scale = minScale
                }
            }
        }
    }
    
    // Funkcije za rotaciju
    func rotateClockwise() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            rotation += 45
        }
    }
    
    func rotateCounterclockwise() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            rotation -= 45
        }
    }
    
    func startContinuousRotationClockwise() {
        isRotating = true
        lastUpdateTime = CACurrentMediaTime()
        
        displayLink = CADisplayLink(target: self, selector: #selector(handleClockwiseRotation))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func startContinuousRotationCounterclockwise() {
        isRotating = true
        lastUpdateTime = CACurrentMediaTime()
        
        displayLink = CADisplayLink(target: self, selector: #selector(handleCounterclockwiseRotation))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func handleClockwiseRotation() {
        guard isRotating else { return }
        
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        rotation += rotationSpeed * deltaTime
    }
    
    @objc private func handleCounterclockwiseRotation() {
        guard isRotating else { return }
        
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        rotation -= rotationSpeed * deltaTime
    }
    
    func stopRotation() {
        isRotating = false
        displayLink?.invalidate()
        displayLink = nil
    }
    
    // Funkcija za reset slike
    func resetImage() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            scale = minScale
            rotation = 0
        }
    }
} 