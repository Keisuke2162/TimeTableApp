import SwiftUI
import Domain

/// 設定タブ画面。
/// 科目管理とスロット数の設定を提供する。
struct SettingsTabView: View {
    @State var viewModel: SettingsViewModel
    let onSignOut: () -> Void

    @State private var showingAddSubject = false

    var body: some View {
        NavigationStack {
            Form {
                // 科目管理
                Section("科目管理") {
                    ForEach(viewModel.subjects) { subject in
                        NavigationLink {
                            SubjectEditView(
                                subject: subject,
                                onSave: { updated in
                                    Task { await viewModel.saveSubject(updated) }
                                }
                            )
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(AppColors.color(at: subject.colorIndex))
                                    .frame(width: 12, height: 12)

                                Text(subject.name)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let subject = viewModel.subjects[index]
                            Task { await viewModel.deleteSubject(subject) }
                        }
                    }

                    Button {
                        showingAddSubject = true
                    } label: {
                        Label("科目を追加", systemImage: "plus")
                    }
                }

                // スロット数設定
                Section("1日のマス数") {
                    Stepper("\(viewModel.slotsPerDay) マス", value: $viewModel.slotsPerDay, in: 2...6)
                        .onChange(of: viewModel.slotsPerDay) {
                            Task { await viewModel.saveSlotsPerDay() }
                        }

                    Text("2〜6マスの範囲で設定できます")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // サインアウト
                Section {
                    Button(role: .destructive) {
                        onSignOut()
                    } label: {
                        HStack {
                            Spacer()
                            Text("サインアウト")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("設定")
            .sheet(isPresented: $showingAddSubject) {
                SubjectEditView(
                    subject: nil,
                    onSave: { newSubject in
                        Task { await viewModel.saveSubject(newSubject) }
                    }
                )
            }
            .task {
                await viewModel.loadSettings()
            }
        }
    }
}
