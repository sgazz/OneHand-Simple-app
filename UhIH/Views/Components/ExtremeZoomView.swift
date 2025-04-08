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
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            VStack(spacing: isLandscape ? 10 : 20) {
                Text(LocalizedStringKey("extreme.title"))
                    .font(isLandscape ? .title2 : .title)
                    .bold()
                
                VStack(alignment: .leading, spacing: isLandscape ? 8 : 15) {
                    FeatureRow(icon: "plus.magnifyingglass", 
                              text: LocalizedStringKey("extreme.feature.zoom"),
                              isLandscape: isLandscape)
                    FeatureRow(icon: "sparkles", 
                              text: LocalizedStringKey("extreme.feature.pro"),
                              isLandscape: isLandscape)
                    FeatureRow(icon: "arrow.up.forward", 
                              text: LocalizedStringKey("extreme.feature.levels"),
                              isLandscape: isLandscape)
                    FeatureRow(icon: "exclamationmark.triangle", 
                              text: LocalizedStringKey("extreme.feature.advanced"),
                              isLandscape: isLandscape)
                }
                .padding(.vertical, isLandscape ? 5 : 10)
                
                Text(LocalizedStringKey("extreme.price"))
                    .font(isLandscape ? .callout : .headline)
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
                        Text(LocalizedStringKey("extreme.purchase"))
                            .font(isLandscape ? .callout : .headline)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(isLandscape ? 8 : 12)
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
                        Text(LocalizedStringKey("extreme.restore"))
                            .font(isLandscape ? .footnote : .body)
                            .foregroundColor(.blue)
                    }
                }
                .disabled(isPurchasing || isRestoring)
                
                Button(action: {
                    HapticManager.playSelection()
                    isPresented = false
                }) {
                    Text(LocalizedStringKey("extreme.later"))
                        .font(isLandscape ? .footnote : .body)
                        .foregroundColor(.secondary)
                }
                .disabled(isPurchasing || isRestoring)
            }
            .padding(isLandscape ? 12 : 16)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding()
        }
    }
}

#Preview {
    ExtremeZoomView(isPresented: .constant(true),
                    onPurchase: { },
                    onRestore: { })
} 