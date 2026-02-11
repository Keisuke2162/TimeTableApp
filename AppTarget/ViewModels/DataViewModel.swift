import Foundation
import Observation
import Domain
import UseCase

/// データ画面のロジックを管理する ViewModel。
/// Contribution Graph と科目ごとの累計実績時間を計算する。
@Observable
@MainActor
final class DataViewModel {

    // MARK: - Types

    struct DayData: Sendable, Identifiable {
        var id: String { dateString }
        let dateString: String
        let completedCount: Int
        let totalSlots: Int
    }

    struct SubjectStat: Sendable, Identifiable {
        let id: String
        let name: String
        let colorIndex: Int
        let totalActualMinutes: Int
    }

    // MARK: - State

    private(set) var contributionData: [DayData] = []
    private(set) var subjectStats: [SubjectStat] = []
    private(set) var isLoading = false
    var errorMessage: String?

    // MARK: - Dependencies

    private let timetableUseCase: TimetableUseCase
    private let subjectUseCase: SubjectUseCase
    private let settingsUseCase: SettingsUseCase
    private let userId: String

    // MARK: - Init

    init(
        timetableUseCase: TimetableUseCase,
        subjectUseCase: SubjectUseCase,
        settingsUseCase: SettingsUseCase,
        userId: String
    ) {
        self.timetableUseCase = timetableUseCase
        self.subjectUseCase = subjectUseCase
        self.settingsUseCase = settingsUseCase
        self.userId = userId
    }

    // MARK: - Actions

    /// データを読み込む（過去140日分 = 20週）。
    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            let slotsPerDay = try await settingsUseCase.fetchSlotsPerDay(userId: userId)
            let subjects = try await subjectUseCase.fetchSubjects(userId: userId)
            let dateStrings = DateHelper.dateStrings(lastDays: 140)
            let timetables = try await timetableUseCase.fetchTimetables(userId: userId, dateStrings: dateStrings)

            let timetableMap = Dictionary(uniqueKeysWithValues: timetables.map { ($0.dateString, $0) })

            // Contribution データ
            contributionData = dateStrings.map { dateString in
                if let tt = timetableMap[dateString] {
                    DayData(
                        dateString: dateString,
                        completedCount: tt.completedCount,
                        totalSlots: tt.slots.count
                    )
                } else {
                    DayData(
                        dateString: dateString,
                        completedCount: 0,
                        totalSlots: slotsPerDay
                    )
                }
            }

            // 科目ごとの累計実績時間
            var statMap: [String: Int] = [:]
            for tt in timetables {
                for slot in tt.slots where slot.isCompleted {
                    if let sid = slot.subjectId {
                        statMap[sid, default: 0] += slot.actualMinutes
                    }
                }
            }

            subjectStats = subjects.compactMap { subject in
                guard let minutes = statMap[subject.id], minutes > 0 else { return nil }
                return SubjectStat(
                    id: subject.id,
                    name: subject.name,
                    colorIndex: subject.colorIndex,
                    totalActualMinutes: minutes
                )
            }.sorted { $0.totalActualMinutes > $1.totalActualMinutes }

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
