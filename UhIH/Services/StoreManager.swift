import StoreKit

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProducts: [Product] = []
    
    private let productIdentifiers = ["com.onehand.app.pro"]
    
    #if DEBUG
    private var mockPurchased = false
    
    private func simulatePurchase() {
        print("StoreManager: Симулирам куповину...")
        mockPurchased = true
        print("StoreManager: Симулација куповине је успешна")
    }
    #endif
    
    private init() {
        print("StoreManager: Иницијализација...")
        
        // Проверавамо да ли је StoreKit конфигурација доступна
        if let configURL = Bundle.main.url(forResource: "StoreKit", withExtension: "storekit") {
            print("StoreManager: Пронађена StoreKit конфигурација на локацији: \(configURL.path)")
        } else {
            print("StoreManager: УПОЗОРЕЊЕ - StoreKit конфигурација није пронађена!")
        }
        
        // Учитавамо производе одмах при иницијализацији
        Task {
            await loadProducts()
        }
    }
    
    func loadProducts() async {
        print("StoreManager: Учитавање производа...")
        print("StoreManager: Тражим производе са ID-јевима: \(productIdentifiers)")
        
        do {
            products = try await Product.products(for: productIdentifiers)
            
            print("StoreManager: Успешно учитани производи: \(products.count)")
            if products.isEmpty {
                print("StoreManager: УПОЗОРЕЊЕ - Нису пронађени производи!")
                print("StoreManager: Проверите да ли је StoreKit конфигурација правилно подешена")
                print("StoreManager: Производ ID који тражимо: \(productIdentifiers)")
            }
            
            for product in products {
                print("StoreManager: Производ - ID: \(product.id)")
                print("StoreManager: Производ - Име: \(product.displayName)")
                print("StoreManager: Производ - Цена: \(product.displayPrice)")
                print("StoreManager: Производ - Тип: \(product.type)")
            }
        } catch {
            print("StoreManager: Грешка при учитавању производа: \(error)")
            print("StoreManager: Детаљи грешке: \(error.localizedDescription)")
        }
    }
    
    func purchase() async throws {
        print("StoreManager: Започињем куповину...")
        
        #if DEBUG
        simulatePurchase()
        return
        #else
        guard let product = products.first else {
            print("StoreManager: Нема доступних производа за куповину")
            throw StoreError.productNotFound
        }
        
        print("StoreManager: Покушавам куповину производа:")
        print("- ID: \(product.id)")
        print("- Име: \(product.displayName)")
        print("- Цена: \(product.displayPrice)")
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(_):
                print("StoreManager: Куповина је успешна, верификујем трансакцију...")
                purchasedProducts.append(product)
                print("StoreManager: Трансакција је успешно обрађена")
            case .userCancelled:
                print("StoreManager: Корисник је отказао куповину")
                throw StoreError.userCancelled
            case .pending:
                print("StoreManager: Куповина је на чекању")
                throw StoreError.pending
            @unknown default:
                print("StoreManager: Непозната грешка при куповини")
                throw StoreError.unknown
            }
        } catch {
            print("StoreManager: Грешка при куповини: \(error)")
            throw error
        }
        #endif
    }
    
    func restorePurchases() async throws {
        #if DEBUG
        print("StoreManager: Симулирам обнављање куповине...")
        simulatePurchase()
        #else
        try await AppStore.sync()
        await updatePurchasedProducts()
        #endif
    }
    
    var isProUser: Bool {
        #if DEBUG
        return mockPurchased
        #else
        return !purchasedProducts.isEmpty
        #endif
    }
}

enum StoreError: LocalizedError {
    case productNotFound
    case userCancelled
    case pending
    case verificationFailed(any Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Pro верзија није доступна за куповину."
        case .userCancelled:
            return "Куповина је отказана."
        case .pending:
            return "Куповина је на чекању."
        case .verificationFailed:
            return "Грешка при верификацији куповине."
        case .unknown:
            return "Дошло је до непознате грешке."
        }
    }
} 

