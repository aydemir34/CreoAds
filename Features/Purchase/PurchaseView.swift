import SwiftUI
import RevenueCat // RevenueCat'i import etmeyi unutma

struct PurchaseView: View {

    // ViewModel'i oluştur ve gözlemle
    @StateObject private var viewModel = PurchaseViewModel()

    var body: some View {
        NavigationView { // Daha düzgün bir görünüm için NavigationView kullanabiliriz
            VStack(spacing: 20) {

                // MARK: - Durum Mesajları ve Yükleme Göstergesi
                if viewModel.isLoading {
                    ProgressView("Loading Packages...")
                }

                if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                if let successMessage = viewModel.successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                }

                // MARK: - Sunulan Paketler Listesi
                if let currentOffering = viewModel.offerings?.current {
                    Text("Choose a Credit Package:")
                        .font(.headline)

                    // Paketleri listele
                    ForEach(currentOffering.availablePackages) { package in
                        PackageView(package: package) { selectedPackage in
                            // Satın alma işlemini başlat
                            Task {
                                await viewModel.purchase(package: selectedPackage)
                            }
                        }
                    }
                } else if !viewModel.isLoading {
                    // Yüklenmiyorsa ve sunum yoksa bilgi ver
                    Text("No credit packages available at the moment. Please check back later.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                Spacer() // Öğeleri yukarı iter

                // MARK: - Satın Almaları Geri Yükle Butonu
                Button("Restore Purchases") {
                    Task {
                        await viewModel.restorePurchases()
                    }
                }
                .padding(.bottom)

            }
            .padding() // VStack'e genel padding
            .navigationTitle("Buy Credits") // Sayfa başlığı
            .navigationBarTitleDisplayMode(.inline)
            .task { // View göründüğünde sunumları çek
                if viewModel.offerings == nil { // Sadece ilk açılışta veya ihtiyaç halinde çek
                    await viewModel.fetchOfferings()
                }
            }
            // Hata veya başarı mesajlarını belirli bir süre sonra temizle (isteğe bağlı)
            .onChange(of: viewModel.errorMessage) { _ in clearMessagesAfterDelay() }
            .onChange(of: viewModel.successMessage) { _ in clearMessagesAfterDelay() }
        }
    }

    // Hata/Başarı mesajlarını temizlemek için yardımcı fonksiyon
    private func clearMessagesAfterDelay() {
        Task {
            // 5 saniye bekle
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            viewModel.errorMessage = nil
            viewModel.successMessage = nil
        }
    }
}

// MARK: - Tek Bir Paketi Gösteren Alt View
struct PackageView: View {
    let package: Package
    let purchaseAction: (Package) -> Void // Satın alma eylemini dışarıdan al

    var body: some View {
        Button {
            purchaseAction(package) // Butona basıldığında eylemi tetikle
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(package.storeProduct.localizedTitle)
                        .font(.headline)
                    Text(package.storeProduct.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(package.localizedPriceString)
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemGray6)) // Hafif arka plan rengi
            .cornerRadius(10)
        }
        .buttonStyle(.plain) // Buton stilini düzeltir
    }
}

// MARK: - Preview Provider
struct PurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseView()
    }
}
