import SwiftUI

enum NavigationDirection {
    case left, right
}

class GuideAnimationManager: ObservableObject {
    @Published var slideOffset: CGFloat = 0
    @Published var opacity: Double = 1
    @Published var scale: CGFloat = 1
    
    private let screenWidth = UIScreen.main.bounds.width
    
    func animateTransition(to direction: NavigationDirection, completion: @escaping () -> Void) {
        let targetOffset = direction == .left ? -screenWidth : screenWidth
        
        withAnimation(AppTheme.Animations.spring) {
            slideOffset = targetOffset / 2
            opacity = 0
            scale = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.slideOffset = -targetOffset
            self.opacity = 0
            
            withAnimation(AppTheme.Animations.spring) {
                self.slideOffset = 0
                self.opacity = 1
                self.scale = 1
            }
            
            completion()
        }
    }
    
    func resetAnimation() {
        withAnimation(AppTheme.Animations.spring) {
            slideOffset = 0
            opacity = 1
            scale = 1
        }
    }
}

extension GuideAnimationManager {
    func handleDragGesture(value: DragGesture.Value) {
        slideOffset = value.translation.width
        opacity = 1.0 - abs(Double(value.translation.width / 300))
        scale = 1.0 - abs(value.translation.width / 1000)
    }
    
    func handleDragEnd(value: DragGesture.Value, 
                      currentIndex: Int,
                      totalSections: Int,
                      onNavigate: (Int, NavigationDirection) -> Void) {
        let threshold: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 75 : 50
        
        if value.translation.width > threshold && currentIndex > 0 {
            onNavigate(currentIndex - 1, .right)
        } else if value.translation.width < -threshold && currentIndex < totalSections - 1 {
            onNavigate(currentIndex + 1, .left)
        } else {
            resetAnimation()
        }
    }
} 