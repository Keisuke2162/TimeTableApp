import SwiftUI

/// アプリ全体で使用するカラーパレット。
/// 大人が使いやすいモダンで落ち着いたトーンを10色定義する。
/// 科目のテーマカラーとして使用する。
enum AppColors {
    /// 10色のプリセットカラー定義。
    static let presets: [Color] = [
        Color(red: 0.42, green: 0.50, blue: 0.64),  // Slate Blue
        Color(red: 0.56, green: 0.68, blue: 0.55),  // Sage Green
        Color(red: 0.77, green: 0.57, blue: 0.56),  // Dusty Rose
        Color(red: 0.78, green: 0.72, blue: 0.60),  // Warm Sand
        Color(red: 0.61, green: 0.56, blue: 0.77),  // Soft Lavender
        Color(red: 0.42, green: 0.64, blue: 0.63),  // Ocean Teal
        Color(red: 0.77, green: 0.51, blue: 0.42),  // Terracotta
        Color(red: 0.72, green: 0.64, blue: 0.30),  // Muted Gold
        Color(red: 0.55, green: 0.56, blue: 0.60),  // Steel Gray
        Color(red: 0.48, green: 0.50, blue: 0.77),  // Soft Indigo
    ]

    /// プリセットカラー名（設定画面の表示用）。
    static let presetNames: [String] = [
        "スレートブルー",
        "セージグリーン",
        "ダスティローズ",
        "ウォームサンド",
        "ソフトラベンダー",
        "オーシャンティール",
        "テラコッタ",
        "ミューテッドゴールド",
        "スチールグレー",
        "ソフトインディゴ",
    ]

    /// Contribution Graph 用の段階的な緑色。
    static let contributionLevels: [Color] = [
        Color(.systemGray5),                          // 0: なし
        Color(red: 0.56, green: 0.68, blue: 0.55).opacity(0.3),  // 1: 薄い
        Color(red: 0.56, green: 0.68, blue: 0.55).opacity(0.55), // 2: やや薄い
        Color(red: 0.56, green: 0.68, blue: 0.55).opacity(0.8),  // 3: やや濃い
        Color(red: 0.56, green: 0.68, blue: 0.55),               // 4: 濃い
    ]

    /// インデックスに対応するプリセットカラーを返す。範囲外なら最初の色を返す。
    static func color(at index: Int) -> Color {
        guard presets.indices.contains(index) else { return presets[0] }
        return presets[index]
    }

    /// 完了数に応じた Contribution カラーを返す。
    static func contributionColor(completedCount: Int, totalSlots: Int) -> Color {
        guard totalSlots > 0 else { return contributionLevels[0] }
        let ratio = Double(completedCount) / Double(totalSlots)
        switch ratio {
        case 0:
            return contributionLevels[0]
        case 0..<0.25:
            return contributionLevels[1]
        case 0.25..<0.5:
            return contributionLevels[2]
        case 0.5..<0.75:
            return contributionLevels[3]
        default:
            return contributionLevels[4]
        }
    }
}
