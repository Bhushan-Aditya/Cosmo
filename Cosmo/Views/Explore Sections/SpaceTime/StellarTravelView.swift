import SwiftUI

// MARK: - Main View
struct StellarTravelView: View {
    @State private var selectedSection = 0
    @State private var isAnimating = false
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    @State private var zoomLevel: Double = 1.0

    let sections = ["Overview", "Technology", "Navigation", "Challenges"]

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Hero Section
                heroSection

                // Section Selector
                sectionSelector

                // Content Section
                contentSection

                Spacer(minLength: 50)
            }
        }
        .background(
            EnhancedCosmicBackground(
                parallaxOffset: parallaxOffset,
                starfieldRotation: starfieldRotation,
                zoomLevel: zoomLevel
            )
        )
        .onAppear(perform: startAnimations)
        .gesture(createParallaxGesture())
    }

    private var heroSection: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 200, height: 200)
                .blur(radius: 20)

            VStack(spacing: 15) {
                Text("🚀")
                    .font(.system(size: 60))
                    .scaleEffect(isAnimating ? 1.1 : 1.0)

                Text("Stellar Travel")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Exploring Interstellar Space")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 20)
    }

    private var sectionSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(0..<sections.count, id: \.self) { index in
                    Button(action: {
                        withAnimation {
                            selectedSection = index
                        }
                    }) {
                        Text(sections[index])
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedSection == index ?
                                          Color.blue.opacity(0.3) :
                                            Color.black.opacity(0.3))
                            )
                            .foregroundColor(selectedSection == index ?
                                                 .white : .gray)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 25) {
            switch selectedSection {
            case 0:
                overviewSection
            case 1:
                technologySection
            case 2:
                navigationSection
            case 3:
                challengesSection
            default:
                EmptyView()
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut, value: selectedSection)
    }

    private func startAnimations() {
        withAnimation(Animation.easeInOut(duration: 2.0).repeatForever()) {
            isAnimating = true
        }
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            starfieldRotation = 360
        }
    }

    private func createParallaxGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                parallaxOffset = value.translation.width
            }
            .onEnded { _ in
                withAnimation(.spring()) {
                    parallaxOffset = 0
                }
            }
    }
}

// MARK: - Content Sections
extension StellarTravelView {
    var overviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Stellar Travel Overview")

            InfoCard(
                icon: "🌠",
                title: "Definition",
                content: "Interstellar travel involves journeying between star systems in our galaxy"
            )

            InfoCard(
                icon: "📏",
                title: "Distances",
                content: "The nearest star system, Alpha Centauri, is about 4.37 light-years away from Earth"
            )

            InfoCard(
                icon: "🎯",
                title: "Mission Types",
                content: "Includes robotic exploration, generational ships, and potential colony missions"
            )
        }
    }

    var technologySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Key Technologies")

            InfoCard(
                icon: "⚡",
                title: "Propulsion",
                content: "Advanced propulsion systems including ion engines, nuclear propulsion, and solar sails"
            )

            InfoCard(
                icon: "🛡️",
                title: "Shielding",
                content: "Protection against cosmic radiation and interstellar debris"
            )

            InfoCard(
                icon: "🏗️",
                title: "Ship Design",
                content: "Self-sustaining spacecraft with redundant systems and long-term life support"
            )

            InfoCard(
                icon: "💫",
                title: "FTL Concepts",
                content: "Theoretical faster-than-light travel methods including warp drives and wormholes"
            )
        }
    }

    var navigationSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Navigation Systems")

            InfoCard(
                icon: "🧭",
                title: "Stellar Mapping",
                content: "3D mapping of star systems and celestial objects for route planning"
            )

            InfoCard(
                icon: "📡",
                title: "Communication",
                content: "Long-range communication systems using quantum entanglement and laser arrays"
            )

            InfoCard(
                icon: "🤖",
                title: "AI Navigation",
                content: "Advanced AI systems for real-time course corrections and obstacle avoidance"
            )

            InfoCard(
                icon: "📊",
                title: "Data Processing",
                content: "Quantum computers for processing vast amounts of navigational data"
            )
        }
    }

    var challengesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Current Challenges")

            InfoCard(
                icon: "⏳",
                title: "Time Dilation",
                content: "Relativistic effects at high speeds affecting mission duration and communication"
            )

            InfoCard(
                icon: "🛠️",
                title: "Technical Limits",
                content: "Current propulsion technology limitations and energy requirements"
            )

            InfoCard(
                icon: "🤯",
                title: "Human Factors",
                content: "Psychological and physiological challenges of long-term space travel"
            )

            InfoCard(
                icon: "💾",
                title: "Resource Management",
                content: "Maintaining supplies and equipment for extended missions"
            )
        }
    }
}

// MARK: - Preview
struct StellarTravelView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StellarTravelView()
        }
        .preferredColorScheme(.dark)
    }
}
