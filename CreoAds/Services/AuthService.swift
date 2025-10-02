import Foundation
import FirebaseAuth
import Combine
import FirebaseFirestore
import FirebaseCore
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift
import CryptoKit

// MARK: - AuthError Enum
enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case invalidEmailFormat
    case networkError
    case firestoreError(String)
    case signOutFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email address or password."
        case .emailAlreadyInUse:
            return "This email address is already in use by another account."
        case .weakPassword:
            return "The password is too weak. Please choose a stronger password (at least 6 characters)."
        case .invalidEmailFormat:
            return "The email address format is invalid."
        case .networkError:
            return "Network error. Please check your internet connection."
        case .firestoreError(let message):
            return "Database error: \(message)"
        case .signOutFailed:
            return "Failed to sign out. Please try again."
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
}

// MARK: - Apple Sign In Nonce Helper
// Bu yardımcı fonksiyonlar, Apple ile girişin güvenliğini artırır.
private var currentNonce: String?

private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    var randomBytes = [UInt8](repeating: 0, count: length)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    if errorCode != errSecSuccess {
        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
    }
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    let nonce = randomBytes.map { byte in
        charset[Int(byte) % charset.count]
    }
    return String(nonce)
}

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()
    return hashString
}

// MARK: - AuthService Class
@MainActor
class AuthService: NSObject, ObservableObject { // NSObject ekledik (Apple Delegate için)
    @Published var user: User?
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    
    var isAuthenticated: Bool { user != nil }
    
    // MARK: - Initialization
    override init() {
        super.init()
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Sign Up Method
    func signUp(email: String, password: String) async throws {
        do {
            print("[AuthService] Attempting to sign up user: \(email)")
            
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = authResult.user
            
            print("[AuthService] User successfully created in Firebase Auth: \(user.uid)")
            
            let userDataDict: [String: Any] = [
                "email": email.lowercased(),
                "uid": user.uid,
                "remainingCredits": 2,
                "generatedImageCount": 0,
                "createdAt": Timestamp(date: Date())
            ]
            
            do {
                try await db.collection("users").document(user.uid).setData(userDataDict)
                print("[AuthService] User data successfully set in Firestore for user \(user.uid)")
            } catch {
                print("[AuthService] Firestore error during sign up for user \(user.uid): \(error)")
                throw AuthError.firestoreError("Failed to save initial user data after sign up: \(error.localizedDescription)")
            }
            
        } catch let error as NSError {
            print("[AuthService] SignUp Error - Code: \(error.code), Domain: \(error.domain), Desc: \(error.localizedDescription)")
            guard let errorCode = AuthErrorCode(rawValue: error.code) else {
                print("[AuthService] Unknown or non-Auth error code during sign up: \(error.code)")
                throw AuthError.unknown
            }
            
            switch errorCode {
            case .emailAlreadyInUse:
                throw AuthError.emailAlreadyInUse
            case .weakPassword:
                throw AuthError.weakPassword
            case .invalidEmail:
                throw AuthError.invalidEmailFormat
            case .networkError:
                throw AuthError.networkError
            default:
                print("[AuthService] Unhandled Auth error code during sign up: \(errorCode.rawValue)")
                throw AuthError.unknown
            }
        }
    }
    
    // MARK: - Log In Method
    func logIn(email: String, password: String) async throws {
        do {
            print("[AuthService] Attempting to log in user: \(email)")
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            print("[AuthService] User successfully logged in: \(authResult.user.uid)")
        } catch let error as NSError {
            print("[AuthService] LogIn Error - Code: \(error.code), Domain: \(error.domain), Desc: \(error.localizedDescription)")
            guard let errorCode = AuthErrorCode(rawValue: error.code) else {
                print("[AuthService] Unknown or non-Auth error code during log in: \(error.code)")
                throw AuthError.unknown
            }
            
            switch errorCode {
            case .invalidEmail, .wrongPassword, .userNotFound, .userDisabled, .invalidCredential:
                throw AuthError.invalidCredentials
            case .networkError:
                throw AuthError.networkError
            default:
                print("[AuthService] Unhandled Auth error code during log in: \(errorCode.rawValue)")
                throw AuthError.unknown
            }
        }
    }
    
    // MARK: - Log Out Method
    func logOut() throws {
        do {
            print("[AuthService] Attempting to log out user: \(user?.email ?? "N/A")")
            try Auth.auth().signOut()
            print("[AuthService] User successfully logged out.")
        } catch let error as NSError {
            print("[AuthService] LogOut Error - Code: \(error.code), Domain: \(error.domain), Desc: \(error.localizedDescription)")
            throw AuthError.signOutFailed
        }
    }
    
    // MARK: - Credit Management
    func updateRemainingCredits(by amount: Int) async throws {
        guard let uid = user?.uid else {
            print("[AuthService] Error: User not logged in, cannot update credits.")
            throw AuthError.unknown
        }
        
        let userDocRef = db.collection("users").document(uid)
        print("[AuthService] Attempting to update credits for user \(uid) by \(amount).")
        
        do {
            try await userDocRef.updateData([
                "remainingCredits": FieldValue.increment(Int64(amount))
            ])
            print("[AuthService] Successfully updated credits for user \(uid).")
        } catch {
            print("[AuthService] Firestore error updating credits for user \(uid): \(error)")
            throw AuthError.firestoreError("Failed to update credits: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Apple Sign In
    func handleAppleSignIn(authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw AuthError.invalidCredentials
        }
        
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        
        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthError.invalidCredentials
        }
        
        let credential = OAuthProvider.credential(
                providerID: .apple,
                idToken: idTokenString,
                rawNonce: nonce
            )
        
        let authResult = try await Auth.auth().signIn(with: credential)
        let user = authResult.user
        
        try await createUserIfNeeded(
            uid: user.uid,
            email: user.email ?? appleIDCredential.email ?? "apple_\(user.uid)@creoads.app",
            displayName: appleIDCredential.fullName?.formatted() ?? "Apple User"
        )
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle(presenting viewController: UIViewController) async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.unknown
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.invalidCredentials
        }
        
        let accessToken = result.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        let authResult = try await Auth.auth().signIn(with: credential)
        let user = authResult.user
        
        try await createUserIfNeeded(
            uid: user.uid,
            email: user.email ?? "google_\(user.uid)@creoads.app",
            displayName: user.displayName ?? "Google User"
        )
    }
    
    // MARK: - Helper
    private func createUserIfNeeded(uid: String, email: String, displayName: String) async throws {
        let userDocRef = db.collection("users").document(uid)
        
        do {
            let snapshot = try await userDocRef.getDocument()
            
            if !snapshot.exists {
                let userData: [String: Any] = [
                    "email": email.lowercased(),
                    "uid": uid,
                    "displayName": displayName,
                    "remainingCredits": 2,
                    "generatedImageCount": 0,
                    "createdAt": Timestamp(date: Date()),
                    "authProvider": "social"
                ]
                
                try await userDocRef.setData(userData)
                print("[AuthService] New user created in Firestore: \(uid)")
            } else {
                print("[AuthService] User already exists in Firestore: \(uid)")
            }
        } catch {
            print("[AuthService] Error checking/creating user in Firestore: \(error)")
            throw AuthError.firestoreError("Failed to create user profile: \(error.localizedDescription)")
        }
    }
}

// MARK: - Apple Sign In Coordinator & Delegate
// Bu Coordinator, Apple'ın delegate tabanlı sistemini modern async/await'e çevirir.
class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    private var continuation: CheckedContinuation<ASAuthorization, Error>?
    
    func signIn() async throws -> ASAuthorization {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let nonce = randomNonceString()
            currentNonce = nonce
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            let authController = ASAuthorizationController(authorizationRequests: [request])
            authController.delegate = self
            authController.presentationContextProvider = self
            authController.performRequests()
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation?.resume(returning: authorization)
        continuation = nil
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}
