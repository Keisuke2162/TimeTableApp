import Domain

/// 科目管理に関するユースケース。
public final class SubjectUseCase: Sendable {
    private let repository: any SubjectRepository

    public init(repository: any SubjectRepository) {
        self.repository = repository
    }

    /// すべての科目を取得する。
    public func fetchSubjects(userId: String) async throws -> [Subject] {
        try await repository.fetchSubjects(userId: userId)
    }

    /// 科目を保存する（新規追加・更新兼用）。
    public func saveSubject(userId: String, subject: Subject) async throws {
        try await repository.saveSubject(userId: userId, subject: subject)
    }

    /// 科目を削除する。
    public func deleteSubject(userId: String, subjectId: String) async throws {
        try await repository.deleteSubject(userId: userId, subjectId: subjectId)
    }
}
