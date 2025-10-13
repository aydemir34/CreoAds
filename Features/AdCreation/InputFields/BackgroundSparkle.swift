// BackgroundSparkle.swift
import SwiftUI

struct BackgroundSparkle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat          // Boyut create sırasında belirlenecek
    var opacity: Double
    var speed: CGVector
    var life: Double
    let maxLife: Double
    var color: Color
    
    private let fadeInDuration: Double = 1.5
    private let fadeOutDuration: Double = 2.0
    // --- YENİ: Temel boyut ve opaklık ---
    let baseSize: CGFloat      // Parçacığın temel boyutu
    let baseOpacity: Double    // Parçacığın temel maksimum opaklığı
    // --- BİTTİ ---


    static func create(in canvasSize: CGSize,
                       initialColor: Color,
                       initialBaseSize: CGFloat,    // Engine'den gelen ortalama boyut
                       initialBaseOpacity: Double,  // Engine'den gelen ortalama opaklık
                       initialSpeedMagnitude: CGFloat) -> BackgroundSparkle {
        
        let randomX = CGFloat.random(in: 0...canvasSize.width)
        let randomY = CGFloat.random(in: 0...canvasSize.height)
        
        // --- DEĞİŞİKLİK: Boyut ve Opaklık Belirleme ---
        // Boyutu ve opaklığı create sırasında bir kere belirle, update içinde sürekli random atama yapma.
        let currentActualSize = initialBaseSize * CGFloat.random(in: 0.8...1.2)
        let currentActualMaxOpacity = initialBaseOpacity * Double.random(in: 0.8...1.0) // Bu, parçacığın ulaşacağı maks opaklık
        // --- DEĞİŞİKLİK SONU ---
        
        let angle = CGFloat.random(in: 0...(2 * .pi))
        let speedMagnitudePerTick = initialSpeedMagnitude * (1.0 / 60.0)
        let speedX = cos(angle) * speedMagnitudePerTick
        let speedY = sin(angle) * speedMagnitudePerTick
        
        let lifeSpan = Double.random(in: 5.0...10.0)
        
        return BackgroundSparkle(
            position: CGPoint(x: randomX, y: randomY),
            size: currentActualSize, // Belirlenen boyutu ata
            opacity: 0.0,
            speed: CGVector(dx: speedX, dy: speedY),
            life: lifeSpan,
            maxLife: lifeSpan,
            color: initialColor,
            // --- YENİ: Temel değerleri sakla ---
            baseSize: currentActualSize, // Bu parçacığın kendi temel boyutu
            baseOpacity: currentActualMaxOpacity // Bu parçacığın kendi temel opaklığı
            // --- BİTTİ ---
        )
    }

    mutating func update(deltaTime: Double, in canvasSize: CGSize,
                         baseSizeForColorScheme: CGFloat,    // Bu parametreler artık doğrudan kullanılmayacak,
                         baseOpacityForColorScheme: Double) { // çünkü parçacık kendi base değerlerini biliyor.
                                                              // Ancak API uyumluluğu için şimdilik kalabilir.
        life -= deltaTime
        
        if life <= 0 {
            opacity = 0
            return
        }

        position.x += speed.dx
        position.y += speed.dy

        let age = maxLife - life
        
        if age < fadeInDuration {
            self.opacity = (age / fadeInDuration) * self.baseOpacity // Kendi baseOpacity'sini kullan
        } else if life < fadeOutDuration {
            self.opacity = (life / fadeOutDuration) * self.baseOpacity // Kendi baseOpacity'sini kullan
        } else {
            self.opacity = self.baseOpacity // Kendi baseOpacity'sini kullan
        }
        
        // Boyut artık create sırasında belirlendiği için burada değiştirmiyoruz.
        // self.size = baseSizeForColorScheme * CGFloat.random(in: 0.9...1.1) // BU SATIRI KALDIR/YORUMA AL
        // self.size zaten parçacığın kendi baseSize'ı.
        
        self.size = max(0.5, self.size)
        self.opacity = max(0, min(1, self.opacity))
    }

    mutating func respawn(in canvasSize: CGSize,
                          initialColor: Color,
                          initialBaseSize: CGFloat,
                          initialBaseOpacity: Double,
                          initialSpeedMagnitude: CGFloat) {
        self = BackgroundSparkle.create(in: canvasSize,
                                        initialColor: initialColor,
                                        initialBaseSize: initialBaseSize,
                                        initialBaseOpacity: initialBaseOpacity,
                                        initialSpeedMagnitude: initialSpeedMagnitude)
    }
}
