import Domain
import FirebaseFirestore

/// TimetableRepository の具象実装。
/// Firestore を使用して日付単位の時間割データを管理する。
///
/// Firestore 構造:
///   users/{userId}/timetable/{yyyy-MM-dd} -> { slots: [TimetableSlotDTO] }
public final class TimetableRepositoryImpl: TimetableRepository, @unchecked Sendable {
    private let db: Firestore

    public init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    public func fetchDailyTimetable(userId: String, dateString: String) async throws -> DailyTimetable? {
        let doc = try await db.collection("users").document(userId)
            .collection("timetable").document(dateString).getDocument()

        guard doc.exists, let data = doc.data(),
              let slotsArray = data["slots"] as? [[String: Any]]
        else { return nil }

        let slots = slotsArray.compactMap { dict -> TimetableSlot? in
            TimetableSlotDTO.fromDictionary(dict)?.toDomain(dateString: dateString)
        }

        guard !slots.isEmpty else { return nil }
        return DailyTimetable(dateString: dateString, slots: slots)
    }

    public func saveDailyTimetable(userId: String, timetable: DailyTimetable) async throws {
        let slotsData = timetable.slots
            .map { TimetableSlotDTO.fromDomain($0).toDictionary() }

        try await db.collection("users").document(userId)
            .collection("timetable").document(timetable.dateString)
            .setData(["slots": slotsData])
    }

    public func fetchTimetables(userId: String, dateStrings: [String]) async throws -> [DailyTimetable] {
        var results: [DailyTimetable] = []
        for dateString in dateStrings {
            if let timetable = try await fetchDailyTimetable(userId: userId, dateString: dateString) {
                results.append(timetable)
            }
        }
        return results
    }
}
