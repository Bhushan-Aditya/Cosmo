import SwiftUI

// MARK: - Orbit Class
enum OrbitClass {
    case leo, meo, geo, lagrange

    var label: String {
        switch self {
        case .leo: return "LEO"
        case .meo: return "MEO"
        case .geo: return "GEO"
        case .lagrange: return "L2"
        }
    }

    var fullLabel: String {
        switch self {
        case .leo: return "Low Earth Orbit"
        case .meo: return "Medium Earth Orbit"
        case .geo: return "Geostationary Orbit"
        case .lagrange: return "Lagrange Point 2"
        }
    }

    var color: Color {
        switch self {
        case .leo: return Color(red: 0.38, green: 0.78, blue: 1.00)
        case .meo: return Color(red: 0.35, green: 0.95, blue: 0.68)
        case .geo: return Color(red: 1.00, green: 0.86, blue: 0.30)
        case .lagrange: return Color(red: 0.82, green: 0.55, blue: 1.00)
        }
    }

    // 0→1 fraction used for the altitude progress bar
    var barFraction: Double {
        switch self {
        case .leo:      return 0.30
        case .meo:      return 0.54
        case .geo:      return 0.74
        case .lagrange: return 0.92
        }
    }

    // Radius fraction for the diagram rings
    var diagramFraction: Double {
        switch self {
        case .leo:      return 0.28
        case .meo:      return 0.50
        case .geo:      return 0.72
        case .lagrange: return 0.90
        }
    }
}

// MARK: - Satellite Type
enum SatelliteType: CaseIterable, Equatable {
    case scientific, communication, navigation, observation, weather, military

    var label: String {
        switch self {
        case .scientific:    return "Science"
        case .communication: return "Comms"
        case .navigation:    return "Navigation"
        case .observation:   return "Earth Obs"
        case .weather:       return "Weather"
        case .military:      return "Military"
        }
    }

    var description: String {
        switch self {
        case .scientific:    return "Scientific Research"
        case .communication: return "Communication"
        case .navigation:    return "Navigation"
        case .observation:   return "Earth Observation"
        case .weather:       return "Weather"
        case .military:      return "Military"
        }
    }

    var icon: String {
        switch self {
        case .scientific:    return "flask.fill"
        case .communication: return "antenna.radiowaves.left.and.right"
        case .navigation:    return "location.fill"
        case .observation:   return "eye.fill"
        case .weather:       return "cloud.sun.fill"
        case .military:      return "shield.fill"
        }
    }

    var color: Color {
        switch self {
        case .scientific:    return Color(red: 0.80, green: 0.50, blue: 1.00)
        case .communication: return Color(red: 0.28, green: 0.85, blue: 0.92)
        case .navigation:    return Color(red: 0.35, green: 0.92, blue: 0.55)
        case .observation:   return Color(red: 1.00, green: 0.70, blue: 0.28)
        case .weather:       return Color(red: 0.45, green: 0.75, blue: 1.00)
        case .military:      return Color(red: 1.00, green: 0.42, blue: 0.42)
        }
    }
}

// MARK: - Satellite Status
enum SatelliteStatus: Equatable {
    case active, inactive, deorbited

    var label: String {
        switch self {
        case .active:    return "Active"
        case .inactive:  return "Inactive"
        case .deorbited: return "Deorbited"
        }
    }

    var color: Color {
        switch self {
        case .active:    return Color(red: 0.25, green: 0.90, blue: 0.52)
        case .inactive:  return Color(red: 1.00, green: 0.72, blue: 0.28)
        case .deorbited: return Color(red: 1.00, green: 0.42, blue: 0.42)
        }
    }
}

// MARK: - Model
struct Satellite: Identifiable {
    let id = UUID()
    let name: String
    let type: SatelliteType
    let launchDate: String
    let operator_: String
    let purpose: String
    let facts: [String]
    let altitude: String
    let status: SatelliteStatus
    let icon: String
    let description: String
    let orbit: OrbitClass

    // Legacy compat fields (not used in new UI)
    var emoji: String { "" }
    var image: String { icon }
}

// MARK: - Orbital Diagram
struct OrbitalDiagramView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let cx = w / 2
            let cy = h / 2
            let maxR = min(w, h) / 2 - 8

            ZStack {
                TimelineView(.animation) { timeline in
                    ZStack {
                        Canvas { ctx, _ in
                            let t = timeline.date.timeIntervalSinceReferenceDate
                            let rings: [(OrbitClass, Double)] = [(.leo, 0.28), (.meo, 0.50), (.geo, 0.72)]
                            for (orbit, frac) in rings {
                                let r = maxR * frac
                                let rect = CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)

                                // Solid orbit ring
                                ctx.stroke(
                                    Path(ellipseIn: rect),
                                    with: .color(orbit.color.opacity(0.18)),
                                    lineWidth: 1
                                )

                                // Dashed outer ring
                                let dashedRect = rect.insetBy(dx: -3, dy: -3)
                                ctx.stroke(
                                    Path(ellipseIn: dashedRect),
                                    with: .color(orbit.color.opacity(0.08)),
                                    style: StrokeStyle(lineWidth: 1, dash: [3, 6])
                                )

                                // Orbiting dot
                                let speed = 0.55 / frac
                                let angle = t * speed + frac * 2.2
                                let sx = cx + cos(angle) * r
                                let sy = cy + sin(angle) * r
                                let dotR: Double = 3.5
                                ctx.fill(
                                    Path(ellipseIn: CGRect(x: sx - dotR, y: sy - dotR, width: dotR * 2, height: dotR * 2)),
                                    with: .color(orbit.color.opacity(0.9))
                                )
                                // Glow dot
                                ctx.fill(
                                    Path(ellipseIn: CGRect(x: sx - dotR * 2, y: sy - dotR * 2, width: dotR * 4, height: dotR * 4)),
                                    with: .color(orbit.color.opacity(0.20))
                                )
                            }
                        }
                    }
                    .allowsHitTesting(false)
                }

                // Earth
                ZStack {
                    Circle()
                        .fill(Color(red: 0.22, green: 0.50, blue: 0.84).opacity(0.18))
                        .frame(width: maxR * 0.30, height: maxR * 0.30)
                        .blur(radius: 8)
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.22, green: 0.50, blue: 0.84),
                                    Color(red: 0.10, green: 0.60, blue: 0.38)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: maxR * 0.21, height: maxR * 0.21)
                        .overlay(
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [.white.opacity(0.22), .clear],
                                        center: UnitPoint(x: 0.3, y: 0.25),
                                        startRadius: 0,
                                        endRadius: maxR * 0.1
                                    )
                                )
                        )
                }

                // Legend
                VStack(alignment: .leading, spacing: 5) {
                    ForEach([OrbitClass.leo, .meo, .geo], id: \.label) { orbit in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(orbit.color)
                                .frame(width: 6, height: 6)
                            Text(orbit.label)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(orbit.color)
                            Text("· \(orbit.fullLabel)")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.42))
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(10)
            }
        }
    }
}

// MARK: - Type Filter Chip
struct TypeFilterChip: View {
    let label: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .black : .white.opacity(0.70))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule(style: .continuous)
                        .fill(isSelected ? color : Color.white.opacity(0.08))
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(
                                    isSelected ? color.opacity(0) : Color.white.opacity(0.14),
                                    lineWidth: 1
                                )
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pulsing Status Dot
struct SatStatusDot: View {
    let status: SatelliteStatus
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 5) {
            ZStack {
                if status == .active {
                    Circle()
                        .fill(status.color.opacity(0.32))
                        .frame(width: 14, height: 14)
                        .scaleEffect(pulse ? 1.8 : 1.0)
                        .opacity(pulse ? 0.0 : 0.7)
                        .animation(
                            .easeOut(duration: 1.5).repeatForever(autoreverses: false),
                            value: pulse
                        )
                }
                Circle()
                    .fill(status.color)
                    .frame(width: 7, height: 7)
            }
            Text(status.label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(status.color)
        }
        .onAppear { pulse = true }
    }
}

// MARK: - Orbit Altitude Bar
struct OrbitAltitudeBar: View {
    let orbit: OrbitClass
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(orbit.color)
                    .frame(width: 8, height: 8)
                Text(orbit.fullLabel)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(orbit.color)
                Spacer()
                Text(orbit.label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(orbit.color)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(orbit.color.opacity(0.14)))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.07))
                        .frame(height: 5)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [orbit.color, orbit.color.opacity(0.50)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: appeared ? geo.size.width * orbit.barFraction : 0,
                            height: 5
                        )
                        .animation(
                            .spring(response: 0.75, dampingFraction: 0.78).delay(0.15),
                            value: appeared
                        )
                }
            }
            .frame(height: 5)
        }
        .onAppear { appeared = true }
    }
}

// MARK: - Satellite Row Card
struct SatelliteRowCard: View {
    let satellite: Satellite
    @State private var showDetails = false
    @State private var iconAngle: Double = 0

    private var tc: Color { satellite.type.color }

    var body: some View {
        Button(action: { showDetails = true }) {
            HStack(spacing: 14) {

                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .fill(tc.opacity(0.11))
                        .frame(width: 60, height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 17, style: .continuous)
                                .stroke(tc.opacity(0.32), lineWidth: 1)
                        )
                    Image(systemName: satellite.icon)
                        .font(.system(size: 25, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [tc, tc.opacity(0.60)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(iconAngle))
                        .animation(
                            .linear(duration: 20).repeatForever(autoreverses: false),
                            value: iconAngle
                        )
                        .onAppear { iconAngle = 360 }
                }

                // Text block
                VStack(alignment: .leading, spacing: 5) {
                    Text(satellite.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(satellite.purpose)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.52))
                        .lineLimit(1)

                    HStack(spacing: 7) {
                        Text(satellite.type.label)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(tc)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(tc.opacity(0.11)))

                        Text(satellite.orbit.label)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(satellite.orbit.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(satellite.orbit.color.opacity(0.11)))
                    }
                }

                Spacer(minLength: 0)

                // Right
                VStack(alignment: .trailing, spacing: 6) {
                    SatStatusDot(status: satellite.status)

                    Text(satellite.altitude)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.38))
                        .lineLimit(1)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.22))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [tc.opacity(0.08), Color.black.opacity(0.22)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(tc.opacity(0.22), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetails) {
            SatelliteDetailView(satellite: satellite)
        }
    }
}

// MARK: - Satellite Detail View
struct SatelliteDetailView: View {
    let satellite: Satellite
    @Environment(\.dismiss) private var dismiss

    private var tc: Color { satellite.type.color }

    var infoItems: [(String, String, String)] {
        [
            ("person.2.fill",                  "Operator",   satellite.operator_),
            ("calendar",                       "Launched",   satellite.launchDate),
            ("arrow.up.to.line",               "Altitude",   satellite.altitude),
            ("circle.dotted",                  "Orbit Class",satellite.orbit.fullLabel),
            ("bolt.fill",                      "Purpose",    satellite.purpose)
        ]
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, tc.opacity(0.10), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 26) {

                    // Hero icon
                    ZStack {
                        Circle()
                            .fill(tc.opacity(0.10))
                            .frame(width: 220, height: 220)
                            .blur(radius: 45)

                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .fill(tc.opacity(0.13))
                            .frame(width: 110, height: 110)
                            .overlay(
                                RoundedRectangle(cornerRadius: 34, style: .continuous)
                                    .stroke(tc.opacity(0.45), lineWidth: 1.5)
                            )
                        Image(systemName: satellite.icon)
                            .font(.system(size: 50, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [tc, tc.opacity(0.55)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .frame(height: 165)
                    .padding(.top, 28)

                    // Name + type + status
                    VStack(spacing: 10) {
                        Text(satellite.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 10) {
                            Text(satellite.type.description)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(tc)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(tc.opacity(0.13))
                                        .overlay(Capsule().stroke(tc.opacity(0.40), lineWidth: 1))
                                )

                            SatStatusDot(status: satellite.status)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Description
                    Text(satellite.description)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 28)

                    // Orbital position bar
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Orbital Position", systemImage: "circle.dotted")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)

                        OrbitAltitudeBar(orbit: satellite.orbit)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white.opacity(0.04))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(satellite.orbit.color.opacity(0.22), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)

                    // Info grid
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 10
                    ) {
                        ForEach(infoItems, id: \.1) { icon, label, value in
                            VStack(alignment: .leading, spacing: 5) {
                                HStack(spacing: 5) {
                                    Image(systemName: icon)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(tc)
                                    Text(label)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.52))
                                }
                                Text(value)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.80)
                            }
                            .padding(.horizontal, 13)
                            .padding(.vertical, 11)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(tc.opacity(0.07))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(tc.opacity(0.24), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    // Facts
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Key Facts", systemImage: "sparkles")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        VStack(spacing: 8) {
                            ForEach(Array(satellite.facts.enumerated()), id: \.element) { idx, fact in
                                HStack(alignment: .top, spacing: 13) {
                                    ZStack {
                                        Circle()
                                            .fill(tc.opacity(0.18))
                                            .frame(width: 32, height: 32)
                                        Text("\(idx + 1)")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(tc)
                                    }
                                    Text(fact)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.85))
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer(minLength: 0)
                                }
                                .padding(13)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [tc.opacity(0.11), tc.opacity(0.04)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(tc.opacity(0.20), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                    }

                    Spacer(minLength: 50)
                }
            }
            .overlay(alignment: .topTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.72))
                        .padding(10)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.11))
                                .overlay(Circle().stroke(Color.white.opacity(0.14), lineWidth: 1))
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
struct SatelliteView: View {
    @State private var starfieldRotation: Double = 0
    @State private var selectedType: SatelliteType? = nil

    let satellites: [Satellite] = [
        Satellite(
            name: "Hubble Space Telescope",
            type: .scientific,
            launchDate: "April 24, 1990",
            operator_: "NASA",
            purpose: "Deep-space visual observation",
            facts: [
                "Has made over 1.5 million observations in 34 years of service",
                "Orbits Earth every 95 minutes at 27,000 km/h",
                "Helped scientists confirm the universe is 13.8 billion years old",
                "Named after astronomer Edwin Hubble, who proved galaxies exist beyond the Milky Way"
            ],
            altitude: "540 km",
            status: .active,
            icon: "binoculars.fill",
            description: "Hubble is the trailblazer of space-based astronomy. Since 1990 it has revealed billions of galaxies, confirmed the accelerating expansion of the universe, and become one of science's most productive instruments.",
            orbit: .leo
        ),
        Satellite(
            name: "Space Station (ISS)",
            type: .scientific,
            launchDate: "November 20, 1998",
            operator_: "15-nation consortium",
            purpose: "Microgravity research platform",
            facts: [
                "As large as a football field — the biggest human-made structure in orbit",
                "Continuously occupied by humans since October 31, 2000",
                "Completes 16 orbits per day — 16 sunrises and sunsets",
                "Visible to the naked eye as a brilliant moving star"
            ],
            altitude: "408 km",
            status: .active,
            icon: "rays",
            description: "The ISS is humanity's permanent home in space. Built from 15 nations cooperating over a decade, it studies the effects of microgravity on everything from medicine to materials science.",
            orbit: .leo
        ),
        Satellite(
            name: "James Webb Telescope",
            type: .scientific,
            launchDate: "December 25, 2021",
            operator_: "NASA / ESA / CSA",
            purpose: "Infrared deep-field astronomy",
            facts: [
                "Parked 1.5 million km from Earth at the L2 Lagrange point",
                "Its 6.5 m gold mirror is 2.7× the size of Hubble's",
                "Can detect starlight from just 200 million years after the Big Bang",
                "First telescope to directly image an exoplanet's atmosphere"
            ],
            altitude: "1,500,000 km",
            status: .active,
            icon: "sparkles",
            description: "JWST is the most powerful observatory ever launched. By observing in infrared it peers through cosmic dust to study the first stars, galaxies, and the atmospheres of worlds orbiting other suns.",
            orbit: .lagrange
        ),
        Satellite(
            name: "Starlink Constellation",
            type: .communication,
            launchDate: "May 23, 2019",
            operator_: "SpaceX",
            purpose: "Global broadband internet",
            facts: [
                "Over 5,000 satellites now form the constellation — the largest ever",
                "Uses laser inter-satellite links for ultra-low-latency routing",
                "Delivers broadband to 100+ countries including the most remote regions",
                "Each satellite carries autonomous collision-avoidance capability"
            ],
            altitude: "550 km",
            status: .active,
            icon: "network",
            description: "Starlink is SpaceX's mega-constellation rewriting global internet access. Thousands of LEO satellites work together to deliver low-latency broadband anywhere on the planet's surface.",
            orbit: .leo
        ),
        Satellite(
            name: "TDRS-M",
            type: .communication,
            launchDate: "August 18, 2017",
            operator_: "NASA",
            purpose: "Space mission comms relay",
            facts: [
                "Part of NASA's Tracking and Data Relay Satellite System",
                "Provides 24/7 communications for the ISS, Hubble, and other missions",
                "Eliminates communication dead zones caused by Earth's curvature",
                "Sits in geostationary orbit for a fixed field of view of Earth"
            ],
            altitude: "35,786 km",
            status: .active,
            icon: "antenna.radiowaves.left.and.right",
            description: "TDRS-M is the invisible backbone of NASA missions. Without it the ISS and Hubble would lose contact with Earth for hours each day — TDRS keeps the link alive around the clock.",
            orbit: .geo
        ),
        Satellite(
            name: "GOES-16",
            type: .weather,
            launchDate: "November 19, 2016",
            operator_: "NOAA",
            purpose: "Real-time weather monitoring",
            facts: [
                "Captures a complete Earth disk image every 10–15 minutes",
                "Tracks hurricanes, tornadoes, and wildfires in real time",
                "Monitors solar flares and geomagnetic storm activity",
                "Data feeds directly into US National Weather Service forecasts"
            ],
            altitude: "35,786 km",
            status: .active,
            icon: "cloud.sun.fill",
            description: "GOES-16 is America's premier weather eye in geostationary orbit. Its continuous full-disk imagery and lightning mapping underpin every US weather forecast and severe-storm warning.",
            orbit: .geo
        ),
        Satellite(
            name: "GPS III SV05",
            type: .navigation,
            launchDate: "June 17, 2021",
            operator_: "US Space Force",
            purpose: "Global positioning services",
            facts: [
                "3× more accurate than the previous GPS generation",
                "Features enhanced anti-jamming and anti-spoofing capability",
                "Interoperable with Europe's Galileo and other GNSS systems",
                "Designed for a 15-year operational lifespan"
            ],
            altitude: "20,200 km",
            status: .active,
            icon: "location.fill",
            description: "GPS III is the cutting edge of the Global Positioning System. With improved accuracy and resilience, it serves billions of civilian users and critical military operations worldwide every second.",
            orbit: .meo
        ),
        Satellite(
            name: "Galileo FOC-M9",
            type: .navigation,
            launchDate: "December 4, 2021",
            operator_: "European Union",
            purpose: "European GNSS constellation",
            facts: [
                "Part of Europe's fully independent navigation constellation",
                "Provides free civilian positioning accuracy better than 1 metre",
                "Completely independent from the US GPS system",
                "30 operational satellites cover the entire globe"
            ],
            altitude: "23,222 km",
            status: .active,
            icon: "location.north.fill",
            description: "Galileo gives Europe sovereign navigation capability independent of any other nation. It offers higher civilian accuracy than GPS and is interoperable with all major global navigation systems.",
            orbit: .meo
        ),
        Satellite(
            name: "Landsat 9",
            type: .observation,
            launchDate: "September 27, 2021",
            operator_: "NASA / USGS",
            purpose: "Earth surface change monitoring",
            facts: [
                "Images the entire Earth land surface every 16 days",
                "Continues a 50-year Earth observation record begun in 1972",
                "Tracks deforestation, glacier retreat, and urban expansion",
                "All data is freely available to researchers worldwide"
            ],
            altitude: "705 km",
            status: .active,
            icon: "globe.americas.fill",
            description: "Landsat 9 is the latest in the longest continuous record of Earth's surface from space. Its data helps scientists measure environmental change, manage water resources, and support disaster response.",
            orbit: .leo
        ),
        Satellite(
            name: "WorldView-3",
            type: .observation,
            launchDate: "August 13, 2014",
            operator_: "Maxar Technologies",
            purpose: "High-resolution commercial imaging",
            facts: [
                "Resolves objects as small as 31 cm — the sharpest commercial resolution",
                "Carries 16 spectral bands including short-wave infrared",
                "Used for precision agriculture, urban planning, and intelligence",
                "Can revisit any point on Earth up to 4.5 times per day"
            ],
            altitude: "617 km",
            status: .active,
            icon: "camera.viewfinder",
            description: "WorldView-3 delivers the sharpest commercial satellite imagery on the market. With 16 spectral bands and sub-metre resolution, it serves defence agencies, farmers, and city planners alike.",
            orbit: .leo
        )
    ]

    var filteredSatellites: [Satellite] {
        guard let type = selectedType else { return satellites }
        return satellites.filter { $0.type == type }
    }

    func count(for type: SatelliteType) -> Int {
        satellites.filter { $0.type == type }.count
    }

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
                            Image(systemName: "satellite.fill")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, Color(red: 0.55, green: 0.85, blue: 1.0).opacity(0.85)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("Satellites")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text("\(satellites.count) spacecraft · Tap to explore details")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.55))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 14)

                    // MARK: Orbit Diagram
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white.opacity(0.035))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )

                        OrbitalDiagramView()
                            .padding(14)
                    }
                    .frame(height: 200)
                    .padding(.horizontal, 16)

                    // MARK: Type Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            TypeFilterChip(
                                label: "All (\(satellites.count))",
                                color: .white,
                                isSelected: selectedType == nil
                            ) {
                                withAnimation(.spring(response: 0.34, dampingFraction: 0.75)) {
                                    selectedType = nil
                                }
                            }

                            ForEach(SatelliteType.allCases, id: \.description) { type in
                                let n = count(for: type)
                                if n > 0 {
                                    TypeFilterChip(
                                        label: "\(type.label) (\(n))",
                                        color: type.color,
                                        isSelected: selectedType == type
                                    ) {
                                        withAnimation(.spring(response: 0.34, dampingFraction: 0.75)) {
                                            selectedType = (selectedType == type) ? nil : type
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }

                    // MARK: Satellite List
                    VStack(spacing: 10) {
                        ForEach(filteredSatellites) { satellite in
                            SatelliteRowCard(satellite: satellite)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                                    removal: .opacity
                                ))
                        }
                    }
                    .animation(
                        .spring(response: 0.40, dampingFraction: 0.80),
                        value: selectedType
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
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

struct SatelliteView_Previews: PreviewProvider {
    static var previews: some View {
        SatelliteView()
    }
}
