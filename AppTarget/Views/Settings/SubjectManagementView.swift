import SwiftUI
import Domain

/// 科目一覧管理 View。
/// 科目の追加・編集・削除を行う。
struct SubjectManagementView: View {
    @State var viewModel: SettingsViewModel
    @State private var showingAddSubject = false

    var body: some View {
        List {
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
                            .frame(width: 16, height: 16)

                        Text(subject.name)
                            .font(.body)
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let subject = viewModel.subjects[index]
                    Task { await viewModel.deleteSubject(subject) }
                }
            }
        }
        .navigationTitle("科目管理")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSubject = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSubject) {
            SubjectEditView(
                subject: nil,
                onSave: { newSubject in
                    Task { await viewModel.saveSubject(newSubject) }
                }
            )
        }
    }
}
