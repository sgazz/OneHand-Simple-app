import SwiftUI

struct CompassIndicator: View {
    let pitch: Double
    let roll: Double
    let isActive: Bool
    let maxDistance: CGFloat = 100
    
    private var arrowOpacity: Double {
        isActive ? 1.0 : 0.0
    }
    
    var body: some View {
        ZStack {
            // Vertikalne strelice
            VStack(spacing: maxDistance) {
                Image(systemName: "arrow.up")
                    .opacity(pitch < 0 ? arrowOpacity : 0.3)
                Image(systemName: "arrow.down")
                    .opacity(pitch > 0 ? arrowOpacity : 0.3)
            }
            
            // Horizontalne strelice
            HStack(spacing: maxDistance) {
                Image(systemName: "arrow.left")
                    .opacity(roll < 0 ? arrowOpacity : 0.3)
                Image(systemName: "arrow.right")
                    .opacity(roll > 0 ? arrowOpacity : 0.3)
            }
        }
        .font(.system(size: 24, weight: .bold))
        .foregroundColor(.white)
        .opacity(isActive ? 1 : 0) // Ceo kompas se sakriva kada nije aktivan
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

#Preview {
    ZStack {
        Color.black
        CompassIndicator(pitch: 0.5, roll: -0.3, isActive: true)
    }
} 