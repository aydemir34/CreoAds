import SwiftUI
import AuthenticationServices
import UIKit

// MARK: - Ana Görünüm
struct AnimatedLoginView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var animationPhase: CGFloat = 0
    @State private var showAuthUI = false
    @State private var showEmailLoginSheet = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var appleSignInCoordinator: AppleSignInCoordinator?
    
    private let showcaseCards: [LoginShowcaseCard] = [
        .init(title: "Nature Escape", subtitle: "Outdoor ürün vitrini", style: .nature),
        .init(title: "Graffiti Drop", subtitle: "Sokak modası kampanyası", style: .graffiti),
        .init(title: "Food Paradise", subtitle: "Gurme menü tanıtımı", style: .food),
        .init(title: "Floral Bloom", subtitle: "İlkbahar özel serisi", style: .floral),
        .init(title: "Neon Cyber", subtitle: "Cyber Monday koleksiyonu", style: .neon),
        .init(title: "Pixel Adventure", subtitle: "Gaming aksesuar lansmanı", style: .pixel)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            // Ekran genişliğine göre orantısal bir faktör hesaplıyoruz.
            // Tasarımımızı 393 punto genişliğindeki bir ekrana göre yaptık.
            let scaleFactor = geometry.size.width / 393.0
            
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "0F172A"), Color(hex: "1E2B3B")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()

                    // Kartların Animasyon Alanı
                    ZStack {
                        ForEach(Array(showcaseCards.enumerated()), id: \.offset) { index, card in
                            LoginProductCardView(card: card, scaleFactor: scaleFactor)
                                .opacity(cardOpacity(for: index))
                                .offset(
                                    x: cardOffsetX(for: index, scale: scaleFactor), // DÜZELTİLDİ: scale parametresi eklendi
                                    y: cardOffsetY(for: index, scale: scaleFactor)  // DÜZELTİLDİ: scale parametresi eklendi
                                )
                                .rotationEffect(.degrees(cardRotation(for: index)))
                                .animation(
                                    .spring(response: 0.7, dampingFraction: 0.8)
                                        .delay(Double(index) * 0.15),
                                    value: animationPhase
                                )
                                .zIndex(cardZIndex(for: index))
                        }
                    }
                    // Kartların taşmaması için yüksekliği ekranın yarısı olarak orantılıyoruz.
                    .frame(height: geometry.size.height * 0.55)
                    
                    Spacer()
                    
                    // Giriş Butonları Alanı
                    if showAuthUI {
                        authButtonsView(scaleFactor: scaleFactor, safeAreaBottom: geometry.safeAreaInsets.bottom)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .onAppear {
                startAnimation()
                self.appleSignInCoordinator = AppleSignInCoordinator()
            }
            .sheet(isPresented: $showEmailLoginSheet) {
                // DÜZELTİLDİ: iOS 16 sürüm kontrolü eklendi
                if #available(iOS 16.0, *) {
                    LoginView()
                        .environmentObject(authService)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                } else {
                    LoginView()
                        .environmentObject(authService)
                }
            }
            .animation(.easeInOut, value: isLoading)
        }
    }

    // MARK: - Alt Görünümler (Subviews)
    
    /// Giriş butonlarını ve başlığı içeren bölüm.
    private func authButtonsView(scaleFactor: CGFloat, safeAreaBottom: CGFloat) -> some View {
        VStack(spacing: 20 * scaleFactor) {
            Text("Profesyonel Reklam Görselleri Oluşturun")
                .font(.system(size: 28 * scaleFactor, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .transition(.opacity)
            }
            
            VStack(spacing: 22 * scaleFactor) {
                Text("Continue with:")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                
                HStack(spacing: 25 * scaleFactor) {
                    SocialLoginButton(icon: "apple.logo", isSystemIcon: true, isLoading: isLoading, scaleFactor: scaleFactor) { signInWithApple() }
                    SocialLoginButton(icon: "google.logo", isSystemIcon: false, isLoading: isLoading, scaleFactor: scaleFactor) { signInWithGoogle() }
                    SocialLoginButton(icon: "facebook.logo", isSystemIcon: false, isLoading: isLoading, scaleFactor: scaleFactor) { signInWithFacebook() }
                        .opacity(0.5).disabled(true)
                }
                
                LoginAuthButton(
                    icon: "envelope.fill", title: "E-posta ile Devam Et",
                    backgroundColor: Color(hex: "3B82F6").opacity(0.8),
                    foregroundColor: .white,
                    isLoading: isLoading,
                    scaleFactor: scaleFactor
                ) { showEmailLoginSheet = true }
            }
        }
        .padding(.horizontal, 28 * scaleFactor)
        .padding(.bottom, safeAreaBottom > 0 ? 20 : 40)
    }

    // MARK: - Authentication Metotları
    
    private func signInWithApple() {
        guard let coordinator = appleSignInCoordinator else { return }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let authorization = try await coordinator.signIn()
                try await authService.handleAppleSignIn(authorization: authorization)
                await MainActor.run { isLoading = false }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = (error as? AuthError)?.errorDescription ?? error.localizedDescription
                }
            }
        }
    }
    
    private func signInWithGoogle() {
        guard let rootViewController = UIApplication.shared.topViewController() else {
            errorMessage = "Uygulama penceresi bulunamadı."
            return
        }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                try await authService.signInWithGoogle(presenting: rootViewController)
                await MainActor.run { isLoading = false }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = (error as? AuthError)?.errorDescription ?? error.localizedDescription
                }
            }
        }
    }
    
    private func signInWithFacebook() {
        errorMessage = "Facebook girişi yakında eklenecek"
    }
    
    // MARK: - Animasyon ve Yardımcı Fonksiyonlar
    
    private func startAnimation() {
        guard animationPhase == 0 else { return }
        withAnimation { animationPhase = 1 }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.6)) {
                showAuthUI = true
            }
        }
    }
    
    private func cardZIndex(for index: Int) -> Double {
        let zIndices: [Double] = [1, 2, 3, 4, 6, 5]
        return zIndices[index]
    }
    
    private func cardOpacity(for index: Int) -> Double {
        let opacities: [Double] = [1.0, 1.0, 1.0, 1.0, 0.95, 0.95]
        return animationPhase == 0 ? 0 : opacities[index]
    }
    
    // DÜZELTİLDİ: Bu fonksiyonlar artık 'scale' parametresi alıyor.
    private func cardOffsetX(for index: Int, scale: CGFloat) -> CGFloat {
        let positions: [CGFloat] = [-140, -150, 150, 140, 0, 0]
        return positions[index] * animationPhase * scale
    }
    
    private func cardOffsetY(for index: Int, scale: CGFloat) -> CGFloat {
        let positions: [CGFloat] = [-120, 140, 80, -120, -100, 150]
        return positions[index] * animationPhase * scale
    }
    
    private func cardRotation(for index: Int) -> Double {
        let rotations: [Double] = [-6, 4, 6, -4, 2, -2]
        return rotations[index] * Double(animationPhase)
    }
} // <-- AnimatedLoginView struct'ının BİTİŞİ BURASI


// MARK: - Destekleyici Alt Görünümler (Supporting Views)
// Bu struct'lar AnimatedLoginView'in DIŞINDA olmalı.

private struct LoginProductCardView: View {
    let card: LoginShowcaseCard
    let scaleFactor: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 40 * scaleFactor)
            .fill(LinearGradient(colors: card.style.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 168 * scaleFactor, height: 230 * scaleFactor)
            .overlay(
                VStack(alignment: .leading, spacing: 16 * scaleFactor) {
                    Image(systemName: card.style.iconName)
                        .font(.system(size: 42 * scaleFactor, weight: .bold))
                        .foregroundColor(card.style.accentColor)
                        .frame(width: 64 * scaleFactor, height: 64 * scaleFactor)
                        .background(Color.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16 * scaleFactor))
                        .shadow(color: .black.opacity(0.15), radius: 12 * scaleFactor, y: 8 * scaleFactor)
                    Spacer()
                    Text(card.title)
                        .font(.system(size: 20 * scaleFactor, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Text(card.subtitle)
                        .font(.system(size: 14 * scaleFactor, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(22 * scaleFactor)
            )
            .shadow(color: .black.opacity(0.22), radius: 18 * scaleFactor, y: 12 * scaleFactor)
    }
}

private struct SocialLoginButton: View {
    let icon: String
    let isSystemIcon: Bool
    let isLoading: Bool
    let scaleFactor: CGFloat
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Group {
                if isSystemIcon {
                    Image(systemName: icon).font(.system(size: 22 * scaleFactor, weight: .semibold))
                } else {
                    Image(icon).resizable().aspectRatio(contentMode: .fit).frame(width: 22 * scaleFactor, height: 22 * scaleFactor)
                }
            }
            .foregroundColor(.white)
            .frame(width: 60 * scaleFactor, height: 60 * scaleFactor)
            .background(Color.white.opacity(0.12))
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1.0)
    }
}

private struct LoginAuthButton: View {
    let icon: String
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    var isLoading: Bool = false
    let scaleFactor: CGFloat
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12 * scaleFactor) {
                Image(systemName: icon).font(.system(size: 20 * scaleFactor, weight: .semibold))
                Text(title).font(.system(size: 17 * scaleFactor, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58 * scaleFactor)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(28 * scaleFactor)
            .shadow(color: backgroundColor == .white ? Color.black.opacity(0.08) : Color.black.opacity(0.20), radius: 10 * scaleFactor, y: 6 * scaleFactor)
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1.0)
    }
}


// MARK: - Veri Modelleri ve Extension'lar
// Bunlar da dosyanın en altında, top-level olarak kalmalı.

private struct LoginShowcaseCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let style: LoginCardStyle
}

private enum LoginCardStyle {
    case graffiti, neon, pixel, floral, nature, food
    
    var gradientColors: [Color] {
        switch self {
        case .graffiti: return [Color(hex: "FB923C"), Color(hex: "F97316")]
        case .neon:     return [Color(hex: "1E3A8A"), Color(hex: "2563EB")]
        case .pixel:    return [Color(hex: "EF4444"), Color(hex: "F97316")]
        case .floral:   return [Color(hex: "FBCFE8"), Color(hex: "F472B6")]
        case .nature:   return [Color(hex: "86EFAC"), Color(hex: "22C55E")]
        case .food:     return [Color(hex: "FDE68A"), Color(hex: "FBBF24")]
        }
    }
    
    var accentColor: Color {
        switch self {
        case .graffiti: return Color(hex: "22D3EE")
        case .neon:     return Color(hex: "60A5FA")
        case .pixel:    return Color(hex: "FACC15")
        case .floral:   return Color(hex: "FEF3C7")
        case .nature:   return Color(hex: "14532D")
        case .food:     return Color(hex: "F97316")
        }
    }
    
    var iconName: String {
        switch self {
        case .graffiti: return "paintbrush.pointed.fill"
        case .neon:     return "bolt.fill"
        case .pixel:    return "gamecontroller.fill"
        case .floral:   return "leaf.fill"
        case .nature:   return "mountain.2.fill"
        case .food:     return "fork.knife"
        }
    }
}

private extension UIApplication {
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? keyWindow?.rootViewController

        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController,
           let selected = tabController.selectedViewController {
            return topViewController(controller: selected)
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }

    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
