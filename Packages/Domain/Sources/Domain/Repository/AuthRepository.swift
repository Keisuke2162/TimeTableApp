/// 認証機能を抽象化するリポジトリプロトコル。
/// Firebase Auth の具象実装は Infra 層で提供する。
public protocol AuthRepository: Sendable {
    /// 現在ログイン中のユーザー ID。未ログインなら nil。
    var currentUserId: String? { get }

    /// Google 認証のトークンを使って Firebase にサインインする。
    func signInWithGoogle(idToken: String, accessToken: String) async throws -> String

    /// Apple 認証のトークンを使って Firebase にサインインする。
    func signInWithApple(idToken: String, nonce: String) async throws -> String

    /// サインアウトする。
    func signOut() throws

    /// 認証状態の変化を監視するストリームを返す。ユーザー ID または nil を流す。
    func observeAuthState() -> AsyncStream<String?>
}
