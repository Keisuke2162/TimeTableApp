import Domain
import FirebaseFirestore

/// SubjectRepository の具象実装。
/// Firestore を使用して科目データを管理する。
///
/// Firestore 構造:
///   users/{userId}/subjects/{subjectId} -> { name: String, colorIndex: Int }
public final class SubjectRepositoryImpl: SubjectRepository, @unchecked Sendable {
    private let db: Firestore

    public init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    public func fetchSubjects(userId: String) async throws -> [Subject] {
        let snapshot = try await db.collection("users").document(userId)
            .collection("subjects").getDocuments()

        return snapshot.documents.compactMap { doc -> Subject? in
            SubjectDTO.fromDictionary(id: doc.documentID, doc.data())?.toDomain()
        }
    }

    public func saveSubject(userId: String, subject: Subject) async throws {
        let dto = SubjectDTO.fromDomain(subject)
        try await db.collection("users").document(userId)
            .collection("subjects").document(subject.id)
            .setData(dto.toDictionary())
    }

    public func deleteSubject(userId: String, subjectId: String) async throws {
        try await db.collection("users").document(userId)
            .collection("subjects").document(subjectId)
            .delete()
    }
}
