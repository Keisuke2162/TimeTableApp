import Foundation

/// 日付関連のユーティリティ。
/// アプリ全体で日付文字列（yyyy-MM-dd）と Date の相互変換、週の計算に使用する。
enum DateHelper {
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        return f
    }()

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M/d"
        f.locale = Locale(identifier: "ja_JP")
        return f
    }()

    private static let dayOfWeekFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "E"
        f.locale = Locale(identifier: "ja_JP")
        return f
    }()

    private static let monthYearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月"
        f.locale = Locale(identifier: "ja_JP")
        return f
    }()

    /// Date を "yyyy-MM-dd" 文字列に変換する。
    static func string(from date: Date) -> String {
        formatter.string(from: date)
    }

    /// "yyyy-MM-dd" 文字列を Date に変換する。
    static func date(from string: String) -> Date? {
        formatter.date(from: string)
    }

    /// 日付の表示用文字列 "M/d" を返す。
    static func displayString(from date: Date) -> String {
        displayFormatter.string(from: date)
    }

    /// 曜日の短縮名（月、火、…）を返す。
    static func dayOfWeek(from date: Date) -> String {
        dayOfWeekFormatter.string(from: date)
    }

    /// 年月の表示用文字列 "yyyy年M月" を返す。
    static func monthYearString(from date: Date) -> String {
        monthYearFormatter.string(from: date)
    }

    /// 指定日を含む週（月〜日）の日付配列を返す。
    static func weekDates(containing date: Date) -> [Date] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // 月曜始まり
        let weekday = calendar.component(.weekday, from: date)
        // weekday: 1=日, 2=月, ..., 7=土
        // 月曜日からのオフセットを計算
        let mondayOffset = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -mondayOffset, to: date) else {
            return []
        }
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: monday)
        }
    }

    /// 指定日を含む週の日付文字列配列を返す。
    static func weekDateStrings(containing date: Date) -> [String] {
        weekDates(containing: date).map { string(from: $0) }
    }

    /// 指定日を起点に n 日分の日付配列を返す。
    static func dates(from baseDate: Date, count: Int) -> [Date] {
        let calendar = Calendar.current
        return (0..<count).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: baseDate)
        }
    }

    /// 指定日を起点に n 日分の日付文字列配列を返す。
    static func dateStrings(from baseDate: Date, count: Int) -> [String] {
        dates(from: baseDate, count: count).map { string(from: $0) }
    }

    /// 指定日数前から今日までの日付文字列配列を返す（Contribution Graph 用）。
    static func dateStrings(lastDays count: Int, from baseDate: Date = Date()) -> [String] {
        let calendar = Calendar.current
        return (0..<count).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: baseDate) else { return nil }
            return string(from: date)
        }
    }

    /// 今日の日付文字列を返す。
    static var todayString: String {
        string(from: Date())
    }
}
