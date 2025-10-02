import SwiftUI
import RevenueCat
import FirebaseAuth

@MainActor
class PurchaseViewModel: ObservableObject {
    
    @Published var fullName: String = ""
    @Published var businessName: String = ""
    @Published var businessDescription: String = ""
    @Published var offerings: Offerings? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    init() {
        print("PurchaseViewModel initialized.")
    }
    
    func fetchOfferings() async {
        guard !isLoading else { return }
        
        print("[PurchaseViewModel] Fetching offerings.")
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let fetchedOfferings = try await Purchases.shared.offerings()
            self.offerings = fetchedOfferings
            print("[PurchaseViewModel] Offerings fetched successfully.")
            
            if fetchedOfferings.current == nil || fetchedOfferings.current?.availablePackages.isEmpty == true {
                print("[PurchaseViewModel] No current offering or packages found.")
                self.errorMessage = "No credit packages available at the moment. Please check back later."
            }
        } catch {
            print("[PurchaseViewModel] Error fetching offerings: \(error)")
            self.errorMessage = "Failed to load purchase options: There was a credentials issue. Check the underlying error for more details. Invalid API Key."
            self.offerings = nil
        }
        
        isLoading = false
    }
    
    func purchase(package: Package) async {
        guard !isLoading else { return }
        
        print("[PurchaseViewModel] Attempting to purchase package: \(package.identifier)")
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let result = try await Purchases.shared.purchase(package: package)
            
            print("[PurchaseViewModel] Purchase successful (simulated): \(result.transaction?.transactionIdentifier ?? "N/A")")
            self.successMessage = "\(package.storeProduct.localizedTitle) purchased successfully! (Verification needed)"
            
        } catch {
            let nsError = error as NSError
            
            if nsError.domain == ErrorCode.errorDomain {
                let errorCode = nsError.code
                if errorCode == ErrorCode.purchaseCancelledError.rawValue {
                    print("[PurchaseViewModel] Purchase cancelled by user.")
                    self.errorMessage = "Purchase cancelled."
                } else {
                    print("[PurchaseViewModel] RevenueCat Error: Code \(errorCode)")
                    self.errorMessage = "Purchase failed: \(error.localizedDescription)"
                }
            } else {
                print("[PurchaseViewModel] Unknown error: \(error)")
                self.errorMessage = "An unknown error occurred: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
    
    func restorePurchases() async {
        guard !isLoading else { return }
        
        print("[PurchaseViewModel] Attempting to restore purchases.")
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            
            print("[PurchaseViewModel] Purchases restored successfully.")
            
            if customerInfo.entitlements.active.isEmpty {
                self.successMessage = "Purchases restored. No active subscriptions found."
            } else {
                let activeEntitlements = customerInfo.entitlements.active.keys.joined(separator: ", ")
                self.successMessage = "Purchases restored. Active entitlements: \(activeEntitlements)"
            }
            
        } catch {
            print("[PurchaseViewModel] Error restoring purchases: \(error)")
            self.errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
