import SwiftUI

struct OnboardingPageView: View {
    // Veri modeli olarak artık 'OnboardingStep' kullanıyoruz.
    let step: OnboardingStep

    var body: some View {
        VStack(spacing: 20) {
            // Tüm verileri 'step' üzerinden alıyoruz (step.systemImage, step.title vb.)
            Image(systemName: step.systemImage)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(.accentColor) // accentColor'ı genel tema rengi olarak kullanıyoruz
                .padding(.bottom, 30)

            Text(step.subtitle)
                .font(.headline)
                .foregroundColor(.secondary)

            Text(step.title)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(step.description)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.top, 10)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
        // Bu, metnin ekrana sığma ve ortalanma sorununu çözen kısımdır.
        .frame(maxHeight: .infinity)
    }
}
