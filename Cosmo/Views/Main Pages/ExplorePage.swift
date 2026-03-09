import SwiftUI

// MARK: - Models
struct ExploreSection: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let emoji: String
    let description: String
    let color: Color
}

struct SectionGroup: Identifiable {
    let id = UUID()
    let title: String
    let sections: [ExploreSection]
}

// MARK: - Color Extension
extension Color {
    static func random(opacity: Double = 1) -> Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1),
            opacity: opacity
        )
    }
}

// MARK: - Section Card
struct SectionCard: View {
    let section: ExploreSection

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(section.emoji)
                    .font(.system(size: 28))
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(section.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(section.description)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .frame(height: 85)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(section.color.opacity(0.5), lineWidth: 2)
        )
    }
}

// MARK: - Section Content View
struct SectionContentView: View {
    let section: ExploreSection

    var body: some View {
        if section.title == "Solar System" {
            SolarSystemView()
        } else if section.title == "Satellites" {
            SatelliteView()
        } else if section.title == "Moons" {
            MoonView()
        } else if section.title == "Comets" {
            CometView()
        } else if section.title == "Black Holes" {
            BlackHoleView()
        } else if section.title == "Constellations" {
            ConstellationView()
        } else if section.title == "Dimensions" {
            DimensionsView()
        } else if section.title == "Wormholes" {
            WormholeView()
        } else if section.title == "Eclipses" {
            EclipseView()
        } else if section.title == "Gravity" {
            GravityView()
        } else if section.title == "Solar Flares" {
            SolarFlareView()
        } else if section.title == "Tidal Wave" {
            TideExplorerView()
        } else if section.title == "Cryogenic Sleep" {
            CryogenicSleepView()
        } else if section.title == "Gravitational Time Delay" {
            GravitationalDelayView()
        } else if section.title == "Stellar Travel" {
            StellarTravelView()
        } else if section.title == "Time Delay" {
            TimeDelayView()
        } else if section.title == "Hyperloop" {
            HyperloopView()
        } else if section.title == "Rocket" {
            RocketView()
        } else if section.title == "Space Stations" {
            SpaceStationView()
        } else if section.title == "Space Telescopes" {
            TelescopeView()        }
        else {
            VStack {
                Text(section.emoji)
                    .font(.system(size: 50))
                    .padding()

                Text("\(section.title) Content")
                    .font(.title)
                    .foregroundColor(.white)

                Text("Coming Soon")
                    .foregroundColor(.gray)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        }
    }
}
// MARK: - Main Explore Page
struct ExplorePage: View {
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    @State private var zoomLevel: Double = 1.0

    let sectionGroups = [
        SectionGroup(title: "Solar System", sections: [
            ExploreSection(title: "Solar System", icon: "sun.max.fill", emoji: "☀️", description: "Our cosmic neighborhood", color: .orange),
            ExploreSection(title: "Moons", icon: "moon.fill", emoji: "🌙", description: "Natural satellites", color: .gray),
            ExploreSection(title: "Satellites", icon: "antenna.radiowaves.left.and.right", emoji: "📡", description: "Artificial observers", color: .cyan),
            ExploreSection(title: "Comets", icon: "sparkles", emoji: "☄️", description: "Icy wanderers", color: .blue)
        ]),

        SectionGroup(title: "Cosmic Phenomena", sections: [
            ExploreSection(title: "Black Holes", icon: "circle.fill", emoji: "🕳️", description: "Points of no return", color: .purple),
            ExploreSection(title: "Wormholes", icon: "tornado", emoji: "🌀", description: "Space-time tunnels", color: .indigo),
            ExploreSection(title: "Constellations", icon: "star.fill", emoji: "✨", description: "Star patterns", color: .yellow),
            ExploreSection(title: "Dimensions", icon: "cube.fill", emoji: "🔮", description: "Beyond 3D space", color: .mint)
        ]),

        SectionGroup(title: "Space-Time", sections: [
            ExploreSection(title: "Time Delay", icon: "clock.fill", emoji: "⏰", description: "Relativistic effects", color: .orange),
            ExploreSection(title: "Gravitational Time Delay", icon: "arrow.down.circle", emoji: "🕒", description: "Time dilation by gravity", color: .purple),
            ExploreSection(title: "Stellar Travel", icon: "airplane", emoji: "🚀", description: "Interstellar journeys", color: .green),
            ExploreSection(title: "Cryogenic Sleep", icon: "snowflake", emoji: "❄️", description: "Deep space preservation", color: .blue)
        ]),

        SectionGroup(title: "Earth & Space", sections: [
            ExploreSection(title: "Eclipses", icon: "circle.circle.fill", emoji: "🌑", description: "Solar & Lunar eclipses", color: .gray),
            ExploreSection(title: "Tidal Wave", icon: "water.waves", emoji: "🌊", description: "Lunar influence", color: .blue),
            ExploreSection(title: "Gravity", icon: "arrow.down.circle.fill", emoji: "🌍", description: "Universal force", color: .red),
            ExploreSection(title: "Solar Flares", icon: "sun.max.fill", emoji: "🌞", description: "Solar storms", color: .yellow)
        ]),

        SectionGroup(title: "Technology", sections: [
            ExploreSection(title: "Hyperloop", icon: "train.side.front.car", emoji: "🚄", description: "Future transport", color: .pink),
            ExploreSection(title: "Space Telescopes", icon: "telescope.fill", emoji: "🔭", description: "Eye on the cosmos", color: .blue), // <-- "Space Telescopes"
            ExploreSection(title: "Space Stations", icon: "building.fill", emoji: "🛸", description: "Orbital outposts", color: .gray),
            ExploreSection(title: "Rocket", icon: "bolt.fill", emoji: "🚀 ", description: "Tomorrow's space tech", color: .green) // <-- "Rocket"
        ]),
    ]

    private func startCosmicAnimations() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            starfieldRotation = 360
        }
    }

    var body: some View {
        ZStack {
            EnhancedCosmicBackground(
                parallaxOffset: parallaxOffset,
                starfieldRotation: starfieldRotation,
                zoomLevel: zoomLevel
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Cosmic Odyssey 🌌")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        .padding(.horizontal)

                    ForEach(sectionGroups) { group in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(group.title)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)

                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 12),
                                    GridItem(.flexible(), spacing: 12)
                                ],
                                spacing: 12
                            ) {
                                ForEach(group.sections) { section in
                                    NavigationLink(
                                        destination: SectionContentView(section: section)
                                    ) {
                                        SectionCard(section: section)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    Spacer(minLength: 20)
                }
            }
        }
        .onAppear { startCosmicAnimations() }
        .preferredColorScheme(.dark)
    }
}

struct ExplorePage_Previews: PreviewProvider {
    static var previews: some View {
        ExplorePage()
    }
}
