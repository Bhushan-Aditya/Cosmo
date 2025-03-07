import SwiftUI

// MARK: - Navigation
enum AppPage {
    case landing
    case home
    case explore
    case theories
    case quiz
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
            
            NavigationStack {
                Group {
                    switch currentPage {
                    case .landing:
                        LandingPage(currentPage: $currentPage)
                    case .home:
                        HomePage(currentPage: $currentPage)
                    case .explore:
                        ExplorePage()
                    case .theories:
                        TheoryExplorerView()
                    case .quiz:
                        WelcomeView()
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(currentPage == .landing)
                .toolbar {
                    if currentPage != .landing {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage = .home
                                }
                            }) {
                                Image(systemName: "house.fill")
                                    .foregroundColor(.white)
                                    .font(.title3)
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                withAnimation {
                                    showStars.toggle()
                                }
                            }) {
                                Image(systemName: showStars ? "star.fill" : "star")
                                    .foregroundColor(CosmosColors.starlight)
                                    .font(.title3)
                            }
                        }
                    }
                }
            }
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
