/// 時間割データへのアクセスを抽象化するリポジトリプロトコル。
/// Firestore の具象実装は Infra 層で提供する。
public protocol TimetableRepository: Sendable {
    /// 指定日の時間割を取得する。データがなければ nil を返す。
    func fetchDailyTimetable(userId: String, dateString: String) async throws -> DailyTimetable?

    /// 指定日の時間割を保存する。
    func saveDailyTimetable(userId: String, timetable: DailyTimetable) async throws

    /// 指定期間の時間割を一括取得する。
    func fetchTimetables(userId: String, dateStrings: [String]) async throws -> [DailyTimetable]
}
