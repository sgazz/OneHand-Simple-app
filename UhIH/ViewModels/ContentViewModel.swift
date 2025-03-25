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
    private var motionBoundary: MotionBoundary?
    
    // Set za čuvanje Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // Feedback generator za bounce
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    private var lastDebugPrintTime: TimeInterval = 0
    private let debugPrintInterval: TimeInterval = 0.5 // Prikazujemo podatke svakih 500ms
    
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
        
        // Ažuriramo boundary kada se promeni zoom
        updateMotionBoundary()
    }
    
    @objc private func handleZoomOut() {
        guard isZooming else { return }
        
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        scale = max(scale - currentZoomSpeed * CGFloat(deltaTime * 60), minScale)
        currentZoomSpeed = min(currentZoomSpeed * accelerationFactor, maxZoomSpeed)
        
        // Ažuriramo boundary kada se promeni zoom
        updateMotionBoundary()
    }
    
    private func updateMotionBoundary() {
        guard let image = selectedImage else { return }
        
        // Ažuriramo boundary sa novom skalom
        motionBoundary = MotionBoundary(
            imageSize: image.size,
            viewSize: UIScreen.main.bounds.size,
            scale: scale
        )
        
        // Ažuriramo debug informacije
        if let scaledSize = calculateImageSize(at: scale),
           let maxOffset = calculateMaxOffset() {
            let screenSize = UIScreen.main.bounds.size
            let distanceFromLeft = maxOffset.x + imageOffset.x
            let distanceFromRight = maxOffset.x - imageOffset.x
            let distanceFromTop = maxOffset.y + imageOffset.y
            let distanceFromBottom = maxOffset.y - imageOffset.y
            
            print("""
            ----------------------------------------
            ZOOM PROMENA: \(String(format: "%.1f", scale))x
            ----------------------------------------
            Ekran: \(Int(screenSize.width))×\(Int(screenSize.height))
            Slika: \(Int(scaledSize.width))×\(Int(scaledSize.height))
            ----------------------------------------
            Od ivica:
            Levo: \(String(format: "%.1f", distanceFromLeft))px
            Desno: \(String(format: "%.1f", distanceFromRight))px
            Gore: \(String(format: "%.1f", distanceFromTop))px
            Dole: \(String(format: "%.1f", distanceFromBottom))px
            ----------------------------------------
            """)
        }
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
    
    func toggleMotionTracking() {
        isMotionTrackingEnabled.toggle()
        
        if isMotionTrackingEnabled {
            startMotionTracking()
        } else {
            stopMotionTracking()
        }
    }
    
    private func startMotionTracking() {
        guard let image = selectedImage else { return }
        
        // Inicijalizujemo boundary sa trenutnim dimenzijama
        motionBoundary = MotionBoundary(
            imageSize: image.size,
            viewSize: UIScreen.main.bounds.size,
            scale: scale
        )
        
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
        // Pomeranje počinje tek kada je slika zoomirana (scale > 1.0)
        let motionFactor: CGFloat = scale > 1.0 ? (1.0 + (scale - 1.0) * (4.0 / 9.0)) : 0.0
        
        // Konvertujemo nagib u pomeranje sa manjom osetljivošću
        let deltaX = CGFloat(roll) * motionFactor * 15 // Smanjili smo sa 25 na 15
        let deltaY = CGFloat(pitch) * motionFactor * 15 // Smanjili smo sa 25 na 15
        
        // Proveravamo granice i ažuriramo poziciju sa glatkom animacijom
        if let maxOffset = calculateMaxOffset() {
            // Računamo potencijalnu novu poziciju
            let potentialX = imageOffset.x + deltaX
            let potentialY = imageOffset.y + deltaY
            
            // Ograničavamo pomeranje na maksimalne vrednosti sa glatkim prelazima
            withAnimation(.interactiveSpring(
                response: 0.8,           // Povećali smo sa 0.5 na 0.8 za sporije kretanje
                dampingFraction: 0.85,   // Povećali smo sa 0.8 na 0.85 za glatkije zaustavljanje
                blendDuration: 0.4       // Povećali smo sa 0.3 na 0.4 za glatkije prelaze
            )) {
                imageOffset.x = max(min(potentialX, maxOffset.x), -maxOffset.x)
                imageOffset.y = max(min(potentialY, maxOffset.y), -maxOffset.y)
            }
        } else {
            // Ako nemamo granice, ažuriramo poziciju normalno
            withAnimation(.interactiveSpring(
                response: 0.8,           // Povećali smo sa 0.5 na 0.8 za sporije kretanje
                dampingFraction: 0.85,   // Povećali smo sa 0.8 na 0.85 za glatkije zaustavljanje
                blendDuration: 0.4       // Povećali smo sa 0.3 na 0.4 za glatkije prelaze
            )) {
                imageOffset = CGPoint(
                    x: imageOffset.x + deltaX,
                    y: imageOffset.y + deltaY
                )
            }
        }
        
        // Debug informacije (smanjena frekvenca)
        let currentTime = CACurrentMediaTime()
        if currentTime - lastDebugPrintTime >= debugPrintInterval {
            if let scaledSize = calculateImageSize(at: scale),
               let maxOffset = calculateMaxOffset() {
                let screenSize = UIScreen.main.bounds.size
                let distanceFromLeft = maxOffset.x + imageOffset.x
                let distanceFromRight = maxOffset.x - imageOffset.x
                let distanceFromTop = maxOffset.y + imageOffset.y
                let distanceFromBottom = maxOffset.y - imageOffset.y
                
                print("""
                ----------------------------------------
                Ekran: \(Int(screenSize.width))×\(Int(screenSize.height))
                Slika: \(Int(scaledSize.width))×\(Int(scaledSize.height)) (\(String(format: "%.1f", scale))x)
                ----------------------------------------
                Od ivica:
                Levo: \(String(format: "%.1f", distanceFromLeft))px
                Desno: \(String(format: "%.1f", distanceFromRight))px
                Gore: \(String(format: "%.1f", distanceFromTop))px
                Dole: \(String(format: "%.1f", distanceFromBottom))px
                ----------------------------------------
                Pitch: \(String(format: "%.1f", pitch))° | Roll: \(String(format: "%.1f", roll))°
                Pomeranje: \(String(format: "%.1f", deltaX))px,\(String(format: "%.1f", deltaY))px
                ----------------------------------------
                """)
            }
            lastDebugPrintTime = currentTime
        }
    }
    
    func resetImage() {
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
        """
    }
    
    // Funkcija za računanje maksimalnog pomeranja slike u svakom smeru
    private func calculateMaxOffset() -> (x: CGFloat, y: CGFloat)? {
        guard let image = selectedImage else { return nil }
        
        // Računamo ravnomerno raspoređen fiksni zoom od 1.0 do 5.0 za zoom od 1 do 10
        let fixedScale: CGFloat = 1.0 + (scale - 1.0) * (4.0 / 9.0)
        
        let scaledWidth = image.size.width * fixedScale
        let scaledHeight = image.size.height * fixedScale
        
        // Dobijamo veličinu ekrana
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
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
