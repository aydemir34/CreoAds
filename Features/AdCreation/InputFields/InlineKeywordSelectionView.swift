//
//  InlineKeywordSelectionView.swift
//  CreoAds
//
//  Created by Ömer F. Aydemir on 05/05/2025.
//
import SwiftUI

    // --- Inline Keyword Seçim Görünümü ---
    struct InlineKeywordSelectionView: View {
        let keywords: [String]
        let onSelectKeyword: (String) -> Void
        // Sütunları dinamik olarak ayarla
        let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
        
        var body: some View {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(keywords, id: \.self) { keyword in
                    Button { onSelectKeyword(keyword) } label: {
                        Text(keyword)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8).padding(.vertical, 5)
                            .frame(maxWidth: .infinity) // Buton genişlesin
                            .foregroundColor(Color.primary.opacity(0.9))
                            .background(Color(.systemGray5).opacity(0.8))
                            .cornerRadius(8)
                            .lineLimit(1) // Tek satır
                            .minimumScaleFactor(0.8) // Gerekirse küçülsün
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(10) // Grid içeriğine padding
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10)) // Arka plan
            .shadow(color: Color.black.opacity(0.1), radius: 3, y: 1) // Hafif gölge
        }
    }
    
