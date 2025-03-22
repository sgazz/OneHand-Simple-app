import Foundation
import CoreMotion
import Combine

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private let updateInterval: TimeInterval = 1.0 / 60.0 // 60Hz osvežavanje
    
    // Published properties za praćenje nagiba
    @Published var pitch: Double = 0.0  // nagib napred-nazad
    @Published var roll: Double = 0.0   // nagib levo-desno
    
    // Status praćenja pokreta
    @Published var isTracking: Bool = false
    
    // Granice za bounce efekat
    private var bounceThreshold: Double = 0.1
    private var lastBounceTime: Date?
    private let bounceInterval: TimeInterval = 0.5
    
    init() {
        setupMotionManager()
    }
    
    private func setupMotionManager() {
        motionManager.deviceMotionUpdateInterval = updateInterval
    }
    
    func startTracking() {
        guard !isTracking, motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self,
                  let motion = motion,
                  error == nil else { return }
            
            // Ažuriramo vrednosti sa filterom za glatkije pokrete
            self.pitch = motion.attitude.pitch
            self.roll = motion.attitude.roll
            
            // Proveravamo granice i primenjujemo bounce ako je potrebno
            self.checkBoundsAndApplyBounce()
        }
        
        isTracking = true
    }
    
    func stopTracking() {
        guard isTracking else { return }
        
        motionManager.stopDeviceMotionUpdates()
        isTracking = false
        
        // Resetujemo vrednosti
        pitch = 0.0
        roll = 0.0
    }
    
    private func checkBoundsAndApplyBounce() {
        // Implementiraćemo kasnije kada dodamo MotionBoundary
    }
    
    deinit {
        stopTracking()
    }
} 