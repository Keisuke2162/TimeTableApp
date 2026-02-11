import SwiftUI

/// データタブ画面。
/// Contribution Graph と科目ごとの累計実績時間を表示する。
struct DataTabView: View {
    @State var viewModel: DataViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Contribution Graph
                    VStack(alignment: .leading, spacing: 8) {
                        Text("学習記録")
                            .font(.headline)

                        ContributionGraphView(data: viewModel.contributionData)
                    }
                    .padding(.horizontal)

                    Divider()
                        .padding(.horizontal)

                    // Subject Stats
                    VStack(alignment: .leading, spacing: 12) {
                        Text("科目別 累計時間")
                            .font(.headline)
                            .padding(.horizontal)

                        if viewModel.subjectStats.isEmpty {
                            Text("まだデータがありません")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                                .padding(.horizontal)
                        } else {
                            ForEach(viewModel.subjectStats) { stat in
                                subjectStatRow(stat)
                                    .padding(.horizontal)
                            }
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
            .navigationTitle("データ")
            .refreshable {
                await viewModel.loadData()
            }
            .task {
                await viewModel.loadData()
            }
            .overlay {
                if viewModel.isLoading && viewModel.contributionData.isEmpty {
                    ProgressView("読み込み中...")
                }
            }
        }
    }

    private func subjectStatRow(_ stat: DataViewModel.SubjectStat) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(AppColors.color(at: stat.colorIndex))
                .frame(width: 12, height: 12)

            Text(stat.name)
                .font(.subheadline)

            Spacer()

            Text(formatTotalMinutes(stat.totalActualMinutes))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func formatTotalMinutes(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 && m > 0 { return "\(h)h \(m)m" }
        if h > 0 { return "\(h)h" }
        return "\(m)m"
    }
}
