import SwiftUI

@MainActor
class WelcomeGuideViewModel: ObservableObject {
    @AppStorage("shouldShowWelcomeGuide") private var shouldShowWelcomeGuide: Bool = true
    @Published var isShowingGuide: Bool = false
    @Published var showAlways: Bool = true
    
    // Reference to ContentViewModel
    private let contentViewModel: ContentViewModel
    
    init(contentViewModel: ContentViewModel) {
        self.contentViewModel = contentViewModel
    }
    
    var selectedHand: ContentViewModel.Handedness? {
        get { contentViewModel.selectedHand }
        set { contentViewModel.selectedHand = newValue }
    }
    
    func showGuide() {
        isShowingGuide = shouldShowWelcomeGuide
    }
    
    func dismissGuide() {
        isShowingGuide = false
        shouldShowWelcomeGuide = showAlways
    }
} 