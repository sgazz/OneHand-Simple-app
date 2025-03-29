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
    
    // Додајемо observer za сцену
    private var scenePhaseObserver: AnyCancellable?
    
    // Додајемо нове константе за оптимизацију величине
    private let screenScale = UIScreen.main.scale
    private var maxImageDimension: CGFloat {
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let screenSize = UIScreen.main.bounds.size
        
        // Прилагођавамо максималну димензију слике на основу меморије уређаја
        // и величине екрана
        if totalMemory < 2_000_000_000 { // 2GB
            return min(1536, max(screenSize.width, screenSize.height) * screenScale)
        } else if totalMemory < 4_000_000_000 { // 4GB
            return min(2048, max(screenSize.width, screenSize.height) * screenScale)
        } else {
            return min(3072, max(screenSize.width, screenSize.height) * screenScale)
        }
    }
    
    init() {
        setupScenePhaseObserver()
        setupMemoryWarningObserver()
    }
    
    deinit {
        scenePhaseObserver?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupScenePhaseObserver() {
        scenePhaseObserver = NotificationCenter.default
            .publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.handleBackgroundTransition()
            }
    }
    
    private func setupMemoryWarningObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    private func handleBackgroundTransition() {
        // Чистимо кеш слика које нису тренутно приказане
        images.removeAll(where: { $0 !== selectedImage })
        
        // Ослобађамо ресурсе који нису неопходни
        displayLink?.invalidate()
        displayLink = nil
        stopMotionTracking()
        
        // Форсирамо ослобађање меморије
        autoreleasepool {
            images = []
            if let currentImage = selectedImage {
                images = [currentImage]
            }
        }
    }
    
    @objc private func handleMemoryWarning() {
        // Чистимо све слике осим тренутно приказане
        images.removeAll(where: { $0 !== selectedImage })
        
        // Ресетујемо зум и ротацију на подразумеване вредности
        scale = minScale
        rotation = 0
        imageOffset = .zero
        
        // Форсирамо ослобађање меморије
        autoreleasepool {
            images = []
            if let currentImage = selectedImage {
                images = [currentImage]
            }
        }
    }
    
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
            if let data = try? await item.loadTransferable(type: Data.self) {
                // Prvo učitavamo sliku da bismo dobili njene dimenzije
                if let originalImage = UIImage(data: data) {
                    await MainActor.run {
                        // Optimizujemo sliku pre čuvanja
                        if let optimizedImage = compressImage(originalImage) {
                            // Čistimo prethodne slike iz memorije
                            images.removeAll()
                            selectedImage = optimizedImage
                            images.append(optimizedImage)
                            hasSelectedImage = true
                            scale = minScale
                            HapticManager.playImpact(style: .medium)
                        }
                    }
                }
            }
        }
    }
    
    // Funkcija za kompresiju i optimizaciju slike
    private func compressImage(_ image: UIImage) -> UIImage? {
        let scale = image.size.width > image.size.height ? 
            maxImageDimension / image.size.width : 
            maxImageDimension / image.size.height
            
        // Ако је слика мања од максималне димензије, само је компресујемо
        if scale >= 1.0 {
            return compressImageData(image)
        }
        
        // Рачунамо нову величину слике
        let newSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        
        // Користимо оптимизовани контекст за цртање
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0 // Спречавамо додатно скалирање
        format.preferredRange = .standard
        
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let scaledImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return compressImageData(scaledImage)
    }
    
    // Funkcija za kompresiju podataka slike
    private func compressImageData(_ image: UIImage) -> UIImage? {
        // Динамички одређујемо квалитет компресије на основу величине слике
        let compressionQuality: CGFloat
        let pixelCount = image.size.width * image.size.height
        
        if pixelCount > 4_000_000 { // 4 мегапиксела
            compressionQuality = 0.6
        } else if pixelCount > 2_000_000 { // 2 мегапиксела
            compressionQuality = 0.7
        } else {
            compressionQuality = 0.8
        }
        
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            return image
        }
        return UIImage(data: imageData)
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
        guard let scaledSize = calculateImageSize(at: scale) else { return NSLocalizedString("image_detail.no_image", comment: "Message when no image is selected") }
        
        return String(format: NSLocalizedString("image_detail.size_info", comment: "Image size information"),
                     "\(Int(scaledSize.width))×\(Int(scaledSize.height))")
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
        guard let maxOffset = calculateMaxOffset() else { return "" }
        
        return String(format: NSLocalizedString("image_detail.offset_info", comment: "Image offset information"),
                     String(format: "%.1f", imageOffset.x),
                     String(format: "%.1f", imageOffset.y),
                     String(format: "%.1f", maxOffset.x),
                     String(format: "%.1f", maxOffset.y))
    }
} 
