import Foundation

struct WelcomeGuideSection: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    
    static let sections: [WelcomeGuideSection] = [
        WelcomeGuideSection(
            title: "Dobrodošli",
            content: "Dobrodošli u OneHand Simple App! Naučite kako da koristite aplikaciju za interaktivno upravljanje slikama."
        ),
        WelcomeGuideSection(
            title: "Osnovne funkcije",
            content: "Izaberite vašu dominantnu ruku i sliku iz galerije da biste započeli."
        ),
        WelcomeGuideSection(
            title: "Gestikulacije",
            content: "Koristite nagibe uređaja za pomeranje slike. Za zumiranje i rotaciju koristite dugmad u radijalnom meniju."
        ),
        WelcomeGuideSection(
            title: "Saveti",
            content: "Za najbolje rezultate, držite uređaj stabilno i koristite male, kontrolisane pokrete."
        )
    ]
} 