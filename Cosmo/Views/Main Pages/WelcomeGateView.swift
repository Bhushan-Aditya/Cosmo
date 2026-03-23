import SwiftUI
import AuthenticationServices
import CryptoKit
import Security

struct WelcomeGateView: View {
    @Binding var currentPage: AppPage
    @State private var showContent = false
    @State private var isAuthenticating = false
    @State private var authErrorMessage: String?
    @State private var currentNonce: String?

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ParticleSystem(particleCount: 100)
                .opacity(0.5)

            OrbitingPlanetsView(orbitAngle: 180)

            VStack(spacing: 28) {
                Spacer()

                VStack(spacing: 14) {
                    Text("Welcome to Cosmo")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(CosmosColors.text)
                        .multilineTextAlignment(.center)

                    Text("Start your journey")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(CosmosColors.secondaryText)
                }
                .padding(.horizontal, 24)

                Spacer()

                VStack(spacing: 12) {
                    SignInWithAppleButton(.continue, onRequest: configureAppleSignInRequest, onCompletion: handleAppleSignInCompletion)
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 52)
                        .clipShape(Capsule())
                        .overlay {
                            if isAuthenticating {
                                ProgressView()
                                    .tint(.black)
                            }
                        }
                        .disabled(isAuthenticating)
                        .opacity(isAuthenticating ? 0.8 : 1)

                    if let authErrorMessage {
                        Text(authErrorMessage)
                            .font(.footnote)
                            .foregroundColor(.red.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                    }
                }
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
                .padding(.bottom, 60)
            }
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            logAuth("WelcomeGate appeared")
            withAnimation(.easeOut(duration: 0.9)) {
                showContent = true
            }
        }
    }

    private func configureAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        authErrorMessage = nil
        logAuth("Apple sign-in request started. Raw nonce: \(nonce)")
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        logAuth("Apple request configured. SHA256 nonce: \(request.nonce ?? "nil")")
    }

    private func handleAppleSignInCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .failure(let error):
            authErrorMessage = error.localizedDescription
            logAuth("Apple sign-in failed: \(error.localizedDescription)")

        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                authErrorMessage = "Invalid Apple ID credentials."
                logAuth("Apple sign-in returned invalid credential type")
                return
            }

            guard
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8)
            else {
                authErrorMessage = "Unable to read Apple identity token."
                logAuth("Apple credential missing identity token")
                return
            }

            isAuthenticating = true
            logAuth("Apple sign-in success. User ID: \(credential.user)")
            logAuth("Apple email: \(credential.email ?? "nil"), fullName: \(credential.fullName?.formatted() ?? "nil")")
            logAuth("Apple identity token: \(idToken)")

            Task {
                do {
                    let session = try await SupabaseAuthService.shared.signInWithApple(idToken: idToken, rawNonce: currentNonce)
                    await MainActor.run {
                        AuthSessionStore.shared.persistSuccessfulLogin(session: session)
                        logAuth("Supabase auth success. User id: \(session.user.id), email: \(session.user.email ?? "nil")")
                        logAuth("Supabase access token: \(session.accessToken)")
                        logAuth("Supabase refresh token: \(session.refreshToken)")
                        logAuth("Routing to Explore page")
                        isAuthenticating = false
                        currentNonce = nil
                        withAnimation(.easeInOut(duration: 0.45)) {
                            currentPage = .explore
                        }
                    }
                } catch {
                    await MainActor.run {
                        isAuthenticating = false
                        currentNonce = nil
                        authErrorMessage = error.localizedDescription
                        logAuth("Supabase auth failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)

            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with code: \(errorCode)")
            }

            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }

        return result
    }

    private func logAuth(_ message: String) {
#if DEBUG
        print("[AuthFlow] \(message)")
#endif
    }
}

#if DEBUG
struct WelcomeGateView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeGateView(currentPage: .constant(.welcomeGate))
    }
}
#endif

