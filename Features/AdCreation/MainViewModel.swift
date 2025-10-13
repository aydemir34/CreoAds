import Foundation
import FirebaseFirestore
import Combine
import SwiftUI
import UIKit

@MainActor
class MainViewModel: ObservableObject {

    @Published var credits: Int = 0
    @Published var generatedImageCount: Int = 0
    @Published var selectedUIImage: UIImage? = nil
    @Published var adDescription: String = ""
    @Published var showingAlert: Bool = false
    @Published var showingCreditAlert: Bool = false
    @Published var isLoadingImage: Bool = false
    @Published var generatedAdImage: UIImage? = nil
    @Published var apiError: OpenAIError? = nil { didSet { showingAlert = apiError != nil } }

    private let authService: AuthService
    private let openAIService: OpenAIService
    private let storageService: StorageService
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    private var firestoreListener: ListenerRegistration?

    init(authService: AuthService, openAIService: OpenAIService, storageService: StorageService) {
        self.authService = authService
        self.openAIService = openAIService
        self.storageService = storageService
        observeAuthChanges()
    }

    deinit { firestoreListener?.remove() }

    private func observeAuthChanges() {
        authService.$user.sink { [weak self] user in
            guard let self = self else { return }
            self.firestoreListener?.remove()
            if let user = user { self.setupFirestoreListener(for: user.uid) }
            else { self.credits = 0; self.generatedImageCount = 0 }
        }.store(in: &cancellables)
    }

    private func setupFirestoreListener(for userId: String) {
        let userDocRef = db.collection("users").document(userId)
        firestoreListener = userDocRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else { return }
            self.credits = document.data()?["remainingCredits"] as? Int ?? 0
            self.generatedImageCount = document.data()?["generatedImageCount"] as? Int ?? 0
        }
    }
    
    func generateAd() {
        // Test modu kontrolü
        if UserDefaults.standard.bool(forKey: "testMode") {
            print("🧪 Test modu aktif - Sahte görsel oluşturuluyor")
            isLoadingImage = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // Sahte bir görsel oluştur
                let testImage = self.createTestImage()
                self.generatedAdImage = testImage
                self.isLoadingImage = false
                print("✅ Test görseli oluşturuldu")
            }
            return
        }
        
        // Normal API çağrısı
        generateAdImage()
    }
    
    private func createTestImage() -> UIImage {
        let size = CGSize(width: 400, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Gradient arka plan
            let colors = [UIColor.blue.cgColor, UIColor.purple.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
            context.cgContext.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: size.width, y: size.height), options: [])
            
            // Test metni
            let text = "Test Ad Image"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.white
            ]
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
        }
    }

    private func generateAdImage() {
        guard let image = selectedUIImage, !adDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            apiError = .apiError("Please select an image and enter a description.")
            return
        }
        Task {
            guard await checkCreditsAndFreeTier() else { return }
            isLoadingImage = true
            apiError = nil
            do {
                let generatedImage = try await openAIService.generateAdvertisementImage(prompt: adDescription, inputImage: image)
                self.generatedAdImage = generatedImage
                await handleSuccessfulGeneration(with: generatedImage)
            } catch let error as OpenAIError {
                self.apiError = error
            } catch {
                self.apiError = .unknown
            }
            self.isLoadingImage = false
        }
    }

    private func handleSuccessfulGeneration(with image: UIImage) async {
        guard let userId = authService.user?.uid else {
            apiError = .apiError("User not found after image generation.")
            return
        }
        let usedFreeTier = generatedImageCount < 2
        do {
            try await updateUserDataInFirestore(userId: userId, usedFreeTier: usedFreeTier)
            try await saveGeneratedImageToHistory(image: image, userId: userId)
        } catch {
            apiError = .apiError("DB/Storage Error: \(error.localizedDescription)")
        }
    }

    private func checkCreditsAndFreeTier() async -> Bool {
        if generatedImageCount < 2 {
            let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
            do {
                let deviceUsageDoc = try await db.collection("deviceUsage").document(deviceId).getDocument()
                if deviceUsageDoc.exists {
                    if credits <= 0 {
                        showingCreditAlert = true
                        return false
                    }
                } else {
                    return true
                }
            } catch {
                apiError = .apiError("Could not verify device usage: \(error.localizedDescription)")
                return false
            }
        }
        if credits > 0 {
            return true
        } else {
            showingCreditAlert = true
            return false
        }
    }

    private func saveGeneratedImageToHistory(image: UIImage, userId: String) async throws {
        let downloadURL = try await storageService.uploadImage(image: image, userId: userId)
        let userDocRef = db.collection("users").document(userId)
        try await userDocRef.updateData(["generatedImageUrls": FieldValue.arrayUnion([downloadURL.absoluteString])])
    }

    private func updateUserDataInFirestore(userId: String, usedFreeTier: Bool) async throws {
        let userRef = db.collection("users").document(userId)
        let deviceRef = db.collection("deviceUsage").document(UIDevice.current.identifierForVendor?.uuidString ?? "")
        
        try await db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userDocument: DocumentSnapshot
            do {
                try userDocument = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            var dataToUpdate: [String: Any] = ["generatedImageCount": FieldValue.increment(Int64(1))]

            if usedFreeTier {
                transaction.setData(["userId": userId, "timestamp": Timestamp(date: Date())], forDocument: deviceRef)
            } else {
                guard let currentCredits = userDocument.data()?["remainingCredits"] as? Int, currentCredits > 0 else {
                    let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Insufficient credits."])
                    errorPointer?.pointee = error
                    return nil
                }
                dataToUpdate["remainingCredits"] = FieldValue.increment(Int64(-1))
            }
            
            transaction.updateData(dataToUpdate, forDocument: userRef)
            return nil
        })
    }
}
