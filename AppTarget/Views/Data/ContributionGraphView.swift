import SwiftUI

/// GitHub スタイルの Contribution Graph を描画する SwiftUI View。
/// 過去約20週間のデータを、週を列・曜日を行としてグリッド表示する。
/// マスの色は、その日の完了数に応じて濃淡が変わる。
struct ContributionGraphView: View {
    let data: [DataViewModel.DayData]

    private let cellSize: CGFloat = 13
    private let cellSpacing: CGFloat = 3
    private let rows = 7 // 月〜日

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: cellSpacing) {
                    // 曜日ラベル
                    VStack(spacing: cellSpacing) {
                        ForEach(weekdayLabels, id: \.self) { label in
                            Text(label)
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                                .frame(width: 20, height: cellSize)
                        }
                    }

                    // グリッド（週ごとの列）
                    ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                        VStack(spacing: cellSpacing) {
                            ForEach(week, id: \.dateString) { day in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(AppColors.contributionColor(
                                        completedCount: day.completedCount,
                                        totalSlots: day.totalSlots
                                    ))
                                    .frame(width: cellSize, height: cellSize)
                            }
                            // 足りない曜日を埋める
                            ForEach(0..<(rows - week.count), id: \.self) { _ in
                                Color.clear
                                    .frame(width: cellSize, height: cellSize)
                            }
                        }
                    }
                }
            }

            // 凡例
            HStack(spacing: 4) {
                Spacer()
                Text("少ない")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                ForEach(0..<AppColors.contributionLevels.count, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColors.contributionLevels[i])
                        .frame(width: cellSize, height: cellSize)
                }
                Text("多い")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Computed

    /// データを週ごとにグループ化する。各週は月曜始まり。
    private var weeks: [[DataViewModel.DayData]] {
        guard !data.isEmpty else { return [] }

        var result: [[DataViewModel.DayData]] = []
        var currentWeek: [DataViewModel.DayData] = []
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2

        for day in data {
            guard let date = DateHelper.date(from: day.dateString) else { continue }
            let weekday = calendar.component(.weekday, from: date)
            // 月曜=0, 火曜=1, ..., 日曜=6
            let mondayIndex = (weekday + 5) % 7

            if mondayIndex == 0 && !currentWeek.isEmpty {
                result.append(currentWeek)
                currentWeek = []
            }
            currentWeek.append(day)
        }

        if !currentWeek.isEmpty {
            result.append(currentWeek)
        }

        return result
    }

    private var weekdayLabels: [String] {
        ["月", "火", "水", "木", "金", "土", "日"]
    }
}
