import SwiftUI
import PhotosUI
import UIKit

// MARK: - Focusable alanlar
enum FocusableField: Hashable {
    case description
}

// MARK: - Light/Dark renk desteği
extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor(dynamicProvider: { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        }))
    }
}

// FramePreferenceKey buradan TAMAMEN SİLİNDİ. Artık ayrı bir dosyada.

struct MainView: View {
    // MARK: – Dependencies & ViewModel
    @StateObject private var viewModel: MainViewModel
    @EnvironmentObject private var coordinator: OnboardingCoordinator
    // MARK: – UI State
    @State private var showingImagePicker = false
    @State private var showGeneratedImageViewSheet = false
    @State private var gradientRotation: Double = 0
    @State private var focusedBorderRotation: Double = 0
    @State private var openCategoryMenu: String?
    @State private var currentColorScheme: ColorScheme = .light

    @State private var imageSectionFrame: CGRect = .zero
    @State private var descriptionEditorFrame: CGRect = .zero
    @State private var actionAreaFrame: CGRect = .zero
    
    // MARK: – Static Data
    struct KeywordCategoryData: Identifiable {
        let id = UUID()
        let name: String
        let keywords: [String]
    }
    
    let rainbowColors: [Color] = [ .red, .orange, .yellow, .green, .blue, .indigo, .purple, .red ]
    static let dynamicGradientColorsForButtons: [Color] = [ Color(light: .blue.opacity(0.7), dark: .blue.opacity(0.8)), Color(light: .purple.opacity(0.6), dark: .purple.opacity(0.7)), Color(light: .pink.opacity(0.7), dark: .pink.opacity(0.8)) ]
    static let dynamicGradientColorsGeneral: [Color] = [ Color(light: .green.opacity(0.7), dark: .green.opacity(0.8)), Color(light: .yellow.opacity(0.6), dark: .yellow.opacity(0.7)), Color(light: .blue.opacity(0.7), dark: .blue.opacity(0.8)) ]
    private let keywordData: [KeywordCategoryData] = [ .init(name: "Style", keywords: ["Photorealistic", "Cartoon", "Minimalist", "Vintage", "Futuristic"]), .init(name: "Shot", keywords: ["Product shot", "Studio light", "On a table", "In nature", "Close-up"]), .init(name: "Mood", keywords: ["Happy", "Calm", "Energetic", "Luxurious", "Cozy"]), .init(name: "Color", keywords: ["Vibrant colors", "Pastel tones", "Monochrome", "Black and white", "Warm colors"]), .init(name: "Creative", keywords: ["Floating in air", "Surrounded by flowers", "On a pedestal", "With smoke effect", "Splash of water"]) ]
    
    // MARK: – Initialization
    init() {
    self._viewModel = StateObject(wrappedValue: MainViewModel(authService: AuthService(), openAIService: OpenAIService(), storageService: StorageService()))
    }
    
    // MARK: – Body
    var body: some View {
        NavigationView {
            navigationContent
        }
        .preferredColorScheme(currentColorScheme)
        .onAppear(perform: setupAnimations)
        .sheet(isPresented: $showingImagePicker) {
            PhotoPicker(selectedUIImage: $viewModel.selectedUIImage)
        }
        .sheet(isPresented: $showGeneratedImageViewSheet, onDismiss: {
            viewModel.generatedAdImage = nil
        }) {
            generatedImageSheetContent
        }
        .alert(isPresented: $viewModel.showingCreditAlert) { creditAlert }
        .alert("Error", isPresented: $viewModel.showingAlert, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(viewModel.apiError?.localizedDescription ?? "An unknown error occurred.")
        })
        .onChange(of: viewModel.generatedAdImage) { newValue in
            if newValue != nil {
                showGeneratedImageViewSheet = true
            }
        }
    }
    
    // MARK: - Helper Views & Methods
    
    /// NavigationView'ın tüm içeriğini barındıran yardımcı view.
    private var navigationContent: some View {
        ZStack {
            MainContentView(
                viewModel: viewModel,
                showingImagePicker: $showingImagePicker,
                openCategoryMenu: $openCategoryMenu,
                gradientRotation: gradientRotation,
                focusedBorderRotation: focusedBorderRotation,
                keywordData: keywordData,
                rainbowColors: rainbowColors,
                dynamicGradientColorsGeneral: Self.dynamicGradientColorsGeneral
            ) { frame in
                descriptionEditorFrame = frame
            }
            .onPreferenceChange(FramePreferenceKey.self) { values in
                imageSectionFrame = values["ImageSection"] ?? imageSectionFrame
                actionAreaFrame = values["ActionArea"] ?? actionAreaFrame
            }

            //    if !coordinator.isOnboardingCompleted {
            //        OnboardingOverlayView(
            //            imageFrame: imageSectionFrame,
            //            editorFrame: descriptionEditorFrame,
            //            actionFrame: actionAreaFrame
            //        )
            //    }
        }
        .navigationTitle("Create Ad")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                colorSchemeToggleButton
            }
        }
    }
    
    private var colorSchemeToggleButton: some View {
        Button {
            withAnimation(.easeInOut) {
                currentColorScheme = (currentColorScheme == .light ? .dark : .light)
            }
        } label: {
            Image(systemName: currentColorScheme == .dark ? "moon.stars.fill" : "sun.max.fill")
        }
    }
    
    @ViewBuilder
    private var generatedImageSheetContent: some View {
        if let realImage = viewModel.generatedAdImage {
            GeneratedImageView(
                image: realImage,
                prompt: viewModel.adDescription,
                onShare: shareImage,
                onSave: { ImageSaver().writeToPhotoAlbum(image: realImage) }
            )
        }
    }
    
    private var creditAlert: Alert {
        Alert(
            title: Text("Insufficient Credits"),
            message: Text("You don't have enough credits to purchase more."),
            primaryButton: .default(Text("Purchase")),
            secondaryButton: .cancel()
        )
    }
    
    private func setupAnimations() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            gradientRotation = 360
        }
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            focusedBorderRotation = 360
        }
    }
    
    private func shareImage(_ image: UIImage) {
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            activityController.popoverPresentationController?.sourceView = rootViewController.view
            activityController.popoverPresentationController?.sourceRect = CGRect(
                x: rootViewController.view.bounds.midX,
                y: rootViewController.view.bounds.midY,
                width: 0,
                height: 0
            )
            activityController.popoverPresentationController?.permittedArrowDirections = []
            rootViewController.present(activityController, animated: true, completion: nil)
        }
    }
}

// Preview Provider
#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
    MainView()
        .environmentObject(OnboardingCoordinator())
    }
}
#endif
