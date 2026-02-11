import Foundation
import Observation
import Domain
import UseCase

/// 時間割画面のロジックを管理する ViewModel。
/// 週単位でデータを管理し、横スクロールによる週の切り替えをサポートする。
@Observable
@MainActor
final class TimetableViewModel {

    // MARK: - State

    private(set) var weekTimetables: [DailyTimetable] = []
    private(set) var subjects: [Subject] = []
    private(set) var slotsPerDay: Int = 5
    private(set) var isLoading = false
    var errorMessage: String?

    /// 現在表示中の週の基準日。
    var currentWeekBaseDate: Date = Date()

    /// 現在の週の日付文字列配列。
    var currentWeekDateStrings: [String] {
        DateHelper.weekDateStrings(containing: currentWeekBaseDate)
    }

    /// 現在の週の日付配列。
    var currentWeekDates: [Date] {
        DateHelper.weekDates(containing: currentWeekBaseDate)
    }

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

    /// 初期データを読み込む。
    func loadInitialData() async {
        isLoading = true
        errorMessage = nil

        do {
            slotsPerDay = try await settingsUseCase.fetchSlotsPerDay(userId: userId)
            subjects = try await subjectUseCase.fetchSubjects(userId: userId)
            await loadCurrentWeek()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// 現在の週のデータを読み込む。
    func loadCurrentWeek() async {
        do {
            weekTimetables = try await timetableUseCase.fetchWeek(
                userId: userId,
                dateStrings: currentWeekDateStrings,
                slotsCount: slotsPerDay
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// 前の週に移動する。
    func goToPreviousWeek() async {
        if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeekBaseDate) {
            currentWeekBaseDate = newDate
            await loadCurrentWeek()
        }
    }

    /// 次の週に移動する。
    func goToNextWeek() async {
        if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentWeekBaseDate) {
            currentWeekBaseDate = newDate
            await loadCurrentWeek()
        }
    }

    /// 今週に戻る。
    func goToThisWeek() async {
        currentWeekBaseDate = Date()
        await loadCurrentWeek()
    }

    /// スロットの科目を設定する。
    func setSubject(for slotId: String, dateString: String, subjectId: String?) async {
        guard let dayIndex = weekTimetables.firstIndex(where: { $0.dateString == dateString }),
              let slotIndex = weekTimetables[dayIndex].slots.firstIndex(where: { $0.id == slotId })
        else { return }

        weekTimetables[dayIndex].slots[slotIndex].subjectId = subjectId
        await saveDailyTimetable(weekTimetables[dayIndex])
    }

    /// スロットの予定時間を設定する。
    func setPlannedMinutes(for slotId: String, dateString: String, minutes: Int) async {
        guard let dayIndex = weekTimetables.firstIndex(where: { $0.dateString == dateString }),
              let slotIndex = weekTimetables[dayIndex].slots.firstIndex(where: { $0.id == slotId })
        else { return }

        weekTimetables[dayIndex].slots[slotIndex].plannedMinutes = minutes
        await saveDailyTimetable(weekTimetables[dayIndex])
    }

    /// スロットの実績時間を設定する。
    func setActualMinutes(for slotId: String, dateString: String, minutes: Int) async {
        guard let dayIndex = weekTimetables.firstIndex(where: { $0.dateString == dateString }),
              let slotIndex = weekTimetables[dayIndex].slots.firstIndex(where: { $0.id == slotId })
        else { return }

        weekTimetables[dayIndex].slots[slotIndex].actualMinutes = minutes
        await saveDailyTimetable(weekTimetables[dayIndex])
    }

    /// スロットの完了状態を切り替える。
    func toggleCompletion(for slotId: String, dateString: String) async {
        guard let dayIndex = weekTimetables.firstIndex(where: { $0.dateString == dateString }),
              let slotIndex = weekTimetables[dayIndex].slots.firstIndex(where: { $0.id == slotId })
        else { return }

        weekTimetables[dayIndex].slots[slotIndex].isCompleted.toggle()
        await saveDailyTimetable(weekTimetables[dayIndex])
    }

    /// スロットを並び替える。
    func reorderSlots(dateString: String, from source: IndexSet, to destination: Int) async {
        guard let dayIndex = weekTimetables.firstIndex(where: { $0.dateString == dateString })
        else { return }

        weekTimetables[dayIndex].slots.move(fromOffsets: source, toOffset: destination)
        for i in weekTimetables[dayIndex].slots.indices {
            weekTimetables[dayIndex].slots[i].displayOrder = i
        }
        await saveDailyTimetable(weekTimetables[dayIndex])
    }

    /// 科目名を取得するヘルパー。
    func subjectName(for subjectId: String?) -> String {
        guard let subjectId,
              let subject = subjects.first(where: { $0.id == subjectId })
        else { return "未設定" }
        return subject.name
    }

    /// 科目カラーインデックスを取得するヘルパー。
    func subjectColorIndex(for subjectId: String?) -> Int? {
        guard let subjectId,
              let subject = subjects.first(where: { $0.id == subjectId })
        else { return nil }
        return subject.colorIndex
    }

    // MARK: - Private

    private func saveDailyTimetable(_ timetable: DailyTimetable) async {
        do {
            try await timetableUseCase.saveDailyTimetable(userId: userId, timetable: timetable)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
