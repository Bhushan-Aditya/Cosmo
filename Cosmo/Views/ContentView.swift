import SwiftUI

// MARK: - Navigation
enum AppPage {
    case landing
    case welcomeGate
    case home
    case explore
    case theories
    case quiz
    case neo
}

// MARK: - Theme
struct CosmosConstants {
    static let padding: CGFloat = 20
    static let cornerRadius: CGFloat = 15
    static let animationDuration: Double = 0.3

    struct Fonts {
        static let title = Font.system(size: 40, weight: .bold)
        static let subtitle = Font.system(size: 24, weight: .semibold)
        static let body = Font.system(size: 16, weight: .regular)
    }
}

// MARK: - Main View
struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var toastManager = ToastManager.shared
    @State private var currentPage: AppPage = AuthSessionStore.shared.hasValidLogin ? .explore : .landing
    @State private var showStars = true

    var body: some View {
        ZStack {
            StarfieldView()
                .opacity(showStars ? 1 : 0)

            switch currentPage {
            case .landing:
                LandingPage(currentPage: $currentPage)
            case .welcomeGate:
                WelcomeGateView(currentPage: $currentPage)
            case .home, .explore, .theories, .quiz, .neo:
                MainTabView(selectedTab: $currentPage, showStars: $showStars)
            }

            ToastOverlayView(manager: toastManager)
                .ignoresSafeArea(edges: .top)
                .zIndex(999)
        }
        .onAppear {
            enforceSessionValidity()
            Task { await SupabaseUploadQueue.shared.drain() }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                enforceSessionValidity()
                Task { await SupabaseUploadQueue.shared.drain() }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .authDidLogout)) { _ in
            withAnimation(.easeInOut(duration: 0.35)) {
                currentPage = .landing
            }
        }
    }

    private func enforceSessionValidity() {
        let hasSession = AuthSessionStore.shared.hasValidLogin
        let isInMainApp = currentPage == .home || currentPage == .explore || currentPage == .theories || currentPage == .quiz || currentPage == .neo

        if !hasSession && isInMainApp {
            withAnimation(.easeInOut(duration: 0.35)) {
                currentPage = .landing
            }
        }
    }
}

// MARK: - Native Liquid Glass Tab Bar
private struct MainTabView: View {
    @Binding var selectedTab: AppPage
    @Binding var showStars: Bool

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ExplorePage()
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tabItem {
                Label("Explore", systemImage: "sparkles")
            }
            .tag(AppPage.explore)
            
            NavigationStack {
                TheoryExplorerView()
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tabItem {
                Label("Theories", systemImage: "atom")
            }
            .tag(AppPage.theories)
            
            NavigationStack {
                QuizHomeView()
            }
            .tabItem {
                Label("Quiz", systemImage: "questionmark.circle.fill")
            }
            .tag(AppPage.quiz)
            
            NavigationStack {
                NeoView()
            }
            .tabItem {
                Label("Game", systemImage: "gamecontroller.fill")
            }
            .tag(AppPage.neo)
        }
        .onAppear {
            setupLiquidGlassTabBar()
            if selectedTab == .landing || selectedTab == .home {
                selectedTab = .explore
            }
        }
    }
    
    private func setupLiquidGlassTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        // Liquid glass effect with blur
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundEffect = blurEffect
        
        // Subtle border on top
        appearance.shadowColor = UIColor.white.withAlphaComponent(0.1)
        appearance.shadowImage = UIImage()
        
        // Selected item appearance
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        // Normal item appearance
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.5)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.5),
            .font: UIFont.systemFont(ofSize: 10, weight: .regular)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Background Animation
struct StarfieldView: View {
    let starCount = 100

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                ForEach(0..<starCount, id: \.self) { _ in
                    StarParticle(size: geometry.size)
                }
            }
        }
    }
}

struct StarParticle: View {
    let size: CGSize
    @State private var position: CGPoint
    @State private var opacity = Double.random(in: 0.2...0.8)

    init(size: CGSize) {
        self.size = size
        self._position = State(initialValue: CGPoint(
            x: .random(in: 0...size.width),
            y: .random(in: 0...size.height)
        ))
    }

    var body: some View {
        Circle()
            .fill(CosmosColors.starlight)
            .frame(width: 2, height: 2)
            .position(position)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    Animation
                        .easeInOut(duration: Double.random(in: 1.0...3.0))
                        .repeatForever(autoreverses: true)
                ) {
                    opacity = Double.random(in: 0.4...1.0)
                }
            }
    }
}

// MARK: - Shared Components
struct CosmosButton: View {
    let text: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.title3.bold())
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            CosmosColors.accent,
                            CosmosColors.starlight
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(CosmosConstants.cornerRadius)
                .shadow(
                    color: CosmosColors.accent.opacity(isHovered ? 0.5 : 0),
                    radius: isHovered ? 10 : 0
                )
                .scaleEffect(isHovered ? 1.02 : 1)
                .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .padding(.horizontal)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct CosmosTitle: View {
    let text: String
    @State private var opacity = 0.0

    var body: some View {
        Text(text)
            .font(CosmosConstants.Fonts.title)
            .foregroundColor(CosmosColors.text)
            .multilineTextAlignment(.center)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 1.0)) {
                    opacity = 1.0
                }
            }
    }
}

struct CosmosSubtitle: View {
    let text: String
    @State private var opacity = 0.0

    var body: some View {
        Text(text)
            .font(CosmosConstants.Fonts.subtitle)
            .foregroundColor(CosmosColors.secondaryText)
            .multilineTextAlignment(.center)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 1.0).delay(0.3)) {
                    opacity = 1.0
                }
            }
    }
}

// MARK: - Preview
#if DEBUG

#endif
