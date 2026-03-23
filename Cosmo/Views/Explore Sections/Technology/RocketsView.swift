import SwiftUI

// MARK: - Models
struct Rocket: Identifiable {
    let id = UUID()
    let name: String
    let manufacturer: String
    let country: String
    let status: RocketStatus
    let firstFlight: String
    let height: String
    let diameter: String
    let mass: String
    let payload: String
    let thrust: String
    let stages: Int
    let successRate: Double
    let description: String
    let features: [String]
    let specifications: [String: String]
    let accentColor: Color
    let type: RocketType
}

enum RocketStatus: String, Equatable {
    case active = "Active"
    case inDevelopment = "In Development"
    case retired = "Retired"
    case testing = "Testing"

    var color: Color {
        switch self {
        case .active:        return Color(red: 0.25, green: 0.90, blue: 0.52)
        case .inDevelopment: return Color(red: 0.45, green: 0.72, blue: 1.0)
        case .retired:       return Color(red: 0.62, green: 0.62, blue: 0.68)
        case .testing:       return Color(red: 1.0, green: 0.72, blue: 0.28)
        }
    }
}

enum RocketType: String, CaseIterable, Identifiable, Equatable {
    case orbital    = "Orbital"
    case heavyLift  = "Heavy Lift"
    case superHeavy = "Super Heavy"
    case smallSat   = "Small Sat"
    case suborbital = "Suborbital"

    var id: Self { self }

    var icon: String {
        switch self {
        case .orbital:    return "paperplane.fill"
        case .heavyLift:  return "rocket.fill"
        case .superHeavy: return "bolt.fill"
        case .smallSat:   return "dot.radiowaves.right"
        case .suborbital: return "arrow.up.right"
        }
    }

    var color: Color {
        switch self {
        case .orbital:    return Color(red: 0.45, green: 0.72, blue: 1.0)
        case .heavyLift:  return Color(red: 1.0, green: 0.55, blue: 0.28)
        case .superHeavy: return Color(red: 1.0, green: 0.38, blue: 0.38)
        case .smallSat:   return Color(red: 0.38, green: 0.92, blue: 0.65)
        case .suborbital: return Color(red: 0.80, green: 0.55, blue: 1.0)
        }
    }
}

// MARK: - ViewModel
final class RocketViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedType: RocketType? = nil

    func filtered(from rockets: [Rocket]) -> [Rocket] {
        rockets.filter { rocket in
            let typeMatch = selectedType == nil || rocket.type == selectedType
            let searchMatch = searchText.isEmpty
                || rocket.name.localizedCaseInsensitiveContains(searchText)
                || rocket.manufacturer.localizedCaseInsensitiveContains(searchText)
                || rocket.country.localizedCaseInsensitiveContains(searchText)
            return typeMatch && searchMatch
        }
    }
}

// MARK: - Pulsing Status Badge
struct RocketStatusBadge: View {
    let status: RocketStatus
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 5) {
            ZStack {
                if status == .active {
                    Circle()
                        .fill(status.color.opacity(0.30))
                        .frame(width: 14, height: 14)
                        .scaleEffect(pulse ? 1.8 : 1)
                        .opacity(pulse ? 0 : 0.7)
                        .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: pulse)
                }
                Circle()
                    .fill(status.color)
                    .frame(width: 7, height: 7)
            }
            Text(status.rawValue)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(status.color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(status.color.opacity(0.12)))
        .onAppear { pulse = true }
    }
}

// MARK: - Success Rate Bar
struct SuccessRateBar: View {
    let rate: Double
    let color: Color
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Success Rate")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.52))
                Spacer()
                Text(rate > 0 ? "\(Int(rate * 100))%" : "No flights")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(rate > 0 ? color : .white.opacity(0.38))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.07))
                        .frame(height: 4)
                    if rate > 0 {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.55)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .frame(width: appeared ? geo.size.width * rate : 0, height: 4)
                            .animation(.spring(response: 0.75, dampingFraction: 0.8).delay(0.1), value: appeared)
                    }
                }
            }
            .frame(height: 4)
        }
        .onAppear { appeared = true }
    }
}

// MARK: - Rocket Row Card
struct RocketCard: View {
    let rocket: Rocket
    @State private var showDetails = false

    private var tc: Color { rocket.accentColor }

    var body: some View {
        Button(action: { showDetails = true }) {
            VStack(alignment: .leading, spacing: 12) {

                // Header row
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(rocket.name)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                        Text("\(rocket.manufacturer) · \(rocket.country)")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.50))
                    }
                    Spacer()
                    RocketStatusBadge(status: rocket.status)
                }

                // Spec pills row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        rocketSpecPill(icon: "ruler", label: "Height", value: rocket.height, color: tc)
                        rocketSpecPill(icon: "scalemass", label: "Mass", value: rocket.mass, color: tc)
                        rocketSpecPill(icon: "bolt.fill", label: "Thrust", value: rocket.thrust, color: tc)
                        rocketSpecPill(icon: "shippingbox.fill", label: "Payload", value: rocket.payload, color: tc)
                        rocketSpecPill(icon: "calendar", label: "First Flight", value: rocket.firstFlight, color: tc)
                    }
                }

                // Success rate bar
                SuccessRateBar(rate: rocket.successRate, color: tc)

                // Footer
                HStack(spacing: 8) {
                    Image(systemName: rocket.type.icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(rocket.type.color)
                    Text(rocket.type.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(rocket.type.color)
                    Spacer()
                    Text("View Details")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(tc.opacity(0.85))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(tc.opacity(0.50))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [tc.opacity(0.09), Color.black.opacity(0.25)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(tc.opacity(0.24), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetails) {
            RocketDetailView(rocket: rocket)
        }
    }

    private func rocketSpecPill(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.50))
            }
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(color.opacity(0.22), lineWidth: 1)
                )
        )
    }
}

// MARK: - Rocket Detail View
struct RocketDetailView: View {
    let rocket: Rocket
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    private var tc: Color { rocket.accentColor }
    let tabs = ["Overview", "Specs", "Features"]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, tc.opacity(0.10), Color.black],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Hero icon
                    ZStack {
                        Circle()
                            .fill(tc.opacity(0.10))
                            .frame(width: 200, height: 200)
                            .blur(radius: 40)
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(tc.opacity(0.13))
                            .frame(width: 100, height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .stroke(tc.opacity(0.40), lineWidth: 1.5)
                            )
                        Image(systemName: "rocket.fill")
                            .font(.system(size: 44, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [tc, tc.opacity(0.55)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                    }
                    .frame(height: 155)
                    .padding(.top, 28)

                    // Name + status
                    VStack(spacing: 10) {
                        Text(rocket.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        HStack(spacing: 10) {
                            RocketStatusBadge(status: rocket.status)
                            Text(rocket.type.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(rocket.type.color)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule().fill(rocket.type.color.opacity(0.14))
                                        .overlay(Capsule().stroke(rocket.type.color.opacity(0.35), lineWidth: 1))
                                )
                        }
                    }
                    .padding(.horizontal, 24)

                    // Description
                    Text(rocket.description)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 28)

                    // Success rate bar
                    SuccessRateBar(rate: rocket.successRate, color: tc)
                        .padding(.horizontal, 24)

                    // Tabs
                    ConceptTabBar(
                        tabs: tabs,
                        selected: Binding(get: { selectedTab }, set: { selectedTab = $0 }),
                        color: tc
                    )

                    // Tab content
                    Group {
                        switch selectedTab {
                        case 0: overviewTab
                        case 1: specsTab
                        case 2: featuresTab
                        default: EmptyView()
                        }
                    }
                    .animation(.easeInOut(duration: 0.22), value: selectedTab)
                    .padding(.horizontal, 20)

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
                            Circle().fill(Color.white.opacity(0.11))
                                .overlay(Circle().stroke(Color.white.opacity(0.14), lineWidth: 1))
                        )
                }
                .padding(.top, 18)
                .padding(.trailing, 20)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var overviewTab: some View {
        let items: [(String, String, String)] = [
            ("person.2.fill", "Manufacturer", rocket.manufacturer),
            ("flag.fill",     "Country",      rocket.country),
            ("calendar",      "First Flight",  rocket.firstFlight),
            ("ruler",         "Height",        rocket.height),
            ("circle",        "Diameter",      rocket.diameter),
            ("scalemass",     "Mass",          rocket.mass),
            ("bolt.fill",     "Thrust",        rocket.thrust),
            ("shippingbox",   "Payload",       rocket.payload),
            ("square.stack.3d.up", "Stages",  "\(rocket.stages)")
        ]
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(items, id: \.1) { icon, label, value in
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) {
                        Image(systemName: icon)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(tc)
                        Text(label)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.50))
                    }
                    Text(value)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.80)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(tc.opacity(0.07))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(tc.opacity(0.22), lineWidth: 1)
                        )
                )
            }
        }
    }

    private var specsTab: some View {
        VStack(spacing: 8) {
            ForEach(rocket.specifications.keys.sorted(), id: \.self) { key in
                HStack {
                    Text(key)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.60))
                    Spacer()
                    Text(rocket.specifications[key] ?? "—")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(tc.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(tc.opacity(0.18), lineWidth: 1)
                        )
                )
            }
        }
    }

    private var featuresTab: some View {
        VStack(spacing: 8) {
            ForEach(Array(rocket.features.enumerated()), id: \.element) { idx, feature in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(tc)
                    Text(feature)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.85))
                    Spacer(minLength: 0)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(tc.opacity(0.07))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(tc.opacity(0.20), lineWidth: 1)
                        )
                )
            }
        }
    }
}

// MARK: - Main View
struct RocketView: View {
    @StateObject private var viewModel = RocketViewModel()
    @State private var starfieldRotation: Double = 0

    let rockets: [Rocket] = [
        Rocket(name: "New Glenn", manufacturer: "Blue Origin", country: "United States",
               status: .active, firstFlight: "2025", height: "98 m", diameter: "7 m",
               mass: "1,000 t", payload: "45 t to LEO", thrust: "17.1 MN", stages: 2,
               successRate: 0.50,
               description: "Blue Origin's heavy-lift workhorse designed for high-cadence reusable launch. Its BE-4 engines run on liquid natural gas for a cleaner burn profile.",
               features: ["Reusable first stage", "BE-4 methalox engines", "7 m payload fairing", "Maritime landing system", "Designed for 25 reuses"],
               specifications: ["Engine": "BE-4 (7×)", "Propellant": "LNG / LOX", "Landing": "Maritime platform", "Recovery": "Propulsive", "Fairing Ø": "7 m"],
               accentColor: Color(red: 0.45, green: 0.72, blue: 1.0), type: .heavyLift),

        Rocket(name: "Falcon 9", manufacturer: "SpaceX", country: "United States",
               status: .active, firstFlight: "2010", height: "70 m", diameter: "3.7 m",
               mass: "549 t", payload: "22.8 t to LEO", thrust: "7.6 MN", stages: 2,
               successRate: 0.99,
               description: "The world's most reliable orbital rocket. Its Merlin engines and propulsive landing have revolutionised reusable launch — booster B1058 has flown 20+ times.",
               features: ["Propulsive first-stage landing", "Merlin 1D+ Vacuum upper stage", "Landing legs and grid fins", "Drone ship / land landings", "Fairing recovery system"],
               specifications: ["Engines": "Merlin 1D (9×)", "Propellant": "RP-1 / LOX", "Landing": "ASDS or LZ-1/LZ-2", "Max Reuses": "20+", "Cost/Launch": "~$67M"],
               accentColor: Color(red: 1.0, green: 1.0, blue: 1.0).opacity(0.9), type: .orbital),

        Rocket(name: "Starship / Super Heavy", manufacturer: "SpaceX", country: "United States",
               status: .testing, firstFlight: "2023", height: "121 m", diameter: "9 m",
               mass: "5,000 t", payload: "150 t to LEO", thrust: "74 MN", stages: 2,
               successRate: 0.40,
               description: "The largest and most powerful rocket ever built. Fully reusable design aims to reduce launch costs to ~$10/kg to orbit — a 1000× reduction from Saturn V.",
               features: ["Fully reusable both stages", "Raptor 2 methalox engines", "Chopstick booster catch system", "Liquid oxygen header propellant", "Point-to-point Earth transport"],
               specifications: ["Booster Engines": "Raptor 2 (33×)", "Ship Engines": "Raptor 2 (6×)", "Propellant": "CH₄ / LOX", "Landing": "Mechazilla arms", "Cost Target": "<$10M"],
               accentColor: Color(red: 1.0, green: 0.52, blue: 0.28), type: .superHeavy),

        Rocket(name: "Ariane 6", manufacturer: "ArianeGroup", country: "European Union",
               status: .active, firstFlight: "2024", height: "63 m", diameter: "5.4 m",
               mass: "900 t", payload: "21.6 t to LEO", thrust: "15.2 MN", stages: 2,
               successRate: 0.75,
               description: "Europe's heavy-lift workhorse designed for versatility and commercial competitiveness. Two configurations (A62 / A64) adapt to different payload classes.",
               features: ["A62 and A64 configurations", "P120C solid strap-on boosters", "Vinci re-ignitable upper stage", "Dual-launch capability", "European autonomous access to space"],
               specifications: ["Core Engine": "Vulcain 2.1", "Upper Stage": "Vinci", "Propellant": "LH₂ / LOX", "Launch Site": "Kourou, French Guiana", "Cost/Launch": "~€90M"],
               accentColor: Color(red: 0.52, green: 0.68, blue: 1.0), type: .heavyLift),

        Rocket(name: "Vulcan Centaur", manufacturer: "ULA", country: "United States",
               status: .active, firstFlight: "2024", height: "67 m", diameter: "5.4 m",
               mass: "546 t", payload: "27 t to LEO", thrust: "9.8 MN", stages: 2,
               successRate: 1.0,
               description: "ULA's next-generation national security launch vehicle replacing Atlas V and Delta IV. SMART Reuse recovers the expensive engine section via helicopter.",
               features: ["BE-4 liquid natural gas engines", "Up to 6 solid strap-on boosters", "Centaur V cryogenic upper stage", "SMART Reuse engine recovery", "National security certified"],
               specifications: ["Engine": "BE-4 (2×)", "Upper Stage": "Centaur V", "Propellant": "LNG / LOX", "Booster Recovery": "SMART Reuse", "Configurations": "VC2S to VC6S"],
               accentColor: Color(red: 0.42, green: 0.88, blue: 0.70), type: .heavyLift),

        Rocket(name: "H3", manufacturer: "JAXA / MHI", country: "Japan",
               status: .active, firstFlight: "2024", height: "63 m", diameter: "5.2 m",
               mass: "574 t", payload: "6.5 t to GTO", thrust: "8.9 MN", stages: 2,
               successRate: 0.5,
               description: "Japan's flagship next-generation launcher replacing H-IIA/B. LE-9 expander-bleed engines offer higher reliability with fewer moving parts than rival designs.",
               features: ["LE-9 expander-bleed main engine", "SRB-3 solid strap-on boosters", "H3-22 / H3-24 / H3-30 variants", "Cost-reduction focus (~$50M)", "All-domestic Japanese production"],
               specifications: ["Engine": "LE-9 (2×)", "Propellant": "LH₂ / LOX", "Variants": "H3-22 / 24 / 30", "Launch Site": "Tanegashima", "Cost Target": "$50M"],
               accentColor: Color(red: 1.0, green: 0.38, blue: 0.38), type: .orbital),

        Rocket(name: "Neutron", manufacturer: "Rocket Lab", country: "United States",
               status: .inDevelopment, firstFlight: "2026", height: "40 m", diameter: "7 m",
               mass: "480 t", payload: "15 t to LEO", thrust: "5.4 MN", stages: 2,
               successRate: 0.0,
               description: "Rocket Lab's reusable medium-lift vehicle targeting constellation deployment. Carbon-composite structure and catch-landing aim for 24-hour turnaround.",
               features: ["Fully reusable first stage", "Archimedes methalox engines", "Carbon composite airframe", "Catch-based landing recovery", "24-hour turnaround target"],
               specifications: ["Engine": "Archimedes (9×)", "Propellant": "LOX / CH₄", "Recovery": "Catch system", "Material": "Carbon composite", "Target Cost": "$30M"],
               accentColor: Color(red: 0.80, green: 0.52, blue: 1.0), type: .orbital),

        Rocket(name: "Electron", manufacturer: "Rocket Lab", country: "United States / NZ",
               status: .active, firstFlight: "2017", height: "18 m", diameter: "1.2 m",
               mass: "13 t", payload: "300 kg to LEO", thrust: "225 kN", stages: 2,
               successRate: 0.90,
               description: "The small-sat market's most successful dedicated launcher. Electric turbopumps and helicopter booster recovery make Electron uniquely cost-effective.",
               features: ["Electric turbopump Rutherford engines", "Helicopter booster recovery", "Carbon composite structure", "Photon kick stage option", "Rapid manifest capability"],
               specifications: ["Engine": "Rutherford (9×)", "Propellant": "RP-1 / LOX", "Recovery": "Helicopter catch", "Cost/Launch": "~$7.5M", "Launch Site": "NZ / Virginia"],
               accentColor: Color(red: 0.38, green: 0.92, blue: 0.65), type: .smallSat),

        Rocket(name: "Long March 9", manufacturer: "CASC", country: "China",
               status: .inDevelopment, firstFlight: "2028", height: "108 m", diameter: "10 m",
               mass: "4,122 t", payload: "140 t to LEO", thrust: "58 MN", stages: 3,
               successRate: 0.0,
               description: "China's super-heavy crewed Moon and Mars mission rocket. With a 10-metre core and 58 MN of thrust, it rivals the Saturn V in capability.",
               features: ["10 m diameter core stage", "Lunar and Mars mission capable", "Partially reusable design", "YF-130 kerolox engines", "Next-generation Chinese flagship"],
               specifications: ["Engine": "YF-130 (4×)", "Propellant": "Kerosene / LOX", "Core Ø": "10 m", "Boosters": "4–6 strap-ons", "Mission Scope": "Deep space"],
               accentColor: Color(red: 1.0, green: 0.38, blue: 0.42), type: .superHeavy),

        Rocket(name: "Angara A5", manufacturer: "Khrunichev", country: "Russia",
               status: .active, firstFlight: "2014", height: "64 m", diameter: "2.9 m",
               mass: "773 t", payload: "24.5 t to LEO", thrust: "10.5 MN", stages: 3,
               successRate: 0.80,
               description: "Russia's modular heavy-lift platform built from Universal Rocket Modules. Designed to replace legacy Proton rockets with a cleaner, domestic-propellant alternative.",
               features: ["Universal Rocket Module (URM) design", "All-Russian production", "Non-toxic RP-1/LOX propellants", "Multiple configurations", "All-weather launch capability"],
               specifications: ["Engine": "RD-191 (5×)", "Propellant": "RP-1 / LOX", "Configurations": "A3 / A5 / A5V", "Launch Site": "Plesetsk / Vostochny", "Dev. Cost": "$3B+"],
               accentColor: Color(red: 0.68, green: 0.45, blue: 1.0), type: .heavyLift)
    ]

    var filteredRockets: [Rocket] { viewModel.filtered(from: rockets) }

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
                            Image(systemName: "rocket.fill")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, Color(red: 1.0, green: 0.58, blue: 0.28).opacity(0.85)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("Rockets")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text("\(rockets.count) launch vehicles · Tap to explore")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.55))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 14)

                    // Stats row
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            globalStatPill(icon: "rocket.fill",         value: "\(rockets.count)",   label: "Rockets",   color: Color(red: 1.0, green: 0.55, blue: 0.28))
                            globalStatPill(icon: "checkmark.seal.fill", value: "99%",               label: "Best Rate", color: Color(red: 0.25, green: 0.90, blue: 0.52))
                            globalStatPill(icon: "globe",               value: "8",                 label: "Countries", color: Color(red: 0.45, green: 0.72, blue: 1.0))
                            globalStatPill(icon: "arrow.up.forward",    value: "Super Heavy",        label: "Largest",   color: Color(red: 1.0, green: 0.38, blue: 0.38))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                    }
                    .padding(.bottom, 6)

                    // Search bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.45))
                        TextField("Search rockets, manufacturers…", text: $viewModel.searchText)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .tint(Color(red: 1.0, green: 0.58, blue: 0.28))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)

                    // Type filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            TypeFilterChip(
                                label: "All (\(rockets.count))",
                                color: .white,
                                isSelected: viewModel.selectedType == nil
                            ) {
                                withAnimation(.spring(response: 0.34, dampingFraction: 0.75)) {
                                    viewModel.selectedType = nil
                                }
                            }
                            ForEach(RocketType.allCases) { type in
                                let n = rockets.filter { $0.type == type }.count
                                if n > 0 {
                                    TypeFilterChip(
                                        label: "\(type.rawValue) (\(n))",
                                        color: type.color,
                                        isSelected: viewModel.selectedType == type
                                    ) {
                                        withAnimation(.spring(response: 0.34, dampingFraction: 0.75)) {
                                            viewModel.selectedType = viewModel.selectedType == type ? nil : type
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }

                    // Rocket list
                    VStack(spacing: 12) {
                        ForEach(filteredRockets) { rocket in
                            RocketCard(rocket: rocket)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                                    removal: .opacity
                                ))
                        }

                        if filteredRockets.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 36))
                                    .foregroundColor(.white.opacity(0.25))
                                Text("No rockets match your search")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.45))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        }
                    }
                    .animation(.spring(response: 0.40, dampingFraction: 0.80), value: viewModel.selectedType)
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

    private func globalStatPill(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.50))
            }
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(color.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(color.opacity(0.26), lineWidth: 1)
                )
        )
    }
}

struct RocketView_Previews: PreviewProvider {
    static var previews: some View {
        RocketView()
    }
}
