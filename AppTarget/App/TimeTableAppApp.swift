import SwiftUI
import Infra
import GoogleSignIn

@main
struct TimeTableAppApp: App {
    private let container: DependencyContainer

    init() {
        FirebaseConfigurator.configure()
        self.container = DependencyContainer()
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

/// 認証状態に応じてログイン画面またはメイン画面を切り替えるルート View。
struct RootView: View {
    let container: DependencyContainer
    @State private var authViewModel: AuthViewModel

    init(container: DependencyContainer) {
        self.container = container
        self._authViewModel = State(
            initialValue: AuthViewModel(authUseCase: container.authUseCase)
        )
    }

    var body: some View {
        Group {
            if authViewModel.isSignedIn {
                MainTabView(
                    container: container,
                    userId: authViewModel.userId ?? "",
                    onSignOut: {
                        authViewModel.signOut()
                    }
                )
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
        .task {
            await authViewModel.observeAuthState()
        }
    }
}
