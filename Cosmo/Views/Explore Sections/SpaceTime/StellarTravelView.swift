import SwiftUI

struct StellarTravelView: View {
    private let themeColor = Color(red: 0.38, green: 0.78, blue: 1.0)
    @State private var selectedTab = 0
    @State private var starfieldRotation: Double = 0

    let tabs = ["Overview", "Propulsion", "Navigation", "Challenges"]

    var body: some View {
        ZStack {
            EnhancedCosmicBackground(
                parallaxOffset: 0,
                starfieldRotation: starfieldRotation,
                zoomLevel: 1.0
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 10) {
                            Image(systemName: "star.leadinghalf.filled")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, themeColor.opacity(0.85)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("Stellar Travel")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text("Humanity's greatest frontier — journeys between stars")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.55))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 14)

                    // Hero
                    ConceptHeroView(
                        emoji: "🚀",
                        title: "Interstellar Flight",
                        subtitle: "The nearest star is 4.24 light-years away. At the best current rocket speeds, it would take 70,000 years to reach. Here's how we might do it faster.",
                        color: themeColor
                    )
                    .padding(.horizontal, 16)

                    ConceptTabBar(tabs: tabs, selected: $selectedTab, color: themeColor)

                    VStack(alignment: .leading, spacing: 10) {
                        switch selectedTab {
                        case 0: overviewCards
                        case 1: propulsionCards
                        case 2: navigationCards
                        case 3: challengeCards
                        default: EmptyView()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 36)
                    .animation(.easeInOut(duration: 0.25), value: selectedTab)
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                starfieldRotation = 360
            }
        }
        .preferredColorScheme(.dark)
    }

    private var overviewCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "The Scale of the Challenge", color: themeColor)
            InfoCard(icon: "📏", title: "Nearest Star",
                content: "Proxima Centauri is 4.24 light-years (40 trillion km) away. At Voyager's speed (61,000 km/h), it would take ~73,000 years.",
                accentColor: themeColor)
            InfoCard(icon: "🌠", title: "The Light-Year Barrier",
                content: "Even at 10% light speed — thousands of times faster than any spacecraft today — the journey would take 42 years one-way.",
                accentColor: themeColor)
            InfoCard(icon: "🎯", title: "Mission Categories",
                content: "Interstellar missions range from tiny laser-propelled probes (Breakthrough Starshot) to generation ships carrying thousands of colonists.",
                accentColor: themeColor)
            InfoCard(icon: "🌍", title: "Why Go?",
                content: "Backup civilisation, scientific discovery, resource access, and the fundamental human drive to explore — all argue for eventual interstellar travel.",
                accentColor: themeColor)
        }
    }

    private var propulsionCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Propulsion Concepts", color: themeColor)
            InfoCard(icon: "🔆", title: "Solar / Laser Sails",
                content: "Tiny reflective sails pushed by laser arrays could accelerate gram-scale probes to 20% light speed. Breakthrough Starshot targets Alpha Centauri in 20 years.",
                accentColor: themeColor)
            InfoCard(icon: "⚛️", title: "Nuclear Pulse Drive",
                content: "Project Orion (1950s-60s) proposed detonating nuclear bombs behind a spacecraft. Could reach 3–5% light speed — enough for a 100-year mission.",
                accentColor: themeColor)
            InfoCard(icon: "🌀", title: "Antimatter Engine",
                content: "Matter-antimatter annihilation releases 100× more energy per gram than fusion. A perfect antimatter drive could reach 50%+ light speed — if we could make enough.",
                accentColor: themeColor)
            InfoCard(icon: "💫", title: "Alcubierre Warp Drive",
                content: "A theoretical bubble of contracted space ahead and expanded space behind could allow FTL travel without local acceleration — but requires exotic negative-energy matter.",
                accentColor: themeColor)
        }
    }

    private var navigationCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Navigation Across Light-Years", color: themeColor)
            InfoCard(icon: "🧭", title: "Pulsar Navigation",
                content: "Millisecond pulsars act as cosmic lighthouses. Their unique timing signatures allow a spacecraft to determine its position anywhere in the galaxy.",
                accentColor: themeColor)
            InfoCard(icon: "📡", title: "Laser Communication",
                content: "Tightly focused laser beams can transmit data over interstellar distances, though even at light speed, reply times would be measured in decades.",
                accentColor: themeColor)
            InfoCard(icon: "🤖", title: "Autonomous AI",
                content: "No human crew could remain alert for decades. Advanced AI must handle all navigation decisions, emergencies, and course corrections in real time.",
                accentColor: themeColor)
            InfoCard(icon: "🗺️", title: "Stellar Cartography",
                content: "ESA's Gaia mission has mapped 1.8 billion stars in 3D — providing unprecedented navigation charts for any future interstellar mission.",
                accentColor: themeColor)
        }
    }

    private var challengeCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "The Hard Problems", color: themeColor)
            InfoCard(icon: "☢️", title: "Cosmic Radiation",
                content: "Interstellar space is saturated with galactic cosmic rays — high-energy particles that penetrate spacecraft walls and damage DNA over decades of exposure.",
                accentColor: themeColor)
            InfoCard(icon: "🪨", title: "Interstellar Debris",
                content: "At 20% light speed, a grain of sand carries the energy of a hand grenade. Even sparse interstellar dust becomes a lethal threat without active shielding.",
                accentColor: themeColor)
            InfoCard(icon: "🧬", title: "Human Biology",
                content: "Long-duration weightlessness, radiation, isolation, and confinement cause serious physiological and psychological damage — all still unsolved problems.",
                accentColor: themeColor)
            InfoCard(icon: "⚡", title: "Energy Requirements",
                content: "Accelerating a 1,000-tonne ship to 10% light speed requires more energy than all of current human civilisation produces in a year.",
                accentColor: themeColor)
        }
    }
}

struct StellarTravelView_Previews: PreviewProvider {
    static var previews: some View {
        StellarTravelView()
    }
}
