import SwiftUI

// MARK: - Models
struct ExploreSection: Identifiable {
    var id: String { title }
    let title: String
    let icon: String
    let emoji: String
    let description: String
    let color: Color
    let categoryFilter: ExploreFilter
    let nextEventDate: String?
    let eventNote: String?
}

struct SectionGroup: Identifiable {
    var id: String { title }
    let title: String
    let filter: ExploreFilter
    let sections: [ExploreSection]
}

enum ExploreFilter: String, CaseIterable {
    case all = "All"
    case solarSystem = "Solar System"
    case phenomena = "Phenomena"
    case spaceTime = "Space-Time"
    case earthSpace = "Earth & Space"
    case technology = "Technology"

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .solarSystem: return "sun.max.fill"
        case .phenomena: return "sparkles"
        case .spaceTime: return "clock.fill"
        case .earthSpace: return "globe.americas.fill"
        case .technology: return "telescope.fill"
        }
    }
}

// MARK: - Section Card (Uniform animated cards)
struct SectionCard: View {
    let section: ExploreSection
    // Fixed uniform dimensions
    private let animHeight: CGFloat = 108
    private let infoHeight: CGFloat = 68

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Animation area — custom Canvas animation per topic
            SectionAnimationView(title: section.title, accentColor: section.color)
                .frame(height: animHeight)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 16, bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0, topTrailingRadius: 16,
                        style: .continuous
                    )
                )

            // Info area — uniform fixed height
            VStack(alignment: .leading, spacing: 4) {
                Text(section.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(section.description)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.58))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(height: infoHeight, alignment: .topLeading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: animHeight + infoHeight)   // ← uniform total height
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.38))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(section.color.opacity(0.35), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: section.color.opacity(0.18), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let filter: ExploreFilter
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                Image(systemName: filter.icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(filter.rawValue)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(isSelected ? .black : .white.opacity(0.85))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.white.opacity(0.95) : Color.white.opacity(0.10))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(isSelected ? 0 : 0.18), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Section Content View
struct SectionContentView: View {
    let section: ExploreSection

    var body: some View {
        Group {
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
                TelescopeView()
            } else {
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
}

// MARK: - Main Explore Page
struct ExplorePage: View {
    @State private var selectedFilter: ExploreFilter = .all
    @State private var starfieldRotation: Double = 0
    @State private var parallaxOffset: CGFloat = 0
    @State private var zoomLevel: Double = 1.0
    @State private var animateCards = false

    let sectionGroups: [SectionGroup] = [
        SectionGroup(title: "Solar System", filter: .solarSystem, sections: [
            ExploreSection(title: "Solar System", icon: "sun.max.fill", emoji: "☀️",
                           description: "Our cosmic neighborhood of 8 planets", color: .orange,
                           categoryFilter: .solarSystem,
                           nextEventDate: "Mar 20, 2026", eventNote: "Spring Equinox"),
            ExploreSection(title: "Moons", icon: "moon.fill", emoji: "🌙",
                           description: "300+ natural satellites orbit planets", color: .gray,
                           categoryFilter: .solarSystem,
                           nextEventDate: "Mar 14, 2026", eventNote: "Full Moon"),
            ExploreSection(title: "Satellites", icon: "antenna.radiowaves.left.and.right", emoji: "📡",
                           description: "Artificial eyes in the sky", color: .cyan,
                           categoryFilter: .solarSystem,
                           nextEventDate: "Apr 6, 2026", eventNote: "Starlink Launch"),
            ExploreSection(title: "Comets", icon: "sparkles", emoji: "☄️",
                           description: "Icy wanderers from the Oort Cloud", color: .blue,
                           categoryFilter: .solarSystem,
                           nextEventDate: "May 31, 2026", eventNote: "C/2023 A3 Return"),
        ]),

        SectionGroup(title: "Cosmic Phenomena", filter: .phenomena, sections: [
            ExploreSection(title: "Black Holes", icon: "circle.fill", emoji: "🕳️",
                           description: "Regions where gravity defeats light", color: .purple,
                           categoryFilter: .phenomena,
                           nextEventDate: "Jun 12, 2026", eventNote: "EHT New Image"),
            ExploreSection(title: "Wormholes", icon: "tornado", emoji: "🌀",
                           description: "Theoretical tunnels through space-time", color: .indigo,
                           categoryFilter: .phenomena,
                           nextEventDate: nil, eventNote: nil),
            ExploreSection(title: "Constellations", icon: "star.fill", emoji: "✨",
                           description: "Ancient star patterns in the sky", color: .yellow,
                           categoryFilter: .phenomena,
                           nextEventDate: "Apr 2026", eventNote: "Virgo Season"),
            ExploreSection(title: "Dimensions", icon: "cube.fill", emoji: "🔮",
                           description: "The reality beyond 3D space", color: .mint,
                           categoryFilter: .phenomena,
                           nextEventDate: nil, eventNote: nil),
        ]),

        SectionGroup(title: "Space-Time", filter: .spaceTime, sections: [
            ExploreSection(title: "Time Delay", icon: "clock.fill", emoji: "⏰",
                           description: "Relativistic time dilation effects", color: .orange,
                           categoryFilter: .spaceTime,
                           nextEventDate: nil, eventNote: nil),
            ExploreSection(title: "Gravitational Time Delay", icon: "arrow.down.circle", emoji: "🕒",
                           description: "How gravity warps the flow of time", color: .purple,
                           categoryFilter: .spaceTime,
                           nextEventDate: nil, eventNote: nil),
            ExploreSection(title: "Stellar Travel", icon: "airplane", emoji: "🚀",
                           description: "Reaching for the nearest stars", color: .green,
                           categoryFilter: .spaceTime,
                           nextEventDate: nil, eventNote: nil),
            ExploreSection(title: "Cryogenic Sleep", icon: "snowflake", emoji: "❄️",
                           description: "Suspended animation for deep space", color: .blue,
                           categoryFilter: .spaceTime,
                           nextEventDate: nil, eventNote: nil),
        ]),

        SectionGroup(title: "Earth & Space", filter: .earthSpace, sections: [
            ExploreSection(title: "Eclipses", icon: "circle.circle.fill", emoji: "🌑",
                           description: "When worlds align to block the sun", color: .gray,
                           categoryFilter: .earthSpace,
                           nextEventDate: "Aug 12, 2026", eventNote: "Total Solar Eclipse"),
            ExploreSection(title: "Tidal Wave", icon: "water.waves", emoji: "🌊",
                           description: "The Moon's gravitational pull on Earth", color: .blue,
                           categoryFilter: .earthSpace,
                           nextEventDate: "Mar 14, 2026", eventNote: "King Tide"),
            ExploreSection(title: "Gravity", icon: "arrow.down.circle.fill", emoji: "🌍",
                           description: "The universal force that shapes cosmos", color: .red,
                           categoryFilter: .earthSpace,
                           nextEventDate: nil, eventNote: nil),
            ExploreSection(title: "Solar Flares", icon: "sun.max.fill", emoji: "🌞",
                           description: "Powerful eruptions from the Sun", color: .yellow,
                           categoryFilter: .earthSpace,
                           nextEventDate: "Mar 2026", eventNote: "Solar Max Peak"),
        ]),

        SectionGroup(title: "Technology", filter: .technology, sections: [
            ExploreSection(title: "Hyperloop", icon: "train.side.front.car", emoji: "🚄",
                           description: "The future of high-speed travel", color: .pink,
                           categoryFilter: .technology,
                           nextEventDate: nil, eventNote: nil),
            ExploreSection(title: "Space Telescopes", icon: "telescope.fill", emoji: "🔭",
                           description: "Humanity's eye on the cosmos", color: .blue,
                           categoryFilter: .technology,
                           nextEventDate: "Jun 2026", eventNote: "Roman Telescope Launch"),
            ExploreSection(title: "Space Stations", icon: "building.fill", emoji: "🛸",
                           description: "Outposts in low Earth orbit", color: .gray,
                           categoryFilter: .technology,
                           nextEventDate: "2027", eventNote: "Lunar Gateway Phase 1"),
            ExploreSection(title: "Rocket", icon: "bolt.fill", emoji: "🚀",
                           description: "Tomorrow's launch vehicles", color: .green,
                           categoryFilter: .technology,
                           nextEventDate: "Mar 2026", eventNote: "Starship Flight 10"),
        ]),
    ]

    private var filteredGroups: [SectionGroup] {
        if selectedFilter == .all {
            return sectionGroups
        }
        return sectionGroups.filter { $0.filter == selectedFilter }
    }

    private var allFilteredSections: [ExploreSection] {
        filteredGroups.flatMap { $0.sections }
    }

    var body: some View {
        ZStack {
            EnhancedCosmicBackground(
                parallaxOffset: parallaxOffset,
                starfieldRotation: starfieldRotation,
                zoomLevel: zoomLevel
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.white, Color.yellow.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("Cosmic Odyssey")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text("Explore the Universe · March 2026")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.55))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // MARK: - Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(ExploreFilter.allCases, id: \.self) { filter in
                                FilterChip(
                                    filter: filter,
                                    isSelected: selectedFilter == filter
                                ) {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        selectedFilter = filter
                                        animateCards = false
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            animateCards = true
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                    }

                    // MARK: - Content Grid
                    if selectedFilter == .all {
                        ForEach(filteredGroups) { group in
                            groupSection(group)
                        }
                    } else {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ],
                            spacing: 12
                        ) {
                            ForEach(Array(allFilteredSections.enumerated()), id: \.element.id) { index, section in
                                NavigationLink(destination: SectionContentView(section: section)) {
                                    SectionCard(section: section)
                                }
                                .buttonStyle(.plain)
                                .offset(y: animateCards ? 0 : 30)
                                .opacity(animateCards ? 1 : 0)
                                .animation(
                                    .spring(response: 0.45, dampingFraction: 0.75).delay(Double(index) * 0.05),
                                    value: animateCards
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 100)
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
                starfieldRotation = 360
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                animateCards = true
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func groupSection(_ group: SectionGroup) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(group.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
                .padding(.horizontal, 20)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(Array(group.sections.enumerated()), id: \.element.id) { index, section in
                    NavigationLink(destination: SectionContentView(section: section)) {
                        SectionCard(section: section)
                    }
                    .buttonStyle(.plain)
                    .offset(y: animateCards ? 0 : 30)
                    .opacity(animateCards ? 1 : 0)
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.75).delay(Double(index) * 0.06),
                        value: animateCards
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 20)
    }
}

struct ExplorePage_Previews: PreviewProvider {
    static var previews: some View {
        ExplorePage()
    }
}
