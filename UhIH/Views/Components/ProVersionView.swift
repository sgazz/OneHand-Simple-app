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
        VStack(spacing: 12) {
            Text("pro.unlock_title", bundle: .main)
                .font(.title3)
                .bold()
            
            VStack(alignment: .leading, spacing: 8) {
                FeatureRow(icon: "plus.magnifyingglass", text: "pro.feature.zoom")
                FeatureRow(icon: "slider.horizontal.3", text: "pro.feature.zoom_control")
                FeatureRow(icon: "gauge.with.dots.needle.50percent", text: "pro.feature.performance")
                FeatureRow(icon: "star.fill", text: "pro.feature.support")
            }
            .padding(.vertical, 8)
            
            Text("pro.price", bundle: .main)
                .font(.callout)
                .foregroundColor(.blue)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
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
                    Text("pro.buy_button", bundle: .main)
                        .font(.callout)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(8)
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
                    Text("pro.restore_button", bundle: .main)
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
            }
            .disabled(isPurchasing || isRestoring)
            
            Button(action: {
                HapticManager.playSelection()
                isPresented = false
            }) {
                Text("pro.maybe_later", bundle: .main)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .disabled(isPurchasing || isRestoring)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 16)
        .padding(12)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: LocalizedStringKey
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: 16))
            Text(text, bundle: .main)
                .font(.footnote)
        }
    }
}

#Preview {
    ProVersionView(isPresented: .constant(true),
                  onPurchase: { },
                  onRestore: { })
} 