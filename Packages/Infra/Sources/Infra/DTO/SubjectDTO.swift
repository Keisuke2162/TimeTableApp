import Domain

/// Firestore に保存する科目の Data Transfer Object。
struct SubjectDTO: Codable, Sendable {
    let id: String
    let name: String
    let colorIndex: Int

    func toDomain() -> Subject {
        Subject(id: id, name: name, colorIndex: colorIndex)
    }

    static func fromDomain(_ subject: Subject) -> SubjectDTO {
        SubjectDTO(id: subject.id, name: subject.name, colorIndex: subject.colorIndex)
    }

    func toDictionary() -> [String: Any] {
        [
            "name": name,
            "colorIndex": colorIndex,
        ]
    }

    static func fromDictionary(id: String, _ dict: [String: Any]) -> SubjectDTO? {
        guard let name = dict["name"] as? String,
              let colorIndex = dict["colorIndex"] as? Int
        else { return nil }

        return SubjectDTO(id: id, name: name, colorIndex: colorIndex)
    }
}
