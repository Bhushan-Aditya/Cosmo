import SwiftUI

// MARK: - Planet Model
struct Planet: Identifiable {
    var id: String { name }
    let name: String
    let primaryColor: Color
    let secondaryColor: Color
    let accentColor: Color
    let ringColor: Color
    let hasRings: Bool
    let facts: [String]
    let diameter: String
    let distance: String
    let orbitalPeriod: String
    let temperature: String
    let description: String
    let moons: String
    let planetType: String

    // Backward compat
    var color: Color { accentColor }
}

// MARK: - Planet Visual (Custom Drawn)
struct PlanetVisual: View {
    let planet: Planet
    let size: CGFloat
    var showGlow: Bool = true

    var body: some View {
        ZStack {
            // Atmospheric glow
            if showGlow {
                Circle()
                    .fill(planet.accentColor.opacity(0.22))
                    .frame(width: size * 1.55, height: size * 1.55)
                    .blur(radius: size * 0.22)
            }

            // Ring behind planet
            if planet.hasRings {
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                planet.ringColor.opacity(0.55),
                                planet.ringColor.opacity(0.75),
                                planet.ringColor.opacity(0.40)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: size * 1.78, height: size * 0.34)
            }

            // Planet sphere
            Circle()
                .fill(
                    LinearGradient(
                        colors: [planet.primaryColor, planet.secondaryColor],
                        startPoint: UnitPoint(x: 0.18, y: 0.12),
                        endPoint: UnitPoint(x: 0.88, y: 0.92)
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.32), Color.clear],
                                center: UnitPoint(x: 0.27, y: 0.22),
                                startRadius: 0,
                                endRadius: size * 0.54
                            )
                        )
                        .frame(width: size, height: size)
                )
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, Color.black.opacity(0.28)],
                                startPoint: UnitPoint(x: 0.25, y: 0.25),
                                endPoint: UnitPoint(x: 0.95, y: 0.95)
                            )
                        )
                        .frame(width: size, height: size)
                )

            // Ring in front (bottom half only, layered above planet)
            if planet.hasRings {
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                planet.ringColor.opacity(0.45),
                                planet.ringColor.opacity(0.65),
                                planet.ringColor.opacity(0.35)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: size * 1.78, height: size * 0.34)
                    .mask(
                        Rectangle()
                            .frame(width: size * 1.78, height: size * 0.17)
                            .offset(y: size * 0.085)
                    )
            }
        }
    }
}

// MARK: - Planet Carousel Item
struct PlanetCarouselItem: View {
    let planet: Planet
    let isSelected: Bool
    let index: Int
    let onTap: () -> Void

    @State private var appeared = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(planet.accentColor.opacity(0.22))
                            .frame(width: 60, height: 60)
                            .blur(radius: 10)
                    }
                    PlanetVisual(planet: planet, size: isSelected ? 44 : 34, showGlow: isSelected)
                }
                .frame(width: 62, height: 62)
                .scaleEffect(appeared ? 1 : 0.65)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.68).delay(Double(index) * 0.05),
                    value: appeared
                )

                Text(planet.name)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? planet.accentColor : .white.opacity(0.5))
                    .lineLimit(1)
            }
            .frame(width: 68)
        }
        .buttonStyle(.plain)
        .onAppear { appeared = true }
    }
}

// MARK: - Single Orbit View
struct PlanetOrbitView: View {
    let planet: Planet
    let orbitIndex: Int

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let cx = w / 2
            let cy = h / 2
            let rx = w * 0.33
            let ry = h * 0.30

            ZStack {
                // Orbit ring
                Ellipse()
                    .stroke(planet.accentColor.opacity(0.22), lineWidth: 1)
                    .frame(width: rx * 2, height: ry * 2)
                    .position(x: cx, y: cy)

                // Dashed outer ring
                Ellipse()
                    .stroke(
                        planet.accentColor.opacity(0.10),
                        style: StrokeStyle(lineWidth: 1, dash: [3, 6])
                    )
                    .frame(width: rx * 2 + 10, height: ry * 2 + 8)
                    .position(x: cx, y: cy)

                // Sun
                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(Color.yellow.opacity(0.12 - Double(i) * 0.03))
                            .frame(
                                width: CGFloat(24 + i * 12),
                                height: CGFloat(24 + i * 12)
                            )
                    }
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white, Color(red: 1, green: 0.92, blue: 0.5), Color.orange],
                                center: .center,
                                startRadius: 0,
                                endRadius: 12
                            )
                        )
                        .frame(width: 20, height: 20)
                }
                .position(x: cx, y: cy)

                // Orbiting planet
                TimelineView(.animation) { timeline in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    let speed = 0.42 / Double(orbitIndex + 1)
                    let angle = t * speed
                    let x = cos(angle) * rx
                    let y = sin(angle) * ry

                    PlanetVisual(planet: planet, size: 38, showGlow: true)
                        .position(x: cx + x, y: cy + y)
                }
            }
        }
    }
}

// MARK: - Stat Pill
struct StatPill: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.55))
            }
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(color.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(color.opacity(0.28), lineWidth: 1)
                )
        )
    }
}

// MARK: - Fun Fact Card
struct FunFactCard: View {
    let fact: String
    let index: Int
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.18))
                    .frame(width: 34, height: 34)
                Text("\(index + 1)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(color)
            }

            Text(fact)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.88))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.12), color.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(color.opacity(0.22), lineWidth: 1)
                )
        )
    }
}

// MARK: - Planet Info Panel
struct PlanetInfoPanel: View {
    let planet: Planet
    let planetIndex: Int

    @State private var showingDetails = false
    @State private var factsVisible = false

    var statItems: [(String, String, String)] {
        [
            ("ruler", "Diameter", planet.diameter),
            ("location", "Distance", planet.distance),
            ("clock.arrow.circlepath", "Orbit", planet.orbitalPeriod),
            ("thermometer.medium", "Temp", planet.temperature),
            ("moon.stars.fill", "Moons", planet.moons)
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // ─── Hero Card ───────────────────────────────────────────
            ZStack(alignment: .bottom) {
                // Background gradient wash
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                planet.primaryColor.opacity(0.20),
                                planet.secondaryColor.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(planet.accentColor.opacity(0.28), lineWidth: 1)
                    )

                VStack(spacing: 0) {
                    // Orbit animation
                    PlanetOrbitView(planet: planet, orbitIndex: planetIndex)
                        .frame(height: 168)

                    // Name row
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(planet.name)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                            Text(planet.planetType)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(planet.accentColor.opacity(0.9))
                        }

                        Spacer()

                        Button(action: { showingDetails = true }) {
                            HStack(spacing: 5) {
                                Text("Explore")
                                    .font(.system(size: 13, weight: .semibold))
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(planet.accentColor.opacity(0.18))
                                    .overlay(
                                        Capsule(style: .continuous)
                                            .stroke(planet.accentColor.opacity(0.5), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 18)
                    .padding(.top, 4)
                }
            }

            // ─── Stat Pills (Horizontal Scroll) ──────────────────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 9) {
                    ForEach(statItems, id: \.1) { icon, label, value in
                        StatPill(icon: icon, label: label, value: value, color: planet.accentColor)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }

            // ─── Description ─────────────────────────────────────────
            VStack(alignment: .leading, spacing: 8) {
                Label("About", systemImage: "info.circle.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(planet.accentColor.opacity(0.9))

                Text(planet.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.82))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(planet.accentColor.opacity(0.18), lineWidth: 1)
                    )
            )

            // ─── Fun Facts ───────────────────────────────────────────
            VStack(alignment: .leading, spacing: 10) {
                Label("Fun Facts", systemImage: "sparkles")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(planet.accentColor.opacity(0.9))

                VStack(spacing: 8) {
                    ForEach(Array(planet.facts.enumerated()), id: \.element) { idx, fact in
                        FunFactCard(fact: fact, index: idx, color: planet.accentColor)
                            .opacity(factsVisible ? 1 : 0)
                            .offset(y: factsVisible ? 0 : 18)
                            .animation(
                                .spring(response: 0.45, dampingFraction: 0.78)
                                    .delay(Double(idx) * 0.07),
                                value: factsVisible
                            )
                    }
                }
            }
        }
        .onAppear { resetFacts() }
        .onChange(of: planet.id) { _, _ in resetFacts() }
        .sheet(isPresented: $showingDetails) {
            PlanetDetailView(planet: planet)
        }
    }

    private func resetFacts() {
        factsVisible = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            factsVisible = true
        }
    }
}

// MARK: - Planet Detail View (Redesigned)
struct PlanetDetailView: View {
    let planet: Planet
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, planet.primaryColor.opacity(0.12), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Hero
                    ZStack {
                        Circle()
                            .fill(planet.accentColor.opacity(0.12))
                            .frame(width: 220, height: 220)
                            .blur(radius: 40)
                        PlanetVisual(planet: planet, size: 110, showGlow: true)
                    }
                    .frame(height: 170)
                    .padding(.top, 28)

                    // Name + type badge
                    VStack(spacing: 10) {
                        Text(planet.name)
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.white)

                        Text(planet.planetType)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(planet.accentColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(planet.accentColor.opacity(0.14))
                                    .overlay(
                                        Capsule(style: .continuous)
                                            .stroke(planet.accentColor.opacity(0.45), lineWidth: 1)
                                    )
                            )
                    }

                    // Description
                    Text(planet.description)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.horizontal, 28)

                    // Stats grid
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 10
                    ) {
                        StatPill(icon: "ruler", label: "Diameter", value: planet.diameter, color: planet.accentColor)
                        StatPill(icon: "location", label: "Distance", value: planet.distance, color: planet.accentColor)
                        StatPill(
                            icon: "clock.arrow.circlepath", label: "Orbital Period",
                            value: planet.orbitalPeriod, color: planet.accentColor
                        )
                        StatPill(
                            icon: "thermometer.medium", label: "Temperature",
                            value: planet.temperature, color: planet.accentColor
                        )
                        StatPill(icon: "moon.stars.fill", label: "Moons", value: planet.moons, color: planet.accentColor)
                        StatPill(icon: "globe", label: "Type", value: planet.planetType, color: planet.accentColor)
                    }
                    .padding(.horizontal, 20)

                    // Facts
                    VStack(alignment: .leading, spacing: 10) {
                        Label("All Facts", systemImage: "sparkles")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        VStack(spacing: 8) {
                            ForEach(Array(planet.facts.enumerated()), id: \.element) { idx, fact in
                                FunFactCard(fact: fact, index: idx, color: planet.accentColor)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }

                    Spacer(minLength: 50)
                }
            }

            // Close button
            .overlay(alignment: .topTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.75))
                        .padding(10)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.12))
                                .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                        )
                }
                .padding(.top, 18)
                .padding(.trailing, 20)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Main View
struct SolarSystemView: View {
    @State private var selectedIndex: Int = 2   // Default: Earth
    @State private var starfieldRotation: Double = 0

    let planets: [Planet] = [
        Planet(
            name: "Mercury",
            primaryColor: Color(red: 0.62, green: 0.58, blue: 0.54),
            secondaryColor: Color(red: 0.34, green: 0.32, blue: 0.29),
            accentColor: Color(red: 0.75, green: 0.70, blue: 0.62),
            ringColor: .clear,
            hasRings: false,
            facts: [
                "Only slightly larger than Earth's Moon — the smallest planet",
                "Surface swings 610 °C between day and night with no atmosphere to buffer",
                "A year on Mercury lasts just 88 Earth days — the fastest orbit",
                "Scarred with ancient craters, including the 1,550 km-wide Caloris Basin"
            ],
            diameter: "4,879 km",
            distance: "57.9 M km",
            orbitalPeriod: "88 days",
            temperature: "−180 to 430 °C",
            description: "The swift, cratered world closest to the Sun. Without an atmosphere, temperature extremes are brutal — and a single day lasts 176 Earth days.",
            moons: "0",
            planetType: "Rocky Planet"
        ),
        Planet(
            name: "Venus",
            primaryColor: Color(red: 0.94, green: 0.82, blue: 0.50),
            secondaryColor: Color(red: 0.76, green: 0.54, blue: 0.20),
            accentColor: Color(red: 1.00, green: 0.90, blue: 0.55),
            ringColor: .clear,
            hasRings: false,
            facts: [
                "The hottest planet — 462 °C surface temperature, hotter than Mercury",
                "Rotates backwards; the Sun rises in the west on Venus",
                "A day on Venus is longer than a Venusian year",
                "Atmospheric pressure is 90× that of Earth — like 900 m underwater"
            ],
            diameter: "12,104 km",
            distance: "108.2 M km",
            orbitalPeriod: "225 days",
            temperature: "462 °C",
            description: "Earth's toxic twin — similar in size but with a runaway greenhouse effect, sulfuric-acid clouds, and crushing pressure. The brightest natural object in the night sky after the Moon.",
            moons: "0",
            planetType: "Rocky Planet"
        ),
        Planet(
            name: "Earth",
            primaryColor: Color(red: 0.22, green: 0.50, blue: 0.84),
            secondaryColor: Color(red: 0.10, green: 0.62, blue: 0.40),
            accentColor: Color(red: 0.38, green: 0.75, blue: 1.00),
            ringColor: .clear,
            hasRings: false,
            facts: [
                "The only known world to harbor life — with 8.7 million species",
                "71 % of the surface is covered by liquid water",
                "Earth's magnetic field shields life from lethal solar radiation",
                "The Moon stabilises our axial tilt, keeping seasons consistent for billions of years"
            ],
            diameter: "12,742 km",
            distance: "149.6 M km",
            orbitalPeriod: "365.25 days",
            temperature: "−88 to 58 °C",
            description: "Our pale blue dot — the only confirmed life-bearing world. Liquid water, a breathable atmosphere, and a protective magnetic field make Earth uniquely habitable.",
            moons: "1",
            planetType: "Rocky Planet"
        ),
        Planet(
            name: "Mars",
            primaryColor: Color(red: 0.80, green: 0.32, blue: 0.16),
            secondaryColor: Color(red: 0.50, green: 0.16, blue: 0.06),
            accentColor: Color(red: 1.00, green: 0.50, blue: 0.28),
            ringColor: .clear,
            hasRings: false,
            facts: [
                "Olympus Mons is the tallest volcano in the solar system — nearly 3× the height of Everest",
                "Iron oxide (rust) gives Mars its vivid red colour",
                "Dust storms can engulf the entire planet for months",
                "Evidence of ancient river valleys and lake beds hints at past liquid water"
            ],
            diameter: "6,779 km",
            distance: "227.9 M km",
            orbitalPeriod: "687 days",
            temperature: "−153 to 20 °C",
            description: "The Red Planet — a cold, rusty desert with the solar system's biggest volcano and a canyon longer than the US is wide. The most explored world beyond Earth.",
            moons: "2",
            planetType: "Rocky Planet"
        ),
        Planet(
            name: "Jupiter",
            primaryColor: Color(red: 0.86, green: 0.70, blue: 0.48),
            secondaryColor: Color(red: 0.60, green: 0.40, blue: 0.25),
            accentColor: Color(red: 1.00, green: 0.84, blue: 0.58),
            ringColor: .clear,
            hasRings: false,
            facts: [
                "The Great Red Spot has been raging as a storm for over 350 years",
                "More than 1,300 Earths could fit inside Jupiter",
                "Its magnetic field is 20,000× stronger than Earth's",
                "Jupiter has at least 95 confirmed moons — including the four Galilean moons"
            ],
            diameter: "139,820 km",
            distance: "778.5 M km",
            orbitalPeriod: "11.8 years",
            temperature: "−110 °C",
            description: "The solar system's giant — so massive it nearly became a second star. Its swirling cloud bands and perpetual storms make it one of the most dramatic worlds.",
            moons: "95",
            planetType: "Gas Giant"
        ),
        Planet(
            name: "Saturn",
            primaryColor: Color(red: 0.90, green: 0.82, blue: 0.58),
            secondaryColor: Color(red: 0.70, green: 0.58, blue: 0.32),
            accentColor: Color(red: 1.00, green: 0.92, blue: 0.68),
            ringColor: Color(red: 0.90, green: 0.80, blue: 0.54),
            hasRings: true,
            facts: [
                "Its rings stretch 282,000 km wide but are only ~1 km thick",
                "The rings are up to 90 % water ice — billions of tiny fragments",
                "Saturn is the least dense planet and would float on water",
                "Winds near Saturn's equator howl at 1,800 km/h"
            ],
            diameter: "116,460 km",
            distance: "1.4 B km",
            orbitalPeriod: "29.5 years",
            temperature: "−178 °C",
            description: "The jewel of the solar system — its breathtaking ring system is made of countless ice and rock fragments. Despite its enormous size it's less dense than water.",
            moons: "146",
            planetType: "Gas Giant"
        ),
        Planet(
            name: "Uranus",
            primaryColor: Color(red: 0.48, green: 0.82, blue: 0.88),
            secondaryColor: Color(red: 0.24, green: 0.58, blue: 0.70),
            accentColor: Color(red: 0.60, green: 0.92, blue: 0.96),
            ringColor: Color(red: 0.52, green: 0.84, blue: 0.90),
            hasRings: false,
            facts: [
                "Tilts at 98 ° — it literally rolls on its side around the Sun",
                "Coldest planetary atmosphere in the solar system at −224 °C",
                "Discovered in 1781 — the first planet found with a telescope",
                "Its 13 faint rings were discovered only in 1977"
            ],
            diameter: "50,724 km",
            distance: "2.9 B km",
            orbitalPeriod: "84 years",
            temperature: "−224 °C",
            description: "The tilted ice giant — rolling on its side as it orbits, causing 42-year-long polar days. Its cyan-blue hue comes from methane absorbing red light.",
            moons: "27",
            planetType: "Ice Giant"
        ),
        Planet(
            name: "Neptune",
            primaryColor: Color(red: 0.16, green: 0.36, blue: 0.90),
            secondaryColor: Color(red: 0.06, green: 0.18, blue: 0.65),
            accentColor: Color(red: 0.36, green: 0.62, blue: 1.00),
            ringColor: .clear,
            hasRings: false,
            facts: [
                "Winds reach 2,100 km/h — the fastest in the solar system",
                "Neptune was predicted mathematically before anyone observed it",
                "Its moon Triton orbits backwards and is slowly spiralling inward",
                "One Neptune year = 165 Earth years — it completed its first orbit since discovery in 2011"
            ],
            diameter: "49,244 km",
            distance: "4.5 B km",
            orbitalPeriod: "165 years",
            temperature: "−214 °C",
            description: "The windiest world — supersonic storms rage across its deep indigo surface. The most distant planet, Neptune takes 165 years to complete a single lap of the Sun.",
            moons: "16",
            planetType: "Ice Giant"
        )
    ]

    var selectedPlanet: Planet { planets[selectedIndex] }

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

                    // MARK: Header
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 10) {
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, Color.yellow.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("Solar System")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text("Tap a planet to explore · \(planets.count) worlds")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.55))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // MARK: Planet Carousel
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 2) {
                            ForEach(Array(planets.enumerated()), id: \.element.id) { idx, planet in
                                PlanetCarouselItem(
                                    planet: planet,
                                    isSelected: idx == selectedIndex,
                                    index: idx
                                ) {
                                    let gen = UIImpactFeedbackGenerator(style: .light)
                                    gen.impactOccurred()
                                    withAnimation(.spring(response: 0.38, dampingFraction: 0.75)) {
                                        selectedIndex = idx
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                    }

                    // MARK: Planet Info Panel
                    PlanetInfoPanel(planet: selectedPlanet, planetIndex: selectedIndex)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 28)
                        .id(selectedPlanet.id)
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
}

// MARK: - Preview
struct SolarSystem_Previews: PreviewProvider {
    static var previews: some View {
        SolarSystemView()
    }
}
