import SwiftUI

// MARK: - CreoAds Premium Onboarding View
struct CreoAdsOnboardingView: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator
    @State private var currentPage = 0
    @State private var userName = ""
    @State private var selectedSector = ""
    @State private var productType = ""
    
    // Sektör seçenekleri
    private let sectors = [
        "E-ticaret", "Restoran/Cafe", "Moda/Aksesuar",
        "Kozmetik/Bakım", "El Yapımı Ürünler", "Diğer"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            // Dikey ekran yüksekliğine göre bir ölçek faktörü hesaplıyoruz.
            // Referans olarak iPhone 13/14 Pro yüksekliğini (844pt) alıyoruz.
            let vScale = geometry.size.height / 844.0

            ZStack {
                LinearGradient(
                    colors: [Color(hex: "0F172A"), Color(hex: "1E293B")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    
                    TabView(selection: $currentPage) {
                        // DÜZELTİLDİ: Sayfalar artık birer fonksiyon ve ölçek faktörünü parametre olarak alıyorlar.
                        welcomePage(scale: vScale).tag(0)
                        personalizationPage(scale: vScale).tag(1)
                        featuresPage(scale: vScale).tag(2)
                        commitmentPage(scale: vScale).tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)
                    
                    // DÜZELTİLDİ: footer'a da ölçek faktörü gönderiliyor.
                    footerView(scale: vScale)
                }
            }
        }
        .onAppear {
            userName = coordinator.userName
            selectedSector = coordinator.userSector
            productType = coordinator.userProductType
        }
    }
    
    // MARK: - Header & Footer Views
    
    private var headerView: some View {
        HStack {
            Button(action: previousPage) {
                Image(systemName: "arrow.left")
                    .font(.title3)
                    .foregroundColor(currentPage == 0 ? .clear : .white)
            }
            .disabled(currentPage == 0)
            
            Spacer()
            
            Text("CreoAds")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button("Atla") { completeOnboarding() }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .opacity(currentPage == 3 ? 0 : 1)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    // DÜZELTİLDİ: Footer artık bir fonksiyon
    private func footerView(scale: CGFloat) -> some View {
        VStack(spacing: 20 * scale) {
            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentPage ? Color(hex: "F59E0B") : Color.white.opacity(0.3))
                        .frame(width: index == currentPage ? 24 : 8, height: 4)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
                }
            }
            
            if currentPage == 3 {
                TapHoldCommitmentView(scale: scale) { completeOnboarding() }
            } else {
                navigationButtons
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
    
    // MARK: - Onboarding Pages (Artık Fonksiyonlar)

    // DÜZELTİLDİ: welcomePage artık bir fonksiyon
    private func welcomePage(scale: CGFloat) -> some View {
        VStack(spacing: 40 * scale) {
            Spacer()
            ZStack {
                Circle().fill(LinearGradient(colors: [Color(hex: "3B82F6"), Color(hex: "1E40AF")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 120 * scale, height: 120 * scale)
                    .shadow(color: Color(hex: "3B82F6").opacity(0.3), radius: 20 * scale)
                Image(systemName: "wand.and.stars").font(.system(size: 50 * scale, weight: .light)).foregroundColor(.white)
            }
            VStack(spacing: 20 * scale) {
                Text("CreoAds'e Hoş Geldiniz").font(.system(size: 32 * scale, weight: .bold)).foregroundColor(.white).multilineTextAlignment(.center)
                Text("AI ile Profesyonel Reklam Görselleri").font(.system(size: 20 * scale, weight: .medium)).foregroundColor(Color(hex: "3B82F6")).multilineTextAlignment(.center)
                VStack(spacing: 16 * scale) {
                    Text("Fotoğrafçı masrafları, ekipman kiralama, saatlerce çekim... Artık geride kaldı!").font(.system(size: 16 * scale, weight: .medium)).foregroundColor(.white.opacity(0.9)).multilineTextAlignment(.center).padding(.horizontal, 20)
                    Text("Bu uygulamayı bir fotoğrafçı tasarladı. Hayal gücünüzle sınırlı, profesyonel ürün görselleri artık cebinizde.").font(.system(size: 14 * scale)).foregroundColor(.white.opacity(0.7)).multilineTextAlignment(.center).padding(.horizontal, 20)
                }
            }
            Spacer()
            Spacer()
        }
        .padding(.horizontal)
    }
    
    // DÜZELTİLDİ: personalizationPage artık bir fonksiyon
    private func personalizationPage(scale: CGFloat) -> some View {
        ScrollView {
            VStack(spacing: 32 * scale) {
                Image(systemName: "person.crop.circle.badge.plus").font(.system(size: 80 * scale)).foregroundColor(Color(hex: "10B981"))
                VStack(spacing: 24 * scale) {
                    Text("Merhaba! 👋").font(.system(size: 28 * scale, weight: .bold)).foregroundColor(.white)
                    Text("Seni daha iyi tanıyalım").font(.system(size: 18 * scale, weight: .medium)).foregroundColor(.white.opacity(0.8))
                    VStack(spacing: 20 * scale) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Adın nedir?").font(.system(size: 16 * scale, weight: .medium)).foregroundColor(.white)
                            TextField("İsmini gir", text: $userName).textFieldStyle(PremiumTextFieldStyle(scale: scale))
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hangi sektörde çalışıyorsun?").font(.system(size: 16 * scale, weight: .medium)).foregroundColor(.white)
                            Menu {
                                ForEach(sectors, id: \.self) { sector in Button(sector) { selectedSector = sector } }
                            } label: {
                                HStack {
                                    Text(selectedSector.isEmpty ? "Sektör seç" : selectedSector).foregroundColor(selectedSector.isEmpty ? .white.opacity(0.5) : .white)
                                    Spacer()
                                    Image(systemName: "chevron.down").foregroundColor(.white.opacity(0.7))
                                }
                                .padding(12 * scale).background(Color.white.opacity(0.1)).cornerRadius(12 * scale).overlay(RoundedRectangle(cornerRadius: 12 * scale).stroke(Color(hex: "F59E0B"), lineWidth: 1))
                            }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ne tür ürünler satıyorsun?").font(.system(size: 14 * scale, weight: .medium)).foregroundColor(.white.opacity(0.8))
                            TextField("Örn: Ayakkabı, takı, yemek...", text: $productType).textFieldStyle(PremiumTextFieldStyle(scale: scale))
                        }
                        Text("Bu bilgiler görsellerini kişiselleştirmek için kullanılacak").font(.system(size: 12 * scale)).foregroundColor(.white.opacity(0.6)).multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20 * scale)
        }
    }
    
    // DÜZELTİLDİ: featuresPage artık bir fonksiyon ve ScrollView içeriyor
    private func featuresPage(scale: CGFloat) -> some View {
        ScrollView {
            VStack(spacing: 24 * scale) {
                Image(systemName: "chart.line.uptrend.xyaxis").font(.system(size: 60 * scale)).foregroundColor(Color(hex: "8B5CF6"))
                
                VStack(spacing: 20 * scale) {
                    Text("2 hafta içinde hedeflerimiz:").font(.system(size: 22 * scale, weight: .bold)).foregroundColor(.white).multilineTextAlignment(.center)
                    VStack(spacing: 12 * scale) {
                        expectationRow(icon: "📈", title: "Ürün görüntülenmelerinde %20 artış", scale: scale)
                        expectationRow(icon: "💬", title: "Sosyal medya etkileşiminde %20 artış", scale: scale)
                        expectationRow(icon: "💰", title: "Profesyonel görünümle satış artışı", scale: scale)
                    }
                    
                    Text("Neler yapabilirsin?").font(.system(size: 18 * scale, weight: .semibold)).foregroundColor(.white)
                    VStack(spacing: 12 * scale) {
                        featureRow(icon: "📸", title: "Ürün fotoğrafını yükle", scale: scale)
                        featureRow(icon: "✨", title: "AI promptunu yaz", scale: scale)
                        featureRow(icon: "🎨", title: "Profesyonel görsel al", scale: scale)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20 * scale)
        }
    }
    
    // DÜZELTİLDİ: commitmentPage artık bir fonksiyon
    private func commitmentPage(scale: CGFloat) -> some View {
        VStack(spacing: 32 * scale) {
            Spacer()
            Image(systemName: "gift.fill").font(.system(size: 80 * scale)).foregroundColor(Color(hex: "F59E0B"))
            VStack(spacing: 24 * scale) {
                Text(userName.isEmpty ? "Başlamaya Hazır mısın?" : "Hazır mısın \(userName)?")
                    .font(.system(size: 28 * scale, weight: .bold)).foregroundColor(.white).multilineTextAlignment(.center)
                VStack(spacing: 16 * scale) {
                    HStack {
                        Image(systemName: "gift.fill").foregroundColor(Color(hex: "F59E0B"))
                        Text("İlk 2 görseliniz ÜCRETSİZ!").font(.system(size: 18 * scale, weight: .semibold)).foregroundColor(Color(hex: "F59E0B"))
                    }
                    Text("Hemen deneyimle, beğenirsen devam et!").font(.system(size: 16 * scale)).foregroundColor(.white.opacity(0.8)).multilineTextAlignment(.center)
                }
                Text("CreoAds ile profesyonel ürün görselleri yaratarak işimi büyüteceğim!").font(.system(size: 16 * scale, weight: .medium)).foregroundColor(.white.opacity(0.9)).multilineTextAlignment(.center).padding(.horizontal, 20)
            }
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Subviews & Actions
    
    private var navigationButtons: some View {
        HStack {
            Button("Atla") { completeOnboarding() }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            Spacer()
            
            Button("İleri") {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    currentPage += 1
                }
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(Color(hex: "3B82F6"))
            .disabled(currentPage == 1 && (userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedSector.isEmpty))
            .opacity(currentPage == 1 && (userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedSector.isEmpty) ? 0.4 : 1.0)
        }
    }

    private func expectationRow(icon: String, title: String, scale: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 16 * scale) {
            Text(icon).font(.system(size: 24 * scale)).frame(width: 28 * scale, alignment: .leading)
            Text(title).font(.system(size: 16 * scale)).foregroundColor(.white).fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(EdgeInsets(top: 12 * scale, leading: 20 * scale, bottom: 12 * scale, trailing: 20 * scale))
        .background(Color.white.opacity(0.05)).cornerRadius(12 * scale)
    }
    
    private func featureRow(icon: String, title: String, scale: CGFloat) -> some View {
        HStack(spacing: 16 * scale) {
            Text(icon).font(.system(size: 20 * scale))
            Text(title).font(.system(size: 14 * scale)).foregroundColor(.white.opacity(0.9))
            Spacer()
        }
    }
    
    private func previousPage() {
        if currentPage > 0 {
            withAnimation(.easeInOut) { currentPage -= 1 }
        }
    }
    
    private func completeOnboarding() {
        let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedProduct = productType.trimmingCharacters(in: .whitespacesAndNewlines)
        
        coordinator.updateUserProfile(name: trimmedName, sector: selectedSector, productType: trimmedProduct)
        coordinator.completeAppOnboarding()
    }
}

// MARK: - Ayrı Komponentler

private struct TapHoldCommitmentView: View {
    let scale: CGFloat
    var onComplete: () -> Void
    
    // Bu komponent artık kendi durumunu tamamen kendi içinde yönetiyor.
    @State private var progress: Double = 0
    @State private var isPressing = false
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            // Arka plan ve progress halkaları
            Circle().stroke(Color.white.opacity(0.3), lineWidth: 4 * scale)
            Circle().trim(from: 0, to: progress)
                .stroke(Color(hex: "F59E0B"), style: StrokeStyle(lineWidth: 4 * scale, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
            
            // İçerik (ikon ve yazı)
            VStack(spacing: 8 * scale) {
                Image(systemName: "hand.tap.fill").font(.system(size: 24 * scale))
                Text("Basılı Tut").font(.system(size: 12 * scale))
            }
            .foregroundColor(.white)
            .scaleEffect(isPressing ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressing)
        }
        .frame(width: 120 * scale, height: 120 * scale)
        // DÜZELTİLMİŞ JEST TANIMLAYICI
        .onLongPressGesture(minimumDuration: 1.5, maximumDistance: .infinity, perform: {
            // Bu blok, SADECE 1.5 saniyelik basılı tutma başarılı olduğunda çalışır.
            self.isPressing = false
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
            onComplete() // Dışarıya verilen "tamamlandı" eylemini çağır.
            
        }, onPressingChanged: { isPressing in
            // Bu blok, parmak dokunduğunda ve kalktığında anlık olarak çalışır.
            self.isPressing = isPressing
            if isPressing {
                // Basmaya başlayınca zamanlayıcıyı başlat.
                startTimer()
            } else {
                // Parmak erken kaldırılırsa zamanlayıcıyı durdur ve sıfırla.
                stopTimer()
            }
        })
    }
    
    // DÜZELTİLDİ: Zamanlayıcı fonksiyonları artık bu komponentin içinde ve dolu.
    private func startTimer() {
        stopTimer() // Önceki bir timer varsa temizle.
        progress = 0
        let interval: TimeInterval = 0.05
        let totalDuration: TimeInterval = 1.5
        let increment = interval / totalDuration
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            progress = min(progress + increment, 1.0)
            if progress >= 1.0 {
                // Animasyon bittiğinde sadece timer'ı durdururuz.
                // Asıl eylem 'perform' bloğunda gerçekleşir.
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        // Eğer animasyon tamamlanmadan bırakıldıysa, progress'i animasyonla sıfırla.
        if progress < 1.0 {
            withAnimation(.easeOut(duration: 0.3)) {
                progress = 0
            }
        }
    }
}

private struct PremiumTextFieldStyle: TextFieldStyle {
    let scale: CGFloat
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12 * scale)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12 * scale)
            .overlay(RoundedRectangle(cornerRadius: 12 * scale).stroke(Color(hex: "F59E0B"), lineWidth: 1))
            .foregroundColor(.white)
    }
}

// Preview Provider'ı da güncelleyelim.
#if DEBUG
struct CreoAdsOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        CreoAdsOnboardingView()
            .environmentObject(OnboardingCoordinator())
    }
}
#endif
