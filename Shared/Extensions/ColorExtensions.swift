//
//  ColorExtensions.swift
//  CreoAds
//
//  Created by Ömer F. Aydemir on 17/09/2025.
//

import SwiftUI

// MARK: - CreoAds Color Extensions
/// CreoAds uygulaması için özel renk yardımcıları
extension Color {
    
    // MARK: - CreoAds Color Palette
    /// CreoAds ana renk paleti - static değişkenler
    static let creoBlue = Color(red: 176/255, green: 233/255, blue: 255/255) // #B0E9FF
    static let creoDark = Color(red: 0/255, green: 44/255, blue: 56/255) // #002C38
    static let creoGray = Color.gray.opacity(0.2)
    
    // MARK: - Semantic Colors
    /// Anlamsal renk tanımları
    static let onboardingPrimary = Color.creoBlue
    static let onboardingSecondary = Color.creoDark
    static let onboardingBackground = Color.white
    
    // MARK: - Helper Methods
    /// RGB değerlerinden Color oluşturur
    static func creoRGB(_ red: Double, _ green: Double, _ blue: Double, opacity: Double = 1.0) -> Color {
        return Color(red: red/255, green: green/255, blue: blue/255, opacity: opacity)
    }
}
