//
//  EditorFramePreferenceKey.swift
//  CreoAds
//
//  Created by Ömer F. Aydemir on 10/05/2025.
//


import SwiftUI

struct EditorFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        // Genellikle son değeri alırız, ancak birden fazla eleman bu key'i set ederse
        // birleştirme mantığı gerekebilir. Bizim durumumuzda tek bir editör var.
        value = nextValue()
    }
}