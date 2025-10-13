import SwiftUI
import AVKit

struct CreoAdsOnboardingView: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator
    @State private var currentPage = 0
    @State private var userName = ""
    @State private var selectedSector = ""
    @State private var heroScale: CGFloat = 0.8
    @State private var heroOpacity: Double = 0
    @State private var isPressing = false
    
    private let sectors = [
        "E-ticaret", "Restoran/Cafe", "Moda/Aksesuar",
        "Kozmetik/Bakım", "El Yapımı Ürünler", "Diğer"
    ]
    
    var body: some View {
        ZStack {
            // Background - Sadece ilk 2 sayfa için
            if currentPage < 2 {
                backgroundGradient
                    .ignoresSafeArea()
            }
            
            // TabView - TAM EKRAN
            TabView(selection: $currentPage) {
                heroPage.tag(0)
                valueAndPersonalizationPage.tag(1)
                visualGuidePage.tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            .ignoresSafeArea() // ← BURASI ÖNEMLİ
            
            // Header - Sadece 2. sayfa için
            if currentPage == 1 {
                VStack {
                    headerView
                    Spacer()
                }
            }
            
            // Footer - Her sayfa için özel
            VStack {
                Spacer()
                
                if currentPage == 0 || currentPage == 1 {
                    footerView
                        .background(Color.clear)
                } else if currentPage == 2 {
                    videoPageFooter
                        .background(Color.clear)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) {
                heroScale = 1.0
                heroOpacity = 1.0
            }
            userName = coordinator.userName
            selectedSector = coordinator.userSector
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        Group {
            switch currentPage {
            case 0:
                // Hero page - Açık mavi gradient
                LinearGradient(
                    colors: [Color(hex: "E0F2FE"), Color(hex: "BAE6FD")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case 1:
                // Value page - Koyu gradient
                LinearGradient(
                    colors: [Color(hex: "0F172A"), Color(hex: "1E293B")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case 2:
                // Visual page - Arka plan için space bırak
                Color.black
            default:
                Color.clear
            }
        }
        .animation(.easeInOut(duration: 0.5), value: currentPage)
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Button(action: previousPage) {
                Image(systemName: "arrow.left")
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text("CreoAds")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button("Atla") { completeOnboarding() }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .opacity(currentPage == 2 ? 0 : 1)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        VStack(spacing: 24) {
            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentPage ? Color(hex: "3B82F6") : Color.white.opacity(0.3))
                        .frame(width: index == currentPage ? 24 : 8, height: 4)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
                }
            }
            
            // Action button - TRANSPARAN ZEMIN
            actionButton
                .background(Color.clear) // ← Siyah zemin kaldırıldı
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .background(Color.clear) // ← Footer zemini transparan
    }
    
    private var videoPageFooter: some View {
        VStack(spacing: 24) {
            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentPage ? Color.white : Color.white.opacity(0.3))
                        .frame(width: index == currentPage ? 24 : 8, height: 4)
                }
            }
            
            // Hold button
            HoldToStartButton(isPressing: $isPressing, onComplete: completeOnboarding)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
    
    private var actionButton: some View {
        Group {
            if currentPage == 0 {
                // Hero page - Pulsing button
                Button(action: nextPage) {
                    HStack(spacing: 12) {
                        Text("Başlayalım")
                            .font(.system(size: 18, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color(hex: "3B82F6"))
                            .shadow(color: Color(hex: "3B82F6").opacity(0.4), radius: 20, x: 0, y: 10)
                    )
                }
                .scaleEffect(heroScale)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: heroScale)
                .onAppear {
                    heroScale = 1.05
                }
            } else if currentPage == 2 {
                // Final page - Hold to start
                HoldToStartButton(isPressing: $isPressing, onComplete: completeOnboarding)
            } else {
                // Middle page - Regular button
                Button(action: nextPage) {
                    Text("İleri")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "3B82F6"))
                        .cornerRadius(16)
                }
                .disabled(userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedSector.isEmpty)
                .opacity(userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedSector.isEmpty ? 0.4 : 1.0)
            }
        }
    }
    
    // MARK: - Pages
    
    private var heroPage: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Animated icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 70, weight: .light))
                    .foregroundColor(Color(hex: "3B82F6"))
                    .rotationEffect(.degrees(heroOpacity == 1 ? 0 : -10))
            }
            .scaleEffect(heroScale)
            .opacity(heroOpacity)
            .padding(.bottom, 32)
            
            // Welcome text
            VStack(spacing: 16) {
                Text("CreoAds")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color(hex: "1E293B"))
                
                Text("Fotoğrafçı masrafı olmadan\nprofesyonel ürün görselleri")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(hex: "475569"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .opacity(heroOpacity)
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    private var valueAndPersonalizationPage: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer().frame(height: 20)
                
                // Personalization first
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Adın nedir?")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        TextField("İsmini gir", text: $userName)
                            .textFieldStyle(CleanTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hangi sektörde çalışıyorsun?")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Menu {
                            ForEach(sectors, id: \.self) { sector in
                                Button(sector) { selectedSector = sector }
                            }
                        } label: {
                            HStack {
                                Text(selectedSector.isEmpty ? "Sektör seç" : selectedSector)
                                    .foregroundColor(selectedSector.isEmpty ? .white.opacity(0.5) : .white)
                                    .font(.system(size: 16))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
                    .padding(.horizontal, 24)
                
                // Value proposition
                VStack(spacing: 16) {
                    Text("2 hafta içinde hedeflerimiz:")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        ValueRow(icon: "📈", text: "Ürün görüntülenmelerinde %20 artış")
                        ValueRow(icon: "💬", text: "Sosyal medya etkileşiminde %20 artış")
                        ValueRow(icon: "💰", text: "Profesyonel görünümle satış artışı")
                    }
                    
                    // Free trial
                    HStack(spacing: 12) {
                        Image(systemName: "gift.fill")
                            .foregroundColor(Color(hex: "F59E0B"))
                        Text("İlk 2 görseliniz ÜCRETSIZ!")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "F59E0B"))
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 20)
            }
        }
    }
    
    private var visualGuidePage: some View {
        ZStack {
            // Video - TAM EKRAN
            LoopingVideoPlayer(videoName: "onboarding_background")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea(.all)
            
            // Hafif overlay
            Color.black.opacity(0.15)
                .edgesIgnoringSafeArea(.all)
            
            // Yazılar - TEK TEK KONUMLANDIRILMIŞ
            GeometryReader { geometry in
                ZStack {
                    // YÜKLE - SOL YUKARI (konumu değiştirilebilir)
                    PositionedStep(
                        text: "YÜKLE",
                        delay: 0.5,
                        x: 80,  // ← YATAY KONUM (sol = küçük, sağ = büyük)
                        y: geometry.size.height * 0.7 // ← DİKEY KONUM (%35 = yukarıda, %50 = ortada)
                    )
                    
                    // TASARLA - SAĞ YUKARI (konumu değiştirilebilir)
                    PositionedStep(
                        text: "TASARLA",
                        delay: 1.0,
                        x: geometry.size.width - 110, // ← SAĞ TARAFA YAKIN
                        y: geometry.size.height * 0.7 // ← BİRAZ DAHA AŞAĞIDA
                    )
                    
                    // PARLA - ORTA (konumu değiştirilebilir, glow efektli)
                    GlowingStep(
                        text: "PARLA",
                        delay: 1.5,
                        x: geometry.size.width / 2 - 10, // ← ORTALANMIŞ
                        y: geometry.size.height * 0.65 // ← BUTONUN YUKARISINDA
                    )
                }
            }
            .ignoresSafeArea(.all)
        }
        .background(Color.clear) // ← Arka plan YOK
    }
    
    // MARK: - Actions
    
    private func nextPage() {
        if currentPage < 2 {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                currentPage += 1
            }
        }
    }
    
    private func previousPage() {
        if currentPage > 0 {
            withAnimation(.easeInOut) {
                currentPage -= 1
            }
        }
    }
    
    private func completeOnboarding() {
        let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        coordinator.updateUserProfile(name: trimmedName, sector: selectedSector, productType: "")
        coordinator.completeAppOnboarding()
    }
}

// MARK: - Supporting Views

private struct ValueRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 24))
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

private struct SimpleStepRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 20) {
            Text(number)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(hex: "3B82F6"))
                .frame(width: 50)
            
            Text(text)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

private struct HoldToStartButton: View {
    @Binding var isPressing: Bool
    var onComplete: () -> Void
    
    @State private var progress: Double = 0
    @State private var timer: Timer?
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 5)
                    .frame(width: 110, height: 110)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "3B82F6"), Color(hex: "8B5CF6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 110, height: 110)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: progress)
                
                VStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Başla")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: scale)
            }
            .frame(width: 110, height: 110)
            .onLongPressGesture(minimumDuration: 1.8, perform: {
                onComplete()
            }, onPressingChanged: { pressing in
                isPressing = pressing
                scale = pressing ? 0.9 : 1.0
                
                if pressing {
                    startProgress()
                } else {
                    stopProgress()
                }
            })
            
            // Alt yazı - Butona basılınca belirgin
            Text("Ekipman ve fotoğrafçı masrafı yok")
                .font(.system(size: 17, weight: .medium, design: .serif))  // ← weight değişti
                .foregroundColor(Color(hex: "F59E0B"))  // ← ALTIN SARI renk
                .tracking(1)
                .multilineTextAlignment(.center)
                .opacity(isPressing ? 1.0 : 0.0)
                .scaleEffect(isPressing ? 1.0 : 0.8)  // ← Hafif zoom efekti
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isPressing)
        }
    }
    
    private func startProgress() {
        progress = 0
        let interval: TimeInterval = 0.05
        let totalDuration: TimeInterval = 1.8
        let increment = interval / totalDuration
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            progress = min(progress + increment, 1.0)
        }
    }
    
    private func stopProgress() {
        timer?.invalidate()
        timer = nil
        
        if progress < 1.0 {
            withAnimation(.easeOut(duration: 0.3)) {
                progress = 0
            }
        }
    }
}

private struct CleanTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .foregroundColor(.white)
            .font(.system(size: 16))
    }
}

// MARK: - Video Player

private struct LoopingVideoPlayer: UIViewRepresentable {
    let videoName: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        guard let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            print("❌ Video bulunamadı: \(videoName).mp4")
            return view
        }
        
        print("✅ Video bulundu: \(videoURL)")
        
        let player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = view.bounds
        
        view.layer.addSublayer(playerLayer)
        
        player.play()
        player.actionAtItemEnd = .none
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }
        
        context.coordinator.player = player
        context.coordinator.playerLayer = playerLayer
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.playerLayer?.frame = uiView.bounds
        }
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.player?.pause()
        coordinator.player = nil
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var player: AVPlayer?
        var playerLayer: AVPlayerLayer?
    }
}

private struct AnimatedStepRow: View {
    let text: String
    let delay: Double // ← Bu delay değeri yukarıda ayarlanıyor (0.0, 0.3, 0.6)
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Nokta
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 8, height: 8)
                .opacity(isVisible ? 1 : 0)
            
            // Yazı
            Text(text)
                .font(.system(size: 36, weight: .light, design: .serif))
                .foregroundColor(.white.opacity(0.9))
                .tracking(3)
                .textCase(.uppercase)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 30) // Aşağıdan yukarı kayarak gelir
            
            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(delay)) { // ← 1 saniye yavaş belirme
                isVisible = true
            }
        }
    }
}

private struct ElegantStepRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 8, height: 8)
            
            Text(text)
                .font(.system(size: 36, weight: .light, design: .serif))
                .foregroundColor(.white.opacity(0.85))
                .tracking(3)
                .textCase(.uppercase)
            
            Spacer()
        }
    }
}

// TEK YAZI KOMPONENTİ
private struct PositionedStep: View {
    let text: String
    let delay: Double
    let x: CGFloat
    let y: CGFloat
    
    @State private var isVisible = false
    
    var body: some View {
        Text(text)
            .font(.system(size: 38, weight: .light, design: .serif))
            .foregroundColor(.white.opacity(0.9))
            .tracking(4)
            .textCase(.uppercase)
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 30)
            .position(x: x, y: y) // Pozisyon
            .onAppear {
                withAnimation(.easeOut(duration: 1.0).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// GLOW EFEKTLİ PARLA
private struct GlowingStep: View {
    let text: String
    let delay: Double
    let x: CGFloat
    let y: CGFloat
    
    @State private var isVisible = false
    @State private var glowIntensity: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Glow layer 1
            Text(text)
                .font(.system(size: 38, weight: .light, design: .serif))
                .foregroundColor(.white)
                .tracking(4)
                .textCase(.uppercase)
                .blur(radius: 20)
                .opacity(glowIntensity * 0.6)
            
            // Glow layer 2
            Text(text)
                .font(.system(size: 38, weight: .light, design: .serif))
                .foregroundColor(.white)
                .tracking(4)
                .textCase(.uppercase)
                .blur(radius: 10)
                .opacity(glowIntensity * 0.8)
            
            // Ana yazı
            Text(text)
                .font(.system(size: 38, weight: .light, design: .serif))
                .foregroundColor(.white.opacity(0.95))
                .tracking(4)
                .textCase(.uppercase)
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 30)
        .position(x: x, y: y)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(delay)) {
                isVisible = true
            }
            
            // Glow animasyonu - yavaşça başlar
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.5) {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    glowIntensity = 2.7
                }
            }
        }
    }
}
