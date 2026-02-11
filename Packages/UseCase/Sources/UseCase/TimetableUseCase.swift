import Domain

/// 時間割の取得・保存に関するユースケース。
public final class TimetableUseCase: Sendable {
    private let repository: any TimetableRepository

    public init(repository: any TimetableRepository) {
        self.repository = repository
    }

    /// 指定日の時間割を取得する。保存済みスロットを slotsCount 個のマスにマージして返す。
    public func fetchOrCreateDaily(userId: String, dateString: String, slotsCount: Int) async throws -> DailyTimetable {
        let saved = try await repository.fetchDailyTimetable(userId: userId, dateString: dateString)
        return mergeSlots(dateString: dateString, saved: saved, slotsCount: slotsCount)
    }

    /// 1週間分の時間割を取得する。
    public func fetchWeek(userId: String, dateStrings: [String], slotsCount: Int) async throws -> [DailyTimetable] {
        let existing = try await repository.fetchTimetables(userId: userId, dateStrings: dateStrings)
        let existingMap = Dictionary(uniqueKeysWithValues: existing.map { ($0.dateString, $0) })

        return dateStrings.map { dateString in
            mergeSlots(dateString: dateString, saved: existingMap[dateString], slotsCount: slotsCount)
        }
    }

    /// 時間割を保存する。subjectId が設定されているスロットのみ保存する。
    public func saveDailyTimetable(userId: String, timetable: DailyTimetable) async throws {
        let meaningful = timetable.slots.filter { $0.subjectId != nil }
        let filtered = DailyTimetable(dateString: timetable.dateString, slots: meaningful)
        try await repository.saveDailyTimetable(userId: userId, timetable: filtered)
    }

    /// 保存済みスロットを slotsCount 個のマスにマージする。
    private func mergeSlots(dateString: String, saved: DailyTimetable?, slotsCount: Int) -> DailyTimetable {
        let savedMap = Dictionary(
            uniqueKeysWithValues: (saved?.slots ?? []).map { ($0.displayOrder, $0) }
        )
        let slots = (0..<slotsCount).map { order in
            savedMap[order] ?? TimetableSlot(dateString: dateString, displayOrder: order)
        }
        return DailyTimetable(dateString: dateString, slots: slots)
    }

    /// 指定期間のすべての時間割を取得する（Contribution Graph 用）。
    public func fetchTimetables(userId: String, dateStrings: [String]) async throws -> [DailyTimetable] {
        try await repository.fetchTimetables(userId: userId, dateStrings: dateStrings)
    }
}
