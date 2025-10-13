// BackgroundSparkleEngine.swift
import SwiftUI
import Combine

class BackgroundSparkleEngine: ObservableObject {
    @Published var sparkles: [BackgroundSparkle] = []
    
    private var particleSpeedMagnitude: CGFloat = 30.0

    // Renk Şeması ve Renkler
    private var currentColorScheme: ColorScheme = .light // Varsayılan veya ortamdan alınacak
        private var lightModeParticleColors: [Color] = [
            Color(hex: "FFD700").opacity(0.9), // Altın Sarısı
            Color(hex: "87CEEB").opacity(0.9), // Gök Mavisi
            Color(hex: "90EE90").opacity(0.9)  // Açık Yeşil
        ]
        // Bu iki değişkeni updateColorScheme içinde ayarlayacağız, o yüzden burada ilk değer ataması yapmayalım veya varsayılan bir değer atayalım.
    private var particleBaseSize: CGFloat = 1.5
    private var particleBaseOpacity: Double = 0.5
    private var darkModeParticleColor: Color = Color.white
    private let targetSparkleCount: Int = 70
    private var internalCanvasSize: CGSize = .zero
    private var timer: Timer?
    private let fixedDeltaTime: Double = 1.0 / 60.0

    init() {
            print("BackgroundSparkleEngine initialized.")
            // updateColorScheme çağrılmadan önce varsayılan değerler atanmış olmalı
            // veya init içinde colorScheme'e göre ilk ayar yapılmalı.
            // MainContentView onAppear'da zaten çağırıyor, bu yüzden sorun olmamalı.
            startTimer()
        }

        deinit {
            stopTimer()
            print("BackgroundSparkleEngine deinitialized.")
        }

    private func startTimer() {
        guard timer == nil else { return }
        // Önceki mesajdaki .common RunLoop düzeltmesini de ekleyelim
        timer = Timer(timeInterval: fixedDeltaTime, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func updateCanvasSize(_ newSize: CGSize) {
        if internalCanvasSize != newSize && newSize != .zero {
            internalCanvasSize = newSize
            print("BackgroundSparkleEngine: canvasSize updated to \(internalCanvasSize). Recreating sparkles.")
            recreateAllSparkles()
        }
    }

    func updateColorScheme(_ scheme: ColorScheme) {
        print("BackgroundSparkleEngine: Updating color scheme to \(scheme)")
        self.currentColorScheme = scheme // Mevcut renk şemasını sakla

        if scheme == .dark {
            particleBaseSize = CGFloat.random(in: 1.8...3.2) // Dark modda biraz daha büyük
            particleBaseOpacity = Double.random(in: 0.5...0.9)
            particleSpeedMagnitude = CGFloat.random(in: 25...35)
        } else { // Light Mode
            // --- DEĞİŞİKLİK BAŞLANGICI ---
            particleBaseSize = CGFloat.random(in: 2.3...4.0) // Light modda biraz daha küçük ama belirgin
            particleBaseOpacity = Double.random(in: 0.8...0.95) // Light modda daha opak olabilirler
            particleSpeedMagnitude = CGFloat.random(in: 25...35)
        }
        recreateAllSparkles()
    }
    
    private func getCurrentSparkleColor() -> Color {
        if self.currentColorScheme == .light {
            return lightModeParticleColors.randomElement() ?? Color.white // Light mod için rastgele bir renk
        } else {
            return darkModeParticleColor // Dark mod için tek renk
        }
    }

    private func recreateAllSparkles() {
        guard internalCanvasSize != .zero else { return }
        sparkles.removeAll() // Önce temizle
                for _ in 0..<targetSparkleCount {
                    if sparkles.count < targetSparkleCount * 2 { // Güvenlik için bir üst limit
                        let newSparkle = BackgroundSparkle.create(
                            in: internalCanvasSize,
                            initialColor: getCurrentSparkleColor(),
                            initialBaseSize: self.particleBaseSize, // Engine'in güncel baseSize'ını kullan
                            initialBaseOpacity: self.particleBaseOpacity, // Engine'in güncel baseOpacity'sini kullan
                            initialSpeedMagnitude: self.particleSpeedMagnitude // Engine'in güncel speedMagnitude'unu kullan
                        )
                        sparkles.append(newSparkle)
            } else { break }
        }
        objectWillChange.send()
    }

    func tick() {
            guard internalCanvasSize != .zero else { return }

            if sparkles.count < targetSparkleCount {
                let difference = targetSparkleCount - sparkles.count
                for _ in 0..<difference {
                     if sparkles.count < targetSparkleCount * 2 {
                        let newSparkle = BackgroundSparkle.create(
                            in: internalCanvasSize,
                            initialColor: getCurrentSparkleColor(),
                            initialBaseSize: self.particleBaseSize,
                            initialBaseOpacity: self.particleBaseOpacity,
                            initialSpeedMagnitude: self.particleSpeedMagnitude
                        )
                        sparkles.append(newSparkle)
                    } else { break }
                }
            }

            for i in sparkles.indices.reversed() {
                // BackgroundSparkle'ın update metodu, kendi içindeki baseSize ve baseOpacity'yi
                // color scheme'e göre ayarlanmış olanlarla güncellemeli.
                sparkles[i].update(deltaTime: fixedDeltaTime,
                                   in: internalCanvasSize,
                                   baseSizeForColorScheme: self.particleBaseSize, // Engine'den güncel değeri ver
                                   baseOpacityForColorScheme: self.particleBaseOpacity) // Engine'den güncel değeri ver

                let s = sparkles[i]
                if s.opacity <= 0.001 ||
                   s.position.x < -s.size * 5 || s.position.x > internalCanvasSize.width + s.size * 5 ||
                   s.position.y < -s.size * 5 || s.position.y > internalCanvasSize.height + s.size * 5 {
                    
                    sparkles[i].respawn(in: internalCanvasSize,
                                        initialColor: getCurrentSparkleColor(),
                                        initialBaseSize: self.particleBaseSize,
                                        initialBaseOpacity: self.particleBaseOpacity,
                                        initialSpeedMagnitude: self.particleSpeedMagnitude)
                }
            }
            objectWillChange.send()
        }
    }
