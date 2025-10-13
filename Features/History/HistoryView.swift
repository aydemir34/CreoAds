import SwiftUI

struct HistoryView: View {
    let authService: AuthService
    @StateObject private var viewModel: HistoryViewModel

    @State private var itemToShare: ShareableImage?

    private let spacing: CGFloat = 4

    init(authService: AuthService) {
        self.authService = authService
        self._viewModel = StateObject(wrappedValue: HistoryViewModel(authService: authService))
    }

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                    Spacer()
                } else if viewModel.imageUrls.isEmpty {
                    Text("No generated images yet.")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    GeometryReader { geometry in
                        let horizontalPadding: CGFloat = 16
                        let availableWidth = geometry.size.width - (spacing * 2) - (horizontalPadding * 2)
                        let columnWidth = availableWidth / 3
                        let columns: [GridItem] = Array(repeating: .init(.fixed(columnWidth), spacing: spacing), count: 3)

                        ScrollView {
                            LazyVGrid(columns: columns, spacing: spacing) {
                                ForEach(viewModel.imageUrls, id: \.self) { urlString in
                                    if let url = URL(string: urlString) {
                                        GridItemView(url: url) { image in
                                            downloadImage(image)
                                        } shareAction: { image in
                                            itemToShare = ShareableImage(image: image)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, horizontalPadding)
                            .padding(.vertical)
                        }
                    }
                }
            }
            .navigationTitle("Showcase")
            .sheet(item: $itemToShare) { item in
                ActivityViewController(activityItems: [item.image])
            }
        }
        .navigationViewStyle(.stack)
    }

    private func downloadImage(_ image: UIImage) {
        ImageSaver().writeToPhotoAlbum(image: image, onSuccess: {
            print("Image saved successfully.")
        }, onError: { error in
            print("Error saving image: \(error.localizedDescription)")
        })
    }
}


// MARK: - GridItemView (iOS Sürüm Kontrolü ile Güncellendi)
struct GridItemView: View {
    let url: URL
    let downloadAction: (UIImage) -> Void
    let shareAction: (UIImage) -> Void

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .foregroundColor(Color(.systemGray5))
                    .overlay(ProgressView())
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .contextMenu {
                        // Context menü butonlarını buraya taşıyoruz
                        contextMenuButtons(for: image)
                    }
            case .failure:
                Rectangle()
                    .foregroundColor(Color(.systemGray4))
                    .overlay(Image(systemName: "photo").foregroundColor(.white))
            @unknown default:
                EmptyView()
            }
        }
        .aspectRatio(1, contentMode: .fill)
        .clipped()
    }
    
    // <-- YENİ FONKSİYON -->
    // Menü butonlarını oluşturan ve versiyon kontrolü yapan yardımcı fonksiyon
    @ViewBuilder
    private func contextMenuButtons(for swiftUIImage: Image) -> some View {
        Button(action: {
            Task {
                // Her zaman çalışan yedek metodu kullanıyoruz.
                // Bu, hem iOS 15 hem 16 için çalışır ve daha basittir.
                if let uiImage = await fetchUIImage(from: url) {
                    downloadAction(uiImage)
                }
            }
        }) {
            Label("Download to Device", systemImage: "square.and.arrow.down")
        }
        
        Button(action: {
            Task {
                if let uiImage = await fetchUIImage(from: url) {
                    shareAction(uiImage)
                }
            }
        }) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
    }

    // <-- YENİ FONKSİYON -->
    // iOS 15 ve altı için UIImage'ı URL'den indiren yedek fonksiyon
    private func fetchUIImage(from url: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Failed to download image data: \(error)")
            return nil
        }
    }
}


// MARK: - Yardımcı Struct'lar (Değişiklik Yok)
struct ShareableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let previewAuthService = AuthService()
        HistoryView(authService: previewAuthService)
    }
}
