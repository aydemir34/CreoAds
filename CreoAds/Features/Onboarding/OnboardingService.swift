import Foundation
import Combine

// MARK: - Onboarding Service
@MainActor
class OnboardingService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isFirstLaunch: Bool
    @Published var showOnboarding: Bool = false
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let onboardingCompletedKey = "hasCompletedOnboarding"
    private let appVersionKey = "lastAppVersion"
    
    // MARK: - Initialization
    init() {
        let hasCompleted = userDefaults.bool(forKey: onboardingCompletedKey)
        self.isFirstLaunch = !hasCompleted
        self.showOnboarding = !hasCompleted
        
        // Version kontrolü (gelecek güncellemeler için)
        checkForVersionUpdate()
    }
    
    // MARK: - Public Methods
    func completeOnboarding() {
        isFirstLaunch = false
        showOnboarding = false
        userDefaults.set(true, forKey: onboardingCompletedKey)
        userDefaults.set(getCurrentAppVersion(), forKey: appVersionKey)
    }
    
    func resetOnboarding() {
        isFirstLaunch = true
        showOnboarding = true
        userDefaults.removeObject(forKey: onboardingCompletedKey)
        userDefaults.removeObject(forKey: appVersionKey)
    }
    
    func shouldShowOnboarding() -> Bool {
        return showOnboarding
    }
    
    // MARK: - Private Methods
    private func checkForVersionUpdate() {
        let currentVersion = getCurrentAppVersion()
        let lastVersion = userDefaults.string(forKey: appVersionKey)
        
        // Eğer versiyon değiştiyse ve önemli güncellemeler varsa onboarding göster
        if lastVersion != currentVersion && shouldShowOnboardingForVersion(currentVersion) {
            showOnboarding = true
        }
    }
    
    private func getCurrentAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private func shouldShowOnboardingForVersion(_ version: String) -> Bool {
        // Gelecekte önemli güncellemeler için onboarding göstermek isteyebiliriz
        return false
    }
    
    // MARK: - Premium Features (Gelecek için hazır)
    func checkPremiumOnboardingAccess() -> Bool {
        // Premium onboarding özellikleri kontrolü
        return true // Şimdilik herkese açık
    }
    
    func trackOnboardingCompletion() {
        // Analytics tracking buraya gelecek
        print("Onboarding completed - Analytics event")
    }
}
