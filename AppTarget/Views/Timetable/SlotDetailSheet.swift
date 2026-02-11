import SwiftUI
import Domain

/// スロットの詳細・編集シート。
/// 科目選択、予定時間・実績時間の設定、完了ステータスの切り替えを行う。
struct SlotDetailSheet: View {
    let slot: TimetableSlot
    let dateString: String
    let subjects: [Subject]
    @State var viewModel: TimetableViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var selectedSubjectId: String?
    @State private var minutes: Int
    @State private var isCompleted: Bool

    init(slot: TimetableSlot, dateString: String, subjects: [Subject], viewModel: TimetableViewModel) {
        self.slot = slot
        self.dateString = dateString
        self.subjects = subjects
        self._viewModel = State(initialValue: viewModel)
        self._selectedSubjectId = State(initialValue: slot.subjectId)
        self._minutes = State(initialValue: slot.minutes)
        self._isCompleted = State(initialValue: slot.isCompleted)
    }

    var body: some View {
        NavigationStack {
            Form {
                completionSection
                subjectSection
                timeSection

                if slot.subjectId != nil {
                    Section {
                        Button(role: .destructive) {
                            clearSlot()
                        } label: {
                            HStack {
                                Spacer()
                                Text("この時間割を削除")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(selectedSubjectName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - Sections

    private var subjectSection: some View {
        Section("科目") {
            if subjects.isEmpty {
                Text("設定画面で科目を追加してください")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                ForEach(subjects) { subject in
                    subjectRow(subject)
                }
            }
        }
    }

    private func subjectRow(_ subject: Subject) -> some View {
        Button {
            selectedSubjectId = selectedSubjectId == subject.id ? nil : subject.id
        } label: {
            HStack {
                Circle()
                    .fill(AppColors.color(at: subject.colorIndex))
                    .frame(width: 12, height: 12)

                Text(subject.name)
                    .foregroundStyle(.primary)

                Spacer()

                if selectedSubjectId == subject.id {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }

    private var timeSection: some View {
        Section("時間設定") {
            Stepper("時間: \(formatMinutes(minutes))", value: $minutes, in: 0...480, step: 15)
        }
    }

    private var completionSection: some View {
        Section {
            Button {
                isCompleted.toggle()
            } label: {
                HStack {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isCompleted ? .green : .secondary)
                    Text(isCompleted ? "完了済み" : "未完了")
                        .foregroundStyle(.primary)
                }
            }
        }
    }

    // MARK: - Helpers

    private var selectedSubjectName: String {
        if let id = selectedSubjectId,
           let subject = subjects.first(where: { $0.id == id }) {
            return subject.name
        }
        return "スロット編集"
    }

    private func formatMinutes(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 && m > 0 { return "\(h)時間\(m)分" }
        if h > 0 { return "\(h)時間" }
        return "\(m)分"
    }

    private func save() {
        Task {
            await viewModel.updateSlot(
                slotId: slot.id,
                dateString: dateString,
                subjectId: selectedSubjectId,
                minutes: minutes,
                isCompleted: isCompleted
            )
            dismiss()
        }
    }

    private func clearSlot() {
        Task {
            await viewModel.updateSlot(
                slotId: slot.id,
                dateString: dateString,
                subjectId: nil,
                minutes: 0,
                isCompleted: false
            )
            dismiss()
        }
    }
}
