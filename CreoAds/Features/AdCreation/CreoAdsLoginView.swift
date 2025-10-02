//
//  CreoAdsLoginView.swift
//  CreoAds
//
//  Created by Ömer F. Aydemir on 30/09/2025.
//


import SwiftUI

// MARK: - Main Login View
struct CreoAdsLoginView: View {
    @State private var animationPhase: CGFloat = 0
    @State private var showAuthButtons = false
    
    let sampleImages = [
        ProductCard(color: .orange, title: "Graffiti Style", style: .graffiti),
        ProductCard(color: .blue, title: "Neon Cyber", style: .neon),
        ProductCard(color: .orange, title: "Pixel Adventure", style: .pixel),
        ProductCard(color: .yellow, title: "Floral Design", style: .floral),
        ProductCard(color: .pink, title: "Nature Scene", style: .nature),
        ProductCard(color: .yellow, title: "Food Paradise", style: .food)
    ]
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [Color(hex: "F5F7FA"), Color(hex: "E8EDF2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Animated Cards Gallery
                ZStack {
                    ForEach(Array(sampleImages.enumerated()), id: \.offset) { index, card in
                        ProductCardView(card: card)
                            .scaleEffect(cardScale(for: index))
                            .blur(radius: cardBlur(for: index))
                            .opacity(cardOpacity(for: index))
                            .offset(x: cardOffsetX(for: index), y: cardOffsetY(for: index))
                            .rotationEffect(.degrees(cardRotation(for: index)))
                            .zIndex(Double(sampleImages.count - index))
                    }
                }
                .frame(height: 450)
                .padding(.bottom, 40)
                
                // Title and Description
                VStack(spacing: 12) {
                    Text("Spielwerk")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .opacity(showAuthButtons ? 1 : 0)
                    
                    Text("Create and Share\nProduct Ads")
                        .font(.system(size: 34, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .opacity(showAuthButtons ? 1 : 0)
                }
                .padding(.bottom, 40)
                
                // Auth Buttons
                VStack(spacing: 16) {
                    AuthButton(
                        icon: "apple.logo",
                        title: "Sign in with Apple",
                        backgroundColor: .black,
                        foregroundColor: .white
                    )
                    
                    AuthButton(
                        icon: "globe",
                        title: "Sign in with Google",
                        backgroundColor: .white,
                        foregroundColor: .black,
                        hasBorder: true
                    )
                    
                    AuthButton(
                        icon: "envelope.fill",
                        title: "Sign in with Email",
                        backgroundColor: .white,
                        foregroundColor: .black,
                        hasBorder: true
                    )
                }
                .opacity(showAuthButtons ? 1 : 0)
                .offset(y: showAuthButtons ? 0 : 30)
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    // MARK: - Animation Logic
    private func startAnimation() {
        // Staggered card animations
        for i in 0..<sampleImages.count {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(Double(i) * 0.15)) {
                animationPhase = 1
            }
        }
        
        // Show auth buttons after cards
        withAnimation(.easeOut(duration: 0.6).delay(Double(sampleImages.count) * 0.15 + 0.3)) {
            showAuthButtons = true
        }
    }
    
    private func cardScale(for index: Int) -> CGFloat {
        let progress = min(animationPhase, 1.0)
        let baseScale: CGFloat = index == 2 ? 1.0 : 0.85
        let targetScale: CGFloat = baseScale
        return 0.3 + (targetScale - 0.3) * progress
    }
    
    private func cardBlur(for index: Int) -> CGFloat {
        let progress = min(animationPhase, 1.0)
        let targetBlur: CGFloat = index == 2 ? 0 : 8
        return (1 - progress) * 20 + targetBlur
    }
    
    private func cardOpacity(for index: Int) -> Double {
        return Double(min(animationPhase, 1.0))
    }
    
    private func cardOffsetX(for index: Int) -> CGFloat {
        let progress = min(animationPhase, 1.0)
        let positions: [CGFloat] = [-140, -70, 0, 70, 140, 210]
        guard index < positions.count else { return 0 }
        return positions[index] * progress
    }
    
    private func cardOffsetY(for index: Int) -> CGFloat {
        let progress = min(animationPhase, 1.0)
        let positions: [CGFloat] = [-50, -150, -80, -150, -30, -100]
        guard index < positions.count else { return 0 }
        return positions[index] * progress
    }
    
    private func cardRotation(for index: Int) -> Double {
        let progress = min(animationPhase, 1.0)
        let rotations: [Double] = [-15, 8, 0, -8, 15, -12]
        guard index < rotations.count else { return 0 }
        return rotations[index] * Double(progress)
    }
}

// MARK: - Product Card View
struct ProductCardView: View {
    let card: ProductCard
    
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(
                LinearGradient(
                    colors: card.style.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 160, height: 220)
            .overlay(
                VStack {
                    Spacer()
                    
                    // Mock product image area
                    RoundedRectangle(cornerRadius: 12)
                        .fill(card.style.accentColor.opacity(0.3))
                        .frame(width: 120, height: 100)
                        .overlay(
                            card.style.icon
                                .font(.system(size: 40))
                                .foregroundColor(card.style.accentColor)
                        )
                    
                    Text("YOUR\nTITLE")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(card.style.textColor)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                    
                    Spacer()
                }
                .padding(20)
            )
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Auth Button
struct AuthButton: View {
    let icon: String
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    var hasBorder: Bool = false
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: hasBorder ? 1.5 : 0)
            )
            .shadow(color: .black.opacity(backgroundColor == .black ? 0.3 : 0.1), 
                    radius: backgroundColor == .black ? 15 : 8, 
                    x: 0, 
                    y: backgroundColor == .black ? 8 : 4)
        }
    }
}

// MARK: - Data Models
struct ProductCard {
    let color: Color
    let title: String
    let style: CardStyle
}

enum CardStyle {
    case graffiti, neon, pixel, floral, nature, food
    
    var gradientColors: [Color] {
        switch self {
        case .graffiti:
            return [Color(hex: "FFB347"), Color(hex: "FF8C42")]
        case .neon:
            return [Color(hex: "1E3A8A"), Color(hex: "3B82F6")]
        case .pixel:
            return [Color(hex: "FF6B35"), Color(hex: "F7931E")]
        case .floral:
            return [Color(hex: "FFF4E6"), Color(hex: "FFE4CC")]
        case .nature:
            return [Color(hex: "FFE5E5"), Color(hex: "FFC9C9")]
        case .food:
            return [Color(hex: "FFF9C4"), Color(hex: "FFF59D")]
        }
    }
    
    var accentColor: Color {
        switch self {
        case .graffiti: return Color(hex: "00F5FF")
        case .neon: return Color(hex: "00F5FF")
        case .pixel: return Color(hex: "4CAF50")
        case .floral: return Color(hex: "E91E63")
        case .nature: return Color(hex: "4CAF50")
        case .food: return Color(hex: "FF5722")
        }
    }
    
    var textColor: Color {
        switch self {
        case .graffiti, .neon, .pixel, .food: return .white
        case .floral, .nature: return Color(hex: "2D3436")
        }
    }
    
    var icon: Image {
        switch self {
        case .graffiti: return Image(systemName: "paintbrush.fill")
        case .neon: return Image(systemName: "bolt.fill")
        case .pixel: return Image(systemName: "gamecontroller.fill")
        case .floral: return Image(systemName: "leaf.fill")
        case .nature: return Image(systemName: "mountain.2.fill")
        case .food: return Image(systemName: "fork.knife")
        }
    }
}

// MARK: - Preview
struct CreoAdsLoginView_Previews: PreviewProvider {
    static var previews: some View {
        CreoAdsLoginView()
    }
}
