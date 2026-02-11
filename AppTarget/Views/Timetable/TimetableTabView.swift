import SwiftUI
import Domain

/// 時間割タブのメイン画面。
/// 週単位で横スクロール（ページング）し、縦に各日のスロットを表示する。
struct TimetableTabView: View {
    @State var viewModel: TimetableViewModel
    @State private var selectedSlot: TimetableSlot?
    @State private var selectedDateString: String?
    @State private var weekOffset: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                weekNavigationBar
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                Divider()

                weekContentView
            }
            .navigationTitle("時間割")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedSlot) { slot in
                if let dateString = selectedDateString {
                    SlotDetailSheet(
                        slot: slot,
                        dateString: dateString,
                        subjects: viewModel.subjects,
                        viewModel: viewModel
                    )
                }
            }
            .task {
                await viewModel.loadInitialData()
            }
        }
    }

    // MARK: - Week Navigation

    private var weekNavigationBar: some View {
        HStack {
            Button {
                Task { await viewModel.goToPreviousWeek() }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.medium))
            }

            Spacer()

            VStack(spacing: 2) {
                if let firstDate = viewModel.currentWeekDates.first {
                    Text(DateHelper.monthYearString(from: firstDate))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                weekRangeText
                    .font(.headline)
            }

            Spacer()

            Button {
                Task { await viewModel.goToNextWeek() }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.medium))
            }
        }
    }

    private var weekRangeText: some View {
        Group {
            if let first = viewModel.currentWeekDates.first,
               let last = viewModel.currentWeekDates.last {
                Text("\(DateHelper.displayString(from: first)) - \(DateHelper.displayString(from: last))")
            } else {
                Text("")
            }
        }
    }

    // MARK: - Week Content

    private var weekContentView: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                WeekPageView(
                    timetables: viewModel.weekTimetables,
                    dates: viewModel.currentWeekDates,
                    subjects: viewModel.subjects,
                    viewModel: viewModel,
                    onSlotTap: { slot, dateString in
                        selectedDateString = dateString
                        selectedSlot = slot
                    }
                )
                .containerRelativeFrame(.horizontal)
            }
        }
        .scrollTargetBehavior(.paging)
    }
}
