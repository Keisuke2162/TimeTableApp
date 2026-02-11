import SwiftUI
import Domain

/// 1日分の列を表示する View。
/// 縦に並ぶスロットセルで構成。
/// 編集モードで onMove による並び替えが可能。
struct DayColumnView: View {
    let date: Date
    let slots: [TimetableSlot]
    let dateString: String
    let subjects: [Subject]
    let displayMode: DisplayMode
    let viewModel: TimetableViewModel
    let onSlotTap: (TimetableSlot) -> Void

    @State private var isEditMode = false

    private var isGridStyle: Bool { displayMode == .week }
    private var slotSpacing: CGFloat { isGridStyle ? 0 : 8 }

    var body: some View {
        VStack(spacing: isGridStyle ? 0 : 4) {
            // Slots
            if isEditMode {
                editableSlotList
            } else {
                staticSlotList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .contextMenu {
            Button(isEditMode ? "完了" : "並び替え") {
                isEditMode.toggle()
            }
        }
    }

    private var staticSlotList: some View {
        VStack(spacing: slotSpacing) {
            ForEach(slots.sorted(by: { $0.displayOrder < $1.displayOrder })) { slot in
                SlotCellView(
                    slot: slot,
                    subject: subjects.first { $0.id == slot.subjectId },
                    isGridStyle: isGridStyle
                )
                .onTapGesture { onSlotTap(slot) }
            }
        }
        .frame(maxHeight: .infinity)
    }

    private var editableSlotList: some View {
        VStack(spacing: slotSpacing) {
            ForEach(slots.sorted(by: { $0.displayOrder < $1.displayOrder })) { slot in
                HStack(spacing: 4) {
                    Image(systemName: "line.3.horizontal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    SlotCellView(
                        slot: slot,
                        subject: subjects.first { $0.id == slot.subjectId },
                        isGridStyle: isGridStyle
                    )
                }
                .onTapGesture {
                    onSlotTap(slot)
                }
            }

            Button("完了") {
                isEditMode = false
            }
            .font(.caption2)
            .padding(.top, 4)
        }
        .frame(maxHeight: .infinity)
    }
}
