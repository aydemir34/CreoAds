import SwiftUI

struct ActionAreaView: View {
    @ObservedObject var viewModel: MainViewModel
    
    private var isCreateButtonDisabled: Bool {
        return viewModel.isLoadingImage || viewModel.selectedUIImage == nil ||
        viewModel.adDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if viewModel.isLoadingImage {
                ProgressView("Generating Ad...")
                    .padding(.bottom, 5)
            }
            else if viewModel.showingAlert {
                Text("Error: \((viewModel.apiError?.localizedDescription ?? "An unknown error occurred."))")
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                // Klavye veya menü açıksa kapat
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                
                // DÜZELTME: generateAdImage() yerine generateAd()
                viewModel.generateAd()
            }) {
                Text("Create Ad")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isCreateButtonDisabled ? Color.gray.opacity(0.5) : Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .accentColor.opacity(isCreateButtonDisabled ? 0 : 0.5), radius: 10, y: 5)
            }
            .disabled(isCreateButtonDisabled)
            .animation(.easeInOut, value: isCreateButtonDisabled)
        }
    }
}

// MARK: - Preview
#if DEBUG
struct ActionAreaView_Previews: PreviewProvider {
    static var previews: some View {
        let authService = AuthService()
        let openAIService = OpenAIService()
        let storageService = StorageService()
        
        let idleVM = MainViewModel(
            authService: authService,
            openAIService: openAIService,
            storageService: storageService
        )
        idleVM.selectedUIImage = UIImage(systemName: "photo")
        idleVM.adDescription = "A sample ad description."
        
        return ActionAreaView(viewModel: idleVM)
            .padding()
            .background(Color(.systemGroupedBackground))
    }
}
#endif
