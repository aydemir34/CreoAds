import SwiftUI
import FirebaseCore
import RevenueCat
import UIKit

// MARK: - Main App Structure
@main
struct CreoadsApp: App {
    
    @StateObject private var authService = AuthService()
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    // MARK: - App Initialization
    init() {
        print("🚀 CreoadsApp init() - Uygulama Başlatılıyor.")
        
        // 2. RevenueCat Configuration - TEST MODE
        // ⚠️ PRODUCTION'DA GERÇEK API KEY KULLANIN!
        let revenueCatApiKey = "test_api_key_placeholder" // TEST MODU
        
        Purchases.logLevel = .debug
        print("💰 RevenueCat yapılandırılıyor (TEST MODE).")
        
        // Test modunda hata vermemesi için try-catch ekleyelim
        do {
            Purchases.configure(withAPIKey: revenueCatApiKey)
            print("✅ RevenueCat başarıyla yapılandırıldı (TEST MODE).")
        } catch {
            print("⚠️ RevenueCat yapılandırma hatası (TEST MODE): \(error)")
        }
    }
    
    // MARK: - App Body
    var body: some Scene {
        WindowGroup {
            AuthGate()
                .environmentObject(authService)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
