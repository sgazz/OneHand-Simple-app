import SwiftUI

struct HelpView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        ZStack {
            // Blur pozadina
            Color.clear
                .edgesIgnoringSafeArea(.all)
                .background(.ultraThinMaterial)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            
            // Sadržaj
            VStack(spacing: 20) {
                // Naslov
                Text("Kako koristiti dugmad")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.top)
                
                // ScrollView sa objašnjenjima
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // Centralno dugme
                        HelpItem(
                            title: "Centralno dugme",
                            icon: "plus",
                            description: "Otvara/zatvara radijalni meni"
                        )
                        
                        // Zumiranje
                        HelpItem(
                            title: "Zumiranje",
                            icon: "magnifyingglass",
                            description: "Dugim držanjem zumira unutra/iz\nDuplim tapom zumira na max/min"
                        )
                        
                        // Rotacija
                        HelpItem(
                            title: "Rotacija",
                            icon: "arrow.clockwise",
                            description: "Dugim držanjem kontinuirano rotira\nDuplim tapom rotira za 45°"
                        )
                        
                        // Reset
                        HelpItem(
                            title: "Reset",
                            icon: "arrow.counterclockwise.circle",
                            description: "Resetuje sliku na početno stanje"
                        )
                        
                        // Praćenje pokreta
                        HelpItem(
                            title: "Praćenje pokreta",
                            icon: "move.3d",
                            description: "Uključuje/isključuje praćenje pokreta telefona"
                        )
                        
                        // Podešavanja
                        HelpItem(
                            title: "Podešavanja",
                            icon: "slider.horizontal.3",
                            description: "Otvara meni sa podešavanjima"
                        )
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.vertical, 40)
            .allowsHitTesting(false)
        }
        .transition(.opacity)
    }
}

// Komponenta za pojedinačno objašnjenje
struct HelpItem: View {
    let title: String
    let icon: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }
}

#Preview {
    HelpView(isPresented: .constant(true), viewModel: ContentViewModel())
} 