import SwiftUI

// MARK: - Onboarding Steps
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case photoGuide = 1
    case promptGuide = 2
    case styleGuide = 3
    
    // MARK: - Content Properties
    var title: String {
        switch self {
        case .welcome: return "Yaratıcı Yönetmen Artık Sensin"
        case .photoGuide: return "Her Şey Doğru Tuvalle Başlar"
        case .promptGuide: return "Hikayeyi Fısıldamak"
        case .styleGuide: return "Usta Dokunuşları"
        }
    }
    
    var subtitle: String {
        switch self {
        case .welcome: return "Sıradanlığı Sanata Dönüştürün"
        case .photoGuide: return "Mükemmel Başlangıç"
        case .promptGuide: return "Yönetmenin Notları"
        case .styleGuide: return "Paletinizi Keşfedin"
        }
    }
    
    var description: String {
        switch self {
        case .welcome: return "CreoAds, ürün fotoğraflarınızı saniyeler içinde anlatan ve satan profesyonel reklamlara dönüştürür."
        case .photoGuide: return "Net ve iyi aydınlatılmış fotoğraflar, yapay zekanın vizyonunuzu mükemmel bir şekilde yansıtmasını sağlar."
        case .promptGuide: return "Ne kadar detay verirseniz, yapay zeka vizyonunuzu o kadar iyi anlar. Renkleri, dokuları ve atmosferi tarif etmekten çekinmeyin."
        case .styleGuide: return "Stil butonları, prompt yazmadan tek dokunuşla reklamınızın ruhunu ve hikayesini tamamen değiştirmenizi sağlar."
        }
    }
    
    var systemImage: String {
        switch self {
        case .welcome: return "sparkles"
        case .photoGuide: return "photo.on.rectangle.angled"
        case .promptGuide: return "pencil.and.outline"
        case .styleGuide: return "paintpalette.fill"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .welcome: return .blue
        case .photoGuide: return .green
        case .promptGuide: return .purple
        case .styleGuide: return .orange
        }
    }
    
    // MARK: - Helper Properties
    var progress: Double {
        let totalSteps = Double(OnboardingStep.allCases.count)
        return (Double(self.rawValue) + 1.0) / totalSteps
    }
    
    // MARK: - Premium Features (Gelecek için hazır)
    var isPremiumFeature: Bool {
        switch self {
        case .welcome, .photoGuide: return false
        case .promptGuide, .styleGuide: return false // Şimdilik hepsi ücretsiz
        }
    }
    
    var premiumBadgeText: String? {
        return isPremiumFeature ? "PRO" : nil
    }
}
