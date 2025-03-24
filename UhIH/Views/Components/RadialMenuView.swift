import SwiftUI

struct RadialMenuView: View {
    @State private var isExpanded = false
    @State private var rotation: Double = 0
    @ObservedObject var viewModel: ContentViewModel
    
    // Konfiguracija dugmadi
    private var menuItems: [RadialMenuItem] {
        [
            RadialMenuItem(icon: "minus.magnifyingglass", color: .white.opacity(0.2)),
            RadialMenuItem(icon: "plus.magnifyingglass", color: .white.opacity(0.2)),
            RadialMenuItem(icon: "arrow.counterclockwise.circle", color: .white.opacity(0.2)),
            RadialMenuItem(icon: "arrow.clockwise", color: .white.opacity(0.2)),
            RadialMenuItem(icon: "arrow.counterclockwise", color: .white.opacity(0.2)),
            RadialMenuItem(icon: "move.3d", color: .white.opacity(0.2)),
            RadialMenuItem(icon: "slider.horizontal.3", color: .white.opacity(0.2))
        ]
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Radijalna dugmad
                ForEach(Array(menuItems.enumerated()), id: \.offset) { index, item in
                    MenuButton(
                        item: item,
                        isExpanded: isExpanded,
                        index: index,
                        totalItems: menuItems.count,
                        rotation: rotation,
                        selectedHand: viewModel.selectedHand ?? .right,
                        viewModel: viewModel,
                        onTap: { showUI() }
                    )
                }
                
                // Centralno dugme
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                        rotation += 45
                        showUI()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        
                        Image(systemName: isExpanded ? "xmark" : "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .frame(width: 70, height: 70)
                }
                .rotationEffect(.degrees(rotation))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .position(
                x: viewModel.selectedHand == .right ? geometry.size.width * 0.7 : geometry.size.width * 0.3,
                y: geometry.size.height - 230
            )
            .onAppear {
                print("Screen size: \(geometry.size)")
                print("X position: \(viewModel.selectedHand == .right ? geometry.size.width * 0.7 : geometry.size.width * 0.3)")
                print("Y position: \(geometry.size.height - 230)")
                print("Distance from bottom: 230.0")
            }
        }
    }
    
    private func showUI() {
        NotificationCenter.default.post(name: NSNotification.Name("ResetUITimer"), object: nil)
    }
}

// Model za menu item
struct RadialMenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
}

// Komponenta za pojedinačno dugme u meniju
struct MenuButton: View {
    let item: RadialMenuItem
    let isExpanded: Bool
    let index: Int
    let totalItems: Int
    let rotation: Double
    let selectedHand: ContentViewModel.Handedness
    @ObservedObject var viewModel: ContentViewModel
    let onTap: () -> Void
    
    var body: some View {
        Image(systemName: item.icon)
            .font(.title3)
            .foregroundColor(.white)
            .frame(width: index == 2 ? 45 : 60, height: index == 2 ? 45 : 60)
            .background(item.color)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
            .onTapGesture {
                onTap()
                if item.icon == "arrow.counterclockwise.circle" {
                    viewModel.resetImage()
                } else if item.icon == "move.3d" {
                    viewModel.toggleMotionTracking()
                }
            }
            .simultaneousGesture(
                TapGesture(count: 2)
                    .onEnded { _ in
                        onTap()
                        switch item.icon {
                        case "plus.magnifyingglass":
                            viewModel.zoomToMax()
                        case "minus.magnifyingglass":
                            viewModel.zoomToMin()
                        case "arrow.clockwise":
                            viewModel.rotateClockwise()
                        case "arrow.counterclockwise":
                            viewModel.rotateCounterclockwise()
                        default:
                            break
                        }
                    }
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.1)
                    .onEnded { _ in
                        onTap()
                        switch item.icon {
                        case "plus.magnifyingglass":
                            viewModel.startContinuousZoomIn()
                        case "minus.magnifyingglass":
                            viewModel.startContinuousZoomOut()
                        case "arrow.clockwise":
                            viewModel.startContinuousRotationClockwise()
                        case "arrow.counterclockwise":
                            viewModel.startContinuousRotationCounterclockwise()
                        default:
                            break
                        }
                    }
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { _ in
                        onTap()
                        viewModel.stopZooming()
                        viewModel.stopRotation()
                    }
            )
            .offset(x: isExpanded ? calculateOffset().x : 0,
                    y: isExpanded ? calculateOffset().y : 0)
            .scaleEffect(isExpanded ? 1 : 0.1)
            .animation(
                .spring(
                    response: 0.5,
                    dampingFraction: 0.8,
                    blendDuration: 0.3
                )
                .delay(Double(index) * 0.03),
                value: isExpanded
            )
    }
    
    private func calculateOffset() -> CGPoint {
        let radius: CGFloat = 90 // Smanjena udaljenost za lakšu dostupnost
        
        // Koordinatni sistem:
        // 0° (0) = desno
        // 90° (π/2) = gore
        // 180° (π) = levo
        // 270° (3π/2) = dole
        
        // Za desnoruke: 315° do 45° (270° raspon)
        // Za levoruke: -45° do -315° (zrcaljenje)
        let startAngle: CGFloat = selectedHand == .right ? .pi*7/4 : -.pi/4 // 315° ili -45°
        let endAngle: CGFloat = selectedHand == .right ? .pi/4 : -.pi*7/4 // 45° ili -315°
        
        // Izračunavanje ugla za trenutno dugme
        let angleRange = endAngle - startAngle
        let angleStep = angleRange / CGFloat(totalItems - 1)
        var angle: CGFloat
        
        if index == 2 { // Reset dugme
            // Izračunavamo uglove za zoom in (index 1) i rotation (index 3)
            let zoomInAngle = startAngle + (angleStep * 1)
            let rotationAngle = startAngle + (angleStep * 3)
            // Postavljamo reset dugme tačno na sredinu između ta dva ugla
            angle = (zoomInAngle + rotationAngle) / 2
            return CGPoint(
                x: selectedHand == .right ? radius * cos(angle) : -radius * cos(angle),
                y: radius * sin(angle)
            )
        } else {
            angle = startAngle + (angleStep * CGFloat(index))
        }
        
        // Konverzija iz radijana u koordinate
        var x = radius * cos(angle)
        let y = radius * sin(angle)
        
        // Zrcalimo x koordinatu za levoruke
        if selectedHand == .left {
            x = -x
        }
        
        return CGPoint(x: x, y: y)
    }
}

#Preview {
    RadialMenuView(viewModel: ContentViewModel())
        .padding()
} 