import SwiftUI

final class WelcomeAnimationManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isLogoAnimating = false
    @Published var rotation = 0.0
    @Published var pitchAngle = 0.0
    @Published var rollAngle = 0.0
    
    // Fade in animations
    @Published var titleOpacity = 0.0
    @Published var logoOpacity = 0.0
    @Published var controlsOpacity = 0.0
    
    // Animation state
    private var isAnimating = false
    
    // MARK: - Animation Constants
    private enum Constants {
        static let fadeInDuration: Double = 0.8
        static let fadeInDelay: Double = 0.3
        static let rotationDuration: Double = 0.8
        static let tiltAngle: Double = 50
        static let resetDelay: Double = 0.1
    }
    
    // MARK: - Public Methods
    func animateEntrance() {
        // Title fade in
        withAnimation(.easeOut(duration: Constants.fadeInDuration)) {
            titleOpacity = 1
        }
        
        // Logo fade in with delay
        withAnimation(.easeOut(duration: Constants.fadeInDuration).delay(Constants.fadeInDelay)) {
            logoOpacity = 1
        }
        
        // Controls fade in with longer delay
        withAnimation(.easeOut(duration: Constants.fadeInDuration).delay(Constants.fadeInDelay * 2)) {
            controlsOpacity = 1
        }
    }
    
    func animateLogo() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // 1. Yaw rotation clockwise
        animateYawRotation(clockwise: true) {
            // 2. Pitch forward and back
            self.animatePitchTilt {
                // 3. Roll left and right
                self.animateRollTilt {
                    // 4. Yaw rotation counter-clockwise
                    self.animateYawRotation(clockwise: false) {
                        // Reset state
                        self.resetAnimationState()
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func animateYawRotation(clockwise: Bool, completion: @escaping () -> Void) {
        withAnimation(Animation.easeInOut(duration: Constants.rotationDuration).repeatCount(1, autoreverses: true)) {
            if clockwise {
                isLogoAnimating = true
            } else {
                rotation = -360
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.rotationDuration * 2) {
            completion()
        }
    }
    
    private func animatePitchTilt(completion: @escaping () -> Void) {
        // Forward tilt
        withAnimation(Animation.easeInOut(duration: Constants.rotationDuration).repeatCount(1, autoreverses: true)) {
            pitchAngle = Constants.tiltAngle
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.rotationDuration * 2) {
            // Backward tilt
            withAnimation(Animation.easeInOut(duration: Constants.rotationDuration).repeatCount(1, autoreverses: true)) {
                self.pitchAngle = -Constants.tiltAngle
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.rotationDuration * 2) {
                // Reset
                withAnimation(.easeInOut(duration: Constants.rotationDuration / 2)) {
                    self.pitchAngle = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.rotationDuration) {
                    completion()
                }
            }
        }
    }
    
    private func animateRollTilt(completion: @escaping () -> Void) {
        // Left tilt
        withAnimation(Animation.easeInOut(duration: Constants.rotationDuration).repeatCount(1, autoreverses: true)) {
            rollAngle = -Constants.tiltAngle
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.rotationDuration * 2) {
            // Right tilt
            withAnimation(Animation.easeInOut(duration: Constants.rotationDuration).repeatCount(1, autoreverses: true)) {
                self.rollAngle = Constants.tiltAngle
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.rotationDuration * 2) {
                // Reset
                withAnimation(.easeInOut(duration: Constants.rotationDuration / 2)) {
                    self.rollAngle = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.rotationDuration) {
                    completion()
                }
            }
        }
    }
    
    private func resetAnimationState() {
        withAnimation(.easeInOut(duration: Constants.rotationDuration / 2)) {
            isLogoAnimating = false
            rotation = 0
        }
        isAnimating = false
    }
} 