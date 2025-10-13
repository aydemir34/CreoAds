import SwiftUI
import FirebaseCore
import RevenueCat
import UIKit

// MARK: - Main App Structure
@main
struct CreoadsApp: App {
    
    @StateObject private var authService = AuthService()
    @StateObject private var onboardingCoordinator = OnboardingCoordinator()
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    // MARK: - App Initialization
    init() {
        print("🚀 CreoadsApp init() - Uygulama Başlatılıyor.")
        
        // RevenueCat Configuration - TEST MODE
        let revenueCatApiKey = "test_api_key_placeholder"
        
        Purchases.logLevel = .debug
        print("💰 RevenueCat yapılandırılıyor (TEST MODE).")
        
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
            AppFlowCoordinator()
                .environmentObject(authService)
                .environmentObject(onboardingCoordinator)
        }
    }
}

// MARK: - Firebase Delegate
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// MARK: - App Flow Coordinator
struct AppFlowCoordinator: View {
    @EnvironmentObject var onboardingCoordinator: OnboardingCoordinator
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        Group {
            if !onboardingCoordinator.isAppOnboardingCompleted {
                // 1. İlk Açılış: App Onboarding (3 sayfa)
                CreoAdsOnboardingView()
                    .transition(.opacity)
            } else if !authService.isAuthenticated {
                // 2. Login Ekranı
                AnimatedLoginView()
                    .transition(.opacity)
            } else if !onboardingCoordinator.isOnboardingCompleted {
                // 3. Eğitim Onboarding (4 sayfa) - Login sonrası
                EducationalOnboardingView()
                    .transition(.opacity)
            } else {
                // 4. Ana Uygulama
                MainAppView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: onboardingCoordinator.isAppOnboardingCompleted)
        .animation(.easeInOut(duration: 0.3), value: authService.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: onboardingCoordinator.isOnboardingCompleted)
    }
}

// MARK: - Main App View
struct MainAppView: View {
    @EnvironmentObject var onboardingCoordinator: OnboardingCoordinator
    
    var body: some View {
        TabView {
            VStack(spacing: 20) {
                Text("Ana Sayfa")
                    .font(.largeTitle)
                
                Text("🎉 Tüm onboarding'ler tamamlandı!")
                    .font(.headline)
                
                #if DEBUG
                Button("🔄 Onboarding'i Sıfırla") {
                    onboardingCoordinator.resetOnboarding()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(12)
                #endif
            }
            .tabItem {
                Label("Ana Sayfa", systemImage: "house.fill")
            }
            
            Text("Oluştur")
                .tabItem {
                    Label("Oluştur", systemImage: "plus.circle.fill")
                }
            
            Text("Profil")
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }
        }
    }
}
