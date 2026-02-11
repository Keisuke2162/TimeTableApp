import SwiftUI
import Domain

/// 時間割の1マスを表示するセル View。
/// 科目設定の有無・完了状態に応じて表示が変わる。
struct SlotCellView: View {
    let slot: TimetableSlot
    let subject: Subject?
    var isGridStyle: Bool = false

    private var textColor: Color {
        slot.isCompleted && subject != nil ? .white : .primary
    }

    private var subTextColor: Color {
        slot.isCompleted && subject != nil ? .white.opacity(0.8) : .secondary
    }

    var body: some View {
        ZStack {
            if let subject {
                VStack(spacing: 2) {
                    Text(subject.name)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(textColor)
                        .lineLimit(1)

                    if slot.minutes > 0 {
                        Text(minutesText(slot.minutes))
                            .font(.system(size: 9))
                            .foregroundStyle(subTextColor)
                    }
                }
                .padding(.horizontal, 2)

                if slot.isCompleted {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(6)
                        }
                        Spacer()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: isGridStyle ? 0 : 8))
        .overlay(
            RoundedRectangle(cornerRadius: isGridStyle ? 0 : 8)
                .stroke(borderColor, lineWidth: 0.5)
        )
    }

    // MARK: - Helpers

    private var backgroundColor: Color {
        if let subject {
            if slot.isCompleted {
                return AppColors.color(at: subject.colorIndex)
            } else {
                return AppColors.color(at: subject.colorIndex).opacity(0.4)
            }
        }
        return Color(.systemGray6)
    }

    private var borderColor: Color {
        if let subject {
            return AppColors.color(at: subject.colorIndex).opacity(0.3)
        }
        return Color(.systemGray4)
    }

    private func minutesText(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return mins > 0 ? "\(hours)h\(mins)m" : "\(hours)h"
        }
        return "\(minutes)m"
    }
}
