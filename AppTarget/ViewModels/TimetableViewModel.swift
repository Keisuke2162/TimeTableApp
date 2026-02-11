import Foundation
import Observation
import Domain
import UseCase

/// 表示モード：3日表示 or 7日（週）表示。
enum DisplayMode: Int, Sendable {
    case oneDay = 1
    case threeDays = 3
    case week = 7

    var dayCount: Int { rawValue }

    var next: DisplayMode {
        switch self {
        case .oneDay: return .threeDays
        case .threeDays: return .week
        case .week: return .oneDay
        }
    }
}

/// 時間割画面のロジックを管理する ViewModel。
@Observable
@MainActor
final class TimetableViewModel {

    // MARK: - Constants

    private static let displayModeKey = "timetable_display_mode"

    // MARK: - State

    /// キャッシュ: 現在期間＋前後7日分のデータを保持する。
    private var cache: [String: DailyTimetable] = [:]

    /// 現在の表示モードに応じた表示用データ。
    var weekTimetables: [DailyTimetable] {
        currentDateStrings.compactMap { cache[$0] }
    }
    private(set) var subjects: [Subject] = []
    private(set) var slotsPerDay: Int = 5
    private(set) var isLoading = false
    var errorMessage: String?
    private var lastModeToggle: Date = .distantPast

    /// 表示モード。
    var displayMode: DisplayMode {
        didSet {
            UserDefaults.standard.set(displayMode.rawValue, forKey: Self.displayModeKey)
        }
    }

    /// 現在表示中の基準日。
    var currentWeekBaseDate: Date = Date()

    /// 現在の表示期間の日付文字列配列。
    var currentDateStrings: [String] {
        switch displayMode {
        case .week:
            return DateHelper.weekDateStrings(containing: currentWeekBaseDate)
        case .threeDays:
            return DateHelper.dateStrings(from: threeDaysStartDate, count: 3)
        case .oneDay:
            return DateHelper.dateStrings(from: currentWeekBaseDate, count: 1)
        }
    }

    /// 現在の表示期間の日付配列。
    var currentDates: [Date] {
        switch displayMode {
        case .week:
            return DateHelper.weekDates(containing: currentWeekBaseDate)
        case .threeDays:
            return DateHelper.dates(from: threeDaysStartDate, count: 3)
        case .oneDay:
            return DateHelper.dates(from: currentWeekBaseDate, count: 1)
        }
    }

    /// 3日表示時の開始日（基準日を中央にする）。
    private var threeDaysStartDate: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: currentWeekBaseDate) ?? currentWeekBaseDate
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
        let saved = UserDefaults.standard.integer(forKey: Self.displayModeKey)
        self.displayMode = DisplayMode(rawValue: saved) ?? .threeDays
    }

    // MARK: - Actions

    /// 初期データを読み込む。
    func loadInitialData() async {
        isLoading = true
        errorMessage = nil

        do {
            slotsPerDay = try await settingsUseCase.fetchSlotsPerDay(userId: userId)
            subjects = try await subjectUseCase.fetchSubjects(userId: userId)
            await loadCurrentPeriod()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// 現在の表示期間＋前後7日分のデータを読み込む。
    func loadCurrentPeriod() async {
        let calendar = Calendar.current
        let dateStrings = buildDateStrings(around: currentWeekBaseDate)
        do {
            let timetables = try await timetableUseCase.fetchWeek(
                userId: userId,
                dateStrings: dateStrings,
                slotsCount: slotsPerDay
            )
            for tt in timetables {
                cache[tt.dateString] = tt
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// 前の期間に移動する。
    func goToPrevious() async {
        if let newDate = Calendar.current.date(byAdding: .day, value: -displayMode.dayCount, to: currentWeekBaseDate) {
            currentWeekBaseDate = newDate
            await prefetchIfNeeded()
        }
    }

    /// 次の期間に移動する。
    func goToNext() async {
        if let newDate = Calendar.current.date(byAdding: .day, value: displayMode.dayCount, to: currentWeekBaseDate) {
            currentWeekBaseDate = newDate
            await prefetchIfNeeded()
        }
    }

    /// 今日に戻る。
    func goToToday() async {
        currentWeekBaseDate = Date()
        await loadCurrentPeriod()
    }

    /// 表示モードを切り替える。
    func toggleDisplayMode() {
        let current = displayMode
        // 連打による二重発火を防止
        guard lastModeToggle.distance(to: Date()) > 0.3 else { return }
        lastModeToggle = Date()
        displayMode = current.next
    }

    /// スロットの完了状態を設定する。
    func setCompletion(slotId: String, dateString: String, isCompleted: Bool) async {
        guard var day = cache[dateString],
              let slotIndex = day.slots.firstIndex(where: { $0.id == slotId })
        else { return }

        day.slots[slotIndex].isCompleted = isCompleted
        cache[dateString] = day

        do {
            try await timetableUseCase.saveDailyTimetable(userId: userId, timetable: day)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// スロットを一括更新して保存する。
    func updateSlot(
        slotId: String,
        dateString: String,
        subjectId: String?,
        minutes: Int,
        isCompleted: Bool
    ) async {
        guard var day = cache[dateString],
              let slotIndex = day.slots.firstIndex(where: { $0.id == slotId })
        else { return }

        day.slots[slotIndex].subjectId = subjectId
        day.slots[slotIndex].minutes = minutes
        day.slots[slotIndex].isCompleted = isCompleted
        cache[dateString] = day

        do {
            try await timetableUseCase.saveDailyTimetable(userId: userId, timetable: day)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// スロットを並び替える。
    func reorderSlots(dateString: String, from source: IndexSet, to destination: Int) async {
        guard var day = cache[dateString] else { return }

        day.slots.move(fromOffsets: source, toOffset: destination)
        for i in day.slots.indices {
            day.slots[i].displayOrder = i
        }
        cache[dateString] = day
        await saveDailyTimetable(day)
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

    /// 現在の表示期間に不足データがあればフェッチし、前後7日分をバックグラウンドでプリフェッチする。
    private func prefetchIfNeeded() async {
        let needed = currentDateStrings.filter { cache[$0] == nil }
        if !needed.isEmpty {
            do {
                let timetables = try await timetableUseCase.fetchWeek(
                    userId: userId,
                    dateStrings: needed,
                    slotsCount: slotsPerDay
                )
                for tt in timetables {
                    cache[tt.dateString] = tt
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        // バックグラウンドで前後7日分をプリフェッチ
        Task {
            let allNeeded = buildDateStrings(around: currentWeekBaseDate)
                .filter { cache[$0] == nil }
            guard !allNeeded.isEmpty else { return }
            do {
                let timetables = try await timetableUseCase.fetchWeek(
                    userId: userId,
                    dateStrings: allNeeded,
                    slotsCount: slotsPerDay
                )
                for tt in timetables {
                    cache[tt.dateString] = tt
                }
            } catch {
                // プリフェッチの失敗はサイレントに無視
            }
        }
    }

    /// 基準日を中心に、現在の表示期間＋前後7日分の日付文字列を返す。
    private func buildDateStrings(around baseDate: Date) -> [String] {
        let calendar = Calendar.current
        guard let start = calendar.date(byAdding: .day, value: -7, to: baseDate) else { return currentDateStrings }
        let totalDays = 7 + displayMode.dayCount + 7
        let weekStrings = DateHelper.weekDateStrings(containing: baseDate)
        let rangeStrings = DateHelper.dateStrings(from: start, count: totalDays)
        return Array(Set(weekStrings + rangeStrings)).sorted()
    }

    private func saveDailyTimetable(_ timetable: DailyTimetable) async {
        do {
            try await timetableUseCase.saveDailyTimetable(userId: userId, timetable: timetable)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
