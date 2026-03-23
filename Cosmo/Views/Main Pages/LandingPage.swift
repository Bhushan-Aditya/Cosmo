import SwiftUI

struct LandingPage: View {
    @Binding var currentPage: AppPage
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showButton = false
    @State private var orbitAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Background Color or Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all) // Ensure the background covers the entire screen
            
            // Particle System for starry background effect
            ParticleSystem(particleCount: 100)
                .opacity(0.5)
            
            // The main orbiting planets animation
            OrbitingPlanetsView(orbitAngle: orbitAngle)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title Group
                VStack(spacing: 20) {
                    Text("COSMOS")
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
                
                // Start Button and Subtitle
                VStack(spacing: 20) {
                    CosmosButton(text: "Continue") {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentPage = .welcomeGate
                        }
                    }
                    .opacity(showButton ? 1 : 0)
                    .offset(y: showButton ? 0 : 50)
                    
                    Text("Tap to explore")
                        .font(.subheadline)
                        .foregroundColor(CosmosColors.secondaryText)
                        .opacity(showButton ? 0.7 : 0)
                }
                .padding(.bottom, 50)
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
