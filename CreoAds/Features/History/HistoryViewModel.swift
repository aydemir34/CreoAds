import SwiftUI
import FirebaseFirestore
import Combine

@MainActor
class HistoryViewModel: ObservableObject {
    
    @Published var imageUrls: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let authService: AuthService
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthService) {
        self.authService = authService
        print("[HistoryViewModel] Initialized.")
        observeAuthChanges()
    }
    
    private func observeAuthChanges() {
        authService.$user
            .sink { [weak self] user in
                guard let self = self else { return }
                self.listenerRegistration?.remove()
                
                if let user = user {
                    self.setupHistoryListener(userID: user.uid)
                } else {
                    self.imageUrls = []
                    self.errorMessage = nil
                    self.isLoading = false
                    print("[HistoryViewModel] User logged out, cleared data and listener.")
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupHistoryListener(userID: String) {
        isLoading = true
        errorMessage = nil
        
        let userDocRef = db.collection("users").document(userID) // DÜZELTME: userId -> userID
        print("[HistoryViewModel] Setting up listener for user: \(userID)")
        
        listenerRegistration = userDocRef.addSnapshotListener { documentSnapshot, error in
            self.isLoading = false
            guard let document = documentSnapshot else {
                self.errorMessage = "Error fetching history: \(error?.localizedDescription ?? "Unknown error")"
                print("[HistoryViewModel] Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                self.errorMessage = "User document data is empty."
                print("[HistoryViewModel] Document data was empty.")
                self.imageUrls = []
                return
            }
            
            print("[HistoryViewModel] Received data: \(data)")
            if let fetchedUrls = data["generatedImageUrls"] as? [String] {
                self.imageUrls = fetchedUrls.reversed()
                print("[HistoryViewModel] Fetched \(self.imageUrls.count) URLs.")
            } else {
                self.imageUrls = []
                print("[HistoryViewModel] 'generatedImageUrls' field not found or not an array.")
            }
            self.errorMessage = nil
        }
    }
    
    deinit {
        listenerRegistration?.remove()
        cancellables.forEach { $0.cancel() }
        print("[HistoryViewModel] Deinitialized and listener removed.")
    }
}
