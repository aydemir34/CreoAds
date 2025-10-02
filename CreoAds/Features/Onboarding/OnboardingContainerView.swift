import SwiftUI

struct OnboardingContainerView: View {
    // Claude ile oluşturduğunuz ve artık projemizin beyni olan Coordinator.
    @StateObject private var coordinator = OnboardingCoordinator()

    var body: some View {
        // Bu View, her sayfanın etrafındaki çerçeveyi (header, footer) sağlar.
        // Bu dosyanın içeriği önceki adımlardaki gibi doğruydu.
        OnboardingBaseView {
            // Kaydırılabilir sayfaları yöneten PageView
            TabView(selection: $coordinator.currentStep.animation(.spring())) {
                // Artık OnboardingStep.allCases üzerinden döngü kuruyoruz.
                ForEach(OnboardingStep.allCases, id: \.self) { step in
                    // OnboardingPageView'a artık 'step' veriyoruz.
                    OnboardingPageView(step: step)
                        .tag(step)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        // Coordinator'ı tüm alt View'ların erişebilmesi için environment'a ekliyoruz.
        .environmentObject(coordinator)
    }
}
