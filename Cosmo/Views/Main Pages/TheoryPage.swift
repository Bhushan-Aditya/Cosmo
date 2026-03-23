import SwiftUI

struct TheoryTypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))

                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color.white.opacity(0.1))
                    .shadow(color: isSelected ? Color.blue.opacity(0.4) : .clear, radius: 8, x: 0, y: 4)
            )
            .foregroundColor(isSelected ? .white : .gray)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.white.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryButton: View {
    let category: TheoryCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 5) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
                Text(category.rawValue)
                    .font(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .allowsTightening(true)
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TheoryTypeIndicator: View {
    let type: TheoryType

    var body: some View {
        HStack {
            if type == .verified {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                Text("Verified")
                    .font(.caption2)
                    .foregroundColor(.green)
            } else if type == .hypothesis {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(.yellow)
                Text("Hypothesis")
                    .font(.caption2)
                    .foregroundColor(.yellow)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.08))
        .cornerRadius(8)
    }
}


struct CategoryTag: View {
    let category: TheoryCategory

    var body: some View {
        Text(category.rawValue)
            .font(.caption.bold())
            .foregroundColor(.blue)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
    }
}


// MARK: - Main Theory Models
struct Theory: Identifiable {
    var id: String { title }
    var title: String
    var category: TheoryCategory
    var scientist: String
    let year: String
    var shortDescription: String
    var fullDescription: String
    let citations: [String]
    let icon: String
    let color: Color
    let type: TheoryType
}

enum TheoryType {
    case verified
    case hypothesis
    case all // Added 'all' case if you intend to filter by all theory types
}

enum TheoryCategory: String, CaseIterable, Identifiable { // Conform to Identifiable
    var id: Self { self } // Conformance to Identifiable - id is the enum case itself

    case all = "All"
    case universe = "Universe"
    case blackHoles = "Black Holes"
    case quantum = "Quantum"
    case relativity = "Relativity"
    case cosmology = "Cosmology"
    case astrobiology = "Astrobiology"
    case particlePhysics = "Particle Physics"
    case spaceTime = "Space-Time"
    case darkMatter = "Dark Matter"
    //Removed case community = "Community" - if this was typo causing issue. If category 'Community' was intended, reinstate it.

    var icon: String {
        switch self {
        case .all: return "star.circle.fill"
        case .universe: return "globe.americas.fill"
        case .blackHoles: return "circle.fill"
        case .quantum: return "atom"
        case .relativity: return "clock.fill"
        case .cosmology: return "sparkles"
        case .astrobiology: return "leaf.fill"
        case .particlePhysics: return "particles"
        case .spaceTime: return "timer"
        case .darkMatter: return "cloud.fill"
        }
    }

    var description: String {
        switch self {
        case .all: return "All theories across categories"
        case .universe: return "Theories about universal structure and evolution"
        case .blackHoles: return "Black hole formation and behavior"
        case .quantum: return "Quantum mechanics and phenomena"
        case .relativity: return "Special and general relativity"
        case .cosmology: return "Origin and evolution of the cosmos"
        case .astrobiology: return "Life in the universe"
        case .particlePhysics: return "Fundamental particles and forces"
        case .spaceTime: return "Nature of space and time"
        case .darkMatter: return "Dark matter and dark energy"
        }
    }
}

// MARK: - Main Theory View
struct TheoryExplorerView: View {
    @State private var selectedTheoryType: TheoryType = .all //Default to all.
    @State private var selectedTheory: Theory? = nil
    @State private var showTheoryDetail = false
    @State private var animateCards = false
    @State private var scrollOffset: CGFloat = 0
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    @State private var zoomLevel: Double = 1.0

    private let theories: [Theory] = TheoryDatabase.allTheories

    init() { // Added initializer to print count on view initialization - for debugging
        print("Total theories loaded: \(theories.count)")
    }

    private func startCosmicAnimations() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            starfieldRotation = 360
        }
    }


    var filteredTheories: [Theory] {
        theories.filter { theory in
            selectedTheoryType == .all || theory.type == selectedTheoryType
        }
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
                    headerSection
                    
                    theorySelectorSection
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                    
                    theoriesList
                }
            }
        }
        .onAppear {
            startCosmicAnimations()
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showTheoryDetail) {
            if let theory = selectedTheory {
                TheoryDetailModal(theory: theory, isShowing: $showTheoryDetail)
            }
        }
    }

    // MARK: - View Components
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                Image(systemName: "atom")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color.cyan.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("Theory Explorer")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
            }
            Text(headerDescription)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.55))
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    private var theorySelectorSection: some View { // Theory type selector 
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                TheoryTypeButton(
                    title: "All",
                    icon: "star.circle.fill",
                    isSelected: selectedTheoryType == .all
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTheoryType = .all
                    }
                }

                TheoryTypeButton(
                    title: "Verified",
                    icon: "checkmark.seal.fill",
                    isSelected: selectedTheoryType == .verified
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTheoryType = .verified
                    }
                }

                TheoryTypeButton(
                    title: "Hypotheses",
                    icon: "questionmark.circle.fill",
                    isSelected: selectedTheoryType == .hypothesis
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTheoryType = .hypothesis
                    }
                }
            }
        }
    }

    // Category + search sections removed (per request).

    private var theoriesList: some View { 
        LazyVStack(spacing: 12) {
            ForEach(Array(filteredTheories.enumerated()), id: \.element.id) { index, theory in
                TheoryCard(theory: theory) { 
                    print("Action from TheoryCard triggered in TheoryExplorerView for: \(theory.title)") 
                    withAnimation {
                        selectedTheory = theory
                        showTheoryDetail = true
                    }
                }
                .offset(y: animateCards ? 0 : 30)
                .opacity(animateCards ? 1 : 0)
                .animation(
                    .spring(response: 0.45, dampingFraction: 0.75)
                    .delay(Double(index) * 0.05),
                    value: animateCards
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 100)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                animateCards = true
            }
        }
    }


    private var headerDescription: String {
        switch selectedTheoryType {
        case .all: return "Explore all verified theories and proposals across the cosmos"
        case .verified:
            return "Explore scientifically verified theories that shape our understanding of the cosmos"

        case .hypothesis:
            return "Explore emerging hypotheses and theoretical proposals"
        }
    }
}


// MARK: - Supporting Views
extension TheoryExplorerView {
    struct TheoryCard: View {
        let theory: Theory
        let action: () -> Void // This is the action closure
        @State private var isHovered = false

        var body: some View {
            Button(action: {
                action()
            }) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header Area (Icon & Titles)
                    HStack(alignment: .top, spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(theory.color.opacity(0.2))
                                .frame(width: 36, height: 36)
                            Image(systemName: theory.icon)
                                .font(.system(size: 16))
                                .foregroundColor(theory.color)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(theory.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)

                            Text(theory.scientist)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(theory.color.opacity(0.9))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                    // Description Area
                    Text(theory.shortDescription)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)

                    // Footer Area (Tags and Metrics)
                    HStack {
                        CategoryTag(category: theory.category)
                        
                        Text(theory.year)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.white.opacity(0.1)))

                        Spacer()
                        
                        TheoryTypeIndicator(type: theory.type)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.03))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.04))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [theory.color.opacity(isHovered ? 0.6 : 0.2), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: theory.color.opacity(isHovered ? 0.15 : 0), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isHovered ? 1.02 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
        }
    }
    struct TheoryDetailModal: View {
        let theory: Theory
        @Binding var isShowing: Bool

        var body: some View {
            ZStack {
                // Glassmorphic Background Overlay
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isShowing = false
                        }
                    }

                VStack(spacing: 0) {
                    // Header Bar
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(theory.title)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)

                            HStack(spacing: 8) {
                                Text(theory.scientist)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(theory.color)
                                Text("•")
                                    .foregroundColor(.white.opacity(0.3))
                                Text(theory.year)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            }

                        }

                        Spacer()

                        Button {
                            withAnimation {
                                isShowing = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color.white.opacity(0.8))
                        }
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.03))

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 24) {
                            // Hero Icon
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [theory.color.opacity(0.3), .clear],
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: 80
                                        )
                                    )
                                    .frame(width: 160, height: 160)

                                Image(systemName: theory.icon)
                                    .font(.system(size: 64))
                                    .foregroundStyle(theory.color.gradient)
                                    .shadow(color: theory.color.opacity(0.5), radius: 10)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)

                            // Full Description
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Overview")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(theory.fullDescription)
                                    .font(.system(size: 16))
                                    .lineSpacing(6)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.horizontal, 24)

                            // Citations Section
                            if !theory.citations.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Citations & Sources")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)

                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(theory.citations, id: \.self) { citation in
                                            HStack(alignment: .top, spacing: 10) {
                                                Image(systemName: "link")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(theory.color)
                                                    .padding(.top, 4)
                                                Text(citation)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.white.opacity(0.7))
                                                    .lineLimit(nil)
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.white.opacity(0.05))
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 8)
                            }


                        }
                        .padding(.bottom, 40)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color(white: 0.08).opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .padding(16)
                .frame(maxWidth: 600)
            }
        }
    }


    }



struct TheoryDatabase { // Theory Database
    static var allTheories: [Theory] {
        // MARK: - Relativity Theories
        let relativityTheories: [Theory] = [
            Theory(
                title: "General Relativity",
                category: .relativity,
                scientist: "Albert Einstein",
                year: "1915",
                shortDescription: "Gravity as a consequence of spacetime curvature",
                fullDescription: """
                    Einstein's theory of general relativity describes gravity as a consequence of spacetime curvature caused by mass and energy. Key principles include:
                    • Gravity is not a force, but a consequence of curved spacetime
                    • Massive objects distort the fabric of spacetime
                    • Light follows curved paths in curved spacetime
                    • Time dilation occurs in strong gravitational fields
                    • The theory predicts black holes and gravitational waves
                    """,
                citations: [
                    "Einstein, A. (1915). 'Die Feldgleichungen der Gravitation'",
                    "Wheeler, J.A. (1973). 'Gravitation'",
                    "Hawking, S. (1988). 'A Brief History of Time'"
                ],
                icon: "clock.fill",
                color: Color(red: 0.4, green: 0.8, blue: 1.0),
                type: .verified
            ),

            Theory(
                title: "Special Relativity",
                category: .relativity,
                scientist: "Albert Einstein",
                year: "1905",
                shortDescription: "The relationship between space and time",
                fullDescription: """
                    Special relativity fundamentally changed our understanding of space and time. Core principles:
                    • The speed of light is constant in all reference frames
                    • Time dilation occurs at high velocities
                    • Mass and energy are equivalent (E = mc²)
                    • No information can travel faster than light
                    • Length contraction occurs at relativistic speeds
                    """,
                citations: [
                    "Einstein, A. (1905). 'Zur Elektrodynamik bewegter Körper'",
                    "Lorentz, H.A. (1904). 'Electromagnetic phenomena'"
                ],
                icon: "bolt.fill",
                color: Color(red: 1.0, green: 0.8, blue: 0.4),
                type: .verified
            ),

            Theory(
                title: "Time Dilation",
                category: .relativity,
                scientist: "Albert Einstein",
                year: "1905",
                shortDescription: "Time passes differently depending on motion and gravity",
                fullDescription: """
                    Time dilation is a difference in elapsed time measured by observers in relative motion or at different gravitational potentials. Effects include:
                    • Moving clocks run slower
                    • Gravitational time dilation near massive objects
                    • The twin paradox
                    • GPS satellites must account for both special and general relativistic time dilation
                    """,
                citations: [
                    "Hafele, J.C. & Keating, R.E. (1972). 'Around-the-World Atomic Clocks'",
                    "Pound, R.V. & Rebka Jr, G.A. (1959). 'Gravitational Red-Shift'"
                ],
                icon: "timer",
                color: Color(red: 0.6, green: 0.4, blue: 0.8),
                type: .verified
            )
        ]

        // MARK: - Quantum Theories
        let quantumTheories: [Theory] = [
            Theory(
                title: "Quantum Mechanics",
                category: .quantum,
                scientist: "Multiple Scientists",
                year: "1900-1927",
                shortDescription: "The behavior of matter and energy at molecular, atomic, nuclear, and smaller scales",
                fullDescription: """
                    Quantum mechanics describes nature at the smallest scales. Key concepts include:
                    • Wave-particle duality
                    • Heisenberg's uncertainty principle
                    • Quantum superposition
                    • Wave function collapse
                    • Quantum entanglement
                    • The Copenhagen interpretation
                    """,
                citations: [
                    "Planck, M. (1900). 'On the Theory of the Energy Distribution Law'",
                    "Bohr, N. (1913). 'On the Constitution of Atoms and Molecules'",
                    "Heisenberg, W. (1927). 'Über den anschaulichen Inhalt'"
                ],
                icon: "atom",
                color: Color(red: 0.8, green: 0.4, blue: 0.6),
                type: .verified
            ),

            Theory(
                title: "Quantum Entanglement",
                category: .quantum,
                scientist: "Einstein, Podolsky, Rosen",
                year: "1935",
                shortDescription: "Quantum states of particles remain connected regardless of distance",
                fullDescription: """
                    Quantum entanglement occurs when particles interact in ways such that their quantum states cannot be described independently. Features include:
                    • 'Spooky action at a distance'
                    • Instantaneous correlation of quantum states
                    • The EPR paradox
                    • Bell's theorem
                    • Applications in quantum computing and cryptography
                    """,
                citations: [
                    "Einstein, A., Podolsky, B., & Rosen, N. (1935). 'Can Quantum-Mechanical Description'",
                    "Bell, J.S. (1964). 'On the Einstein Podolsky Rosen Paradox'"
                ],
                icon: "link.circle",
                color: Color(red: 0.3, green: 0.7, blue: 0.9),
                type: .verified
            )
        ]

        // Continue with more categories...
        // MARK: - Black Hole Theories
        let blackHoleTheories: [Theory] = [
            Theory(
                title: "Black Hole Formation",
                category: .blackHoles,
                scientist: "John Michell (concept), Karl Schwarzschild (math)",
                year: "1783, 1916",
                shortDescription: "Massive stars collapse under gravity to form singularities",
                fullDescription: """
                    Black holes form when massive stars exhaust their nuclear fuel and collapse under their gravitational pull. Key features include:
                    • Schwarzschild radius (event horizon)
                    • Singularity at the center
                    • No radiation escapes beyond the event horizon
                    • Stellar, intermediate, and supermassive black holes
                    • Discovered through X-rays from accretion disks
                    """,
                citations: [
                    "Michell, J. (1783). 'On the Means of Discovering the Distance'",
                    "Schwarzschild, K. (1916). 'Über das Gravitationsfeld'"
                ],
                icon: "circlebadge.fill",
                color: Color(red: 0.5, green: 0.2, blue: 0.8),
                type: .verified
            ),

            Theory(
                title: "Hawking Radiation",
                category: .blackHoles,
                scientist: "Stephen Hawking",
                year: "1974",
                shortDescription: "Black holes emit radiation due to quantum effects near the event horizon",
                fullDescription: """
                    Hawking radiation is theoretical radiation emitted by black holes due to quantum mechanical processes. Features include:
                    • Particle-antiparticle pair creation
                    • Particles escape near the event horizon
                    • Black holes can potentially evaporate over time
                    • Small black holes emit more radiation
                    """,
                citations: [
                    "Hawking, S. (1974). 'Black Hole Explosions?'",
                    "Hawking, S. (1975). 'Particle Creation by Black Holes'"
                ],
                icon: "globe.badge.plus",
                color: Color(red: 0.4, green: 0.7, blue: 1.0),
                type: .verified
            ),

            Theory(
                title: "Primordial Black Holes",
                category: .blackHoles,
                scientist: "Yakov Borisovich Zel'dovich, Igor Novikov",
                year: "1966",
                shortDescription: "Formation of small black holes early in the universe",
                fullDescription: """
                    Primordial black holes may have formed during the high-energy conditions of the early universe. Key characteristics include:
                    • Early density fluctuations create seeds for black holes
                    • Hypothetically smaller than stellar-mass black holes
                    • Possible candidates for dark matter
                    """,
                citations: [
                    "Zel’dovich, Y. & Novikov, I. (1966). 'The Hypothesis of CMB Black Holes'",
                    "Hawking, S. (1971). 'Gravitationally Collapsed Objects'"
                ],
                icon: "sparkles.circle.fill",
                color: Color(red: 0.1, green: 0.4, blue: 0.9),
                type: .verified
            )
        ]
        // MARK: - Universe/Cosmology Theories
        let cosmologyTheories: [Theory] = [
            Theory(
                title: "Big Bang Theory",
                category: .cosmology,
                scientist: "Georges Lemaître & Edwin Hubble",
                year: "1927",
                shortDescription: "The universe began in a hot, dense state and expanded",
                fullDescription: """
                    The Big Bang theory describes the initial state of the universe as a singularity that expanded and cooled over time. Key points include:
                    • Edwin Hubble discovered cosmic expansion through redshift observations
                    • Cosmic microwave background radiation is leftover radiation from the Big Bang
                    • Predicts homogeneity and isotropy (on large scales)
                    """,
                citations: [
                    "Hubble, E.P. (1927). 'A Relation between Distance and Radial Velocity of Nebulae'",
                    "Penzias, A. & Wilson, R. (1965). 'Cosmic Microwave Background'"
                ],
                icon: "flame.fill",
                color: Color.red,
                type: .verified
            ),

            Theory(
                title: "Inflationary Universe",
                category: .cosmology,
                scientist: "Alan Guth",
                year: "1981",
                shortDescription: "An exponential expansion in the early universe to explain uniformity and structure",
                fullDescription: """
                    Inflation theory proposes a brief period of exponential expansion moments after the Big Bang. Key ideas:
                    • Explains flatness and horizons of the universe
                    • Rapid stretching smoothed out irregularities
                    • Quantum fluctuations seeded structures like galaxies
                    """,
                citations: [
                    "Guth, A. (1981). 'Inflationary Universe'",
                    "Linde, A. (1982). 'Chaotic Inflation Models'"
                ],
                icon: "wind.circle",
                color: Color(red: 0.8, green: 0.5, blue: 0.2),
                type: .verified
            ),

            Theory(
                title: "Steady State Model",
                category: .cosmology,
                scientist: "Fred Hoyle, Thomas Gold, Hermann Bondi",
                year: "1948",
                shortDescription: "A competing model to the Big Bang—universe is eternal and constantly creates matter",
                fullDescription: """
                    The Steady State model asserts that as the universe expands, new matter is created to maintain constant density. It fell out of favor due to predictions contradicting observations:
                    • The universe appears isotropic but evolves over time
                    • Background radiation supports a Big Bang event
                    """,
                citations: [
                    "Hoyle, F. (1948). 'The Steady-State Theory in Cosmology'",
                    "Gold, T. & Bondi, H. Papers (1940s)"
                ],
                icon: "house.circle.fill",
                color: Color(.yellow),
                type: .hypothesis
            )
        ]
        // MARK: - Dark Matter/Energy Theories
        let darkMatterTheories: [Theory] = [
            Theory(
                title: "Dark Matter Hypothesis",
                category: .darkMatter,
                scientist: "Fritz Zwicky",
                year: "1933",
                shortDescription: "Invisible mass that explains gravitational effects in galaxies",
                fullDescription: """
                    Dark matter explains "missing mass" in galaxies and their clusters. Evidence:
                    • Galaxy rotational curves (constant velocity)
                    • Gravitational lensing
                    • Structure formation in the cosmic web
                    Key candidates include WIMPs (weakly interacting particles).
                    """,
                citations: [
                    "Zwicky, F. (1933). 'Redshift observations of galaxy clusters'"
                ],
                icon: "eye.slash",
                color: Color.gray,
                type: .verified
            ),

            Theory(
                title: "Dark Energy",
                category: .darkMatter,
                scientist: "Saul Perlmutter, Adam Riess, Brian Schmidt",
                year: "1998",
                shortDescription: "Mysterious energy causing the accelerated expansion of the universe",
                fullDescription: """
                    Dark energy accounts for 68% of the universe's energy density. Key findings:
                    • Observations of Type Ia supernovae revealed accelerated expansion
                    • Dark energy outcompetes gravity over large distances
                    • Its nature remains unknown.
                    """,
                citations: [
                    "Perlmutter, S. et al. (1999). 'Discovery of Cosmic Acceleration'"
                ],
                icon: "bolt.circle.fill",
                color: Color.purple,
                type: .verified
            )
        ]
        // MARK: - Space-Time Theories
        let spaceTimeTheories: [Theory] = [
            Theory(
                title: "Block Universe Theory",
                category: .spaceTime,
                scientist: "Hermann Minkowski",
                year: "1908",
                shortDescription: "Past, present, and future exist simultaneously in 4D spacetime",
                fullDescription: """
                    The Block Universe theory suggests that all moments in time exist simultaneously in a four-dimensional "block" of spacetime. Key concepts:
                    • Time is a dimension, similar to space
                    • All moments exist eternally
                    • The "flow" of time is an illusion
                    • Compatible with special relativity
                    """,
                citations: [
                    "Minkowski, H. (1908). 'Space and Time'",
                    "Einstein, A. (1920). 'Relativity: The Special and General Theory'"
                ],
                icon: "cube.fill",
                color: Color(red: 0.4, green: 0.6, blue: 0.8),
                type: .verified
            ),

            Theory(
                title: "Quantum Gravity",
                category: .spaceTime,
                scientist: "Multiple Scientists",
                year: "1960-Present",
                shortDescription: "Attempts to reconcile quantum mechanics with gravity",
                fullDescription: """
                    Quantum gravity seeks to describe gravity using quantum mechanics principles. Major approaches:
                    • String Theory
                    • Loop Quantum Gravity
                    • Causal Dynamical Triangulations
                    • Asymptotic Safety
                    • Causal Sets
                    """,
                citations: [
                    "Wheeler, J.A. (1957). 'On the Nature of Quantum Geometrodynamics'",
                    "DeWitt, B.S. (1967). 'Quantum Theory of Gravity'"
                ],
                icon: "network",
                color: Color(red: 0.7, green: 0.3, blue: 0.7),
                type: .hypothesis
            )
        ]

        // MARK: - Particle Physics Theories
        let particleTheories: [Theory] = [
            Theory(
                title: "Standard Model",
                category: .particlePhysics,
                scientist: "Multiple Scientists",
                year: "1970s",
                shortDescription: "Fundamental particles and forces of nature",
                fullDescription: """
                    The Standard Model describes fundamental particles and three of four fundamental forces:
                    • Quarks and leptons (matter particles)
                    • Force carriers (bosons)
                    • Higgs mechanism
                    • Electromagnetic, strong, and weak forces
                    """,
                citations: [
                    "Glashow, S. (1961). 'Partial Symmetries of Weak Interactions'",
                    "Weinberg, S. (1967). 'A Model of Leptons'"
                ],
                icon: "atom",
                color: Color(red: 0.9, green: 0.4, blue: 0.4),
                type: .verified
            ),

            Theory(
                title: "Supersymmetry",
                category: .particlePhysics,
                scientist: "Multiple Scientists",
                year: "1970s",
                shortDescription: "Symmetry between fermions and bosons",
                fullDescription: """
                    Supersymmetry proposes a partner particle for each known particle:
                    • Solves hierarchy problem
                    • Provides dark matter candidates
                    • Unifies force coupling constants
                    • Not yet observed experimentally
                    """,
                citations: [
                    "Wess, J. & Zumino, B. (1974). 'Supergauge Transformations'",
                    "Fayet, P. & Ferrara, S. (1977). 'Supersymmetry'"
                ],
                icon: "circle.grid.cross",
                color: Color(red: 0.5, green: 0.8, blue: 0.3),
                type: .hypothesis
            )
        ]

        // MARK: - Astrobiology Theories
        let astrobiologyTheories: [Theory] = [
            Theory(
                title: "Panspermia",
                category: .astrobiology,
                scientist: "Multiple Scientists",
                year: "Ancient-Present",
                shortDescription: "Life spread through space via meteors and cosmic dust",
                fullDescription: """
                    Panspermia suggests life can travel between planets and star systems:
                    • Bacterial spores survive in space
                    • Meteors can transport organic material
                    • Life might originate in multiple locations
                    • Supported by extremophile studies
                    """,
                citations: [
                    "Arrhenius, S. (1903). 'The Propagation of Life in Space'",
                    "Hoyle, F. & Wickramasinghe, N.C. (1981). 'Evolution from Space'"
                ],
                icon: "moon.stars.fill",
                color: Color(red: 0.3, green: 0.9, blue: 0.6),
                type: .hypothesis
            ),

            Theory(
                title: "RNA World Hypothesis",
                category: .astrobiology,
                scientist: "Walter Gilbert",
                year: "1986",
                shortDescription: "RNA preceded DNA in evolution",
                fullDescription: """
                    The RNA World hypothesis suggests RNA was the first genetic material:
                    • RNA can store information and catalyze reactions
                    • Preceded more complex DNA-based life
                    • Supported by ribozyme discovery
                    • Explains the origin of the genetic code
                    """,
                citations: [
                    "Gilbert, W. (1986). 'Origin of Life: The RNA World'",
                    "Cech, T.R. (1989). 'RNA as an Enzyme'"
                ],
                icon: "dna",
                color: Color(red: 0.8, green: 0.6, blue: 0.2),
                type: .verified
            )
        ]
       return relativityTheories + quantumTheories + blackHoleTheories + cosmologyTheories + darkMatterTheories + spaceTimeTheories + particleTheories + astrobiologyTheories
    }

    // Helper methods for filtering
    static func theoriesByCategory(_ category: TheoryCategory) -> [Theory] {
        return allTheories.filter { $0.category == category }
    }

    static func theoriesByType(_ type: TheoryType) -> [Theory] {
        return allTheories.filter { $0.type == type }
    }

    static func searchTheories(_ searchText: String) -> [Theory] {
        guard !searchText.isEmpty else { return allTheories }

        return allTheories.filter { theory in
            theory.title.localizedCaseInsensitiveContains(searchText) ||
            theory.scientist.localizedCaseInsensitiveContains(searchText) ||
            theory.shortDescription.localizedCaseInsensitiveContains(searchText)
        }
    }
}



extension TheoryDatabase {
    static var theoriesCount: [TheoryCategory: Int] {
        get {
            var counts: [TheoryCategory: Int] = [:]
            TheoryCategory.allCases.forEach { category in
                counts[category] = theoriesByCategory(category).count
            }
            return counts
        }
    }

    static var verifiedTheoriesPercentage: Double {
        let verified = theoriesByType(.verified).count
        return Double(verified) / Double(allTheories.count) * 100
    }
}


// MARK: - Preview
struct TheoryExplorerView_Previews: PreviewProvider {
    static var previews: some View {
        TheoryExplorerView()
    }
}
