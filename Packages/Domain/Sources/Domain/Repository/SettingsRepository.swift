/// ユーザー設定へのアクセスを抽象化するリポジトリプロトコル。
/// Firestore の具象実装は Infra 層で提供する。
public protocol SettingsRepository: Sendable {
    /// 1日あたりのスロット数を取得する。未設定なら nil を返す。
    func fetchSlotsPerDay(userId: String) async throws -> Int?

    /// 1日あたりのスロット数を保存する。
    func saveSlotsPerDay(userId: String, count: Int) async throws
}
