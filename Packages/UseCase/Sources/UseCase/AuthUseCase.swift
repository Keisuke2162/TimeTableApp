import Domain

/// 認証に関するユースケース。
/// AuthRepository プロトコル経由で認証を行うため、Firebase 等の具象実装に依存しない。
public final class AuthUseCase: Sendable {
    private let repository: any AuthRepository

    public init(repository: any AuthRepository) {
        self.repository = repository
    }

    public var currentUserId: String? {
        repository.currentUserId
    }

    public func signInWithGoogle(idToken: String, accessToken: String) async throws -> String {
        try await repository.signInWithGoogle(idToken: idToken, accessToken: accessToken)
    }

    public func signInWithApple(idToken: String, nonce: String) async throws -> String {
        try await repository.signInWithApple(idToken: idToken, nonce: nonce)
    }

    public func signOut() throws {
        try repository.signOut()
    }

    public func observeAuthState() -> AsyncStream<String?> {
        repository.observeAuthState()
    }
}
