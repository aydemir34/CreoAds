import SwiftUI

struct MainTabView: View {
    @StateObject private var authService = AuthService()
    @StateObject private var onboardingCoordinator = OnboardingCoordinator()
    
    var body: some View {
        TabView {
            MainView()
                .environmentObject(authService)
                .environmentObject(onboardingCoordinator)
                .tabItem { Label("Create", systemImage: "plus.circle.fill") }
            
            HistoryView(authService: authService)
                .tabItem { Label("Showcase", systemImage: "photo.on.rectangle.angled") }
            
            PurchaseView()
                .tabItem { Label("Purchase", systemImage: "creditcard.fill") }
            
            ProfileView(authService: authService)
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
    }
}
