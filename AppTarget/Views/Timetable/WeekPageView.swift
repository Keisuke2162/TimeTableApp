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

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(dates.enumerated()), id: \.offset) { index, date in
                let dateString = DateHelper.string(from: date)
                let timetable = timetables.first { $0.dateString == dateString }
                let isToday = DateHelper.todayString == dateString

                DayColumnView(
                    date: date,
                    slots: timetable?.slots ?? [],
                    dateString: dateString,
                    isToday: isToday,
                    subjects: subjects,
                    viewModel: viewModel,
                    onSlotTap: { slot in
                        onSlotTap(slot, dateString)
                    }
                )
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }
}
