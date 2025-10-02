import SwiftUI

struct OnboardingWelcomeView: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator

    var body: some View {
        OnboardingContainerView()
            .environmentObject(coordinator)
    }
}
