import SwiftUI

struct RadialMenuView: View {
    @State private var isExpanded = false
    @State private var rotation: Double = 0
    @ObservedObject var viewModel: ContentViewModel
    
    // Konfiguracija dugmadi
    let menuItems: [RadialMenuItem] = [
        RadialMenuItem(icon: "magnifyingglass", color: .blue),
        RadialMenuItem(icon: "crop", color: .green),
        RadialMenuItem(icon: "wand.and.stars", color: .purple),
        RadialMenuItem(icon: "slider.horizontal.3", color: .orange)
    ]
    
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
                        selectedHand: viewModel.selectedHand ?? .right
                    )
                }
                
                // Centralno dugme
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                        rotation += 45
                    }
                }) {
                    Image(systemName: isExpanded ? "xmark" : "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 70, height: 70)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .rotationEffect(.degrees(rotation))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .position(
                x: viewModel.selectedHand == .right ? geometry.size.width * 0.7 : geometry.size.width * 0.3,
                y: geometry.size.height * 0.85
            )
        }
        .frame(height: 200)
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
    
    var body: some View {
        Button(action: {
            // Akcija za dugme
        }) {
            Image(systemName: item.icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(item.color)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .offset(x: isExpanded ? calculateOffset().x : 0,
                y: isExpanded ? calculateOffset().y : 0)
        .opacity(isExpanded ? 1 : 0)
        .scaleEffect(isExpanded ? 1 : 0.1)
    }
    
    private func calculateOffset() -> CGPoint {
        let radius: CGFloat = 90 // Smanjena udaljenost za lakšu dostupnost
        
        // Koordinatni sistem:
        // 0° (0) = desno
        // 90° (π/2) = gore
        // 180° (π) = levo
        // 270° (3π/2) = dole
        
        // Za obe ruke koristimo iste uglove (315° do 135°)
        // Za levoruke ćemo samo zrcaliti x koordinatu
        let startAngle: CGFloat = .pi*7/4 // 315° (225° + 90°)
        let endAngle: CGFloat = .pi*3/4 // 135° (45° + 90°)
        
        // Izračunavanje ugla za trenutno dugme
        let angleRange = endAngle - startAngle
        let angleStep = angleRange / CGFloat(totalItems - 1)
        let angle = startAngle + (angleStep * CGFloat(index))
        
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