import SwiftUI

// MARK: - Models and Data Structures
struct GravityObject: Identifiable {
    let id = UUID()
    let name: String
    let type: GravityType
    let surfaceGravity: String
    let mass: String
    let escapeVelocity: String
    let facts: [String]
    let color: Color
    let comparison: String // Comparison to Earth's gravity
}

enum GravityType {
    case planet
    case moon
    case star
    case blackHole
    case dwarf
    case asteroid

    var description: String {
        switch self {
        case .planet: return "Planet"
        case .moon: return "Moon/Satellite"
        case .star: return "Star"
        case .blackHole: return "Black Hole"
        case .dwarf: return "Dwarf Planet"
        case .asteroid: return "Asteroid"
        }
    }

    var isExtreme: Bool {
        switch self {
        case .blackHole, .star: return true
        default: return false
        }
    }
}

// MARK: - Gravity Data
let gravityObjects = [
    GravityObject(
        name: "Earth",
        type: .planet,
        surfaceGravity: "9.81 m/s²",
        mass: "5.97 × 10²⁴ kg",
        escapeVelocity: "11.2 km/s",
        facts: [
            "Reference point for gravity comparison",
            "Perfect for human evolution",
            "Varies slightly by location",
            "Weakens with altitude",
            "Essential for atmosphere retention"
        ],
        color: .blue,
        comparison: "1.0g (Reference)"
    ),
    GravityObject(
        name: "Jupiter",
        type: .planet,
        surfaceGravity: "24.79 m/s²",
        mass: "1.90 × 10²⁷ kg",
        escapeVelocity: "59.5 km/s",
        facts: [
            "Strongest gravity in solar system",
            "Creates intense atmospheric pressure",
            "Affects entire solar system",
            "Protects Earth from asteroids",
            "Causes extreme weather patterns"
        ],
        color: .orange,
        comparison: "2.4g"
    ),
    GravityObject(
        name: "Sagittarius A*",
        type: .blackHole,
        surfaceGravity: "~10¹² m/s²",
        mass: "4.3 × 10⁶ M☉",
        escapeVelocity: "c",
        facts: [
            "Supermassive black hole",
            "Center of Milky Way",
            "Nothing escapes event horizon",
            "Extreme spacetime curvature",
            "Time dilation effects"
        ],
        color: .purple,
        comparison: "~10¹¹g"
    ),
    GravityObject(
        name: "Moon",
        type: .moon,
        surfaceGravity: "1.62 m/s²",
        mass: "7.34 × 10²² kg",
        escapeVelocity: "2.38 km/s",
        facts: [
            "One-sixth of Earth's gravity",
            "Affects Earth's tides",
            "Perfect for space training",
            "Low escape velocity",
            "Minimal atmosphere retention"
        ],
        color: .gray,
        comparison: "0.166g"
    ),
    GravityObject(
        name: "Sun",
        type: .star,
        surfaceGravity: "274 m/s²",
        mass: "1.989 × 10³⁰ kg",
        escapeVelocity: "617.7 km/s",
        facts: [
            "Controls solar system orbits",
            "Intense gravitational field",
            "Creates solar tide effects",
            "Causes light bending",
            "Center of solar system mass"
        ],
        color: .yellow,
        comparison: "28g"
    ),
    GravityObject(
        name: "Mars",
        type: .planet,
        surfaceGravity: "3.72 m/s²",
        mass: "6.42 × 10²³ kg",
        escapeVelocity: "5.03 km/s",
        facts: [
            "About 38% of Earth's gravity",
            "Future colony consideration",
            "Weak atmosphere retention",
            "Similar day length to Earth",
            "Potential human adaptation"
        ],
        color: .red,
        comparison: "0.38g"
    ),
    GravityObject(
        name: "Ceres",
        type: .dwarf,
        surfaceGravity: "0.28 m/s²",
        mass: "9.39 × 10²⁰ kg",
        escapeVelocity: "0.51 km/s",
        facts: [
            "Largest asteroid belt object",
            "Very weak gravity field",
            "Potential mining base",
            "Nearly spherical shape",
            "Contains frozen water"
        ],
        color: .mint,
        comparison: "0.029g"
    ),
    GravityObject(
        name: "Neutron Star",
        type: .star,
        surfaceGravity: "10¹² m/s²",
        mass: "~3 M☉",
        escapeVelocity: "0.7c",
        facts: [
            "Extreme density object",
            "Incredible surface gravity",
            "Causes gravitational lensing",
            "Rapidly rotating object",
            "Quantum gravity effects"
        ],
        color: .white,
        comparison: "10¹¹g"
    )
]

// MARK: - Gravity Animation Components
struct GravityFieldAnimation: View {
    @State private var isAnimating = false
    let object: GravityObject

    var body: some View {
        ZStack {
            // Core object
            Circle()
                .fill(object.color)
                .frame(width: 40, height: 40)

            // Gravity field visualization
            ForEach(0..<3) { index in
                Circle()
                    .stroke(object.color.opacity(0.3), lineWidth: 2)
                    .frame(width: 40 + CGFloat(index * 20))
                    .scaleEffect(isAnimating ? 1.2 : 1)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.3),
                        value: isAnimating
                    )
            }

            // Special effects for extreme gravity objects
            if object.type.isExtreme {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [object.color, .clear]),
                            center: .center,
                            startRadius: 5,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)
                    .opacity(0.8)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: 1)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Gravity Object Card
struct GravityObjectCard: View {
    let object: GravityObject
    @State private var showDetails = false

    var body: some View {
        Button(action: { showDetails.toggle() }) {
            VStack(spacing: 15) {
                GravityFieldAnimation(object: object)
                    .frame(height: 80)

                VStack(alignment: .leading, spacing: 8) {
                    Text(object.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(object.type.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text(object.comparison)
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
                    .stroke(object.color.opacity(0.5), lineWidth: 2)
            )
        }
        .sheet(isPresented: $showDetails) {
            GravityDetailView(object: object)
        }
    }
}

// MARK: - Detail View Components
struct GravityDetailView: View {
    let object: GravityObject
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    GravityFieldAnimation(object: object)
                        .scaleEffect(2)
                        .frame(height: 200)

                    VStack(alignment: .leading, spacing: 15) {
                        InfoRow(title: "Type", value: object.type.description)
                        InfoRow(title: "Gravity", value: object.surfaceGravity)
                        InfoRow(title: "Mass", value: object.mass)
                        InfoRow(title: "Escape Velocity", value: object.escapeVelocity)
                        InfoRow(title: "Comparison", value: object.comparison)
                    }
                    .padding()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Key Features")
                            .font(.headline)
                            .foregroundColor(.white)

                        ForEach(object.facts, id: \.self) { fact in
                            HStack(alignment: .top) {
                                Text("•")
                                    .foregroundColor(object.color)
                                Text(fact)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(object.name)
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
}

// MARK: - Main Gravity View
struct GravityView: View {
    @State private var selectedFilter: GravityType?
    @State private var parallaxOffset: CGFloat = 0 // For parallax effect if you want to add drag gesture
    @State private var starfieldRotation: Double = 0 // For starfield rotation animation

    var filteredObjects: [GravityObject] {
        if let filter = selectedFilter {
            return gravityObjects.filter { $0.type == filter }
        }
        return gravityObjects
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 20) {
                    Text("Gravity Explorer")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)

                    Text("Discover gravitational forces across the cosmos")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding()

                // Quick Stats
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    QuickStatView(value: "9.81", unit: "m/s²", label: "Earth Gravity")
                    QuickStatView(value: "1G", unit: "", label: "Reference")
                    QuickStatView(value: "∞", unit: "", label: "Black Hole")
                }
                .padding()

                // Filter Buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        FilterButton(title: "All", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        FilterButton(title: "Planets", isSelected: selectedFilter == .planet) {
                            selectedFilter = .planet
                        }
                        FilterButton(title: "Stars", isSelected: selectedFilter == .star) {
                            selectedFilter = .star
                        }
                        FilterButton(title: "Black Holes", isSelected: selectedFilter == .blackHole) {
                            selectedFilter = .blackHole
                        }
                        FilterButton(title: "Moons", isSelected: selectedFilter == .moon) {
                            selectedFilter = .moon
                        }
                        FilterButton(title: "Dwarfs", isSelected: selectedFilter == .dwarf) {
                            selectedFilter = .dwarf
                        }
                    }
                    .padding(.horizontal)
                }

                // Gravity Objects Grid
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(filteredObjects) { object in
                        GravityObjectCard(object: object)
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
        .navigationTitle("Gravity Explorer")
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview
struct GravityView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GravityView()
        }
    }
}
