import SwiftUI

struct InputFieldsView: View {
    @ObservedObject var viewModel: MainViewModel
    @Binding var openCategoryMenu: String?
    
    let keywordData: [MainView.KeywordCategoryData]
    let gradientRotation: Double
    let focusedBorderRotation: Double
    let rainbowColors: [Color]
    let dynamicGradientColors: [Color]
    
    let onEditorFocusChanged: (Bool) -> Void
    let onEditorFrameChanged: (CGRect) -> Void
    
    private func appendKeywordToDescription(_ keyword: String) {
        var currentText = viewModel.adDescription
        while currentText.last?.isWhitespace == true || currentText.last == "," {
            currentText = String(currentText.dropLast())
        }
        
        if currentText.isEmpty {
            viewModel.adDescription = keyword
        } else {
            viewModel.adDescription = currentText + ", " + keyword
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            CategoryKeywordsArea(
                openCategoryMenu: $openCategoryMenu,
                keywordData: keywordData,
                gradientRotation: gradientRotation,
                appendKeywordAction: appendKeywordToDescription
            )
            
            DescriptionEditorArea(
                adDescription: $viewModel.adDescription,
                onFocusChanged: onEditorFocusChanged,
                gradientRotation: gradientRotation,
                focusedBorderRotation: focusedBorderRotation,
                rainbowColors: rainbowColors,
                dynamicGradientColors: dynamicGradientColors
            )
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: EditorFramePreferenceKey.self,
                                  value: geometry.frame(in: .global))
                }
            )
            .onPreferenceChange(EditorFramePreferenceKey.self,
                              perform: onEditorFrameChanged)
        }
    }
}

// MARK: - Preview
#if DEBUG
struct InputFieldsView_Previews: PreviewProvider {
    static var previews: some View {
        let authService = AuthService()
        let openAIService = OpenAIService()
        let storageService = StorageService()
        
        let previewViewModel = MainViewModel(
            authService: authService,
            openAIService: openAIService,
            storageService: storageService
        )
        
        return InputFieldsView(
            viewModel: previewViewModel,
            openCategoryMenu: .constant(nil),
            keywordData: [
                MainView.KeywordCategoryData(name: "Style", keywords: ["Photorealistic", "Cartoon"]),
                MainView.KeywordCategoryData(name: "Mood", keywords: ["Happy", "Calm"])
            ],
            gradientRotation: 0,
            focusedBorderRotation: 0,
            rainbowColors: [.red, .blue, .green],
            dynamicGradientColors: [.blue, .purple, .pink],
            onEditorFocusChanged: { isFocused in
                print("Preview - Editor focus changed: \(isFocused)")
            },
            onEditorFrameChanged: { frame in
                print("Preview - Editor frame changed: \(frame)")
            }
        )
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
#endif
