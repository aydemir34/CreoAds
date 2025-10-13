import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    @State private var showingErrorAlert = false // Alert'ı göstermek için
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome to CreoAds")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .alert("Operation Failed.", isPresented: $showingErrorAlert) {
                    Button("Okay") { } // Alert'ı kapatmak için buton
                } message: {
                    Text(errorMessage ?? "An unknown error occurred.") // errorMessage'ı göster
                }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if isLoading {
                ProgressView().padding()
            }
            
            Button(action: {
                Task {
                    await MainActor.run {
                    isLoading = true
                    errorMessage = nil
                    }
                    do {
                    try await authService.logIn(email: email, password: password)
                    } catch {
                    print("Login failed: \(error.localizedDescription)")
                    await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                    }
                    }
                    await MainActor.run { isLoading = false }
                }
                }) {
                Text("Log In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isLoading)
            .padding(.horizontal)
            
            Button(action: {
                Task {
                    await MainActor.run {
                    isLoading = true
                    errorMessage = nil
                    }
                    do {
                    try await authService.signUp(email: email, password: password)
                    } catch {
                    print("Signup failed: \(error.localizedDescription)")
                    await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                    }
                    }
                    await MainActor.run { isLoading = false }
                }
                })
                {
                Text("Create Account")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
            }
            .disabled(isLoading)
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .bottom)
        .alert("İşlem Başarısız", isPresented: $showingErrorAlert) { // YENİ EKLENDİ
                    Button("Tamam") { }
                } message: {
                    Text(errorMessage ?? "Bilinmeyen bir hata oluştu.")
                }
            }
        }

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(AuthService())
    }
}
