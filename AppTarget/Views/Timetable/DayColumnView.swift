import SwiftUI
import Domain

/// 1日分の列を表示する View。
/// ヘッダー（曜日・日付）と縦に並ぶスロットセルで構成。
/// 編集モードで onMove による並び替えが可能。
struct DayColumnView: View {
    let date: Date
    let slots: [TimetableSlot]
    let dateString: String
    let isToday: Bool
    let subjects: [Subject]
    let viewModel: TimetableViewModel
    let onSlotTap: (TimetableSlot) -> Void

    @State private var isEditMode = false

    var body: some View {
        VStack(spacing: 4) {
            // Header
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
            .padding(.bottom, 4)

            // Slots
            if isEditMode {
                editableSlotList
            } else {
                staticSlotList
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .contextMenu {
            Button(isEditMode ? "完了" : "並び替え") {
                isEditMode.toggle()
            }
        }
    }

    private var staticSlotList: some View {
        VStack(spacing: 4) {
            ForEach(slots.sorted(by: { $0.displayOrder < $1.displayOrder })) { slot in
                SlotCellView(
                    slot: slot,
                    subject: subjects.first { $0.id == slot.subjectId }
                )
                .onTapGesture {
                    onSlotTap(slot)
                }
            }
        }
    }

    private var editableSlotList: some View {
        VStack(spacing: 4) {
            ForEach(slots.sorted(by: { $0.displayOrder < $1.displayOrder })) { slot in
                HStack(spacing: 4) {
                    Image(systemName: "line.3.horizontal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    SlotCellView(
                        slot: slot,
                        subject: subjects.first { $0.id == slot.subjectId }
                    )
                }
                .onTapGesture {
                    onSlotTap(slot)
                }
                .onLongPressGesture {
                    // 長押しでも並び替えモードを維持
                }
            }

            Button("完了") {
                isEditMode = false
            }
            .font(.caption2)
            .padding(.top, 4)
        }
    }
}
