import Infra
import UseCase

/// アプリ全体の依存関係を組み立てる DI コンテナ。
/// Initializer Injection により、各レイヤーのオブジェクトを生成・結合する。
///
/// 依存の流れ:
///   Repository（Infra） → UseCase → ViewModel
@MainActor
final class DependencyContainer {
    // MARK: - Use Cases

    let authUseCase: AuthUseCase
    let timetableUseCase: TimetableUseCase
    let subjectUseCase: SubjectUseCase
    let settingsUseCase: SettingsUseCase

    init() {
        // Repositories
        let authRepository = AuthRepositoryImpl()
        let timetableRepository = TimetableRepositoryImpl()
        let subjectRepository = SubjectRepositoryImpl()
        let settingsRepository = SettingsRepositoryImpl()

        // Use Cases
        self.authUseCase = AuthUseCase(repository: authRepository)
        self.timetableUseCase = TimetableUseCase(repository: timetableRepository)
        self.subjectUseCase = SubjectUseCase(repository: subjectRepository)
        self.settingsUseCase = SettingsUseCase(repository: settingsRepository)
    }
}
