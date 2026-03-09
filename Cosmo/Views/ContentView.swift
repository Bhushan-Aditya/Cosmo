import SwiftUI

// MARK: - Navigation
enum AppPage {
    case landing
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
    @State private var currentPage: AppPage = .landing
    @State private var showStars = true

    var body: some View {
        ZStack {
            StarfieldView()
                .opacity(showStars ? 1 : 0)

            switch currentPage {
            case .landing:
                LandingPage(currentPage: $currentPage)
            case .home, .explore, .theories, .quiz, .neo:
                MainTabView(selectedTab: $currentPage, showStars: $showStars)
            }
        }
    }
}

// MARK: - Liquid Glass Tab Bar
private struct MainTabView: View {
    @Binding var selectedTab: AppPage
    @Binding var showStars: Bool

    init(selectedTab: Binding<AppPage>, showStars: Binding<Bool>) {
        self._selectedTab = selectedTab
        self._showStars = showStars

        // Make system tab bar invisible — we use our own
        let invisible = UITabBarAppearance()
        invisible.configureWithTransparentBackground()
        invisible.backgroundColor = .clear
        invisible.shadowColor = .clear
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().standardAppearance = invisible
        UITabBar.appearance().scrollEdgeAppearance = invisible
    }

    private let tabs: [(page: AppPage, label: String, icon: String)] = [
        (.explore,   "Explore",   "sparkles"),
        (.theories,  "Theories",  "atom"),
        (.quiz,      "Quiz",      "questionmark.circle.fill"),
        (.neo,       "Neo",       "cube.transparent"),
    ]

    var body: some View {
        GeometryReader { proxy in
            let bottomInset = proxy.safeAreaInsets.bottom

            ZStack(alignment: .bottom) {
                // Page content
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        ExplorePage()
                            .toolbar(.hidden, for: .navigationBar)
                    }
                    .tag(AppPage.explore)
                    .tabItem { Label("Explore", systemImage: "sparkles") }

                    NavigationStack {
                        TheoryExplorerView()
                            .toolbar(.hidden, for: .navigationBar)
                    }
                    .tag(AppPage.theories)
                    .tabItem { Label("Theories", systemImage: "atom") }

                    NavigationStack {
                        QuizHomeView()
                    }
                    .tag(AppPage.quiz)
                    .tabItem { Label("Quiz", systemImage: "questionmark.circle.fill") }

                    NavigationStack {
                        NeoView()
                    }
                    .tag(AppPage.neo)
                    .tabItem { Label("Neo", systemImage: "cube.transparent") }
                }
                .tint(.white)
                .toolbarBackground(.hidden, for: .tabBar)
                .toolbarColorScheme(.dark, for: .tabBar)

                // Custom liquid glass capsule tab bar
                liquidTabBar(bottomInset: bottomInset)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            if selectedTab == .landing || selectedTab == .home {
                selectedTab = .explore
            }
        }
    }

    @ViewBuilder
    private func liquidTabBar(bottomInset: CGFloat) -> some View {
        let tabBarHeight: CGFloat = 62
        let bottomPad: CGFloat = max(10, bottomInset * 0.5)

        ZStack {
            // Blur + glass capsule background
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.28),
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.45), radius: 20, x: 0, y: 8)
                .shadow(color: Color.white.opacity(0.05), radius: 2, x: 0, y: -1)

            // Tab buttons
            HStack(spacing: 0) {
                ForEach(tabs, id: \.page) { tab in
                    tabButton(tab: tab)
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: tabBarHeight)
        .padding(.horizontal, 20)
        .padding(.bottom, bottomPad)
    }

    @ViewBuilder
    private func tabButton(tab: (page: AppPage, label: String, icon: String)) -> some View {
        let isSelected = selectedTab == tab.page

        Button {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                selectedTab = tab.page
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 40, height: 28)
                            .transition(.scale.combined(with: .opacity))
                    }
                    Image(systemName: tab.icon)
                        .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.45))
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isSelected)
                }

                Text(tab.label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.45))
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
