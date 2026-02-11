import Foundation

/// 科目を表すドメインエンティティ。
/// ユーザーが設定画面で登録する科目情報。名前とテーマカラー（プリセットのインデックス）を持つ。
public struct Subject: Sendable, Identifiable, Equatable, Hashable {
    public let id: String
    public var name: String
    public var colorIndex: Int

    public init(id: String = UUID().uuidString, name: String, colorIndex: Int) {
        self.id = id
        self.name = name
        self.colorIndex = colorIndex
    }
}

// MARK: - Sample Data

extension Subject {
    public static let sampleData: [Subject] = [
        Subject(id: "s1", name: "英語", colorIndex: 0),
        Subject(id: "s2", name: "読書", colorIndex: 1),
        Subject(id: "s3", name: "プログラミング", colorIndex: 2),
        Subject(id: "s4", name: "運動", colorIndex: 3),
        Subject(id: "s5", name: "音楽", colorIndex: 4),
    ]
}
