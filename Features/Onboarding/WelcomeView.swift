import SwiftUI

struct WelcomeView: View {
    // Artık EnvironmentObject olarak Coordinator'ı bekliyoruz.
    @EnvironmentObject var coordinator: OnboardingCoordinator
    
    @State private var isAnimating = false

    var body: some View {
        // Tüm elemanları dikey olarak hizalamak için ana bir VStack ekledik.
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                Text("Yaratıcı yönetmen artık sensin.")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Sıradan ürün fotoğraflarını, saniyeler içinde olağanüstü reklamlara dönüştür.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 30)

            Spacer()

            Button(action: {
                // Coordinator'a bir sonraki adıma geçmesini söylüyoruz.
                coordinator.next()
            }) {
                Text("2 Ücretsiz Deneme ile Başla")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Preview (DÜZELTİLMİŞ BÖLÜM)
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            // DÜZELTME: Eski OnboardingService yerine yeni Coordinator'ı kullanıyoruz.
            .environmentObject(OnboardingCoordinator())
    }
}
