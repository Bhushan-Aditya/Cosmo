import SwiftUI

// MARK: - Models and Complete Systems Data
struct SpaceStation: Identifiable {
    let id = UUID()
    let name: String
    let type: StationType
    let operator_: String
    let orbit: String
    let status: String
    let launchDate: String
    let facts: [String]
    let color: Color
    let dimensions: String
    let crew: String
}

enum StationType {
    case operational
    case planned
    case retired

    var description: String {
        switch self {
        case .operational: return "Currently Operational"
        case .planned: return "In Development"
        case .retired: return "Historical Station"
        }
    }
}

// MARK: - Space Station Data
let spaceStations = [
    SpaceStation(
        name: "International Space Station",
        type: .operational,
        operator_: "Multi-national",
        orbit: "Low Earth Orbit (400 km)",
        status: "Active",
        launchDate: "1998",
        facts: [
            "Continuously inhabited since 2000",
            "Largest artificial body in orbit",
            "Visible from Earth with naked eye",
            "Travels at 7.66 km/s",
            "International collaboration of 15+ nations"
        ],
        color: .blue,
        dimensions: "109 x 51 meters",
        crew: "7 (typical)"
    ),
    SpaceStation(
        name: "Tiangong Space Station",
        type: .operational,
        operator_: "CNSA (China)",
        orbit: "Low Earth Orbit (340-450 km)",
        status: "Active",
        launchDate: "2021",
        facts: [
            "China's first long-term space station",
            "Modular design with three sections",
            "Supports crew of 3",
            "Features robotic arm",
            "Regular cargo and crew missions"
        ],
        color: .red,
        dimensions: "55 x 39 meters",
        crew: "3 (typical)"
    ),
    SpaceStation(
        name: "Axiom Station",
        type: .planned,
        operator_: "Axiom Space",
        orbit: "Low Earth Orbit",
        status: "In Development",
        launchDate: "2026 (Planned)",
        facts: [
            "First commercial space station",
            "Initially attached to ISS",
            "Supports space tourism",
            "Research and manufacturing capabilities",
            "Eventual ISS replacement"
        ],
        color: .purple,
        dimensions: "Modular design",
        crew: "4-8 (planned)"
    ),
    SpaceStation(
        name: "Orbital Reef",
        type: .planned,
        operator_: "Blue Origin & Sierra Space",
        orbit: "Low Earth Orbit",
        status: "In Development",
        launchDate: "2027 (Planned)",
        facts: [
            "Commercial space business park",
            "Mixed-use facility",
            "Advanced life support systems",
            "Research and manufacturing focus",
            "Supports space tourism"
        ],
        color: .cyan,
        dimensions: "Expandable design",
        crew: "10 (planned)"
    ),
    SpaceStation(
        name: "Mir (Historical)",
        type: .retired,
        operator_: "Soviet/Russian",
        orbit: "Low Earth Orbit",
        status: "Deorbited 2001",
        launchDate: "1986",
        facts: [
            "First modular space station",
            "Operated for 15 years",
            "Hosted 104 astronauts",
            "Conducted over 23,000 experiments",
            "Set space endurance records"
        ],
        color: .gray,
        dimensions: "19 x 31 meters",
        crew: "3 (typical)"
    ),
    SpaceStation(
        name: "Starlab",
        type: .planned,
        operator_: "Nanoracks & Lockheed Martin",
        orbit: "Low Earth Orbit",
        status: "In Development",
        launchDate: "2028 (Planned)",
        facts: [
            "Commercial research station",
            "Single-launch deployment",
            "Advanced lab facilities",
            "Artificial gravity studies",
            "Biology research focus"
        ],
        color: .green,
        dimensions: "340 cubic meters",
        crew: "4 (planned)"
    ),
    SpaceStation(
        name: "Gateway",
        type: .planned,
        operator_: "NASA & International Partners",
        orbit: "Lunar Orbit",
        status: "In Development",
        launchDate: "2025 (Initial Launch)",
        facts: [
            "Lunar space station",
            "Support for Artemis missions",
            "Deep space research platform",
            "International collaboration",
            "Waypoint for Mars missions"
        ],
        color: .orange,
        dimensions: "Modular design",
        crew: "4 (planned)"
    ),
    SpaceStation(
        name: "Haven-1",
        type: .planned,
        operator_: "Vast Space",
        orbit: "Low Earth Orbit",
        status: "In Development",
        launchDate: "2025 (Planned)",
        facts: [
            "Commercial space station",
            "Artificial gravity capability",
            "SpaceX launch partnership",
            "Research facilities",
            "Tourism potential"
        ],
        color: .mint,
        dimensions: "100 cubic meters",
        crew: "4 (planned)"
    )
]
// MARK: - Space Station Card
struct SpaceStationCard: View {
    let station: SpaceStation
    @State private var showDetails = false
    @State private var isAnimating = false

    var body: some View {
        Button(action: { showDetails.toggle() }) {
            VStack(spacing: 15) {
                // Animated Station Visualization
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 60, height: 60)
                        .overlay(
                            ZStack {
                                // Solar Panel Animation
                                ForEach(0..<2) { i in
                                    Rectangle()
                                        .fill(station.color.opacity(0.7))
                                        .frame(width: 40, height: 3)
                                        .offset(x: isAnimating ? 5 : -5)
                                        .rotationEffect(.degrees(Double(i) * 180))
                                }

                                // Station Core
                                Circle()
                                    .fill(station.color)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                    )
                            }
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(station.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(station.type.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text(station.operator_)
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
                    .stroke(station.color.opacity(0.5), lineWidth: 2)
            )
        }
        .sheet(isPresented: $showDetails) {
            SpaceStationDetailView(station: station)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Space Station Detail View
struct SpaceStationDetailView: View {
    let station: SpaceStation
    @Environment(\.presentationMode) var presentationMode
    @State private var isAnimating = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Animated Station Visualization
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 200, height: 200)
                            .overlay(
                                ZStack {
                                    // Orbiting Effect
                                    ForEach(0..<3) { index in
                                        Circle()
                                            .stroke(station.color.opacity(0.3), lineWidth: 2)
                                            .frame(width: 160 + CGFloat(index * 20))
                                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                                            .animation(
                                                Animation.linear(duration: Double(4 - index))
                                                    .repeatForever(autoreverses: false),
                                                value: isAnimating
                                            )
                                    }

                                    // Station Core
                                    StationCoreView(color: station.color)
                                }
                            )
                    }
                    .frame(height: 250)

                    // Station Information
                    VStack(alignment: .leading, spacing: 15) {
                        InfoRow(title: "Type", value: station.type.description)
                        InfoRow(title: "Operator", value: station.operator_)
                        InfoRow(title: "Orbit", value: station.orbit)
                        InfoRow(title: "Status", value: station.status)
                        InfoRow(title: "Launch", value: station.launchDate)
                        InfoRow(title: "Size", value: station.dimensions)
                        InfoRow(title: "Crew", value: station.crew)
                    }
                    .padding()

                    // Key Features
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Key Features")
                            .font(.headline)
                            .foregroundColor(.white)

                        ForEach(station.facts, id: \.self) { fact in
                            HStack(alignment: .top) {
                                Text("•")
                                    .foregroundColor(station.color)
                                Text(fact)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(station.name)
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
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Supporting Views
struct StationCoreView: View {
    let color: Color

    var body: some View {
        ZStack {
            // Main Station Body
            RoundedRectangle(cornerRadius: 5)
                .fill(color)
                .frame(width: 60, height: 30)

            // Solar Panels
            ForEach(0..<2) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color.opacity(0.7))
                    .frame(width: 80, height: 20)
                    .offset(x: i == 0 ? -70 : 70)
            }
        }
    }
}
// MARK: - Space Station Intro View
struct SpaceStationIntroView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 20) {
            // Animated Space Station Logo
            ZStack {
                // Orbiting Circles
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                        .frame(width: 100 + CGFloat(index * 20))
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(
                            Animation.linear(duration: Double(4 - index))
                                .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                }

                // Station Icon
                Text("🛸")
                    .font(.system(size: 60))
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 2)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            .frame(height: 120)

            Text("Space Stations")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)

            Text("Orbital Research & Exploration")
                .font(.title3)
                .foregroundColor(.gray)
                .padding(.bottom, 5)

            Text("Permanent human presence in space through advanced orbital facilities supporting scientific research, technological development, and space exploration.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.gray)

            // Quick Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                QuickStatView(value: "400", unit: "km", label: "Orbit Height")
                QuickStatView(value: "27,600", unit: "km/h", label: "Orbital Speed")
                QuickStatView(value: "22", unit: "Years", label: "Continuous Presence")
            }
            .padding()

            // Feature Cards Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                SpaceStationFeatureCard(emoji: "🔬", text: "Scientific Research")
                SpaceStationFeatureCard(emoji: "🛰️", text: "Earth Observation")
                SpaceStationFeatureCard(emoji: "👨‍🚀", text: "Human Spaceflight")
                SpaceStationFeatureCard(emoji: "🚀", text: "Space Exploration")
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
        )
        .padding()
        .onAppear {
            isAnimating = true
        }
    }
}

struct SpaceStationFeatureCard: View {
    let emoji: String
    let text: String

    var body: some View {
        HStack {
            Text(emoji)
                .font(.title2)
            Text(text)
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}

// MARK: - Main Space Station View
struct SpaceStationView: View {
    @State private var selectedFilter: StationType?
    @State private var searchText = ""
    @State private var isAnimating = false

    var filteredStations: [SpaceStation] {
        var stations = spaceStations

        if let filter = selectedFilter {
            stations = stations.filter { $0.type == filter }
        }

        if !searchText.isEmpty {
            stations = stations.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }

        return stations
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                SpaceStationIntroView()

                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)

                // Filter Buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        FilterButton(title: "All", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        FilterButton(title: "Operational", isSelected: selectedFilter == .operational) {
                            selectedFilter = .operational
                        }
                        FilterButton(title: "Planned", isSelected: selectedFilter == .planned) {
                            selectedFilter = .planned
                        }
                        FilterButton(title: "Historical", isSelected: selectedFilter == .retired) {
                            selectedFilter = .retired
                        }
                    }
                    .padding(.horizontal)
                }

                // Grid of Space Stations
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(filteredStations) { station in
                        SpaceStationCard(station: station)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal)
                .animation(.spring(), value: selectedFilter)
            }
        }
        .background(
            ZStack {
                Color.black

                // Animated Star Field
                StarFieldView() // <------ REMOVE THIS LINE

                // Animated background effects
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .scaleEffect(CGFloat.random(in: 1.0...2.0))
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        )
                        .blur(radius: 50)
                }
            }
            .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Space Stations")
        .preferredColorScheme(.dark)
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search stations...", text: $text)
                .foregroundColor(.white)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}

// MARK: - Preview
struct SpaceStationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SpaceStationView()
        }
    }
}
