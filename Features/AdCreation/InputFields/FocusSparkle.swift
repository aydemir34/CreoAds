// FocusSparkle.swift

import SwiftUI

struct FocusSparkle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var speed: CGVector
    var opacity: Double
    var scale: CGFloat
    let creationDate: Date = Date()
    // Ömür, ateşböceğinin ne kadar süre sonra solmaya başlayacağını belirler.
    // Bu, adjustSparkleCountSmoothly ile birlikte çalışarak eskiyenlerin doğal bir şekilde kaybolmasına yardımcı olabilir.
    var lifeSpan: TimeInterval = TimeInterval.random(in: 3...6) // saniye
    // Hedef hız, yumuşak geçiş için
    var targetSpeedMagnitude: CGFloat // Saniyede piksel / FPS (Engine tarafından ayarlanacak)
    // --- YENİ: Renk Şeması ve Efektler İçin ---
        var color: Color = .yellow // Varsayılan renk (Dark Mode için)
        var shouldUseBreathingEffect: Bool = false // Light mode'da "nefes alma" efekti için
        var baseScale: CGFloat // Nefes alma efekti için temel ölçek
        // --- BİTTİ: Renk Şeması ve Efektler İçin ---

    // initialSpeedMagnitude saniye başına hız olmalı, engine bunu tick başına çevirip verir veya burada çevrilir.
        // Şimdilik engine'in tick başına hız verdiğini varsayalım.
        static func create(in canvasSize: CGSize,
                           initialSpeed: CGVector, // Engine'den tick başına hız alacak
                           initialColor: Color,
                           initialScale: CGFloat,
                           applyBreathingEffect: Bool) -> FocusSparkle {
            
            let position = CGPoint(x: CGFloat.random(in: 0...canvasSize.width),
                                   y: CGFloat.random(in: 0...canvasSize.height))
            
            let opacity = Double.random(in: 0.3...0.8)
            
            return FocusSparkle(position: position,
                                speed: initialSpeed,
                                opacity: opacity,
                                scale: initialScale, // Başlangıç ölçeği
                                targetSpeedMagnitude: sqrt(initialSpeed.dx*initialSpeed.dx + initialSpeed.dy*initialSpeed.dy), // Başlangıç hızı hedef hızdır
                                color: initialColor,
                                shouldUseBreathingEffect: applyBreathingEffect,
                                baseScale: initialScale) // baseScale'i başlangıç scale'i olarak ayarla
        }

        mutating func update(in bounds: CGSize,
                             currentTargetSpeedMagnitudeTick: CGFloat, // Engine'den tick başına hedef hız
                             deltaTime: Double) { // Engine'den deltaTime
            
            // Hedef hızı güncelle (tick başına)
            self.targetSpeedMagnitude = currentTargetSpeedMagnitudeTick

            // Mevcut hızı hedefe doğru yavaşça ayarla
            let currentSpeedMag = sqrt(speed.dx * speed.dx + speed.dy * speed.dy)
            let adjustmentFactor: CGFloat = 0.05
            
            if abs(currentSpeedMag - self.targetSpeedMagnitude) > 0.01 { // Küçük bir eşik (tick başına hız için)
                let angle = atan2(speed.dy, speed.dx)
                let newMagnitude = currentSpeedMag + (self.targetSpeedMagnitude - currentSpeedMag) * adjustmentFactor
                
                speed.dx = cos(angle) * newMagnitude
                speed.dy = sin(angle) * newMagnitude
            }

            position.x += speed.dx // speed zaten tick başına
            position.y += speed.dy

            // Sınır kontrolü: Ekran dışına çıkarsa pozisyonu sıfırla (Engine yeniden oluşturabilir veya respawn edebilir)
            if position.x < -scale * 2 || position.x > bounds.width + scale * 2 ||
               position.y < -scale * 2 || position.y > bounds.height + scale * 2 {
                // Engine'in bu durumu ele alması için opaklığı sıfırlayabiliriz
                opacity = 0
                return
            }

            // Yaşa bağlı opaklık ve "nefes alma" efekti
            let age = Date().timeIntervalSince(creationDate)
            
            if age >= lifeSpan {
                opacity = 0 // Ömrü dolunca tamamen kaybol
                return
            }

            // Normal opaklık (solma/belirme)
            let fadeInDuration: TimeInterval = 0.5
            let fadeOutStartTime = lifeSpan - 1.0

            if age < fadeInDuration {
                opacity = (age / fadeInDuration) * 0.8
            } else if age > fadeOutStartTime {
                let fadeProgress = max(0, (age - fadeOutStartTime) / (lifeSpan - fadeOutStartTime))
                opacity = (1 - fadeProgress) * 0.8
            } else {
                opacity = 0.8 // Tamamen görünür olduğu süre
            }
            
            // --- YENİ: Nefes Alma Efekti ---
            if shouldUseBreathingEffect {
                let pulseSpeed = 1.0 // Saniyede bir tam döngü (hızı ayarlanabilir)
                // age'i kullanarak sinüs dalgası oluştur (-1 ile 1 arasında)
                // (pulse + 1.0) / 2.0 -> 0 ile 1 arasında bir değer verir
                let pulseFactor = (sin(age * pulseSpeed * 2 * .pi) + 1.0) / 2.0
                
                let minScaleFactor: CGFloat = 0.7 // Ne kadar küçüleceği
                let maxScaleFactor: CGFloat = 1.3 // Ne kadar büyüyeceği
                
                // Ölçeği baseScale'e göre pulseFactor ile ayarla
                self.scale = baseScale * (minScaleFactor + (maxScaleFactor - minScaleFactor) * pulseFactor)
                
                // Opaklığı da hafifçe etkileyebiliriz (isteğe bağlı)
                // self.opacity *= (0.8 + 0.2 * pulseFactor)
            }
            // --- BİTTİ: Nefes Alma Efekti ---

            self.opacity = min(max(opacity, 0), 1.0) // Opaklığı 0 ile 1.0 arasında tut
            self.scale = max(0.3, self.scale) // Minimum ölçek
        }
        
        // Respawn metodu (BackgroundSparkle'daki gibi)
        mutating func respawn(in canvasSize: CGSize,
                              initialSpeed: CGVector,
                              initialColor: Color,
                              initialScale: CGFloat,
                              applyBreathingEffect: Bool) {
            self = FocusSparkle.create(in: canvasSize,
                                       initialSpeed: initialSpeed,
                                       initialColor: initialColor,
                                       initialScale: initialScale,
                                       applyBreathingEffect: applyBreathingEffect)
            // creationDate ve lifeSpan'ı da sıfırlamak gerekebilir
            // self.creationDate = Date()
            // self.lifeSpan = TimeInterval.random(in: 3...6)
        }
    }
