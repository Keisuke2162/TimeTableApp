import SwiftUI
import AuthenticationServices

/// ログイン画面。Google / Apple サインインを提供する。
struct LoginView: View {
    @State var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App Icon & Title
            VStack(spacing: 12) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 64))
                    .foregroundStyle(.primary)

                Text("TimeTable")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("余暇を管理する、あなたの時間割")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Sign In Buttons
            VStack(spacing: 16) {
                // Google Sign In
                Button {
                    Task { await viewModel.signInWithGoogle() }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "g.circle.fill")
                            .font(.title2)
                        Text("Google でサインイン")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(.systemBackground))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }

                // TODO: Apple Developer Program 登録後に有効化
                // SignInWithAppleButton(.signIn) { request in
                //     let hashedNonce = viewModel.prepareAppleSignIn()
                //     request.requestedScopes = [.email, .fullName]
                //     request.nonce = hashedNonce
                // } onCompletion: { result in
                //     viewModel.handleAppleSignIn(result: result)
                // }
                // .signInWithAppleButtonStyle(.black)
                // .frame(height: 50)
                // .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)

            if viewModel.isLoading {
                ProgressView()
            }

            Spacer()
                .frame(height: 40)
        }
        .padding()
        .alert("エラー", isPresented: showErrorAlert) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var showErrorAlert: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
}
