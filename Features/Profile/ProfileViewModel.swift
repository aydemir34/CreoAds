// ProfileViewModel.swift
import Foundation
import Combine // Combine'ı import et
import FirebaseFirestore
import FirebaseAuth // FirebaseAuth'ı import et

// ProfileViewModel, ObservableObject protokolünü uygular, böylece SwiftUI view'ları onu dinleyebilir.
@MainActor // UI güncellemelerinin ana thread'de olmasını sağlar
class ProfileViewModel: ObservableObject {
    // @Published: Bu değişkenler değiştiğinde, View'lar otomatik olarak güncellenir.
    @Published var fullName: String = ""
    @Published var businessName: String = ""
    @Published var businessDescription: String = ""
    @Published var userEmail: String = "Loading..." // Başlangıç değeri

    // UI durumunu göstermek için değişkenler
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil // Başarı mesajı için

    // AuthService'i ve Firestore referansını tutarız
    private let authService: AuthService
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    private weak var onboardingCoordinator: OnboardingCoordinator?
    private let onboardingUserNameKey = "onboardingUserName"
    private let onboardingIndustryKey = "onboardingIndustry"
    private let onboardingProductDescriptionKey = "onboardingProductDescription"

    // Giriş yapmış kullanıcının ID'sini kolayca almak için bir helper
    // Bu, authService.user değiştiğinde otomatik olarak güncellenir.
    private var userId: String? {
        authService.user?.uid
    }

    // ViewModel başlatıldığında AuthService'i alır ve kullanıcı değişikliklerini dinlemeye başlar
    init(authService: AuthService) {
        self.authService = authService
        print("[ProfileViewModel] Initialized.")
        observeAuthChanges() // Kullanıcı değişikliklerini ve e-postayı dinle
    }

    // --- YENİ: AuthService'deki kullanıcı değişikliklerini dinleyen fonksiyon ---
    private func observeAuthChanges() {
        authService.$user // AuthService'deki @Published user değişkenini dinle
            .sink { [weak self] firebaseUser in
                guard let self = self else { return }

                // Gelen e-postayı kendi @Published değişkenimize ata
                self.userEmail = firebaseUser?.email ?? "Not Logged In"
                print("[ProfileViewModel] User email updated via listener: \(self.userEmail)")

                // Kullanıcı durumu değiştiğinde (giriş yapıldı veya çıkış yapıldı),
                // Firestore'dan profil verilerini çekmeyi tetikle.
                // Eğer kullanıcı null ise (çıkış yapıldıysa), fetchProfileData bir şey yapmayacak.
                self.fetchProfileData()
            }
            .store(in: &cancellables) // Aboneliği sakla
    }
    // --- observeAuthChanges Sonu ---

    // fetchUserData fonksiyonu kaldırıldı, görevini observeAuthChanges üstlendi.

    // Firestore'dan profil verilerini çeken fonksiyon (Değişiklik yok, observeAuthChanges tarafından tetikleniyor)
    func fetchProfileData() {
        // Kullanıcı ID'si mevcut değilse (çıkış yapılmışsa) işlemi durdur
        guard let uid = userId else {
            print("[ProfileViewModel] User not logged in or ID not yet available, cannot fetch profile.")
            // Giriş yapılmadığında alanları temizleyebiliriz (isteğe bağlı)
            self.fullName = ""
            self.businessName = ""
            self.businessDescription = ""
            // self.errorMessage = "Please log in to view your profile." // Gerekirse mesaj göster
            return
        }

        // Kullanıcı ID'si varsa Firestore'dan veriyi çekmeye devam et
        print("[ProfileViewModel] Fetching profile data for user: \(uid)")
        isLoading = true // Yükleme başladığını belirt
        errorMessage = nil // Önceki hataları temizle
        successMessage = nil // Önceki başarı mesajlarını temizle

        let docRef = db.collection("users").document(uid)

        docRef.getDocument { [weak self] (document, error) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false // Yükleme bitti

                if let error = error {
                    print("[ProfileViewModel] Error fetching profile data: \(error.localizedDescription)")
                    self.errorMessage = "Failed to load profile: \(error.localizedDescription)"
                    return
                }

                if let document = document, document.exists {
                    let data = document.data()
                    self.fullName = data?["fullName"] as? String ?? ""
                    self.businessName = data?["businessName"] as? String ?? ""
                    self.businessDescription = data?["businessDescription"] as? String ?? ""
                    print("[ProfileViewModel] Profile data fetched successfully.")
                } else {
                    print("[ProfileViewModel] Profile document does not exist for user \(uid).")
                    self.fullName = ""
                    self.businessName = ""
                    self.businessDescription = ""
                }
                self.applyOnboardingFallbackIfNeeded()
                        }
                    }
                }
    
    func setOnboardingFallback(_ coordinator: OnboardingCoordinator) {
            onboardingCoordinator = coordinator
            applyOnboardingFallbackIfNeeded()
        }
        
        private func applyOnboardingFallbackIfNeeded() {
            guard let coordinator = onboardingCoordinator else { return }
            
            if fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                fullName = coordinator.userName
            }
            if businessName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                businessName = coordinator.userSector
            }
            if businessDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                businessDescription = coordinator.userProductType
            }
        }
    
    // Profil verilerini Firestore'a kaydeden fonksiyon (Değişiklik yok)
    func saveProfileData() {
        guard let uid = userId else {
            print("[ProfileViewModel] Error: User not logged in, cannot save profile.")
            errorMessage = "You must be logged in to save your profile."
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        let docRef = db.collection("users").document(uid)
        let dataToSave: [String: Any] = [
            "fullName": fullName,
            "businessName": businessName,
            "businessDescription": businessDescription,
            "updatedAt": Timestamp(date: Date())
        ]

        docRef.setData(dataToSave, merge: true) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                if let error = error {
                    print("[ProfileViewModel] Error saving profile data: \(error.localizedDescription)")
                    self.errorMessage = "Failed to save profile: \(error.localizedDescription)"
                } else {
                    print("[ProfileViewModel] Profile data saved successfully.")
                    self.successMessage = "Profile saved successfully!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.successMessage = nil
                    }
                }
            }
        }
    }
    
    private func mergeWithOnboardingDefaults(existing: String?, fallback: String) -> String {
            guard let trimmed = existing?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
                return fallback
            }
            return trimmed
        }

    // AuthService üzerinden çıkış yapma fonksiyonu (Değişiklik yok, do-catch doğru)
    func logOut() {
        print("[ProfileViewModel] Attempting log out via AuthService...")
        do {
            // AuthService'teki logOut fonksiyonu 'throws' olduğu için try kullanıyoruz
            try authService.logOut()
            // Başarılı çıkış sonrası UI zaten AuthGate tarafından güncellenecek
        } catch {
            print("[ProfileViewModel] Error logging out: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Log out failed: \(error.localizedDescription)"
            }
        }
    }
}
