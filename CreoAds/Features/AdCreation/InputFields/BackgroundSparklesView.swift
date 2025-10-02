// BackgroundSparklesView.swift
import SwiftUI

struct BackgroundSparklesView: View {
    @ObservedObject var engine: BackgroundSparkleEngine
    // Renk şemasını doğrudan view içinde de alabiliriz, ancak engine zaten yönetiyor.
    // @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Canvas { context, size in
            // Engine'in canvas boyutunu zaten MainContentView'da güncellediğimizi varsayıyoruz.
            // Bu view'ın boyutu değişirse, engine'e bildirilmesi MainContentView'un sorumluluğunda.
            // engine.updateCanvasSize(size) // Burada tekrar çağırmaya gerek yok.

            for sparkle in engine.sparkles {
                // Opaklığı çok düşük olanları çizmeyebiliriz (performans için küçük bir optimizasyon)
                guard sparkle.opacity > 0.01 else { continue }

                let frame = CGRect(x: sparkle.position.x - sparkle.size / 2,
                                   y: sparkle.position.y - sparkle.size / 2,
                                   width: sparkle.size,
                                   height: sparkle.size)
                
                // Parçacığın kendi rengini ve opaklığını kullan
                // Engine, renk şemasına göre parçacığın 'color' ve 'opacity' özelliklerini zaten ayarlıyor.
                context.fill(Path(ellipseIn: frame), with: .color(sparkle.color.opacity(sparkle.opacity)))
                
                // İsteğe bağlı: Daha yumuşak bir görünüm için hafif bir halo efekti eklenebilir
                // Ancak videodaki efekt daha sadeydi, bu yüzden şimdilik bunu kapalı tutalım.
                /*
                if sparkle.opacity > 0.1 { // Sadece daha görünür olanlara halo
                    let haloSizeFactor: CGFloat = 1.5 // Halo, parçacıktan ne kadar büyük olacak
                    let haloOpacityFactor: Double = 0.3 // Halo'nun opaklığı (parçacığın opaklığına göre)

                    let haloFrame = frame.insetBy(dx: -frame.width * (haloSizeFactor - 1) / 2,
                                                  dy: -frame.height * (haloSizeFactor - 1) / 2)
                    
                    context.fill(Path(ellipseIn: haloFrame), with: .color(sparkle.color.opacity(sparkle.opacity * haloOpacityFactor)))
                }
                */
            }
        }
        .allowsHitTesting(false) // Kullanıcı etkileşimlerini engellemesin
        // .ignoresSafeArea() // Bu, MainContentView seviyesinde yönetilecek
        // TimelineView veya Timer burada YOK, çünkü engine kendi Timer'ı ile çalışıyor.
    }
}
