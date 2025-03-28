import SwiftUI

struct WelcomeLogoView: View {
    // MARK: - Properties
    let size: CGFloat
    let opacity: Double
    let isAnimating: Bool
    let rotation: Double
    let pitchAngle: Double
    let rollAngle: Double
    let onTap: () -> Void
    
    private var logoSize: CGFloat { size * 0.67 }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundCircle
            animatedLogo
        }
        .opacity(opacity)
        .onTapGesture {
            HapticManager.playSelection()
            onTap()
        }
    }
    
    // MARK: - Private Views
    private var backgroundCircle: some View {
        Circle()
            .fill(AppTheme.Gradients.primary)
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
            )
            .shadow(radius: AppTheme.Shadows.medium.radius,
                   x: AppTheme.Shadows.medium.x,
                   y: AppTheme.Shadows.medium.y)
    }
    
    private var animatedLogo: some View {
        Image("OneHandLogo")
            .resizable()
            .scaledToFit()
            .frame(width: logoSize, height: logoSize)
            .foregroundColor(.white)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .rotationEffect(.degrees(rotation))
            .rotation3DEffect(.degrees(pitchAngle), axis: (x: 1, y: 0, z: 0))
            .rotation3DEffect(.degrees(rollAngle), axis: (x: 0, y: 1, z: 0))
    }
}

#Preview {
    ZStack {
        Color.black
        
        WelcomeLogoView(
            size: 120,
            opacity: 1.0,
            isAnimating: false,
            rotation: 0,
            pitchAngle: 0,
            rollAngle: 0,
            onTap: {}
        )
    }
    .frame(width: 300, height: 300)
} 