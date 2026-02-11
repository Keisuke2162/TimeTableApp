import Domain

/// ユーザー設定に関するユースケース。
public final class SettingsUseCase: Sendable {
    private let repository: any SettingsRepository

    public init(repository: any SettingsRepository) {
        self.repository = repository
    }

    /// 1日あたりのスロット数を取得する。未設定ならデフォルト値 5 を返す。
    public func fetchSlotsPerDay(userId: String) async throws -> Int {
        try await repository.fetchSlotsPerDay(userId: userId) ?? 5
    }

    /// 1日あたりのスロット数を保存する。
    public func saveSlotsPerDay(userId: String, count: Int) async throws {
        let clamped = min(max(count, 2), 6)
        try await repository.saveSlotsPerDay(userId: userId, count: clamped)
    }
}
