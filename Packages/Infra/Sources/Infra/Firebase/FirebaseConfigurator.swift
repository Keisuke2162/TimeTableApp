import FirebaseCore

/// Firebase の初期化を Infra 層で管理するヘルパー。
/// AppTarget から直接 FirebaseCore をインポートする必要をなくす。
public enum FirebaseConfigurator {
    /// Firebase を初期化する。アプリ起動時に一度だけ呼び出す。
    public static func configure() {
        FirebaseApp.configure()
    }
}
