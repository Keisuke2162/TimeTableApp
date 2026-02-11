import SwiftUI
import Domain

/// 時間割タブのメイン画面。
/// 週単位で横スクロール（ページング）し、縦に各日のスロットを表示する。
struct TimetableTabView: View {
    @State var viewModel: TimetableViewModel
    @State private var selectedSlot: TimetableSlot?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                weekContentView
            }
            .navigationTitle("時間割")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.toggleDisplayMode()
                    } label: {
                        Image(systemName: displayModeIcon)
                    }
                }
            }
            .sheet(item: $selectedSlot) { slot in
                SlotDetailSheet(
                    slot: slot,
                    dateString: slot.dateString,
                    subjects: viewModel.subjects,
                    viewModel: viewModel
                )
            }
            .task {
                await viewModel.loadInitialData()
            }
            .alert("エラー", isPresented: showErrorAlert) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var showErrorAlert: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    private var displayModeIcon: String {
        switch viewModel.displayMode {
        case .oneDay: return "1.square"
        case .threeDays: return "3.square"
        case .week: return "7.square"
        }
    }

    // MARK: - Content

    private var weekContentView: some View {
        WeekPageView(
            timetables: viewModel.weekTimetables,
            dates: viewModel.currentDates,
            subjects: viewModel.subjects,
            viewModel: viewModel,
            onSlotTap: { slot, _ in
                selectedSlot = slot
            }
        )
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    let horizontal = abs(value.translation.width)
                    let vertical = abs(value.translation.height)
                    guard horizontal > vertical else { return }

                    if value.translation.width < 0 {
                        Task { await viewModel.goToNext() }
                    } else {
                        Task { await viewModel.goToPrevious() }
                    }
                }
        )
    }
}
