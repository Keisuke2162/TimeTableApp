import Domain
import FirebaseFirestore

/// SettingsRepository の具象実装。
/// Firestore を使用してユーザー設定を管理する。
///
/// Firestore 構造:
///   users/{userId}/settings/general -> { slotsPerDay: Int }
public final class SettingsRepositoryImpl: SettingsRepository, @unchecked Sendable {
    private let db: Firestore

    public init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    public func fetchSlotsPerDay(userId: String) async throws -> Int? {
        let doc = try await db.collection("users").document(userId)
            .collection("settings").document("general").getDocument()

        guard doc.exists, let data = doc.data() else { return nil }
        return data["slotsPerDay"] as? Int
    }

    public func saveSlotsPerDay(userId: String, count: Int) async throws {
        try await db.collection("users").document(userId)
            .collection("settings").document("general")
            .setData(["slotsPerDay": count], merge: true)
    }
}
