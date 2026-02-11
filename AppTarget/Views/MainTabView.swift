import SwiftUI
import UseCase

/// メインのタブバー画面。時間割・データ・設定の3タブ構成。
struct MainTabView: View {
    let container: DependencyContainer
    let userId: String
    let onSignOut: () -> Void

    var body: some View {
        TabView {
            TimetableTabView(
                viewModel: TimetableViewModel(
                    timetableUseCase: container.timetableUseCase,
                    subjectUseCase: container.subjectUseCase,
                    settingsUseCase: container.settingsUseCase,
                    userId: userId
                )
            )
            .tabItem {
                Label("時間割", systemImage: "calendar")
            }

            DataTabView(
                viewModel: DataViewModel(
                    timetableUseCase: container.timetableUseCase,
                    subjectUseCase: container.subjectUseCase,
                    settingsUseCase: container.settingsUseCase,
                    userId: userId
                )
            )
            .tabItem {
                Label("データ", systemImage: "chart.bar")
            }

            SettingsTabView(
                viewModel: SettingsViewModel(
                    subjectUseCase: container.subjectUseCase,
                    settingsUseCase: container.settingsUseCase,
                    userId: userId
                ),
                onSignOut: onSignOut
            )
            .tabItem {
                Label("設定", systemImage: "gearshape")
            }
        }
    }
}
