import SwiftUI

struct ExtremeZoomView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isPresented: Bool
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var errorMessage: String?
    
    var onPurchase: () async -> Void
    var onRestore: () async -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Екстремни зум")
                .font(.title)
                .bold()
            
            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(icon: "plus.magnifyingglass", text: "Сви нивои зума (до 20x)")
                FeatureRow(icon: "sparkles", text: "Укључује све Pro функције")
                FeatureRow(icon: "arrow.up.forward", text: "Додатни нивои: 15x и 20x")
                FeatureRow(icon: "exclamationmark.triangle", text: "За напредне кориснике")
            }
            .padding(.vertical)
            
            Text("Само $0.99")
                .font(.headline)
                .foregroundColor(.blue)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                HapticManager.playSelection()
                Task {
                    isPurchasing = true
                    await onPurchase()
                    isPurchasing = false
                }
            }) {
                if isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Купи Extreme Zoom")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .disabled(isPurchasing || isRestoring)
            
            Button(action: {
                HapticManager.playSelection()
                Task {
                    isRestoring = true
                    await onRestore()
                    isRestoring = false
                }
            }) {
                if isRestoring {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Обнови куповину")
                        .foregroundColor(.blue)
                }
            }
            .disabled(isPurchasing || isRestoring)
            
            Button(action: {
                HapticManager.playSelection()
                isPresented = false
            }) {
                Text("Можда касније")
                    .foregroundColor(.secondary)
            }
            .disabled(isPurchasing || isRestoring)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding()
    }
}

#Preview {
    ExtremeZoomView(isPresented: .constant(true),
                    onPurchase: { },
                    onRestore: { })
} 