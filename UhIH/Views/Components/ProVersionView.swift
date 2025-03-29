import SwiftUI

struct ProVersionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isPresented: Bool
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var errorMessage: String?
    
    var onPurchase: () async -> Void
    var onRestore: () async -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Откључајте Pro верзију")
                .font(.title)
                .bold()
            
            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(icon: "plus.magnifyingglass", text: "Сви нивои зума од 1x до 10x")
                FeatureRow(icon: "sparkles", text: "Екстремни зум: 15x и 20x")
                FeatureRow(icon: "checkmark.circle", text: "Прецизнија контрола зумирања")
            }
            .padding(.vertical)
            
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
                    Text("Купи Pro верзију")
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

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: 20))
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    ProVersionView(isPresented: .constant(true),
                  onPurchase: { },
                  onRestore: { })
} 