// FocusSparkleEngine.swift
import SwiftUI
import Combine

class FocusSparkleEngine: ObservableObject { // Class adını FocusSparkleEngine olarak değiştirdiğini varsayıyorum
    @Published var sparkles: [FocusSparkle] = [] // Tipi FocusSparkle olarak değişti
    @Published var internalIsActive: Bool = false {
        didSet {
            if oldValue != internalIsActive {
                // Hedef parçacık sayısı ve hızını doğrudan burada ayarlamak yerine,
                // tick() içinde veya renk şeması güncellendiğinde bu değerler zaten ayarlanacak.
                // Sadece loglama yeterli.
                print("FocusSparkleEngine: internalIsActive changed to \(internalIsActive).")
                if !internalIsActive && sparkles.isEmpty {
                    // stopTimer() // Opsiyonel: Aktif değilse ve parçacık yoksa timer durdurulabilir.
                                 // Ancak timer sürekli çalışıp, aktif değilken tick içinde işlem yapmamak daha basit olabilir.
                } else if internalIsActive && timer == nil {
                    // startTimer() // Eğer timer durdurulduysa yeniden başlat.
                }
                // Eğer aktif değilse, mevcut parçacıkların yavaşça kaybolmasını sağlayabiliriz
                // veya adjustSparkleCountSmoothly ile sayıyı azaltabiliriz.
                // Şimdilik adjustSparkleCountSmoothly bu işi yapacak.
                updateTargetCountsAndSpeeds() // internalIsActive değişince hedefleri güncelle
            }
        }
    }

    private var internalCanvasSize: CGSize = .zero
    private var currentColorScheme: ColorScheme = .dark // Mevcut renk şemasını sakla

    // --- Renk Şemasına ve Aktiflik Durumuna Göre Ayarlanacak Değerler ---
    private var activeParticleCount: Int = 70
    private var inactiveParticleCount: Int = 0 // Aktif değilken hiç parçacık olmasın (veya çok az)
    private var currentTargetSparkleCount: Int

    // Hızlar saniye başına tanımlanacak, sonra tick başına çevrilecek
    private var activeSpeedMagnitudeSecond: CGFloat = 100.0 // Saniyede piksel
    private var inactiveSpeedMagnitudeSecond: CGFloat = 0.0 // Aktif değilken hız sıfır
    private var currentTargetSpeedMagnitudeTick: CGFloat // Tick başına hedef hız

    private var particleColor: Color = .yellow
    private var particleInitialScale: CGFloat = 0.6
    private var applyBreathingEffect: Bool = false
    // --- BİTTİ ---
    
    private let transitionDuration: TimeInterval = 1.0 // Parçacık sayısı değişim süresi
    private var timer: Timer?
    private let fixedDeltaTime: Double = 1.0 / 60.0

    init() {
        // Başlangıç değerlerini inactive duruma göre ayarla
        self.currentTargetSparkleCount = self.inactiveParticleCount
        self.currentTargetSpeedMagnitudeTick = (self.inactiveSpeedMagnitudeSecond / 60.0)
        print("FocusSparkleEngine initialized.")
        updateParametersForSchemeAndActivity() // Başlangıç parametrelerini ayarla
        startTimer()
    }

    deinit {
        stopTimer()
        print("FocusSparkleEngine deinitialized.")
    }

    private func startTimer() {
        guard timer == nil else { return }
        // Timer.scheduledTimer yerine Timer.init ve RunLoop.current.add
        timer = Timer(timeInterval: fixedDeltaTime, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.current.add(timer!, forMode: .common) // .common modunda ekle
        // print("FocusSparkleEngine: Timer started on common run loop mode.")
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTargetCountsAndSpeeds() {
        currentTargetSparkleCount = internalIsActive ? activeParticleCount : inactiveParticleCount
        let targetSpeedSecond = internalIsActive ? activeSpeedMagnitudeSecond : inactiveSpeedMagnitudeSecond
        currentTargetSpeedMagnitudeTick = targetSpeedSecond / 60.0 // Tick başına çevir
    }

    // Renk şeması ve aktiflik durumuna göre parçacık parametrelerini günceller
    private func updateParametersForSchemeAndActivity() {
        updateTargetCountsAndSpeeds()

        if internalIsActive {
            if currentColorScheme == .dark {
                particleColor = .yellow // Veya .orange
                particleInitialScale = CGFloat.random(in: 0.3...0.6)
                applyBreathingEffect = false
                activeParticleCount = 70
                activeSpeedMagnitudeSecond = 50.0
            } else { // Light Mode
                // Rastgele canlı renklerden birini seçebiliriz
                let lightColors: [Color] = [.yellow.opacity(0.8), .blue.opacity(0.7), .green.opacity(0.7)]
                particleColor = lightColors.randomElement() ?? .yellow
                particleInitialScale = CGFloat.random(in: 0.3...0.6)
                applyBreathingEffect = true // Light mode'da nefes alma efekti
                activeParticleCount = 50 // Light mode'da biraz daha az
                activeSpeedMagnitudeSecond = 50.0 // Light mode'da biraz daha yavaş
            }
        } else {
            // Aktif değilken parametrelerin pek önemi yok çünkü sayı 0 olacak
            // Ama yine de varsayılan değerler atanabilir.
        }
        // Parametreler değiştiğinde, mevcut parçacıkların bu yeni özelliklere yavaşça adapte olması
        // veya adjustSparkleCountSmoothly'nin yeni parçacıkları bu ayarlarla oluşturması sağlanabilir.
        // Şimdilik, adjustSparkleCountSmoothly yeni parçacıkları doğru ayarlarla oluşturacak.
    }

    func updateCanvasSize(_ newSize: CGSize) {
        if internalCanvasSize != newSize && newSize != .zero {
            internalCanvasSize = newSize
            print("FocusSparkleEngine: canvasSize updated to \(internalCanvasSize)")
            // Canvas boyutu değişirse, mevcut parçacıklar yeniden konumlandırılabilir veya silinip eklenebilir.
            // Şimdilik bir şey yapmayalım, parçacıklar zaten ekran dışına çıkınca ele alınıyor.
        }
    }

    func updateColorScheme(_ scheme: ColorScheme) {
        if currentColorScheme != scheme {
            currentColorScheme = scheme
            print("FocusSparkleEngine: Updating color scheme to \(scheme)")
            updateParametersForSchemeAndActivity() // Renk şeması değişince parametreleri güncelle
        }
    }

    func tick() {
        guard internalCanvasSize != .zero else { return }
        
        // Eğer aktif değilse ve hiç parçacık yoksa tick'i atla (timer'ı durdurmak yerine)
        if !internalIsActive && sparkles.isEmpty {
            return
        }

        adjustSparkleCountSmoothly()

        for i in sparkles.indices.reversed() {
            sparkles[i].update(in: internalCanvasSize,
                               currentTargetSpeedMagnitudeTick: currentTargetSpeedMagnitudeTick,
                               deltaTime: fixedDeltaTime)
            
            if sparkles[i].opacity <= 0.001 { // Ömrü dolmuş veya ekran dışına çıkmış
                // sparkles.remove(at: i) // Silip yenisini eklemek yerine respawn daha iyi olabilir
                // VEYA
                sparkles[i].respawn(in: internalCanvasSize,
                                    initialSpeed: CGVector.random(magnitude: currentTargetSpeedMagnitudeTick), // Rastgele bir hızla
                                    initialColor: particleColor,
                                    initialScale: particleInitialScale,
                                    applyBreathingEffect: applyBreathingEffect)
                // Respawn sonrası creationDate ve lifeSpan'ı sıfırlamak gerekebilir FocusSparkle içinde.
            }
        }
        objectWillChange.send()
    }

    private func adjustSparkleCountSmoothly() {
        let currentCount = sparkles.count
        let difference = currentTargetSparkleCount - currentCount
        guard difference != 0 else { return }

        let particlesToAdjustPerSecond = Double(abs(difference)) / transitionDuration
        var numToAdjustThisTick = Int((particlesToAdjustPerSecond * fixedDeltaTime).rounded(.up))
        numToAdjustThisTick = max(1, numToAdjustThisTick) // En az 1 parçacık ayarla

        if difference > 0 { // Parçacık ekle
            for _ in 0..<min(numToAdjustThisTick, difference) {
                if sparkles.count < activeParticleCount * 2 { // Aşırı yüklenmeyi önle
                    let angle = CGFloat.random(in: 0...(2 * .pi))
                    let speedX = cos(angle) * currentTargetSpeedMagnitudeTick
                    let speedY = sin(angle) * currentTargetSpeedMagnitudeTick
                    
                    let newSparkle = FocusSparkle.create(
                        in: internalCanvasSize,
                        initialSpeed: CGVector(dx: speedX, dy: speedY),
                        initialColor: particleColor,
                        initialScale: particleInitialScale,
                        applyBreathingEffect: applyBreathingEffect
                    )
                    sparkles.append(newSparkle)
                } else { break }
            }
        } else { // Parçacık sil
            for _ in 0..<min(numToAdjustThisTick, abs(difference)) {
                if !sparkles.isEmpty {
                    // En eski parçacığı silmek yerine, rastgele birini veya ömrü en kısa olanı
                    // yavaşça soldurarak silmek daha iyi bir efekt verebilir.
                    // Şimdilik en basit yöntem:
                    sparkles.removeFirst()
                } else { break }
            }
        }
    }
}

// CGVector için yardımcı extension (FocusSparkleEngine içinde veya globalde olabilir)
extension CGVector {
    static func random(magnitude: CGFloat) -> CGVector {
        let angle = CGFloat.random(in: 0...(2 * .pi))
        return CGVector(dx: cos(angle) * magnitude, dy: sin(angle) * magnitude)
    }
}
