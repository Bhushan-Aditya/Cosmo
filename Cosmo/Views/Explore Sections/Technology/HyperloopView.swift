import SwiftUI


// MARK: - Models and Complete Systems Data
struct HyperloopSystem: Identifiable {
    let id = UUID()
    let name: String
    let type: HyperloopType
    let location: String
    let speed: String
    let status: String
    let completion: String
    let facts: [String]
    let color: Color
    let length: String
}

enum HyperloopType {
    case operational
    case testing
    case proposed

    var description: String {
        switch self {
        case .operational: return "Operational System"
        case .testing: return "Testing Phase"
        case .proposed: return "Proposed Project"
        }
    }
}

// MARK: - All Hyperloop Systems
let hyperloopSystems = [
    HyperloopSystem(
        name: "Virgin Hyperloop",
        type: .testing,
        location: "Nevada, USA",
        speed: "1080 km/h",
        status: "Testing",
        completion: "2027 (Expected)",
        facts: [
            "First human passenger test completed",
            "Uses magnetic levitation",
            "Vacuum sealed tubes",
            "Zero direct emissions",
            "Autonomous operation"
        ],
        color: .red,
        length: "500 meters (Test Track)"
    ),
    HyperloopSystem(
        name: "Hyperloop TT",
        type: .testing,
        location: "Toulouse, France",
        speed: "1200 km/h",
        status: "Development",
        completion: "2026 (Planned)",
        facts: [
            "Full-scale test track",
            "Passive magnetic levitation",
            "AI-powered system",
            "Solar power integration",
            "Smart thermal management"
        ],
        color: .blue,
        length: "320 meters (Test Track)"
    ),
    HyperloopSystem(
        name: "Mumbai-Pune Hyperloop",
        type: .proposed,
        location: "Maharashtra, India",
        speed: "1100 km/h",
        status: "Planning",
        completion: "2028 (Proposed)",
        facts: [
            "First commercial route in India",
            "Reduces travel time to 25 minutes",
            "Digital backbone integration",
            "Expected to carry 16,000 passengers/hour",
            "Environmental impact reduction"
        ],
        color: .orange,
        length: "117.5 kilometers (Planned)"
    ),
    HyperloopSystem(
        name: "Dubai-Abu Dhabi Hyperloop",
        type: .proposed,
        location: "UAE",
        speed: "1130 km/h",
        status: "Design Phase",
        completion: "2030 (Proposed)",
        facts: [
            "Connects major UAE cities",
            "12-minute journey time",
            "Smart city integration",
            "Desert-optimized design",
            "Luxury passenger pods"
        ],
        color: .yellow,
        length: "150 kilometers (Planned)"
    ),
    HyperloopSystem(
        name: "Great Lakes Hyperloop",
        type: .proposed,
        location: "Chicago-Cleveland-Pittsburgh, USA",
        speed: "1080 km/h",
        status: "Feasibility Study",
        completion: "2029 (Proposed)",
        facts: [
            "Multi-city connectivity",
            "Weather-resistant design",
            "Economic corridor development",
            "Cargo transport capability",
            "Interstate cooperation"
        ],
        color: .green,
        length: "773 kilometers (Planned)"
    ),
    HyperloopSystem(
        name: "European Hyperloop",
        type: .testing,
        location: "Netherlands",
        speed: "1000 km/h",
        status: "Testing",
        completion: "2028 (Expected)",
        facts: [
            "European standardization pioneer",
            "Cross-border operation planned",
            "Sustainable energy focus",
            "Urban integration design",
            "Multi-modal transport hub"
        ],
        color: .purple,
        length: "2.7 kilometers (Test Track)"
    ),
    HyperloopSystem(
        name: "Canadian HyperCan",
        type: .proposed,
        location: "Toronto-Montreal Corridor",
        speed: "1000 km/h",
        status: "Initial Planning",
        completion: "2031 (Proposed)",
        facts: [
            "All-weather operation capability",
            "Bilingual service interface",
            "Green energy commitment",
            "High-speed cargo service",
            "Tourism corridor development"
        ],
        color: .cyan,
        length: "540 kilometers (Planned)"
    ),
    HyperloopSystem(
        name: "China Hyperloop",
        type: .testing,
        location: "Guizhou Province, China",
        speed: "1100 km/h",
        status: "Development",
        completion: "2025 (Expected)",
        facts: [
            "Indigenous technology development",
            "High-altitude adaptation",
            "Advanced passenger security",
            "Smart scheduling system",
            "Rural connectivity focus"
        ],
        color: .mint,
        length: "1.5 kilometers (Test Track)"
    )
]
// MARK: - Hyperloop Card
struct HyperloopCard: View {
    let hyperloop: HyperloopSystem
    @State private var showDetails = false
    @State private var isAnimating = false

    var body: some View {
        Button(action: { showDetails.toggle() }) {
            VStack(spacing: 15) {
                // Animated Hyperloop Pod Visualization
                ZStack {
                    Capsule()
                        .fill(Color.black)
                        .frame(width: 40, height: 20)
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    hyperloop.color.opacity(0.7),
                                    hyperloop.color.opacity(0),
                                    Color.clear
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .offset(x: isAnimating ? 40 : -40)
                        )
                        .overlay(
                            Capsule()
                                .stroke(hyperloop.color.opacity(0.5), lineWidth: 2)
                        )
                }
                .frame(width: 60, height: 60)

                VStack(alignment: .leading, spacing: 8) {
                    Text(hyperloop.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(hyperloop.type.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text(hyperloop.location)
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
                    .stroke(hyperloop.color.opacity(0.5), lineWidth: 2)
            )
        }
        .sheet(isPresented: $showDetails) {
            HyperloopDetailView(hyperloop: hyperloop)
        }
        .onAppear {
            withAnimation(
                .linear(duration: 2)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Hyperloop Detail View
struct HyperloopDetailView: View {
    let hyperloop: HyperloopSystem
    @Environment(\.presentationMode) var presentationMode
    @State private var isAnimating = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Animated Hyperloop Visualization
                    ZStack {
                        Capsule()
                            .fill(Color.black)
                            .frame(width: 200, height: 60)
                            .overlay(
                                ZStack {
                                    ForEach(0..<3) { index in
                                        Capsule()
                                            .stroke(hyperloop.color.opacity(0.3), lineWidth: 2)
                                            .scaleEffect(x: isAnimating ? 1.2 : 1, y: 1)
                                            .opacity(isAnimating ? 0 : 1)
                                            .animation(
                                                Animation.easeOut(duration: 1.5)
                                                    .repeatForever(autoreverses: false)
                                                    .delay(Double(index) * 0.3),
                                                value: isAnimating
                                            )
                                    }
                                }
                            )
                    }
                    .frame(height: 200)

                    VStack(alignment: .leading, spacing: 15) {
                        InfoRow(title: "Type", value: hyperloop.type.description)
                        InfoRow(title: "Location", value: hyperloop.location)
                        InfoRow(title: "Speed", value: hyperloop.speed)
                        InfoRow(title: "Status", value: hyperloop.status)
                        InfoRow(title: "Completion", value: hyperloop.completion)
                        InfoRow(title: "Length", value: hyperloop.length)
                    }
                    .padding()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Key Features")
                            .font(.headline)
                            .foregroundColor(.white)

                        ForEach(hyperloop.facts, id: \.self) { fact in
                            HStack(alignment: .top) {
                                Text("•")
                                    .foregroundColor(hyperloop.color)
                                Text(fact)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(hyperloop.name)
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
// MARK: - Hyperloop Intro View
struct HyperloopIntroView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 20) {
            // Animated Logo
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .scaleEffect(isAnimating ? 1.2 : 1)
                    .opacity(isAnimating ? 0.7 : 0.3)

                Text("🚄")
                    .font(.system(size: 60))
                    .offset(x: isAnimating ? 20 : -20)
            }
            .padding()
            .animation(
                Animation.easeInOut(duration: 2)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )

            Text("Hyperloop")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)

            Text("Next Generation Transportation")
                .font(.title3)
                .foregroundColor(.gray)
                .padding(.bottom, 5)

            Text("Ultra-high-speed, sustainable transport system utilizing low-pressure tubes and magnetic levitation technology.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.gray)

            // Quick Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                QuickStatView(value: "1200", unit: "km/h", label: "Top Speed")
                QuickStatView(value: "95%", unit: "", label: "Energy Efficient")
                QuickStatView(value: "0", unit: "CO₂", label: "Emissions")
            }
            .padding()

            // Feature Cards Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                HyperloopFeatureCard(emoji: "⚡", text: "Electric Propulsion")
                HyperloopFeatureCard(emoji: "🌪️", text: "Low Air Resistance")
                HyperloopFeatureCard(emoji: "🔋", text: "Energy Efficient")
                HyperloopFeatureCard(emoji: "🌍", text: "Sustainable Travel")
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

// MARK: - Supporting Components
struct QuickStatView: View {
    let value: String
    let unit: String
    let label: String

    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Text(unit)
                .font(.caption)
                .foregroundColor(.gray)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}

struct HyperloopFeatureCard: View {
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

// MARK: - Main Hyperloop View
struct HyperloopView: View {
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    @State private var selectedFilter: HyperloopType?

    var filteredSystems: [HyperloopSystem] {
        if let filter = selectedFilter {
            return hyperloopSystems.filter { $0.type == filter }
        }
        return hyperloopSystems
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                HyperloopIntroView()

                // Filter Buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        FilterButton(title: "All", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        FilterButton(title: "Operational", isSelected: selectedFilter == .operational) {
                            selectedFilter = .operational
                        }
                        FilterButton(title: "Testing", isSelected: selectedFilter == .testing) {
                            selectedFilter = .testing
                        }
                        FilterButton(title: "Proposed", isSelected: selectedFilter == .proposed) {
                            selectedFilter = .proposed
                        }
                    }
                    .padding(.horizontal)
                }

                // Grid of Hyperloop Systems
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(filteredSystems) { system in
                        HyperloopCard(hyperloop: system)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal)
                .animation(.spring(), value: selectedFilter)
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
                starfieldRotation = 360
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Hyperloop")
        .preferredColorScheme(.dark)
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue.opacity(0.3) : Color.black.opacity(0.3))
                )
        }
    }
}

// MARK: - Preview
struct HyperloopView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HyperloopView()
        }
    }
}
