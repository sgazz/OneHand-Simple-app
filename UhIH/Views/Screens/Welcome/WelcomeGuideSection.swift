import SwiftUI

struct WelcomeGuideSection: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    
    init(titleKey: String, contentKey: String) {
        self.title = NSLocalizedString(titleKey, comment: "")
        self.content = NSLocalizedString(contentKey, comment: "")
    }
    
    static let sections: [WelcomeGuideSection] = [
        WelcomeGuideSection(
            titleKey: "welcome.section1.title",
            contentKey: "welcome.section1.content"
        ),
        WelcomeGuideSection(
            titleKey: "welcome.section2.title",
            contentKey: "welcome.section2.content"
        ),
        WelcomeGuideSection(
            titleKey: "welcome.section3.title",
            contentKey: "welcome.section3.content"
        ),
        WelcomeGuideSection(
            titleKey: "welcome.section4.title",
            contentKey: "welcome.section4.content"
        )
    ]
    
    // Помоћна функција за добијање секције по индексу са провером граница
    static func section(at index: Int) -> WelcomeGuideSection? {
        guard index >= 0 && index < sections.count else { return nil }
        return sections[index]
    }
    
    // Укупан број секција
    static var count: Int {
        sections.count
    }
} 