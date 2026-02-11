import Domain

/// 時間割の取得・保存に関するユースケース。
public final class TimetableUseCase: Sendable {
    private let repository: any TimetableRepository

    public init(repository: any TimetableRepository) {
        self.repository = repository
    }

    /// 指定日の時間割を取得する。存在しなければ指定数の空スロットで初期化して返す。
    public func fetchOrCreateDaily(userId: String, dateString: String, slotsCount: Int) async throws -> DailyTimetable {
        if let existing = try await repository.fetchDailyTimetable(userId: userId, dateString: dateString) {
            return existing
        }
        let slots = (0..<slotsCount).map { order in
            TimetableSlot(dateString: dateString, displayOrder: order)
        }
        return DailyTimetable(dateString: dateString, slots: slots)
    }

    /// 1週間分の時間割を取得する。
    public func fetchWeek(userId: String, dateStrings: [String], slotsCount: Int) async throws -> [DailyTimetable] {
        let existing = try await repository.fetchTimetables(userId: userId, dateStrings: dateStrings)
        let existingMap = Dictionary(uniqueKeysWithValues: existing.map { ($0.dateString, $0) })

        return dateStrings.map { dateString in
            if let timetable = existingMap[dateString] {
                return timetable
            }
            let slots = (0..<slotsCount).map { order in
                TimetableSlot(dateString: dateString, displayOrder: order)
            }
            return DailyTimetable(dateString: dateString, slots: slots)
        }
    }

    /// 時間割を保存する。
    public func saveDailyTimetable(userId: String, timetable: DailyTimetable) async throws {
        try await repository.saveDailyTimetable(userId: userId, timetable: timetable)
    }

    /// 指定期間のすべての時間割を取得する（Contribution Graph 用）。
    public func fetchTimetables(userId: String, dateStrings: [String]) async throws -> [DailyTimetable] {
        try await repository.fetchTimetables(userId: userId, dateStrings: dateStrings)
    }
}
