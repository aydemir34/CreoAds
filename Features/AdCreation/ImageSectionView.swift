// ImageSectionView.swift
import SwiftUI
import UIKit // UIImage için gerekli

struct ImageSectionView: View {
    // MainView'dan gelen Binding'ler
    @Binding var showingImagePicker: Bool
    @Binding var selectedUIImage: UIImage?

    // Animasyon/Görsel efektler için gerekli değerler
    let gradientRotation: Double
    let dynamicGradientColors: [Color] // MainView'dan gelecek

    var body: some View {
        VStack(spacing: 10) { // Dikey düzenleme
            if let uiImage = selectedUIImage {
                // Seçilen görseli göster
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200) // Maksimum yükseklik verelim
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                AngularGradient(gradient: Gradient(colors: dynamicGradientColors), center: .center, angle: .degrees(gradientRotation)),
                                lineWidth: 2
                            )
                    )
                    .shadow(radius: 5)
                    .padding(.horizontal) // Kenarlardan boşluk
                    .onTapGesture { showingImagePicker = true } // Görsele tıklayınca da seçici açılsın
            } else {
                // Görsel seçme butonu/alanı
                Button {
                    showingImagePicker = true
                } label: {
                    ZStack { // Arka plan gradyanı için ZStack
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThinMaterial) // Hafif bulanık arka plan
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        AngularGradient(gradient: Gradient(colors: dynamicGradientColors), center: .center, angle: .degrees(gradientRotation)),
                                        lineWidth: 2
                                    )
                            )

                        VStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.largeTitle)
                            Text("Select Product Image")
                                .font(.headline)
                        }
                        .foregroundColor(.secondary)
                        .padding(40) // İçeriğe boşluk ver
                    }
                    .frame(height: 150) // Yükseklik verelim
                    .padding(.horizontal) // Kenarlardan boşluk
                }
                .buttonStyle(.plain) // Butonun kendi stilini kaldıralım
            }

            // Görsel seçiliyken değiştirme butonu (isteğe bağlı)
            if selectedUIImage != nil {
                Button("Change Image") {
                    showingImagePicker = true
                }
                .font(.caption)
                .padding(.top, 5)
            }
        }
        .padding(.vertical) // Üstten ve alttan boşluk
    }
}

// Preview için örnek Binding ve değerler
#Preview {
    // State değişkenlerini Preview içinde tanımlamamız gerekir
    struct PreviewWrapper: View {
        @State private var showingPicker = false
        @State private var image: UIImage? = UIImage(systemName: "photo") // Örnek görsel
        private let colors = [Color.green, Color.blue] // Örnek renkler

        var body: some View {
            ImageSectionView(
                showingImagePicker: $showingPicker,
                selectedUIImage: $image,
                gradientRotation: 0.0,
                dynamicGradientColors: colors
            )
            .padding()
        }
    }
    return PreviewWrapper()
}







// MARK: Creater
//  ImageSectionView.swift
//  CreoAds
//
//  Created by Ömer F. Aydemir on 04/05/2025.
//

