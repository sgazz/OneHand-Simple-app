import Foundation

struct WelcomeGuideSection: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    
    static let sections: [WelcomeGuideSection] = [
        WelcomeGuideSection(
            title: NSLocalizedString("welcome.section1.title", comment: ""),
            content: NSLocalizedString("welcome.section1.content", comment: "")
        ),
        WelcomeGuideSection(
            title: NSLocalizedString("welcome.section2.title", comment: ""),
            content: NSLocalizedString("welcome.section2.content", comment: "")
        ),
        WelcomeGuideSection(
            title: NSLocalizedString("welcome.section3.title", comment: ""),
            content: NSLocalizedString("welcome.section3.content", comment: "")
        ),
        WelcomeGuideSection(
            title: NSLocalizedString("welcome.section4.title", comment: ""),
            content: NSLocalizedString("welcome.section4.content", comment: "")
        )
    ]
} 