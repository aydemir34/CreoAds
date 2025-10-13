//
//  FocusSparklesView 2.swift
//  CreoAds
//
//  Created by Ömer F. Aydemir on 10/05/2025.
//


// FocusSparklesView.swift
import SwiftUI

struct FocusSparklesView: View { // View adını FocusSparklesView olarak değiştirdiğini varsayıyorum
    @ObservedObject var engine: FocusSparkleEngine // Engine tipi FocusSparkleEngine olarak değişti

    var body: some View {
        Canvas { context, size in
            // engine.updateCanvasSize(size) // Engine'e boyut bilgisi MainContentView'dan iletilecek.
                                        // Özellikle Focus efekti için bu 'size'
                                        // metin editörünün alanı olmalı.
            
            for sparkle in engine.sparkles { // engine.sparkles artık [FocusSparkle]
                guard sparkle.opacity > 0.01 else { continue }

                let frame = CGRect(x: sparkle.position.x - (sparkle.scale * 5) / 2, // Ölçekle çarpılan baz değer (örn: 5 veya 8) ayarlanabilir
                                   y: sparkle.position.y - (sparkle.scale * 5) / 2,
                                   width: sparkle.scale * 5,
                                   height: sparkle.scale * 5)
                
                // Parçacığın kendi rengini ve opaklığını kullan
                context.fill(Path(ellipseIn: frame), with: .color(sparkle.color.opacity(sparkle.opacity)))
                
                // Halo efekti (Focus parçacıkları için daha belirgin olabilir)
                // Renk şemasına göre halo'nun rengi de ayarlanabilir.
                // Örneğin, Dark mode'da sarı parçacığa turuncu halo,
                // Light mode'da mavi parçacığa daha açık mavi bir halo.
                if sparkle.opacity > 0.2 { // Sadece daha görünür olanlara halo
                    let haloColor = sparkle.color.opacity(sparkle.opacity * 0.4) // Ana renkten türetilen halo rengi
                    let haloFrame = frame.insetBy(dx: -frame.width * 0.3, dy: -frame.height * 0.3)
                    context.fill(Path(ellipseIn: haloFrame), with: .color(haloColor))
                }
            }
        }
        .allowsHitTesting(false)
    }
}