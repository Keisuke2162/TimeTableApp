/// 科目データへのアクセスを抽象化するリポジトリプロトコル。
/// Firestore の具象実装は Infra 層で提供する。
public protocol SubjectRepository: Sendable {
    /// すべての科目を取得する。
    func fetchSubjects(userId: String) async throws -> [Subject]

    /// 科目を保存する（新規追加・更新兼用）。
    func saveSubject(userId: String, subject: Subject) async throws

    /// 科目を削除する。
    func deleteSubject(userId: String, subjectId: String) async throws
}
