// CategoryKeywordsArea.swift
import SwiftUI

struct CategoryKeywordsArea: View {
    @Binding var openCategoryMenu: String?
    let keywordData: [MainView.KeywordCategoryData]
    // date parametresi kaldırıldı
    let gradientRotation: Double
    let appendKeywordAction: (String) -> Void

    private func colorForCategory(_ categoryName: String) -> Color {
        switch categoryName {
        case "Style": return Color.blue.opacity(0.7)
        case "Shot": return Color.green.opacity(0.7)
        case "Mood": return Color.purple.opacity(0.7)
        case "Color": return Color.orange.opacity(0.7)
        case "Creative": return Color.red.opacity(0.7)
        default: return Color.gray.opacity(0.7)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Add Keywords (Optional)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(keywordData) { category in
                        CategoryButtonView(
                            categoryName: category.name,
                            categoryColor: colorForCategory(category.name),
                            gradientRotation: gradientRotation,
                            action: {
                                withAnimation(.snappy) {
                                    openCategoryMenu = (openCategoryMenu == category.name) ? nil : category.name
                                }
                            }
                        )
                        .popover(isPresented: Binding(
                            get: { openCategoryMenu == category.name },
                            set: { if !$0 { openCategoryMenu = nil } }
                        ), arrowEdge: .bottom) {
                            KeywordSelectionPopoverView(
                                keywords: category.keywords,
                                onSelectKeyword: { selectedKeyword in
                                    appendKeywordAction(selectedKeyword)
                                    withAnimation { openCategoryMenu = nil }
                                }
                            )
                            .frame(minWidth: 200, idealHeight: 200, maxHeight: 300)
                            .padding()
                            .background(.thinMaterial)
                        }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
            }
        }
    }
}

// KeywordSelectionPopoverView (Aynı kalabilir)
struct KeywordSelectionPopoverView: View {
    let keywords: [String]
    let onSelectKeyword: (String) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            Text("Select a Keyword")
                .font(.headline)
                .padding(.bottom, 5)
            
            List {
                ForEach(keywords, id: \.self) { keyword in
                    Button(keyword) {
                        onSelectKeyword(keyword)
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
            .listStyle(.plain)
        }
    }
}
