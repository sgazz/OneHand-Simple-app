import SwiftUI

class WelcomeGuideViewModel: ObservableObject {
    @AppStorage("shouldShowWelcomeGuide") private var shouldShowWelcomeGuide: Bool = true
    @Published var isShowingGuide: Bool = false
    @Published var showAlways: Bool = true
    
    func showGuide() {
        isShowingGuide = shouldShowWelcomeGuide
    }
    
    func dismissGuide() {
        isShowingGuide = false
        shouldShowWelcomeGuide = showAlways
    }
} 