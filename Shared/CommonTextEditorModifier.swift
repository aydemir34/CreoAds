//
//  CommonTextEditorModifier.swift
//  CreoAds
//
//  Created by Ömer F. Aydemir on 05/05/2025.
//
import SwiftUI
    // --- TextEditor için View Modifier ---
    struct CommonTextEditorModifier: ViewModifier {
        // Parametreler daha genel hale getirildi
        let rotation: Double
        let colors: [Color]       // Gökkuşağı veya dinamik renkler olabilir
        let lineWidth: Double     // Odak durumuna göre dışarıdan ayarlanacak
        let shadowColor: Color    // Odak durumuna göre dışarıdan ayarlanacak
        let shadowRadius: CGFloat // Odak durumuna göre dışarıdan ayarlanacak

        func body(content: Content) -> some View {
            content
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            // Verilen renkleri ve rotasyonu kullan
                            AngularGradient(gradient: Gradient(colors: colors), center: .center, angle: .degrees(rotation)),
                            lineWidth: lineWidth // Verilen çizgi kalınlığını kullan
                        )
                )
                // Verilen gölge parametrelerini kullan
                .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 0)
                // Animasyon burada OLMAYACAK, dışarıda uygulanacak
        }
    }
