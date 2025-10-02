// CategoryButtonView.swift
import SwiftUI

struct CategoryButtonView: View {
    let categoryName: String
    let categoryColor: Color
    let gradientRotation: Double
    let action: () -> Void
    
    private var buttonDynamicGradientColors: [Color] {
        // Bu, MainView içinde tanımlanacak static bir değişkene işaret etmeli
        return MainView.dynamicGradientColorsForButtons
    }

    var body: some View {
        Button(action: action) {
            Text(categoryName)
                .font(.footnote)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundColor(.white)
                .background(categoryColor.opacity(0.85))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: buttonDynamicGradientColors),
                                center: .center,
                                angle: .degrees(gradientRotation)
                            ),
                            lineWidth: 2
                        )
                )
        }
       .buttonStyle(.plain)
    }
}
