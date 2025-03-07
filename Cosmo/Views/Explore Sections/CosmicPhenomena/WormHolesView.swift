import SwiftUI
// MARK: - Models
struct Wormhole: Identifiable {
    let id = UUID()
    let name: String
    let type: WormholeType
    let theoreticalBasis: String
    let characteristics: [String]
    let physicalRequirements: [String]
    let potentialUses: [String]
    let scientificChallenges: [String]
    let relatedTheories: [String]
    let visualRepresentation: String
    let color: Color
}

enum WormholeType {
    case traversable
    case nonTraversable
    case lorentzian
    case schwarzschild
    case einstein_rosen
    
    var description: String {
        switch self {
        case .traversable: return "Traversable"
        case .nonTraversable: return "Non-Traversable"
        case .lorentzian: return "Lorentzian"
        case .schwarzschild: return "Schwarzschild"
        case .einstein_rosen: return "Einstein-Rosen Bridge"
        }
    }
}

// MARK: - Wormhole Card
struct WormholeCard: View {
    let wormhole: Wormhole
    @State private var showDetails = false
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: { showDetails.toggle() }) {
            VStack(spacing: 15) {
                // Animated Wormhole Visualization
                ZStack {
                    // Tunnel effect
                    ForEach(0..<4) { index in
                        Circle()
                            .stroke(wormhole.color.opacity(0.3))
                            .frame(width: 60 - CGFloat(index * 10),
                                   height: 60 - CGFloat(index * 10))
                            .scaleEffect(isAnimating ? 1.2 : 1)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                            .animation(
                                Animation.linear(duration: 2)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(index) * 0.1),
                                value: isAnimating
                            )
                    }
                    
                    Text(wormhole.visualRepresentation)
                        .font(.system(size: 30))
                }
                .frame(height: 80)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(wormhole.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(wormhole.type.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(wormhole.theoreticalBasis)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
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
                    .stroke(wormhole.color.opacity(0.5), lineWidth: 2)
            )
        }
        .sheet(isPresented: $showDetails) {
            WormholeDetailView(wormhole: wormhole)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Wormhole Detail View
struct WormholeDetailView: View {
    let wormhole: Wormhole
    @Environment(\.presentationMode) var presentationMode
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Animated Wormhole Visualization
                    ZStack {
                        // Enhanced tunnel effect
                        ForEach(0..<6) { index in
                            Circle()
                                .stroke(wormhole.color.opacity(0.3))
                                .frame(width: 150 - CGFloat(index * 20),
                                       height: 150 - CGFloat(index * 20))
                                .scaleEffect(isAnimating ? 1.2 : 1)
                                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                                .animation(
                                    Animation.linear(duration: 3)
                                        .repeatForever(autoreverses: false)
                                        .delay(Double(index) * 0.1),
                                    value: isAnimating
                                )
                        }
                        
                        Text(wormhole.visualRepresentation)
                            .font(.system(size: 50))
                    }
                    .frame(height: 200)
                    
                    // Characteristics Section
                    GroupBox(label: Text("Characteristics").foregroundColor(.white)) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(wormhole.characteristics, id: \.self) { characteristic in
                                HStack(alignment: .top) {
                                    Text("•")
                                        .foregroundColor(wormhole.color)
                                    Text(characteristic)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    // Physical Requirements
                    GroupBox(label: Text("Physical Requirements").foregroundColor(.white)) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(wormhole.physicalRequirements, id: \.self) { requirement in
                                HStack(alignment: .top) {
                                    Text("•")
                                        .foregroundColor(wormhole.color)
                                    Text(requirement)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    // Potential Uses
                    GroupBox(label: Text("Potential Applications").foregroundColor(.white)) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(wormhole.potentialUses, id: \.self) { use in
                                HStack(alignment: .top) {
                                    Text("•")
                                        .foregroundColor(wormhole.color)
                                    Text(use)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    // Scientific Challenges
                    GroupBox(label: Text("Scientific Challenges").foregroundColor(.white)) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(wormhole.scientificChallenges, id: \.self) { challenge in
                                HStack(alignment: .top) {
                                    Text("•")
                                        .foregroundColor(wormhole.color)
                                    Text(challenge)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
                .padding()
            }
            .navigationTitle(wormhole.name)
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

// MARK: - Main Wormhole View
struct WormholeView: View {
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    
    let wormholes = [
        Wormhole(
            name: "Einstein-Rosen Bridge",
            type: .einstein_rosen,
            theoreticalBasis: "General Relativity solution connecting two points in spacetime",
            characteristics: [
                "Connects two distant points in space",
                "Theoretical shortcut through spacetime",
                "Requires negative energy density",
                "Subject to quantum instability"
            ],
            physicalRequirements: [
                "Exotic matter with negative energy density",
                "Extremely strong gravitational fields",
                "Stable quantum configuration",
                "Protection from radiation effects"
            ],
            potentialUses: [
                "Interstellar travel",
                "Time travel",
                "Instantaneous communication",
                "Study of quantum gravity"
            ],
            scientificChallenges: [
                "Quantum instability",
                "Hawking radiation",
                "Exotic matter requirements",
                "Gravitational tidal forces"
            ],
            relatedTheories: [
                "General Relativity",
                "Quantum Mechanics",
                "String Theory",
                "Loop Quantum Gravity"
            ],
            visualRepresentation: "🌀",
            color: .blue
        ),
        Wormhole(
            name: "Morris-Thorne Wormhole",
            type: .traversable,
            theoreticalBasis: "Traversable wormhole solution requiring exotic matter",
            characteristics: [
                "Theoretically traversable by humans",
                "Requires artificial stabilization",
                "Two-way passage possible",
                "Time travel potential"
            ],
            physicalRequirements: [
                "Exotic matter maintenance",
                "Stable throat configuration",
                "Protection from vacuum fluctuations",
                "Energy field containment"
            ],
            potentialUses: [
                "Space exploration",
                "Rapid transit system",
                "Scientific research",
                "Communication network"
            ],
            scientificChallenges: [
                "Maintaining stability",
                "Energy requirements",
                "Radiation protection",
                "Technical feasibility"
            ],
            relatedTheories: [
                "Casimir Effect",
                "Quantum Field Theory",
                "Membrane Theory",
                "Cosmic String Theory"
            ],
            visualRepresentation: "🕳️",
            color: .purple
        ),
        // Add more wormholes...
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Intro section
                VStack(spacing: 20) {
                    Text("🌌")
                        .font(.system(size: 60))
                        .padding()
                    
                    Text("Wormholes")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Theoretical bridges in the fabric of spacetime that could connect different points in the universe")
                        .multilineTextAlignment(.center)
                        .padding()
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.3))
                )
                .padding()
                
                // Wormholes Grid
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(wormholes) { wormhole in
                        WormholeCard(wormhole: wormhole)
                    }
                }
                .padding()
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
            withAnimation(.linear(duration: 20)
                .repeatForever(autoreverses: false)) {
                starfieldRotation = 360
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Wormholes")
    }
}
struct WormHoleView_Previews: PreviewProvider {
    static var previews: some View {
        WormholeView()
    }
}
