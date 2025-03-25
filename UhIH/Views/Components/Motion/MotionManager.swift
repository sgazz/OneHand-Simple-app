import Foundation
import CoreMotion
import Combine
import QuartzCore

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private let updateInterval: TimeInterval = 1.0 / 60.0 // 60Hz osvežavanje
    
    // Published properties za praćenje nagiba
    @Published var pitch: Double = 0.0  // nagib napred-nazad
    @Published var roll: Double = 0.0   // nagib levo-desno
    
    // Baseline vrednosti za kalibraciju
    private var baselinePitch: Double = 0.0
    private var baselineRoll: Double = 0.0
    
    // Mrtva zona (u radijanima)
    private let deadZone: Double = 0.05 // približno 2.8 stepeni
    
    // Maksimalne vrednosti (u radijanima)
    private let maxPitch: Double = 0.5 // približno 28.6 stepeni
    private let maxRoll: Double = 0.5  // približno 28.6 stepeni
    
    // Status praćenja pokreta
    @Published var isTracking: Bool = false
    @Published var isInDeadZone: Bool = true
    
    // Granice za bounce efekat
    private var bounceThreshold: Double = 0.1
    private var lastBounceTime: Date?
    private let bounceInterval: TimeInterval = 0.5
    
    // Optimizacija performansi
    private var lastUpdateTime: TimeInterval = 0
    private let minUpdateInterval: TimeInterval = 1.0 / 60.0 // 60fps
    
    init() {
        setupMotionManager()
    }
    
    private func setupMotionManager() {
        motionManager.deviceMotionUpdateInterval = updateInterval
    }
    
    func calibrate() {
        guard let motion = motionManager.deviceMotion else { return }
        baselinePitch = motion.attitude.pitch
        baselineRoll = motion.attitude.roll
        isInDeadZone = true
        lastUpdateTime = CACurrentMediaTime()
    }
    
    func startTracking() {
        guard !isTracking, motionManager.isDeviceMotionAvailable else { return }
        
        // Startujemo praćenje pokreta
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self,
                  let motion = motion,
                  error == nil else { return }
            
            // Optimizacija performansi - proveravamo minimalni interval između ažuriranja
            let currentTime = CACurrentMediaTime()
            guard currentTime - self.lastUpdateTime >= self.minUpdateInterval else { return }
            self.lastUpdateTime = currentTime
            
            // Ako još nismo kalibrisani, postavljamo baseline
            if !self.isTracking {
                self.baselinePitch = motion.attitude.pitch
                self.baselineRoll = motion.attitude.roll
                self.isInDeadZone = true
                self.isTracking = true
                return
            }
            
            // Računamo relativne vrednosti u odnosu na baseline
            let relativePitch = motion.attitude.pitch - self.baselinePitch
            let relativeRoll = motion.attitude.roll - self.baselineRoll
            
            // Proveravamo mrtvu zonu
            let isInPitchDeadZone = abs(relativePitch) < self.deadZone
            let isInRollDeadZone = abs(relativeRoll) < self.deadZone
            self.isInDeadZone = isInPitchDeadZone && isInRollDeadZone
            
            // Ažuriramo vrednosti samo ako smo izvan mrtve zone
            if !self.isInDeadZone {
                // Ograničavamo vrednosti na maksimalne
                self.pitch = -max(min(relativePitch, self.maxPitch), -self.maxPitch)
                self.roll = -max(min(relativeRoll, self.maxRoll), -self.maxRoll)
            } else {
                self.pitch = 0
                self.roll = 0
            }
            
            // Proveravamo granice i primenjujemo bounce ako je potrebno
            self.checkBoundsAndApplyBounce()
        }
    }
    
    func stopTracking() {
        guard isTracking else { return }
        
        motionManager.stopDeviceMotionUpdates()
        isTracking = false
        
        // Resetujemo vrednosti
        pitch = 0.0
        roll = 0.0
        isInDeadZone = true
    }
    
    private func checkBoundsAndApplyBounce() {
        // Implementiraćemo kasnije kada dodamo MotionBoundary
    }
    
    deinit {
        stopTracking()
    }
} 