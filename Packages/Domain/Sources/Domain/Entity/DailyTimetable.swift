import Foundation

/// 1日分の時間割を表すドメインエンティティ。
/// 日付文字列（yyyy-MM-dd）をキーとし、その日のスロット一覧を保持する。
public struct DailyTimetable: Sendable, Identifiable, Equatable {
    public var id: String { dateString }
    public let dateString: String
    public var slots: [TimetableSlot]

    public init(dateString: String, slots: [TimetableSlot]) {
        self.dateString = dateString
        self.slots = slots.sorted { $0.displayOrder < $1.displayOrder }
    }

    /// 完了済みスロットの数を返す。
    public var completedCount: Int {
        slots.filter(\.isCompleted).count
    }
}
