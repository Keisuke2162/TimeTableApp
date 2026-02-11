import SwiftUI
import Domain

/// 科目の追加・編集 View。
/// 科目名とテーマカラー（10色プリセット）を設定する。
struct SubjectEditView: View {
    let subject: Subject?
    let onSave: (Subject) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var selectedColorIndex: Int

    init(subject: Subject?, onSave: @escaping (Subject) -> Void) {
        self.subject = subject
        self.onSave = onSave
        self._name = State(initialValue: subject?.name ?? "")
        self._selectedColorIndex = State(initialValue: subject?.colorIndex ?? 0)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("科目名") {
                    TextField("科目名を入力", text: $name)
                }

                Section("テーマカラー") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(0..<AppColors.presets.count, id: \.self) { index in
                            Button {
                                selectedColorIndex = index
                            } label: {
                                VStack(spacing: 4) {
                                    Circle()
                                        .fill(AppColors.presets[index])
                                        .frame(width: 40, height: 40)
                                        .overlay {
                                            if selectedColorIndex == index {
                                                Circle()
                                                    .stroke(.primary, lineWidth: 2)
                                                    .padding(-3)
                                            }
                                        }

                                    Text(AppColors.presetNames[index])
                                        .font(.system(size: 8))
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                // プレビュー
                Section("プレビュー") {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(AppColors.color(at: selectedColorIndex))
                            .frame(width: 24, height: 24)

                        Text(name.isEmpty ? "科目名" : name)
                            .font(.body)
                            .foregroundStyle(name.isEmpty ? .secondary : .primary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(subject == nil ? "科目を追加" : "科目を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let updated = Subject(
                            id: subject?.id ?? UUID().uuidString,
                            name: name,
                            colorIndex: selectedColorIndex
                        )
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
