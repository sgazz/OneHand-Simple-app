import SwiftUI

struct GuideProgressIndicator: View {
    let currentIndex: Int
    let totalSections: Int
    let onSectionSelect: (Int) -> Void
    @State private var progressScale: CGFloat = 1
    
    var body: some View {
        HStack(spacing: AppTheme.Layout.progressIndicatorSpacing) {
            ForEach(0..<totalSections, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ?
                          AppTheme.Colors.progressActive :
                          AppTheme.Colors.progressInactive)
                    .frame(width: AppTheme.Layout.progressIndicatorSize,
                           height: AppTheme.Layout.progressIndicatorSize)
                    .scaleEffect(index == currentIndex ? progressScale : 1)
                    .animation(Animation.spring(
                        response: 0.3,
                        dampingFraction: 0.5,
                        blendDuration: 0
                    ).repeatCount(1), value: progressScale)
                    .onTapGesture {
                        onSectionSelect(index)
                    }
            }
        }
        .padding(.vertical, AppTheme.Layout.spacingLarge)
        .onChange(of: currentIndex) { oldValue, newValue in
            progressScale = 1.2
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                progressScale = 1.0
            }
        }
    }
}

#Preview {
    GuideProgressIndicator(
        currentIndex: 1,
        totalSections: 4,
        onSectionSelect: { _ in }
    )
    .background(Color.black)
} 