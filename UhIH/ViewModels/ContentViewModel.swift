import SwiftUI
import PhotosUI
import Combine

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
    @Published var isMotionTrackingEnabled: Bool = false
    @Published var imageOffset: CGPoint = .zero
    
    private var displayLink: CADisplayLink?
    private var currentZoomSpeed: CGFloat = 0.02
    private var lastUpdateTime: TimeInterval = 0
    private let rotationSpeed: Double = 180.0 // Konstantna brzina rotacije
    
    let minScale: CGFloat = 1.0  // Početna veličina
    let maxScale: CGFloat = 10.0  // Maksimalni zoom
    let baseZoomSpeed: CGFloat = 0.02 // Bazna brzina kontinuiranog zooma
    let maxZoomSpeed: CGFloat = 0.15 // Maksimalna brzina zooma
    let accelerationFactor: CGFloat = 1.2 // Faktor ubrzanja
    
    private let motionManager = MotionManager()
    
    // Set za čuvanje Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
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
        HapticManager.playZoom(zoomIn: true)
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
            scale = maxScale
        }
    }
    
    func zoomToMin() {
        HapticManager.playZoom(zoomIn: false)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            scale = minScale
        }
    }
    
    func zoomIn() {
        HapticManager.playZoom(zoomIn: true)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            scale = min(scale * 1.2, maxScale)
        }
    }
    
    func zoomOut() {
        HapticManager.playZoom(zoomIn: false)
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
                    HapticManager.playImpact(style: .medium)
                }
            }
        }
    }
    
    // Funkcije za rotaciju
    func rotateClockwise() {
        HapticManager.playRotation(intensity: 0.7)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            rotation += 45
        }
    }
    
    func rotateCounterclockwise() {
        HapticManager.playRotation(intensity: 0.7)
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
        
        // Додајемо хаптички одзив сваких 45 степени
        if Int(rotation.truncatingRemainder(dividingBy: 45)) == 0 {
            HapticManager.playRotation(intensity: 0.5)
        }
    }
    
    @objc private func handleCounterclockwiseRotation() {
        guard isRotating else { return }
        
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        rotation -= rotationSpeed * deltaTime
        
        // Додајемо хаптички одзив сваких 45 степени
        if Int(abs(rotation).truncatingRemainder(dividingBy: 45)) == 0 {
            HapticManager.playRotation(intensity: 0.5)
        }
    }
    
    func stopRotation() {
        isRotating = false
        displayLink?.invalidate()
        displayLink = nil
    }
    
    func toggleMotionTracking() {
        isMotionTrackingEnabled.toggle()
        
        if isMotionTrackingEnabled {
            startMotionTracking()
        } else {
            stopMotionTracking()
        }
    }
    
    private func startMotionTracking() {
        guard selectedImage != nil else { return }
        
        // Resetujemo offset slike na početnu poziciju
        imageOffset = .zero
        
        // Kalibrišemo trenutni položaj telefona kao referentnu tačku
        motionManager.calibrate()
        
        // Startujemo praćenje pokreta
        motionManager.startTracking()
        
        // Pratimo promene u nagibu sa optimizovanim throttle i debounce
        motionManager.$pitch
            .combineLatest(motionManager.$roll)
            .throttle(for: .milliseconds(16), scheduler: RunLoop.main, latest: true) // 60fps
            .debounce(for: .milliseconds(8), scheduler: RunLoop.main)
            .sink { [weak self] pitch, roll in
                self?.updateImagePosition(pitch: pitch, roll: roll)
            }
            .store(in: &cancellables)
    }
    
    private func stopMotionTracking() {
        motionManager.stopTracking()
    }
    
    private func updateImagePosition(pitch: Double, roll: Double) {
        guard let maxOffset = calculateMaxOffset() else { return }
        
        // Računamo delta pomeranje
        let deltaX = CGFloat(roll) * 15.0
        let deltaY = CGFloat(pitch) * 15.0
        
        // Proveravamo da li će novo pomeranje izaći iz granica
        let newX = imageOffset.x + deltaX
        let newY = imageOffset.y + deltaY
        
        // Ograničavamo pomeranje na maksimalne vrednosti
        let clampedX = max(-maxOffset.x, min(maxOffset.x, newX))
        let clampedY = max(-maxOffset.y, min(maxOffset.y, newY))
        
        // Ažuriramo poziciju
        imageOffset = CGPoint(x: clampedX, y: clampedY)
    }
    
    func resetImage() {
        HapticManager.playImpact(style: .rigid)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            scale = minScale
            rotation = 0
        }
        imageOffset = .zero
        stopMotionTracking()
    }
    
    func resetApp() {
        selectedHand = nil
        selectedItems = []
        images = []
        selectedImage = nil
        hasSelectedImage = false
        scale = minScale
        rotation = 0
        imageOffset = .zero
        stopMotionTracking()
    }
    
    // Funkcija za računanje stvarne veličine slike pri različitim zoomovima
    private func calculateImageSize(at scale: CGFloat) -> CGSize? {
        guard let image = selectedImage else { return nil }
        
        // Računamo stvarnu veličinu slike nakon skaliranja
        let scaledWidth = image.size.width * scale
        let scaledHeight = image.size.height * scale
        
        return CGSize(width: scaledWidth, height: scaledHeight)
    }
    
    // Funkcija za prikazivanje informacija o veličini
    func getImageSizeInfo() -> String {
        guard let scaledSize = calculateImageSize(at: scale) else { return "Nema slike" }
        
        return """
        Veličina slike: \(Int(scaledSize.width))×\(Int(scaledSize.height))
        Nivo zumiranja: \(String(format: "%.1f", scale))x
        Rotacija: \(String(format: "%.1f", rotation))°
        """
    }
    
    // Funkcija za računanje maksimalnog pomeranja slike u svakom smeru
    private func calculateMaxOffset() -> (x: CGFloat, y: CGFloat)? {
        guard let image = selectedImage else { return nil }
        
        // Dobijamo veličinu ekrana
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Računamo aspect ratio slike i ekrana
        let imageAspectRatio = image.size.width / image.size.height
        let screenAspectRatio = screenWidth / screenHeight
        
        // Računamo stvarnu veličinu slike nakon skaliranja sa .fit
        let scaledWidth: CGFloat
        let scaledHeight: CGFloat
        
        if imageAspectRatio > screenAspectRatio {
            // Slika je šira od ekrana
            scaledWidth = screenWidth * scale
            scaledHeight = scaledWidth / imageAspectRatio
        } else {
            // Slika je viša od ekrana
            scaledHeight = screenHeight * scale
            scaledWidth = scaledHeight * imageAspectRatio
        }
        
        // Računamo maksimalno pomeranje uzimajući u obzir rotaciju
        let maxOffsetX = max((scaledWidth - screenWidth) / 2, 0)
        let maxOffsetY = max((scaledHeight - screenHeight) / 2, 0)
        
        // Ako je slika rotirana za 90° ili 270°, zamenjujemo X i Y vrednosti
        let normalizedRotation = abs(rotation.truncatingRemainder(dividingBy: 360))
        if normalizedRotation >= 90 && normalizedRotation < 270 {
            return (maxOffsetY, maxOffsetX)
        }
        
        return (maxOffsetX, maxOffsetY)
    }
    
    // Funkcija za prikazivanje informacija o pomeranju
    func getOffsetInfo() -> String {
        guard let maxOffset = calculateMaxOffset() else { return "Nema slike" }
        
        return """
        Trenutno pomeranje: \(Int(imageOffset.x))px,\(Int(imageOffset.y))px
        Maksimalno pomeranje: \(Int(maxOffset.x))px,\(Int(maxOffset.y))px
        """
    }
} 
