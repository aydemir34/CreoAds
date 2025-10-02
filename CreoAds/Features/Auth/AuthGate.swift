import SwiftUI

struct AuthGate: View {
    @StateObject private var authService = AuthService()
    @StateObject private var onboardingCoordinator = OnboardingCoordinator()
    var body: some View {
        if !onboardingCoordinator.isAppOnboardingCompleted {
            CreoAdsOnboardingView()
                .environmentObject(onboardingCoordinator)
        } else {
            Group {
                if authService.user != nil {
                    if onboardingCoordinator.isOnboardingCompleted {
                        MainTabView()
                            .environmentObject(authService)
                            .environmentObject(onboardingCoordinator)
                    } else {
                        OnboardingContainerView()
                            .environmentObject(onboardingCoordinator)
                    }
                } else {
                    AnimatedLoginView()
                        .environmentObject(authService)
                        .environmentObject(onboardingCoordinator)
                }
            }
        }
    }
}
