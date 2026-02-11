import Domain

/// Firestore に保存する時間割スロットの Data Transfer Object。
/// Firestore のドキュメント構造と Domain Entity の間の変換を担う。
struct TimetableSlotDTO: Codable, Sendable {
    let id: String
    let displayOrder: Int
    let subjectId: String?
    let plannedMinutes: Int
    let actualMinutes: Int
    let isCompleted: Bool

    func toDomain(dateString: String) -> TimetableSlot {
        TimetableSlot(
            id: id,
            dateString: dateString,
            displayOrder: displayOrder,
            subjectId: subjectId,
            plannedMinutes: plannedMinutes,
            actualMinutes: actualMinutes,
            isCompleted: isCompleted
        )
    }

    static func fromDomain(_ slot: TimetableSlot) -> TimetableSlotDTO {
        TimetableSlotDTO(
            id: slot.id,
            displayOrder: slot.displayOrder,
            subjectId: slot.subjectId,
            plannedMinutes: slot.plannedMinutes,
            actualMinutes: slot.actualMinutes,
            isCompleted: slot.isCompleted
        )
    }

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "displayOrder": displayOrder,
            "plannedMinutes": plannedMinutes,
            "actualMinutes": actualMinutes,
            "isCompleted": isCompleted,
        ]
        if let subjectId {
            dict["subjectId"] = subjectId
        }
        return dict
    }

    static func fromDictionary(_ dict: [String: Any]) -> TimetableSlotDTO? {
        guard let id = dict["id"] as? String,
              let displayOrder = dict["displayOrder"] as? Int,
              let plannedMinutes = dict["plannedMinutes"] as? Int,
              let actualMinutes = dict["actualMinutes"] as? Int,
              let isCompleted = dict["isCompleted"] as? Bool
        else { return nil }

        return TimetableSlotDTO(
            id: id,
            displayOrder: displayOrder,
            subjectId: dict["subjectId"] as? String,
            plannedMinutes: plannedMinutes,
            actualMinutes: actualMinutes,
            isCompleted: isCompleted
        )
    }
}
