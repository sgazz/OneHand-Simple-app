import SwiftUI

struct RadialMenuView: View {
    @State private var isExpanded = false
    @State private var rotation: Double = 0
    @State private var showSettings = false
    @ObservedObject var viewModel: ContentViewModel
    
    // Boje za bordere
    private let borderColors = [
        "minus.magnifyingglass": Color(red: 0.2, green: 0.8, blue: 0.7).opacity(0.8),      // Tirkizno-zelena
        "plus.magnifyingglass": Color(red: 0.2, green: 0.8, blue: 0.7).opacity(0.8),       // Tirkizno-zelena
        "arrow.counterclockwise.circle": Color(red: 0.8, green: 0.2, blue: 0.2).opacity(0.8), // Tamno crvena
        "arrow.clockwise": Color(red: 0.9, green: 0.5, blue: 0.2).opacity(0.8),           // Topla narandžasta
        "arrow.counterclockwise": Color(red: 0.9, green: 0.5, blue: 0.2).opacity(0.8),    // Topla narandžasta
        "move.3d": Color.white.opacity(0.8),                    // Bela sa providnošću
        "slider.horizontal.3": Color(red: 0.4, green: 0.7, blue: 1.0).opacity(0.8)        // Nebo plava
    ]
    
    // Konfiguracija dugmadi
    private var menuItems: [RadialMenuItem] {
        [
            RadialMenuItem(icon: "minus.magnifyingglass", color: .white.opacity(0.6)),
            RadialMenuItem(icon: "plus.magnifyingglass", color: .white.opacity(0.6)),
            RadialMenuItem(icon: "arrow.counterclockwise.circle", color: .white.opacity(0.6)),
            RadialMenuItem(icon: "arrow.clockwise", color: .white.opacity(0.6)),
            RadialMenuItem(icon: "arrow.counterclockwise", color: .white.opacity(0.6)),
            RadialMenuItem(icon: "move.3d", color: .white.opacity(0.6)),
            RadialMenuItem(icon: "slider.horizontal.3", color: .white.opacity(0.6))
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
                        onTap: { showUI() },
                        showSettings: $showSettings,
                        borderColor: borderColors[item.icon] ?? .white.opacity(0.6)
                    )
                }
                
                // Centralno dugme
                Button(action: {
                    HapticManager.playImpact(style: isExpanded ? .rigid : .light)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                        rotation += 45
                        showUI()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.6))  // Povećan opacitet centralnog dugmeta
                            .overlay(
                                Circle()
                                    .stroke(Color(white: 0.15), lineWidth: 1)
                            )
                            .shadow(color: Color(white: 0.15).opacity(0.3), radius: 2, x: 0, y: 0)
                        
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
        .overlay {
            if showSettings {
                SettingsView(viewModel: viewModel, isPresented: $showSettings)
                    .transition(.opacity)
            }
        }
        .onChange(of: showSettings) { oldValue, newValue in
            if newValue {
                NotificationCenter.default.post(name: NSNotification.Name("SettingsOpened"), object: nil)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name("SettingsClosed"), object: nil)
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
    @Binding var showSettings: Bool
    let borderColor: Color
    
    private var iconOpacity: Double {
        switch item.icon {
        case "minus.magnifyingglass", "plus.magnifyingglass":
            return 1.0  // Zoom ikone
        case "arrow.clockwise", "arrow.counterclockwise":
            return 1.0  // Rotation ikone
        case "slider.horizontal.3":
            return 1.0  // Settings ikona
        default:
            return 0.9  // Ostale ikone
        }
    }
    
    var body: some View {
        Image(systemName: item.icon)
            .font(.system(size: 24, weight: .heavy))
            .foregroundColor(.white)  // Čisto bela boja za SF Symbols
            .frame(width: index == 2 ? 45 : 60, height: index == 2 ? 45 : 60)
            .background(item.color)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(borderColor, lineWidth: 1)
            )
            .shadow(color: borderColor.opacity(0.5), radius: 2, x: 0, y: 0)
            .shadow(color: .white.opacity(0.3), radius: 1, x: 0, y: 0)
            .onTapGesture {
                onTap()
                if item.icon == "arrow.counterclockwise.circle" {
                    HapticManager.playImpact(style: .rigid)
                    viewModel.resetImage()
                } else if item.icon == "move.3d" {
                    HapticManager.playImpact(style: viewModel.isMotionTrackingEnabled ? .soft : .medium)
                    viewModel.toggleMotionTracking()
                } else if item.icon == "slider.horizontal.3" {
                    HapticManager.playSelection()
                    showSettings = true
                }
            }
            .simultaneousGesture(
                TapGesture(count: 2)
                    .onEnded { _ in
                        onTap()
                        switch item.icon {
                        case "plus.magnifyingglass":
                            HapticManager.playZoom(zoomIn: true)
                            viewModel.zoomToMax()
                        case "minus.magnifyingglass":
                            HapticManager.playZoom(zoomIn: false)
                            viewModel.zoomToMin()
                        case "arrow.clockwise":
                            HapticManager.playRotation(intensity: 1.0)
                            viewModel.rotateClockwise()
                        case "arrow.counterclockwise":
                            HapticManager.playRotation(intensity: 1.0)
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
                        HapticManager.playImpact(style: .medium)
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
                        HapticManager.playImpact(style: .light)
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
