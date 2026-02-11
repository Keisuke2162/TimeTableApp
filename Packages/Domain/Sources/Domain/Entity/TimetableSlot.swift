import Foundation

/// 時間割の1マスを表すドメインエンティティ。
/// 日付ごとに複数のスロットが存在し、displayOrder で表示順を管理する。
public struct TimetableSlot: Sendable, Identifiable, Equatable {
    public let id: String
    public var dateString: String
    public var displayOrder: Int
    public var subjectId: String?
    public var minutes: Int
    public var isCompleted: Bool

    public init(
        id: String = UUID().uuidString,
        dateString: String,
        displayOrder: Int,
        subjectId: String? = nil,
        minutes: Int = 0,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.dateString = dateString
        self.displayOrder = displayOrder
        self.subjectId = subjectId
        self.minutes = minutes
        self.isCompleted = isCompleted
    }
}

// MARK: - Sample Data

extension TimetableSlot {
    public static let sampleData: [TimetableSlot] = [
        TimetableSlot(id: "slot1", dateString: "2025-01-13", displayOrder: 0, subjectId: "s1", minutes: 60, isCompleted: true),
        TimetableSlot(id: "slot2", dateString: "2025-01-13", displayOrder: 1, subjectId: "s2", minutes: 30),
        TimetableSlot(id: "slot3", dateString: "2025-01-13", displayOrder: 2),
        TimetableSlot(id: "slot4", dateString: "2025-01-13", displayOrder: 3, subjectId: "s3", minutes: 90, isCompleted: true),
        TimetableSlot(id: "slot5", dateString: "2025-01-13", displayOrder: 4, subjectId: "s4", minutes: 60),
    ]
}
