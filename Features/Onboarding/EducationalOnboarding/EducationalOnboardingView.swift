//
//  EducationalOnboardingView.swift
//  CreoAds
//
//  Created by Ömer F. Aydemir on 13/10/2025.
//


import SwiftUI

// MARK: - Educational Onboarding Main View
struct EducationalOnboardingView: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator
    @State private var currentPage = 0
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "0F172A"), Color(hex: "1E293B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Pages
                TabView(selection: $currentPage) {
                    ExpectationPage().tag(0)
                    PhotoGuidePage().tag(1)
                    PromptGuidePage().tag(2)
                    StyleCategoryPage().tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Footer
                footerView
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                showContent = true
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            // Back button - ilk sayfada gizli
            Button(action: previousPage) {
                Image(systemName: "arrow.left")
                    .font(.title3)
                    .foregroundColor(.white)
            }
            .opacity(currentPage > 0 ? 1 : 0)
            .disabled(currentPage == 0)
            
            Spacer()
            
            Text("Nasıl Kullanılır?")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Skip button - son sayfada gizli
            Button("Atla") {
                completeEducationalOnboarding()
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white.opacity(0.7))
            .opacity(currentPage < 3 ? 1 : 0)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        VStack(spacing: 20) {
            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentPage ? Color(hex: "3B82F6") : Color.white.opacity(0.3))
                        .frame(width: index == currentPage ? 24 : 8, height: 4)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
                }
            }
            
            // Action button
            Button(action: {
                if currentPage < 3 {
                    nextPage()
                } else {
                    completeEducationalOnboarding()
                }
            }) {
                Text(currentPage == 3 ? "Başlayalım! 🚀" : "İleri")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "3B82F6"))
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Actions
    
    private func nextPage() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            currentPage += 1
        }
    }
    
    private func previousPage() {
        withAnimation(.easeInOut) {
            currentPage -= 1
        }
    }
    
    private func completeEducationalOnboarding() {
        coordinator.completeEducationalOnboarding()
    }
}

// MARK: - Page 1: Expectation Management
private struct ExpectationPage: View {
    @State private var isVisible = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer().frame(height: 20)
                
                // Icon
                Image(systemName: "wand.and.stars.inverse")
                    .font(.system(size: 70))
                    .foregroundColor(Color(hex: "8B5CF6"))
                    .opacity(isVisible ? 1 : 0)
                    .scaleEffect(isVisible ? 1 : 0.8)
                
                // Title
                Text("AI Ne Yapabilir?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 20)
                
                // Can Do
                VStack(spacing: 16) {
                    Text("✨ Yapabileceklerimiz:")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ExpectationRow(
                        icon: "checkmark.circle.fill",
                        text: "Arka plan değiştirme",
                        color: Color(hex: "10B981"),
                        delay: 0.3
                    )
                    
                    ExpectationRow(
                        icon: "checkmark.circle.fill",
                        text: "Profesyonel atmosfer ekleme",
                        color: Color(hex: "10B981"),
                        delay: 0.4
                    )
                    
                    ExpectationRow(
                        icon: "checkmark.circle.fill",
                        text: "Ürününüzü öne çıkarma",
                        color: Color(hex: "10B981"),
                        delay: 0.5
                    )
                }
                .padding(.horizontal, 24)
                .opacity(isVisible ? 1 : 0)
                
                // Limitations
                VStack(spacing: 16) {
                    Text("⚠️ Bazen olabilecekler:")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ExpectationRow(
                        icon: "exclamationmark.triangle.fill",
                        text: "Küçük detay kusurları",
                        color: Color(hex: "F59E0B"),
                        delay: 0.6
                    )
                    
                    ExpectationRow(
                        icon: "exclamationmark.triangle.fill",
                        text: "Birkaç deneme gerekebilir",
                        color: Color(hex: "F59E0B"),
                        delay: 0.7
                    )
                }
                .padding(.horizontal, 24)
                .opacity(isVisible ? 1 : 0)
                
                // Tip
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(Color(hex: "3B82F6"))
                    
                    Text("İpucu: 2-3 varyasyon oluşturun!")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .opacity(isVisible ? 1 : 0)
                
                Spacer().frame(height: 20)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Page 2: Photo Guide
private struct PhotoGuidePage: View {
    @State private var isVisible = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer().frame(height: 20)
                
                // Icon
                Image(systemName: "camera.fill")
                    .font(.system(size: 70))
                    .foregroundColor(Color(hex: "10B981"))
                
                // Title
                Text("Doğru Fotoğraf")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                // Good examples
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "10B981"))
                        Text("✅ İyi Örnekler")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    HStack(spacing: 12) {
                        ExamplePhotoCard(isGood: true, label: "Net")
                        ExamplePhotoCard(isGood: true, label: "İyi ışık")
                        ExamplePhotoCard(isGood: true, label: "Merkez")
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        BulletPoint(text: "Net ve iyi ışıklı")
                        BulletPoint(text: "Ürün merkeze yakın")
                        BulletPoint(text: "Farklı açılar")
                    }
                }
                .padding(.horizontal, 24)
                
                // Bad examples
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(hex: "EF4444"))
                        Text("❌ Kötü Örnekler")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    HStack(spacing: 12) {
                        ExamplePhotoCard(isGood: false, label: "Bulanık")
                        ExamplePhotoCard(isGood: false, label: "Karanlık")
                        ExamplePhotoCard(isGood: false, label: "Grup")
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        BulletPoint(text: "Bulanık, karanlık", isNegative: true)
                        BulletPoint(text: "Grup fotoğrafı", isNegative: true)
                        BulletPoint(text: "Çok uzak çekim", isNegative: true)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 20)
            }
        }
    }
}

// MARK: - Page 3: Prompt Guide
private struct PromptGuidePage: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer().frame(height: 20)
                
                // Icon
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 70))
                    .foregroundColor(Color(hex: "8B5CF6"))
                
                // Title
                Text("Güçlü Prompt Yazın")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                // Weak prompt
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(hex: "EF4444"))
                        Text("Zayıf prompt:")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Text("\"güzel bir sahne\"")
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    
                    Text("→ Belirsiz sonuç")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 24)
                
                // Strong prompt
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "10B981"))
                        Text("Güçlü prompt:")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Text("\"Minimal beyaz stüdyo, soft box ışık, siyah zemin, profesyonel\"")
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    
                    Text("→ Net, kaliteli sonuç ✨")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "10B981"))
                }
                .padding(.horizontal, 24)
                
                // Tips
                VStack(spacing: 12) {
                    Text("💡 İpuçları:")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TipRow(text: "Ortamı tanımlayın")
                    TipRow(text: "Renkleri belirtin")
                    TipRow(text: "Atmosferi tarif edin")
                    TipRow(text: "Işık tipini ekleyin")
                }
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 20)
            }
        }
    }
}

// MARK: - Page 4: Style & Category
private struct StyleCategoryPage: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer().frame(height: 20)
                
                // Icon
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 70))
                    .foregroundColor(Color(hex: "F59E0B"))
                
                // Title
                Text("Stiller & Kategoriler")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                // Styles
                VStack(spacing: 16) {
                    Text("Hazır stiller kullanın:")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 12) {
                        StyleButtonDemo(title: "Minimal", color: "E0E7FF")
                        StyleButtonDemo(title: "Urban", color: "1F2937")
                        StyleButtonDemo(title: "Luxury", color: "FEF3C7")
                    }
                }
                .padding(.horizontal, 24)
                
                // Categories
                VStack(spacing: 16) {
                    Text("Kategoriler:")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        CategoryRow(emoji: "🍕", title: "Yemek & İçecek")
                        CategoryRow(emoji: "👗", title: "Moda & Aksesuar")
                        CategoryRow(emoji: "🏠", title: "Ev & Dekorasyon")
                        CategoryRow(emoji: "💄", title: "Kozmetik & Bakım")
                    }
                }
                .padding(.horizontal, 24)
                
                // Final message
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .foregroundColor(Color(hex: "F59E0B"))
                    
                    Text("Her kategori için optimize edilmiş!")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 20)
            }
        }
    }
}

// MARK: - Supporting Components

private struct ExpectationRow: View {
    let icon: String
    let text: String
    let color: Color
    let delay: Double
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20))
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(delay)) {
                isVisible = true
            }
        }
    }
}

private struct ExamplePhotoCard: View {
    let isGood: Bool
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(isGood ? Color(hex: "10B981").opacity(0.2) : Color(hex: "EF4444").opacity(0.2))
                .frame(height: 80)
                .overlay(
                    Image(systemName: isGood ? "checkmark" : "xmark")
                        .font(.system(size: 30))
                        .foregroundColor(isGood ? Color(hex: "10B981") : Color(hex: "EF4444"))
                )
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct BulletPoint: View {
    let text: String
    var isNegative: Bool = false
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isNegative ? Color(hex: "EF4444") : Color(hex: "10B981"))
                .frame(width: 6, height: 6)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
    }
}

private struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(hex: "3B82F6"))
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

private struct StyleButtonDemo: View {
    let title: String
    let color: String
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: color))
                .frame(height: 60)
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct CategoryRow: View {
    let emoji: String
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(emoji)
                .font(.system(size: 28))
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}