import SwiftUI

// MARK: - Models and Complete Systems Data
struct SpaceTelescope: Identifiable {
    let id = UUID()
    let name: String
    let type: TelescopeType
    let operator_: String
    let orbit: String
    let status: String
    let launchDate: String
    let facts: [String]
    let color: Color
    let wavelengths: String
    let primaryMirror: String
    let rotationMechanism: String
    let turnRate: String
    let pointingAccuracy: String
}

enum TelescopeType: CaseIterable, Identifiable {
    var id: Self { self }
    case optical
    case infrared
    case xray
    case multiSpectral

    var description: String {
        switch self {
        case .optical: return "Optical Telescope"
        case .infrared: return "Infrared Observatory"
        case .xray: return "X-Ray Observatory"
        case .multiSpectral: return "Multi-Spectral Telescope"
        }
    }
}
// MARK: - Space Telescope Data
let spaceTelescopes = [
    SpaceTelescope(
        name: "James Webb Space Telescope",
        type: .infrared,
        operator_: "NASA/ESA/CSA",
        orbit: "Sun-Earth L2",
        status: "Operational",
        launchDate: "December 25, 2021",
        facts: [
            "Largest space telescope ever built",
            "Can observe early universe formation",
            "Primary mirror consists of 18 segments",
            "Tennis court-sized sunshield",
            "Operating temperature of -233°C"
        ],
        color: .orange,
        wavelengths: "0.6-28 micrometers",
        primaryMirror: "6.5 meters",
        rotationMechanism: "Reaction wheels & Fine Steering Mirror",
        turnRate: "1.6°/minute",
        pointingAccuracy: "0.007 arcseconds"
    ),
    SpaceTelescope(
        name: "Hubble Space Telescope",
        type: .optical,
        operator_: "NASA/ESA",
        orbit: "Low Earth Orbit",
        status: "Operational",
        launchDate: "April 24, 1990",
        facts: [
            "Over 1.5 million observations made",
            "Serviceable by astronauts",
            "Travels 7 km per second",
            "Generates 150 gigabits of data weekly",
            "Length of a school bus"
        ],
        color: .blue,
        wavelengths: "0.1-2.4 micrometers",
        primaryMirror: "2.4 meters",
        rotationMechanism: "Reaction Wheels & Gyroscopes",
        turnRate: "90° in 15 minutes",
        pointingAccuracy: "0.01 arcseconds"
    ),
    SpaceTelescope(
        name: "Chandra X-ray Observatory",
        type: .xray,
        operator_: "NASA",
        orbit: "Highly Elliptical",
        status: "Operational",
        launchDate: "July 23, 1999",
        facts: [
            "Most powerful X-ray telescope built",
            "Named after Nobel laureate S. Chandrasekhar",
            "Observes black holes and supernovas",
            "45-hour orbital period",
            "Highly precise pointing system"
        ],
        color: .purple,
        wavelengths: "0.1-10 keV",
        primaryMirror: "1.2 meters",
        rotationMechanism: "Reaction Wheels & Momentum Control",
        turnRate: "0.1°/second",
        pointingAccuracy: "0.5 arcseconds"
    ),
    SpaceTelescope(
        name: "Roman Space Telescope",
        type: .multiSpectral,
        operator_: "NASA",
        orbit: "Sun-Earth L2",
        status: "Development",
        launchDate: "May 2027 (Planned)",
        facts: [
            "Wide field of view instrument",
            "Studies dark energy and exoplanets",
            "100x Hubble's field of view",
            "2.4-meter primary mirror",
            "Advanced coronagraph technology"
        ],
        color: .green,
        wavelengths: "0.5-2.0 micrometers",
        primaryMirror: "2.4 meters",
        rotationMechanism: "Enhanced Reaction Wheels",
        turnRate: "1°/minute",
        pointingAccuracy: "0.01 arcseconds"
    ),
    SpaceTelescope(
        name: "SPHEREx",
        type: .multiSpectral,
        operator_: "NASA/JPL",
        orbit: "Low Earth Orbit",
        status: "Development",
        launchDate: "2025 (Planned)",
        facts: [
            "All-sky spectral survey",
            "Studies universe inflation",
            "Maps water and organic molecules",
            "Novel linear variable filters",
            "Two-year primary mission"
        ],
        color: .cyan,
        wavelengths: "0.75-5.0 micrometers",
        primaryMirror: "20 centimeters",
        rotationMechanism: "Scanning Pattern System",
        turnRate: "0.5°/second",
        pointingAccuracy: "1.0 arcseconds"
    ),
    SpaceTelescope(
        name: "XRISM",
        type: .xray,
        operator_: "JAXA/NASA",
        orbit: "Low Earth Orbit",
        status: "Operational",
        launchDate: "September 2023",
        facts: [
            "X-ray spectroscopy mission",
            "Studies hot universe phenomena",
            "Microcalorimeter technology",
            "Successor to Hitomi",
            "International collaboration"
        ],
        color: .red,
        wavelengths: "0.3-12 keV",
        primaryMirror: "0.45 meters",
        rotationMechanism: "Advanced Pointing System",
        turnRate: "0.25°/second",
        pointingAccuracy: "1.5 arcseconds"
    ),
    SpaceTelescope(
        name: "Euclid",
        type: .optical,
        operator_: "ESA",
        orbit: "Sun-Earth L2",
        status: "Operational",
        launchDate: "July 2023",
        facts: [
            "Maps dark universe distribution",
            "Billion galaxy survey",
            "Visible and near-infrared imaging",
            "Six-year mission duration",
            "Advanced stabilization system"
        ],
        color: .mint,
        wavelengths: "0.55-2.0 micrometers",
        primaryMirror: "1.2 meters",
        rotationMechanism: "Cold Gas Thrusters",
        turnRate: "0.75°/minute",
        pointingAccuracy: "0.05 arcseconds"
        ),
        SpaceTelescope(
            name: "Spitzer Space Telescope",
            type: .infrared,
            operator_: "NASA",
            orbit: "Heliocentric",
            status: "Decommissioned",
            launchDate: "August 25, 2003",
            facts: [
                "Formerly SIRTF",
                "Followed Earth-trailing orbit",
                "Studied cool objects in space",
                "End of mission: January 30, 2020",
                "Operated for over 16 years"
            ],
            color: .teal,
            wavelengths: "3-180 micrometers",
            primaryMirror: "0.85 meters",
            rotationMechanism: "Reaction Wheels",
            turnRate: "0.5°/minute",
            pointingAccuracy: "2.0 arcseconds"
        )
]
// MARK: - Telescope Search Bar
struct TelescopeSearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search Telescopes", text: $text)
                .foregroundColor(.white)
        }
        .padding(8)
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
    }
}

// MARK: - Space Telescope Card
struct TelescopeCard: View {
    let telescope: SpaceTelescope
    @State private var showDetails = false
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0

    var body: some View {
        Button(action: { showDetails.toggle() }) {
            VStack(spacing: 15) {
                // Telescope Visualization
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 70, height: 70)

                    TelescopeCoreView(color: telescope.color, isAnimating: isAnimating)
                        .rotationEffect(.degrees(rotationAngle))

                    if isAnimating {
                        TelescopeBeamEffect(color: telescope.color)
                    }
                }
                .frame(height: 80)

                VStack(alignment: .leading, spacing: 8) {
                    Text(telescope.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(telescope.type.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text(telescope.operator_)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(telescope.color.opacity(0.5), lineWidth: 2)
            )
        }
        .sheet(isPresented: $showDetails) {
            TelescopeDetailView(telescope: telescope)
        }
        .onAppear {
            withAnimation(
                .linear(duration: 20)
                .repeatForever(autoreverses: false)
            ) {
                rotationAngle = 360
            }

            withAnimation(
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Telescope Core View
struct TelescopeCoreView: View {
    let color: Color
    let isAnimating: Bool

    var body: some View {
        ZStack {
            // Main Telescope Body
            Capsule()
                .fill(color)
                .frame(width: 40, height: 15)

            // Primary Mirror
            Circle()
                .fill(color.opacity(0.8))
                .frame(width: 25, height: 25)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
                .offset(x: -15)

            // Solar Panels
            ForEach(0..<2) { i in
                Rectangle()
                    .fill(color.opacity(0.7))
                    .frame(width: 30, height: 8)
                    .offset(x: 15, y: i == 0 ? -15 : 15)
            }
        }
        .scaleEffect(isAnimating ? 1.05 : 1)
    }
}

// MARK: - Telescope Beam Effect
struct TelescopeBeamEffect: View {
    let color: Color

    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Cone()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 60)
                    .offset(x: -35)
                    .rotationEffect(.degrees(Double(index) * 5))
            }
        }
    }
}

struct Cone: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Main Telescope View
struct TelescopeView: View {
    @State private var selectedFilter: TelescopeType? = nil
    @State private var searchText = ""
    @State private var showingWavelengthChart = false
    @State private var parallaxOffset: CGFloat = 0 // For parallax effect if you want to add drag gesture
    @State private var starfieldRotation: Double = 0 // For starfield rotation animation


    var filteredTelescopes: [SpaceTelescope] {
        var telescopes = spaceTelescopes

        if let filter = selectedFilter {
            telescopes = telescopes.filter { $0.type == filter }
        }

        if !searchText.isEmpty {
            telescopes = telescopes.filter { telescope in // Explicitly named parameter 'telescope'
                telescope.name.localizedCaseInsensitiveContains(searchText) ||
                telescope.operator_.localizedCaseInsensitiveContains(searchText)
            }
        }

        return telescopes
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Title
                Text("Space Telescopes")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top) // Add some top padding for visual spacing

                // Search and Filter Section
                VStack(spacing: 15) {
                    TelescopeSearchBar(text: $searchText)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            FilterButton(
                                title: "All",
                                isSelected: selectedFilter == nil
                            ) {
                                selectedFilter = nil
                            }

                            ForEach(TelescopeType.allCases) { type in
                                FilterButton(
                                    title: type.description,
                                    isSelected: selectedFilter == type
                                ) {
                                    selectedFilter = type
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Grid of Telescopes
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(filteredTelescopes) { telescope in
                        TelescopeCard(telescope: telescope)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(
            EnhancedCosmicBackground(
                parallaxOffset: parallaxOffset,
                starfieldRotation: starfieldRotation,
                zoomLevel: 1.0
            )
        )
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                starfieldRotation = 360 // Start starfield rotation animation
            }
        }
        // If you want to add drag gesture for parallax effect (optional)
        /*
        .gesture(
            DragGesture()
                .onChanged { value in
                    parallaxOffset = value.translation.width
                }
                .onEnded { _ in
                    withAnimation(.spring()) {
                        parallaxOffset = 0
                    }
                }
        )
        */
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Space Telescopes") // Keep navigation title for back button text
        .preferredColorScheme(.dark)
    }
}
import SwiftUI

// MARK: - Detail View
struct TelescopeDetailView: View {
    let telescope: SpaceTelescope
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    headerSection

                    // *** CHECK DETAIL VIEW PRESENTATION IN CONSOLE ***
                    Text("TelescopeDetailView is presented for: \(telescope.name)")
                        .onAppear { // Use onAppear to ensure it prints when the view is shown
                            print("TelescopeDetailView is presented for: \(telescope.name)")
                        }
                        .hidden() // Keep the text, but hide it from UI


                    // Tab Selection
                    Picker("Information", selection: $selectedTab) {
                        Text("Overview").tag(0)
                        Text("Technical").tag(1)
                        Text("Features").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Content based on selected tab
                    selectedTabView
                }
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
        VStack(spacing: 10) {
            Text(telescope.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white) // Ensure text color for visibility
            Text(telescope.type.description)
                .foregroundColor(.gray)
        }
        .padding()
    }


    @ViewBuilder
    private var selectedTabView: some View {
        switch selectedTab {
        case 0:
            TelescopeOverviewTab(telescope: telescope)
        case 1:
            TelescopeTechnicalTab(telescope: telescope)
        case 2:
            TelescopeFeaturesTab(telescope: telescope)
        default:
            EmptyView()
        }
    }
}

// MARK: - Detail Tab Views
struct TelescopeOverviewTab: View {
    let telescope: SpaceTelescope

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // *** CHECK OVERVIEW TAB RENDERING & DATA IN CONSOLE ***
            Text("TelescopeOverviewTab is rendering for: \(telescope.name)")
                .onAppear {
                    print("TelescopeOverviewTab is rendering for: \(telescope.name)")
                    print("Operator: \(telescope.operator_)")
                }
                .hidden() // Hide in UI

            InfoRow(title: "Type", value: telescope.type.description)
            InfoRow(title: "Operator", value: telescope.operator_)
            InfoRow(title: "Orbit", value: telescope.orbit)
            InfoRow(title: "Status", value: telescope.status)
            InfoRow(title: "Launch", value: telescope.launchDate)
        }
        .padding()
    }
}

struct TelescopeTechnicalTab: View {
    let telescope: SpaceTelescope

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // *** CHECK TECHNICAL TAB RENDERING & DATA IN CONSOLE ***
            Text("TelescopeTechnicalTab is rendering for: \(telescope.name)")
                .onAppear {
                    print("TelescopeTechnicalTab is rendering for: \(telescope.name)")
                    print("Wavelengths: \(telescope.wavelengths)")
                }
                .hidden() // Hide from UI

            InfoRow(title: "Wavelengths", value: telescope.wavelengths)
            InfoRow(title: "Mirror Size", value: telescope.primaryMirror)
            InfoRow(title: "Pointing", value: telescope.pointingAccuracy)
            InfoRow(title: "Turn Rate", value: telescope.turnRate)
            InfoRow(title: "Movement", value: telescope.rotationMechanism)
        }
        .padding()
    }
}

struct TelescopeFeaturesTab: View {
    let telescope: SpaceTelescope

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // *** CHECK FEATURES TAB RENDERING & DATA IN CONSOLE ***
            Text("TelescopeFeaturesTab is rendering for: \(telescope.name)")
                .onAppear {
                    print("TelescopeFeaturesTab is rendering for: \(telescope.name)")
                    print("Facts Count: \(telescope.facts.count)")
                }
                .hidden() // Hide from UI

            ForEach(telescope.facts, id: \.self) { fact in
                HStack(alignment: .top) {
                    Text("•")
                        .foregroundColor(telescope.color)
                    Text(fact)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
    }
}
// MARK: - Preview
struct TelescopeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TelescopeView()
        }
    }
}
