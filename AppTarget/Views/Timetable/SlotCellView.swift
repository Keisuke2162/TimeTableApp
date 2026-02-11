import SwiftUI
import Domain

/// 時間割の1マスを表示するセル View。
/// 科目設定の有無・完了状態に応じて表示が変わる。
struct SlotCellView: View {
    let slot: TimetableSlot
    let subject: Subject?

    var body: some View {
        VStack(spacing: 2) {
            if slot.isCompleted, let subject {
                // 完了済み：テーマカラーで塗りつぶし
                completedView(subject: subject)
            } else if let subject {
                // 科目設定あり：科目名と予定時間を表示
                assignedView(subject: subject)
            } else {
                // 科目設定なし：「未設定」と表示
                unassignedView
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: 0.5)
        )
    }

    // MARK: - Subviews

    private func completedView(subject: Subject) -> some View {
        VStack(spacing: 2) {
            Text(subject.name)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .lineLimit(1)

            Image(systemName: "checkmark")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))

            Text(minutesText(slot.actualMinutes))
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 2)
    }

    private func assignedView(subject: Subject) -> some View {
        VStack(spacing: 2) {
            Text(subject.name)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text(minutesText(slot.plannedMinutes))
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 2)
    }

    private var unassignedView: some View {
        Text("未設定")
            .font(.caption2)
            .foregroundStyle(.tertiary)
    }

    // MARK: - Helpers

    private var backgroundColor: Color {
        if slot.isCompleted, let subject {
            return AppColors.color(at: subject.colorIndex)
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
