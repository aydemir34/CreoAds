import SwiftUI

struct ProfileView: View {
    // ViewModel'i @StateObject olarak tanımlıyoruz.
    // Bu, View yeniden çizilse bile ViewModel'in hayatta kalmasını sağlar.
    @StateObject private var viewModel: ProfileViewModel
    @FocusState private var isKeyboardFocused: Bool // Herhangi bir TextField'a odaklanıldığında true olur
    @EnvironmentObject private var onboardingCoordinator: OnboardingCoordinator
    
    // AuthService'i init ile alıp ViewModel'i başlatıyoruz.
    // Bu, ProfileView'ın doğrudan EnvironmentObject'a bağımlı olmasını engeller.
    init(authService: AuthService) {
        // StateObject'i init içinde bu özel yöntemle başlatmak gerekiyor.
        _viewModel = StateObject(wrappedValue: ProfileViewModel(authService: authService))
        print("[ProfileView] Initialized.")
    }

    var body: some View {
        // NavigationView, her sekmenin kendi başlık çubuğuna sahip olması için eklenebilir.
        // Eğer TabView'ın kendisi zaten bir NavigationView içindeyse, bu gereksiz olabilir.
        NavigationView {
            // Form, içeriği gruplamak ve standart iOS stili sağlamak için kullanılır.
            Form {
                // Kullanıcı Bilgileri Bölümü
                Section("User Information") {
                    HStack { // Hizalama için HStack
                                            Text("Email:")
                                                .foregroundColor(.gray) // Etiketin biraz soluk görünmesi için
                                            Spacer() // E-postayı sağa iter
                                            Text(viewModel.userEmail)
                                                .foregroundColor(.secondary) // Değerin de biraz soluk görünmesi için
                                                .multilineTextAlignment(.trailing) // Uzun e-postalar için
                                        }
                                        // --- E-posta Gösterimi Sonu ---
                    TextField("Full Name", text: $viewModel.fullName)
                        .textContentType(.name) // Otomatik doldurma için ipucu
                        .focused($isKeyboardFocused) // Bu TextField odaklandığında isKeyboardFocused'u true yapar
                    TextField("Business Name", text: $viewModel.businessName)
                                                .textContentType(.organizationName)
                                                .focused($isKeyboardFocused) // Bu TextField odaklandığında isKeyboardFocused'u true yapar
                                        }
                // İş Açıklaması Bölümü
                Section("Business Description") {
                    // TextEditor, çok satırlı metin girişi için kullanılır.
                    // Form içinde düzgün görünmesi için genellikle bir yükseklik vermek gerekir.
                    TextEditor(text: $viewModel.businessDescription)
                        .frame(height: 150) // Yüksekliği ayarla
                        .focused($isKeyboardFocused) // TextEditor odaklandığında isKeyboardFocused'u true yapar
                        // .border(Color.secondary.opacity(0.2)) // Kenarlık eklemek görünürlüğü artırabilir
                }

                // Kaydetme ve Durum Mesajları Bölümü
                Section {
                    // Yükleme sırasında ProgressView gösterilir
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView("Saving...") // Mesaj eklenebilir
                            Spacer()
                        }
                    } else {
                        // Kaydet butonu
                        Button("Save Profile") {
                            viewModel.saveProfileData()
                            hideKeyboard() // Kaydettikten sonra klavyeyi kapat
                        }
                        .disabled(viewModel.isLoading) // Yükleme sırasında butonu devre dışı bırak

                        // Başarı veya hata mesajlarını göster
                        // Önce hata mesajını kontrol et, varsa kırmızı göster
                        if let errorMsg = viewModel.errorMessage {
                            Text(errorMsg)
                                .foregroundColor(.red)
                                .font(.caption)
                        // Hata yoksa başarı mesajını kontrol et, varsa yeşil göster
                        } else if let successMsg = viewModel.successMessage {
                            Text(successMsg)
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                }

                // Hesap Yönetimi Bölümü
                Section("Account") {
                    // Çıkış butonu, rolü destructive olarak ayarlanır (kırmızı görünür)
                    Button("Log Out", role: .destructive) {
                        print("!!! ProfileView: Logout Button Tapped !!!")
                                            viewModel.logOut() // ViewModel üzerinden çıkış yap
                    }
                }
            }
            .navigationTitle("Profile") // NavigationView başlığı
            // .navigationBarTitleDisplayMode(.inline) // Başlık stilini ayarlar (isteğe bağlı)
            .onAppear {
                    print("[ProfileView] Appeared.")
                    viewModel.setOnboardingFallback(onboardingCoordinator)
                }
            
            // --- YENİ: Klavye Araç Çubuğu ---
                        .toolbar {
                            // Klavye göründüğünde gösterilecek araç çubuğu grubu
                            ToolbarItemGroup(placement: .keyboard) {
                                // Boşluk ekleyerek butonu sağa iteriz
                                Spacer()

                                // Bitti butonu
                                Button("Done") {
                                    isKeyboardFocused = false // Herhangi bir TextField/Editor'dan odağı kaldırır (klavyeyi kapatır)
                                }
                            }
                        }
            // Klavyeyi kapatmak için dokunma hareketi (isteğe bağlı)
        //    .onTapGesture {
          //       hideKeyboard()
         //   }
        }
        // iOS 16+ için .navigationViewStyle(.stack) genellikle gereksizdir.
    }
}

// Preview Provider, AuthService'i başlatarak ProfileView'ı önizler
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(authService: AuthService())
    }
}

// Klavye Kapatma Yardımcısı (Eğer projenizde yoksa ekleyin)
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
