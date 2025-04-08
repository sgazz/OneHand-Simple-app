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
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            VStack(spacing: isLandscape ? 10 : 20) {
                Text(LocalizedStringKey("pro.title"))
                    .font(isLandscape ? .title2 : .title)
                    .bold()
                
                VStack(alignment: .leading, spacing: isLandscape ? 8 : 15) {
                    FeatureRow(icon: "plus.magnifyingglass", 
                              text: LocalizedStringKey("pro.feature.zoom"),
                              isLandscape: isLandscape)
                    FeatureRow(icon: "slider.horizontal.3", 
                              text: LocalizedStringKey("pro.feature.control"),
                              isLandscape: isLandscape)
                    FeatureRow(icon: "gauge.with.dots.needle.50percent", 
                              text: LocalizedStringKey("pro.feature.performance"),
                              isLandscape: isLandscape)
                    FeatureRow(icon: "star.fill", 
                              text: LocalizedStringKey("pro.feature.support"),
                              isLandscape: isLandscape)
                }
                .padding(.vertical, isLandscape ? 5 : 10)
                
                Text(LocalizedStringKey("pro.price"))
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
                        Text(LocalizedStringKey("pro.purchase"))
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
                        Text(LocalizedStringKey("pro.restore"))
                            .font(isLandscape ? .footnote : .body)
                            .foregroundColor(.blue)
                    }
                }
                .disabled(isPurchasing || isRestoring)
                
                Button(action: {
                    HapticManager.playSelection()
                    isPresented = false
                }) {
                    Text(LocalizedStringKey("pro.later"))
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

struct FeatureRow: View {
    let icon: String
    let text: LocalizedStringKey
    let isLandscape: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: isLandscape ? 16 : 20))
            Text(text)
                .font(isLandscape ? .footnote : .body)
        }
    }
}

#Preview {
    ProVersionView(isPresented: .constant(true),
                  onPurchase: { },
                  onRestore: { })
} 