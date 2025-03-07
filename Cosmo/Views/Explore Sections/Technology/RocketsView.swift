import SwiftUI

// MARK: - EnhancedCosmicBackground (Implementation from previous responses)

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
    let color: Color
    let type: RocketType
}

enum RocketStatus: String {
    case active = "Active"
    case inDevelopment = "In Development"
    case retired = "Retired"
    case testing = "Testing"

    var color: Color {
        switch self {
        case .active: return .green
        case .inDevelopment: return .blue
        case .retired: return .gray
        case .testing: return .orange
        }
    }
}

enum RocketType: String, CaseIterable, Identifiable {
    case orbital = "Orbital"
    case suborbital = "Suborbital"
    case heavyLift = "Heavy Lift"
    case superHeavy = "Super Heavy"
    case smallSat = "Small Sat"

    var id: Self { self }

    var icon: String {
        switch self {
        case .orbital: return "airplane.circle.fill"
        case .suborbital: return "airplane"
        case .heavyLift: return "rocket.fill"
        case .superHeavy: return "bolt.fill"
        case .smallSat: return "satelliteantennas"
        }
    }
}

// MARK: - Mock Data
let rockets = [
    Rocket(
        name: "New Glenn",
        manufacturer: "Blue Origin",
        country: "United States",
        status: .inDevelopment,
        firstFlight: "2025",
        height: "98m",
        diameter: "7m",
        mass: "1000t",
        payload: "45t to LEO",
        thrust: "17.1 MN",
        stages: 2,
        successRate: 0.0,
        description: "Partially reusable heavy-lift orbital launch vehicle designed for high reliability and rapid reuse",
        features: [
            "Reusable first stage",
            "BE-4 engines",
            "Large payload fairing",
            "Designed for 25 reuses",
            "Maritime landing"
        ],
        specifications: [
            "Engine Type": "BE-4",
            "Propellant": "LNG/LOX",
            "Landing": "Maritime platform",
            "Recovery Method": "Propulsive",
            "Development Status": "Final testing"
        ],
        color: .blue,
        type: .heavyLift
    ),

    Rocket(
        name: "Ariane 6",
        manufacturer: "ArianeGroup",
        country: "European Union",
        status: .testing,
        firstFlight: "2024",
        height: "63m",
        diameter: "5.4m",
        mass: "900t",
        payload: "21.6t to LEO",
        thrust: "15.2 MN",
        stages: 2,
        successRate: 0.0,
        description: "Next-generation European heavy-lift launch vehicle designed for versatility and cost efficiency",
        features: [
            "Modular design",
            "Multiple configurations",
            "Solid rocket boosters",
            "European independence",
            "Commercial focus"
        ],
        specifications: [
            "Engine Type": "Vulcain 2.1",
            "Propellant": "LH2/LOX",
            "Configurations": "A62/A64",
            "Launch Site": "French Guiana",
            "Cost per Launch": "€75M"
        ],
        color: .indigo,
        type: .heavyLift
    ),

    Rocket(
        name: "Vulcan Centaur",
        manufacturer: "ULA",
        country: "United States",
        status: .active,
        firstFlight: "2024",
        height: "67m",
        diameter: "5.4m",
        mass: "546t",
        payload: "27t to LEO",
        thrust: "9.8 MN",
        stages: 2,
        successRate: 1.0,
        description: "Next-generation American launch system replacing Atlas V and Delta IV",
        features: [
            "BE-4 engines",
            "Solid rocket boosters",
            "Advanced Centaur stage",
            "Multiple configurations",
            "National security focus"
        ],
        specifications: [
            "Engine Type": "BE-4",
            "Upper Stage": "Centaur V",
            "Booster Recovery": "SMART Reuse",
            "Max Boosters": "6",
            "Fairing Size": "5.4m"
        ],
        color: .mint,
        type: .heavyLift
    ),

    Rocket(
        name: "H3",
        manufacturer: "JAXA/MHI",
        country: "Japan",
        status: .active,
        firstFlight: "2024",
        height: "63m",
        diameter: "5.2m",
        mass: "574t",
        payload: "6.5t to GTO",
        thrust: "8.9 MN",
        stages: 2,
        successRate: 0.5,
        description: "Japan's new flagship launch vehicle replacing H-IIA/B rockets",
        features: [
            "LE-9 engines",
            "Solid boosters",
            "Multiple variants",
            "Cost reduction focus",
            "Domestic production"
        ],
        specifications: [
            "Engine Type": "LE-9",
            "Propellant": "LH2/LOX",
            "Variants": "H3-22/24/30",
            "Cost Target": "$50M",
            "Launch Site": "Tanegashima"
        ],
        color: .red,
        type: .orbital
    ),

    Rocket(
        name: "Neutron",
        manufacturer: "Rocket Lab",
        country: "United States",
        status: .inDevelopment,
        firstFlight: "2025",
        height: "40m",
        diameter: "7m",
        mass: "480t",
        payload: "15t to LEO",
        thrust: "5.4 MN",
        stages: 2,
        successRate: 0.0,
        description: "Reusable medium-lift launch vehicle optimized for satellite constellation deployment",
        features: [
            "Fully reusable",
            "Archimedes engines",
            "Automated catching",
            "Carbon composite",
            "Rapid reuse"
        ],
        specifications: [
            "Engine Type": "Archimedes",
            "Propellant": "LOX/CH4",
            "Recovery": "Catch system",
            "Material": "Carbon composite",
            "Target Cost": "$30M"
        ],
        color: .black,
        type: .orbital
    ),

    Rocket(
        name: "Long March 9",
        manufacturer: "CASC",
        country: "China",
        status: .inDevelopment,
        firstFlight: "2026",
        height: "108m",
        diameter: "10m",
        mass: "4122t",
        payload: "140t to LEO",
        thrust: "58 MN",
        stages: 3,
        successRate: 0.0,
        description: "China's super heavy-lift launch vehicle for deep space missions",
        features: [
            "Massive payload capacity",
            "Moon mission capable",
            "Mars mission capable",
            "Multiple variants",
            "Advanced propulsion"
        ],
        specifications: [
            "Engine Type": "YF-130",
            "Propellant": "Kerolox",
            "Core Diameter": "10m",
            "Boosters": "4-6",
            "Mission Scope": "Deep Space"
        ],
        color: .red,
        type: .superHeavy
    ),

    Rocket(
        name: "Electron",
        manufacturer: "Rocket Lab",
        country: "United States/New Zealand",
        status: .active,
        firstFlight: "2017",
        height: "18m",
        diameter: "1.2m",
        mass: "13t",
        payload: "300kg to LEO",
        thrust: "225 kN",
        stages: 2,
        successRate: 0.90,
        description: "Small-lift launch vehicle designed for the small satellite market",
        features: [
            "Rapid launch capability",
            "Electric pump-fed engines",
            "Carbon composite structure",
            "Helicopter recovery",
            "Private launch sites"
        ],
        specifications: [
            "Engine Type": "Rutherford",
            "Propellant": "RP-1/LOX",
            "Recovery": "Helicopter catch",
            "Launch Rate": "Monthly",
            "Cost": "$7.5M"
        ],
        color: .black,
        type: .smallSat
    ),

    Rocket(
        name: "Terran R",
        manufacturer: "Relativity Space",
        country: "United States",
        status: .inDevelopment,
        firstFlight: "2026",
        height: "66m",
        diameter: "5m",
        mass: "250t",
        payload: "23.5t to LEO",
        thrust: "7.8 MN",
        stages: 2,
        successRate: 0.0,
        description: "Fully reusable, 3D-printed launch vehicle for medium-lift missions",
        features: [
            "3D printed structure",
            "Fully reusable",
            "Methane powered",
            "Automated manufacturing",
            "Rapid iteration design"
        ],
        specifications: [
            "Engine Type": "Aeon R",
            "Propellant": "LCH4/LOX",
            "Manufacturing": "3D printing",
            "Target Cost": "$40M",
            "Production Time": "60 days"
        ],
        color: .gray,
        type: .orbital
    ),

    Rocket(
        name: "Prime",
        manufacturer: "Orbex",
        country: "United Kingdom",
        status: .inDevelopment,
        firstFlight: "2024",
        height: "19m",
        diameter: "1.3m",
        mass: "18t",
        payload: "180kg to LEO",
        thrust: "70 kN",
        stages: 2,
        successRate: 0.0,
        description: "Environmentally sustainable small satellite launch vehicle",
        features: [
            "Bio-propane fuel",
            "Carbon fiber structure",
            "Zero debris mission",
            "Portable launch ops",
            "European manufacturing"
        ],
        specifications: [
            "Engine Type": "Orbex LP1",
            "Propellant": "Bio-propane/LOX",
            "Carbon Footprint": "-96%",
            "Launch Site": "Scotland",
            "Target Cost": "$12M"
        ],
        color: .green,
        type: .smallSat
    ),

    Rocket(
        name: "Angara A5",
        manufacturer: "Khrunichev",
        country: "Russia",
        status: .active,
        firstFlight: "2014",
        height: "64m",
        diameter: "2.9m",
        mass: "773t",
        payload: "24.5t to LEO",
        thrust: "10.5 MN",
        stages: 3,
        successRate: 0.80,
        description: "Heavy-lift launch vehicle replacing several legacy Russian rockets",
        features: [
            "Universal rocket modules",
            "Multiple configurations",
            "Domestic production",
            "Environmental safety",
            "All-weather capability"
        ],
        specifications: [
            "Engine Type": "RD-191",
            "Propellant": "RP-1/LOX",
            "Configurations": "A3/A5/A5V",
            "Launch Site": "Plesetsk",
            "Development Cost": "$3B"
        ],
        color: .blue,
        type: .heavyLift
    )
]

// MARK: - Main Rocket View
struct RocketView: View {
    @StateObject private var viewModel = RocketViewModel()
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    @State private var zoomLevel: Double = 1.0

    var body: some View {
        ZStack {
            // Background
            EnhancedCosmicBackground(
                parallaxOffset: parallaxOffset,
                starfieldRotation: starfieldRotation,
                zoomLevel: zoomLevel
            )

            // Content
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    Text("Rockets")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top)

                    // Header Statistics
                    RocketStatsHeader()

                    // Search and Filter
                    SearchAndFilterBar(
                        searchText: $viewModel.searchText,
                        selectedType: $viewModel.selectedType
                    )

                    // Rockets Grid
                    LazyVGrid(
                        columns: [GridItem(.flexible())],
                        spacing: 16
                    ) {
                        ForEach(viewModel.filteredRockets) { rocket in
                            RocketCard(rocket: rocket)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Rockets")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear {
            startCosmicAnimations()
        }
    }

    private func startCosmicAnimations() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            starfieldRotation = 360
        }
    }
}



// MARK: - ViewModel
final class RocketViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedType: RocketType? = nil

    var filteredRockets: [Rocket] {
        rockets.filter { rocket in
            let typeMatch = selectedType == nil || rocket.type == selectedType
            let searchMatch = searchText.isEmpty ||
                rocket.name.localizedCaseInsensitiveContains(searchText) ||
                rocket.manufacturer.localizedCaseInsensitiveContains(searchText)
            return typeMatch && searchMatch
        }
    }
}

// MARK: - Stats Header
struct RocketStatsHeader: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 30) {
                StatCard(
                    icon: "rocket.fill",
                    value: "142",
                    label: "Launches"
                )
                StatCard(
                    icon: "checkmark.circle.fill",
                    value: "95%",
                    label: "Success Rate"
                )
                StatCard(
                    icon: "globe",
                    value: "12",
                    label: "Countries"
                )
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Search and Filter Bar
struct SearchAndFilterBar: View {
    @Binding var searchText: String
    @Binding var selectedType: RocketType?

    var body: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search Rockets", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
            }
            .padding(8)
            .background(Color.black.opacity(0.3))
            .cornerRadius(8)
            .padding(.horizontal)

            // Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterPill(
                        title: "All",
                        isSelected: selectedType == nil
                    ) {
                        selectedType = nil
                    }

                    ForEach(RocketType.allCases) { type in
                        FilterPill(
                            title: type.rawValue,
                            icon: type.icon,
                            isSelected: selectedType == type
                        ) {
                            selectedType = type
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Filter Pill
struct FilterPill: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue.opacity(0.3) : Color.black.opacity(0.3))
            .foregroundColor(isSelected ? .blue : .gray)
            .cornerRadius(20)
        }
    }
}
// MARK: - Rocket Card
struct RocketCard: View {
    let rocket: Rocket
    @State private var showDetails = false
    @State private var isHovered = false

    var body: some View {
        Button(action: { showDetails.toggle() }) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                headerSection

                // Main Info
                mainInfoSection

                // Stats Grid
                statsGridSection

                // Footer
                footerSection
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(rocket.color.opacity(isHovered ? 0.5 : 0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetails) {
            RocketDetailView(rocket: rocket)
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(rocket.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(rocket.manufacturer)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            StatusBadge(status: rocket.status)
        }
    }

    private var mainInfoSection: some View {
        HStack(spacing: 20) {
            RocketStat(
                icon: "ruler",
                value: rocket.height,
                label: "Height"
            )
            RocketStat(
                icon: "scale.3d",
                value: rocket.mass,
                label: "Mass"
            )
            RocketStat(
                icon: "bolt.fill",
                value: rocket.thrust,
                label: "Thrust"
            )
        }
    }

    private var statsGridSection: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 12
        ) {
            StatBox(title: "Success Rate", value: "\(Int(rocket.successRate * 100))%")
            StatBox(title: "First Flight", value: rocket.firstFlight)
            StatBox(title: "Stages", value: "\(rocket.stages)")
            StatBox(title: "Payload", value: rocket.payload)
        }
    }

    private var footerSection: some View {
        HStack {
            Text(rocket.type.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(rocket.color.opacity(0.2))
                .foregroundColor(rocket.color)
                .cornerRadius(8)

            Spacer()

            Text("View Details")
                .font(.caption)
                .foregroundColor(.blue)
        }
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: RocketStatus

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)

            Text(status.rawValue)
                .font(.caption)
                .foregroundColor(status.color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status.color.opacity(0.2))
        .cornerRadius(12)
    }
}

// MARK: - Rocket Stat
struct RocketStat: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.gray)

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)

            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Stat Box
struct StatBox: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
        .cornerRadius(8)
    }
}

// MARK: - Rocket Detail View
struct RocketDetailView: View {
    let rocket: Rocket
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Tab Selection
                    Picker("Information", selection: $selectedTab) {
                        Text("Overview").tag(0)
                        Text("Specs").tag(1)
                        Text("Features").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Content based on selected tab
                    TabContent(
                        selectedTab: selectedTab,
                        rocket: rocket
                    )
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            StatusBadge(status: rocket.status)

            Text(rocket.name)
                .font(.title)
                .fontWeight(.bold)

            Text(rocket.manufacturer)
                .foregroundColor(.gray)

            Text(rocket.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

// MARK: - Tab Content
struct TabContent: View {
    let selectedTab: Int
    let rocket: Rocket

    var body: some View {
        VStack(spacing: 20) {
            switch selectedTab {
            case 0:
                OverviewTab(rocket: rocket)
            case 1:
                SpecificationsTab(rocket: rocket)
            case 2:
                FeaturesTab(rocket: rocket)
            default:
                EmptyView()
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Tab Views
struct OverviewTab: View {
    let rocket: Rocket

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            InfoRow(title: "Country", value: rocket.country)
            InfoRow(title: "First Flight", value: rocket.firstFlight)
            InfoRow(title: "Height", value: rocket.height)
            InfoRow(title: "Diameter", value: rocket.diameter)
            InfoRow(title: "Mass", value: rocket.mass)
            InfoRow(title: "Payload Capacity", value: rocket.payload)
            InfoRow(title: "Success Rate", value: "\(Int(rocket.successRate * 100))%")
        }
    }
}

struct SpecificationsTab: View {
    let rocket: Rocket

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(rocket.specifications.keys.sorted()), id: \.self) { key in
                if let value = rocket.specifications[key] {
                    InfoRow(title: key, value: value)
                }
            }
        }
    }
}

struct FeaturesTab: View {
    let rocket: Rocket
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(rocket.features, id: \.self) { feature in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(rocket.color)
                    
                    Text(feature)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// MARK: - Preview
struct RocketView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RocketView()
        }
    }
}
