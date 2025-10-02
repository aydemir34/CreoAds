import SwiftUI

struct MainContentView: View {
    @ObservedObject var viewModel: MainViewModel
    @Binding var showingImagePicker: Bool
    @Binding var openCategoryMenu: String?
    
    let gradientRotation: Double
    let focusedBorderRotation: Double
    let keywordData: [MainView.KeywordCategoryData]
    let rainbowColors: [Color]
    let dynamicGradientColorsGeneral: [Color]
    
    let onEditorFrameChanged: (CGRect) -> Void
    
    @State private var isDescriptionEditorFocused: Bool = false
    
    @StateObject private var backgroundEngine = BackgroundSparkleEngine()
    @StateObject private var focusEngine = FocusSparkleEngine()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderInfoView(credits: viewModel.credits)
            
            ScrollView {
                ZStack {
                    particleEffectsOverlay
                    
                    VStack(spacing: 16) {
                        ImageSectionView(
                            showingImagePicker: $showingImagePicker,
                            selectedUIImage: $viewModel.selectedUIImage,
                            gradientRotation: gradientRotation,
                            dynamicGradientColors: dynamicGradientColorsGeneral
                        )
                        .readFrame(in: .global, for: "ImageSection")
                        
                        InputFieldsView(
                            viewModel: viewModel,
                            openCategoryMenu: $openCategoryMenu,
                            keywordData: keywordData,
                            gradientRotation: gradientRotation,
                            focusedBorderRotation: focusedBorderRotation,
                            rainbowColors: rainbowColors,
                            dynamicGradientColors: dynamicGradientColorsGeneral,
                            onEditorFocusChanged: { isFocused in
                                self.isDescriptionEditorFocused = isFocused
                            },
                            onEditorFrameChanged: onEditorFrameChanged
                        )
                        .padding(.horizontal)
                    }
                }
            }
            .ifAvailable { view in
                if #available(iOS 16.0, *) {
                    view.scrollDismissesKeyboard(.interactively)
                } else {
                    view
                }
            }
            
            ActionAreaView(viewModel: viewModel)
                .padding(.horizontal)
                .padding(.bottom)
                .readFrame(in: .global, for: "ActionArea")
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onTapGesture {
            withAnimation {
                openCategoryMenu = nil
            }
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
        }
        .onChange(of: isDescriptionEditorFocused) { newValue in
            focusEngine.internalIsActive = newValue
        }
    }
    
    private var particleEffectsOverlay: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundSparklesView(engine: backgroundEngine)
                    .onAppear {
                        backgroundEngine.updateCanvasSize(geometry.size)
                        backgroundEngine.updateColorScheme(colorScheme)
                    }
                    .onChange(of: geometry.size) { newSize in
                        backgroundEngine.updateCanvasSize(newSize)
                    }
                    .onChange(of: colorScheme) { newScheme in
                        backgroundEngine.updateColorScheme(newScheme)
                    }
                
                FocusSparklesView(engine: focusEngine)
                    .allowsHitTesting(false)
                    .onAppear {
                        focusEngine.updateColorScheme(colorScheme)
                    }
                    .onChange(of: colorScheme) { newScheme in
                        focusEngine.updateColorScheme(newScheme)
                    }
            }
        }
    }
}

extension View {
    @ViewBuilder
    func ifAvailable<Content: View>(@ViewBuilder content: (Self) -> Content) -> some View {
        content(self)
    }
}
