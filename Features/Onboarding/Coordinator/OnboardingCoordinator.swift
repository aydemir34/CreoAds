//
//  OnboardingCoordinator.swift
//  CreoAds
//
//  Created by Ömer F. Aydemir on 29/09/2025.
//


import SwiftUI
import Combine

// MARK: - Onboarding Coordinator
@MainActor
class OnboardingCoordinator: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentStep: OnboardingStep = .welcome
    @Published var isOnboardingCompleted: Bool = false
    @Published var isAppOnboardingCompleted: Bool = false
    @Published var userName: String = ""
    @Published var userSector: String = ""
    @Published var userProductType: String = ""
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let onboardingCompletedKey = "hasCompletedOnboarding"
    private let appOnboardingCompletedKey = "hasCompletedAppOnboarding"
    private let onboardingUserNameKey = "onboardingUserName"
    private let onboardingSectorKey = "onboardingSector"
    private let onboardingProductTypeKey = "onboardingProductType"
    
    // MARK: - Computed Properties
    var progress: Double {
        let totalSteps = Double(OnboardingStep.allCases.count)
        return (Double(currentStep.rawValue) + 1.0) / totalSteps
    }
    
    var isLastStep: Bool {
        currentStep == OnboardingStep.allCases.last
    }
    
    var isFirstStep: Bool {
        currentStep == OnboardingStep.allCases.first
    }
    
    // MARK: - Initialization
    init() {
    #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("RESET_ONBOARDING") {
                userDefaults.removeObject(forKey: onboardingCompletedKey)
                userDefaults.removeObject(forKey: appOnboardingCompletedKey)
                userDefaults.removeObject(forKey: onboardingUserNameKey)
                userDefaults.removeObject(forKey: onboardingSectorKey)
                userDefaults.removeObject(forKey: onboardingProductTypeKey)
            }
    #endif
            self.isOnboardingCompleted = userDefaults.bool(forKey: onboardingCompletedKey)
            self.isAppOnboardingCompleted = userDefaults.bool(forKey: appOnboardingCompletedKey)
            self.userName = userDefaults.string(forKey: onboardingUserNameKey) ?? ""
            self.userSector = userDefaults.string(forKey: onboardingSectorKey) ?? ""
            self.userProductType = userDefaults.string(forKey: onboardingProductTypeKey) ?? ""
        }
    
    // MARK: - Navigation Methods
    func next() {
        guard !isLastStep else { return }
        
        if let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
           currentIndex + 1 < OnboardingStep.allCases.count {
            currentStep = OnboardingStep.allCases[currentIndex + 1]
        }
    }
    
    func previous() {
        guard !isFirstStep else { return }
        
        if let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
           currentIndex > 0 {
            currentStep = OnboardingStep.allCases[currentIndex - 1]
        }
    }
    
    func goToStep(_ step: OnboardingStep) {
        currentStep = step
    }
    
    // MARK: - User Profile Sync
    func updateUserProfile(name: String, sector: String, productType: String) {
            userName = name
            userSector = sector
            userProductType = productType
            
            userDefaults.set(name, forKey: onboardingUserNameKey)
            userDefaults.set(sector, forKey: onboardingSectorKey)
            userDefaults.set(productType, forKey: onboardingProductTypeKey)
        }
        
        // MARK: - Completion Methods
    
    // MARK: - Completion Methods
    func completeAppOnboarding() {
        isAppOnboardingCompleted = true
        userDefaults.set(true, forKey: appOnboardingCompletedKey)
    }
    
    func completeEducationalOnboarding() {
        isOnboardingCompleted = true
        userDefaults.set(true, forKey: onboardingCompletedKey)
    }
    
    func resetOnboarding() {
            isOnboardingCompleted = false
            isAppOnboardingCompleted = false
            currentStep = .welcome
            userName = ""
            userSector = ""
            userProductType = ""
            userDefaults.removeObject(forKey: onboardingCompletedKey)
            userDefaults.removeObject(forKey: appOnboardingCompletedKey)
            userDefaults.removeObject(forKey: onboardingUserNameKey)
            userDefaults.removeObject(forKey: onboardingSectorKey)
            userDefaults.removeObject(forKey: onboardingProductTypeKey)
        }
    
    // MARK: - Premium Features (Gelecek için hazır)
    func checkPremiumAccess() -> Bool {
        // Premium kontrol mantığı buraya gelecek
        return false
    }
    
    func unlockPremiumFeatures() {
        // Premium özellikler unlock mantığı
    }
}
