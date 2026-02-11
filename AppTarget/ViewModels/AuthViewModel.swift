import Foundation
import Observation
import UseCase
import AuthenticationServices
import CryptoKit
import GoogleSignIn

/// 認証画面のロジックを管理する ViewModel。
@Observable
@MainActor
final class AuthViewModel {

    // MARK: - State

    private(set) var isSignedIn = false
    private(set) var userId: String?
    private(set) var isLoading = false
    var errorMessage: String?

    // MARK: - Dependencies

    private let authUseCase: AuthUseCase
    private var currentNonce: String?

    // MARK: - Init

    init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
        self.userId = authUseCase.currentUserId
        self.isSignedIn = authUseCase.currentUserId != nil
    }

    // MARK: - Actions

    func observeAuthState() async {
        for await uid in authUseCase.observeAuthState() {
            self.userId = uid
            self.isSignedIn = uid != nil
        }
    }

    func signInWithGoogle() async {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first,
              let rootVC = windowScene.windows.first?.rootViewController
        else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            guard let idToken = result.user.idToken?.tokenString else {
                errorMessage = "Google サインインに失敗しました。"
                return
            }

            let uid = try await authUseCase.signInWithGoogle(
                idToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            self.userId = uid
            self.isSignedIn = true
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Apple Sign In

    func prepareAppleSignIn() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        isLoading = true
        errorMessage = nil

        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8),
                  let nonce = currentNonce
            else {
                isLoading = false
                errorMessage = "Apple サインインに失敗しました。"
                return
            }

            Task {
                defer { isLoading = false }
                do {
                    let uid = try await authUseCase.signInWithApple(idToken: idTokenString, nonce: nonce)
                    self.userId = uid
                    self.isSignedIn = true
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }

        case .failure(let error):
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        do {
            try authUseCase.signOut()
            userId = nil
            isSignedIn = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Nonce Utilities

    private func randomNonceString(length: Int = 32) -> String {
        var randomBytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
