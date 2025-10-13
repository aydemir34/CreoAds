import SwiftUI

struct GeneratedImageView: View {
    let image: UIImage
    let prompt: String
    let onShare: (UIImage) -> Void
    let onSave: () -> Void

    @State private var showSaveConfirmation = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Your ad is ready!")
                .font(.largeTitle.bold())

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(16)
                .shadow(radius: 10)
                .padding(.horizontal)

            Text("\"\(prompt)\"")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 16) {
                Button {
                    onSave()
                    showSaveConfirmation = true
                } label: {
                    // <-- HATA DÜZELTİLDİ -->
                    // .fontWeight'u Label yerine içindeki Text'e uyguluyoruz.
                    Label {
                        Text("Save to Photos")
                            .fontWeight(.semibold)
                    } icon: {
                        Image(systemName: "square.and.arrow.down")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    onShare(image)
                } label: {
                    // <-- HATA DÜZELTİLDİ -->
                    Label {
                        Text("Share")
                            .fontWeight(.semibold)
                    } icon: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .alert("Saved!", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The generated ad image has been saved to your photo library.")
        }
    }
}
