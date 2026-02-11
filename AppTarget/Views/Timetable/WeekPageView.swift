import SwiftUI
import Domain

/// 1週間分の時間割を表示する View。
/// 7つの DayColumnView を横に並べる。
struct WeekPageView: View {
    let timetables: [DailyTimetable]
    let dates: [Date]
    let subjects: [Subject]
    let viewModel: TimetableViewModel
    let onSlotTap: (TimetableSlot, String) -> Void

    private var columnSpacing: CGFloat {
        switch viewModel.displayMode {
        case .oneDay: return 0
        case .threeDays: return 6
        case .week: return 0
        }
    }

    private var horizontalPadding: CGFloat {
        switch viewModel.displayMode {
        case .oneDay: return 12
        case .threeDays: return 4
        case .week: return 4
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 日付ヘッダー
            HStack(spacing: columnSpacing) {
                ForEach(Array(dates.enumerated()), id: \.offset) { _, date in
                    let dateString = DateHelper.string(from: date)
                    let isToday = DateHelper.todayString == dateString

                    VStack(spacing: 2) {
                        Text(DateHelper.dayOfWeek(from: date))
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text(DateHelper.displayString(from: date))
                            .font(.caption)
                            .fontWeight(isToday ? .bold : .regular)
                            .foregroundStyle(isToday ? .white : .primary)
                            .frame(width: 32, height: 32)
                            .background(isToday ? Color.accentColor : Color.clear)
                            .clipShape(Circle())
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 4)

            // スロット部分
            HStack(spacing: columnSpacing) {
                ForEach(Array(dates.enumerated()), id: \.offset) { _, date in
                    let dateString = DateHelper.string(from: date)
                    let timetable = timetables.first { $0.dateString == dateString }

                    DayColumnView(
                        date: date,
                        slots: timetable?.slots ?? [],
                        dateString: dateString,
                        subjects: subjects,
                        displayMode: viewModel.displayMode,
                        viewModel: viewModel,
                        onSlotTap: { slot in
                            onSlotTap(slot, dateString)
                        }
                    )
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 8)
            .frame(maxHeight: .infinity)
        }
    }
}
