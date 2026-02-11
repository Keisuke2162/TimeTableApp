import Domain
@preconcurrency import FirebaseAuth

/// AuthRepository の具象実装。
/// Firebase Auth を使用して認証機能を提供する。
public final class AuthRepositoryImpl: AuthRepository, @unchecked Sendable {
    public init() {}

    public var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    public func signInWithGoogle(idToken: String, accessToken: String) async throws -> String {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let result = try await Auth.auth().signIn(with: credential)
        return result.user.uid
    }

    public func signInWithApple(idToken: String, nonce: String) async throws -> String {
        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: nil
        )
        let result = try await Auth.auth().signIn(with: credential)
        return result.user.uid
    }

    public func signOut() throws {
        try Auth.auth().signOut()
    }

    public func observeAuthState() -> AsyncStream<String?> {
        AsyncStream { continuation in
            let handle = Auth.auth().addStateDidChangeListener { _, user in
                continuation.yield(user?.uid)
            }
            continuation.onTermination = { _ in
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
    }
}
