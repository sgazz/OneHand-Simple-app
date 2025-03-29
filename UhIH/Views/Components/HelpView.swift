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
                Text(LocalizedStringKey("help.title"))
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.top)
                
                // ScrollView sa objašnjenjima
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // Centralno dugme
                        HelpItem(
                            title: "help.central_button",
                            icon: "plus",
                            description: "help.central_button_desc"
                        )
                        
                        // Zumiranje
                        HelpItem(
                            title: "help.zoom",
                            icon: "magnifyingglass",
                            description: "help.zoom_desc"
                        )
                        
                        // Rotacija
                        HelpItem(
                            title: "help.rotation",
                            icon: "arrow.clockwise",
                            description: "help.rotation_desc"
                        )
                        
                        // Reset
                        HelpItem(
                            title: "help.reset",
                            icon: "arrow.counterclockwise.circle",
                            description: "help.reset_desc"
                        )
                        
                        // Praćenje pokreta
                        HelpItem(
                            title: "help.motion",
                            icon: "move.3d",
                            description: "help.motion_desc"
                        )
                        
                        // Podešavanja
                        HelpItem(
                            title: "help.settings",
                            icon: "slider.horizontal.3",
                            description: "help.settings_desc"
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
                Text(LocalizedStringKey(title))
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(LocalizedStringKey(description))
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