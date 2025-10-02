//
//  OnboardingProgressView.swift
//  CreoAds
//
//  Created by Ömer F. Aydemir on 17/09/2025.
//

import SwiftUI

struct OnboardingProgressView: View {
    
    let progress: Double
    
    var body: some View {
        ZStack {
            // Arka plan çizgisi
            Capsule()
                .fill(Color.gray.opacity(0.3))
            
            // İlerleme çizgisi
            Capsule()
                .fill(Color.accentColor)
                // Fremi, gelen progress değerine göre ayarla
                .frame(width: 200 * progress)
        }
        .frame(width: 200, height: 8)
        .animation(.easeInOut, value: progress)
    }
}
