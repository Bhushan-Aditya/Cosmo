import SwiftUI
import AuthenticationServices
import CryptoKit
import Security

struct LandingPage: View {
    @Binding var currentPage: AppPage
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showButton = false
    @State private var orbitAngle: Double = 0
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
            .edgesIgnoringSafeArea(.all)
            
            ParticleSystem(particleCount: 100)
                .opacity(0.5)
            
            OrbitingPlanetsView(orbitAngle: orbitAngle)
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 20) {
                    Text("COSMO")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(CosmosColors.text)
                        .opacity(showTitle ? 1 : 0)
                        .blur(radius: showTitle ? 0 : 10)
                        .scaleEffect(showTitle ? 1 : 0.8)
                    
                    Text("Journey Through the Universe")
                        .font(.title)
                        .foregroundColor(CosmosColors.secondaryText)
                        .opacity(showSubtitle ? 1 : 0)
                        .blur(radius: showSubtitle ? 0 : 5)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    SignInWithAppleButton(.signIn, onRequest: configureAppleSignInRequest, onCompletion: handleAppleSignInCompletion)
                        .signInWithAppleButtonStyle(.black)
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
                .opacity(showButton ? 1 : 0)
                .offset(y: showButton ? 0 : 30)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            animateEntrance()
            animateOrbit()
        }
    }
    
    private func animateEntrance() {
        withAnimation(.easeOut(duration: 1.5)) {
            showTitle = true
        }
        withAnimation(.easeOut(duration: 1.5).delay(0.5)) {
            showSubtitle = true
        }
        withAnimation(.easeOut(duration: 1.0).delay(1.0)) {
            showButton = true
        }
    }
    
    private func animateOrbit() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            orbitAngle = 360
        }
    }

    private func configureAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        authErrorMessage = nil
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    private func handleAppleSignInCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .failure(let error):
            authErrorMessage = error.localizedDescription

        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                authErrorMessage = "Invalid Apple ID credentials."
                return
            }

            guard
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8)
            else {
                authErrorMessage = "Unable to read Apple identity token."
                return
            }

            isAuthenticating = true
            let fullName = credential.fullName?.formatted()
            let authorizationCode = credential.authorizationCode
                .flatMap { String(data: $0, encoding: .utf8) }

            Task {
                do {
                    let session = try await SupabaseAuthService.shared.signInWithApple(idToken: idToken, rawNonce: currentNonce)
                    AuthSessionStore.shared.persistSuccessfulLogin(session: session)
                    try? await SupabaseProfileSyncService.shared.upsertCurrentProfile(displayName: fullName)
                    if let authorizationCode, !authorizationCode.isEmpty {
                        await SupabaseAppleAccountService.shared.storeAppleRefreshToken(authorizationCode: authorizationCode)
                    }
                    await PurchaseManager.shared.refreshAndSyncEntitlements()
                    await MainActor.run {
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
}

// MARK: - Orbiting Planets View
struct OrbitingPlanetsView: View {
    let orbitAngle: Double
    
    var body: some View {
        ZStack {
            // Orbit Rings
            ForEach(0..<3) { index in
                Circle()
                    .stroke(CosmosColors.accent.opacity(0.1), lineWidth: 1)
                    .frame(width: CGFloat(200 + index * 100))
            }
            
            // Planet Views
            PlanetView(color: .blue, size: 20)
                .offset(x: 100, y: 0)
                .rotationEffect(.degrees(orbitAngle))
            
            PlanetView(color: .red, size: 15)
                .offset(x: 150, y: 0)
                .rotationEffect(.degrees(-orbitAngle * 0.8))
            
            PlanetView(color: .orange, size: 25)
                .offset(x: 200, y: 0)
                .rotationEffect(.degrees(orbitAngle * 0.6))
        }
    }
}

// MARK: - Planet View
struct PlanetView: View {
    let color: Color
    let size: CGFloat
    @State private var glowOpacity = 0.5
    
    var body: some View {
        ZStack {
            // Glow effect for the planet
            Circle()
                .fill(color)
                .blur(radius: size * 0.3)
                .opacity(glowOpacity)
                .frame(width: size * 1.5, height: size * 1.5)
            
            // Planet body
            Circle()
                .fill(color)
                .frame(width: size, height: size)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                glowOpacity = 0.8
            }
        }
    }
}

// MARK: - Particle System
struct ParticleSystem: View {
    let particleCount: Int
    @State private var positions: [(CGPoint, Double)] = []
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for (position, opacity) in positions {
                    context.opacity = opacity
                    context.fill(
                        Circle().path(in: CGRect(x: position.x, y: position.y, width: 2, height: 2)),
                        with: .color(CosmosColors.starlight)
                    )
                }
            }
            .onAppear {
                positions = (0..<particleCount).map { _ in
                    (
                        CGPoint(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        ),
                        Double.random(in: 0.1...0.5)
                    )
                }
            }
        }
    }
}

// MARK: - Cosmos Button

// MARK: - Colors
struct CosmosColors {
    static let text = Color.white
    static let secondaryText = Color.gray
    static let accent = Color.blue
    static let starlight = Color.white
}

// MARK: - Previews
struct LandingPage_Previews: PreviewProvider {
    static var previews: some View {
        LandingPage(currentPage: .constant(.landing))
    }
}
