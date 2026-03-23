import SwiftUI

// MARK: - Model
struct Dimension: Identifiable {
    let id = UUID()
    let number: Int
    let name: String
    let shortTag: String
    let description: String
    let accentColor: Color
    let symbol: String
    let properties: [String]
    let examples: [String]
    let implications: [String]
}

// MARK: - Animated Dimension Visual
struct DimensionVisual: View {
    let dimension: Dimension
    let size: CGFloat
    @State private var rotate = false

    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(dimension.accentColor.opacity(0.14))
                .frame(width: size * 1.4, height: size * 1.4)
                .blur(radius: size * 0.18)

            // Geometric layers
            ForEach(0..<min(dimension.number, 5), id: \.self) { i in
                let layerSize = size * (0.55 + Double(i) * 0.14)
                RoundedRectangle(cornerRadius: dimension.number > 3 ? 8 : 2, style: .continuous)
                    .stroke(dimension.accentColor.opacity(0.55 - Double(i) * 0.08), lineWidth: 1.5)
                    .frame(width: layerSize, height: layerSize)
                    .rotationEffect(
                        .degrees(rotate
                            ? Double(i) * (dimension.number > 2 ? 18.0 : 0)
                            : 0
                        )
                    )
                    .animation(
                        .linear(duration: 8 + Double(i) * 3)
                            .repeatForever(autoreverses: dimension.number < 3),
                        value: rotate
                    )
            }

            // Central symbol
            Text(dimension.symbol)
                .font(.system(size: size * 0.38))
        }
        .frame(width: size, height: size)
        .onAppear { rotate = true }
    }
}

// MARK: - Dimension Row Card
struct DimensionRowCard: View {
    let dimension: Dimension
    @State private var showDetails = false

    var body: some View {
        Button(action: { showDetails = true }) {
            HStack(spacing: 14) {
                // Visual
                DimensionVisual(dimension: dimension, size: 62)
                    .frame(width: 62, height: 62)

                // Text
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Text("\(dimension.number)D")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(dimension.accentColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(dimension.accentColor.opacity(0.14)))

                        Text(dimension.shortTag)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.45))
                    }

                    Text(dimension.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(dimension.description)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.50))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.25))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [dimension.accentColor.opacity(0.08), Color.black.opacity(0.22)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(dimension.accentColor.opacity(0.22), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetails) {
            DimensionDetailView(dimension: dimension)
        }
    }
}

// MARK: - Dimension Detail Sheet
struct DimensionDetailView: View {
    let dimension: Dimension
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSection = 0

    let sections = ["Properties", "Examples", "Implications"]

    var sectionData: [String] {
        switch selectedSection {
        case 0: return dimension.properties
        case 1: return dimension.examples
        case 2: return dimension.implications
        default: return []
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, dimension.accentColor.opacity(0.10), Color.black],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Hero visual
                    ZStack {
                        Circle()
                            .fill(dimension.accentColor.opacity(0.08))
                            .frame(width: 200, height: 200)
                            .blur(radius: 40)
                        DimensionVisual(dimension: dimension, size: 110)
                    }
                    .frame(height: 160)
                    .padding(.top, 28)

                    // Title
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            Text("\(dimension.number)D")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(dimension.accentColor)
                            Text(dimension.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text(dimension.shortTag)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(dimension.accentColor.opacity(0.9))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                Capsule().fill(dimension.accentColor.opacity(0.14))
                                    .overlay(Capsule().stroke(dimension.accentColor.opacity(0.4), lineWidth: 1))
                            )
                    }

                    Text(dimension.description)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 28)

                    ConceptTabBar(
                        tabs: sections,
                        selected: Binding(get: { selectedSection }, set: { selectedSection = $0 }),
                        color: dimension.accentColor
                    )

                    VStack(spacing: 8) {
                        ForEach(Array(sectionData.enumerated()), id: \.element) { idx, item in
                            HStack(alignment: .top, spacing: 13) {
                                ZStack {
                                    Circle().fill(dimension.accentColor.opacity(0.18)).frame(width: 32, height: 32)
                                    Text("\(idx + 1)")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(dimension.accentColor)
                                }
                                Text(item)
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
                                            colors: [dimension.accentColor.opacity(0.11), dimension.accentColor.opacity(0.04)],
                                            startPoint: .topLeading, endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(dimension.accentColor.opacity(0.20), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                    .animation(.easeInOut(duration: 0.22), value: selectedSection)

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
}

// MARK: - Main View
struct DimensionsView: View {
    @State private var starfieldRotation: Double = 0

    let dimensions: [Dimension] = [
        Dimension(
            number: 1,
            name: "Linear",
            shortTag: "Line · 1 coordinate",
            description: "A single direction extending infinitely — the simplest possible space.",
            accentColor: Color(red: 0.55, green: 0.78, blue: 1.0),
            symbol: "↔",
            properties: [
                "Movement only along a single axis — forward or backward",
                "Position described by one number (x)",
                "No area or volume — only length exists",
                "All 1D 'objects' are points or line segments"
            ],
            examples: [
                "A number line in mathematics",
                "Distance measured along a road",
                "A timeline showing events in order",
                "The pitch of a musical note (frequency axis)"
            ],
            implications: [
                "Foundation for vectors and linear algebra",
                "Basis for measuring any quantity that varies in one way",
                "Critical for understanding higher-dimensional projections",
                "Used in 1D quantum wire systems in condensed matter physics"
            ]
        ),
        Dimension(
            number: 2,
            name: "Planar",
            shortTag: "Plane · 2 coordinates",
            description: "A flat surface with length and width — the world of geometry and maps.",
            accentColor: Color(red: 0.42, green: 0.92, blue: 0.62),
            symbol: "◻",
            properties: [
                "Movement in two independent directions (x, y)",
                "Objects have area but no volume",
                "Angles, shapes, and area are the fundamental concepts",
                "All of Euclidean geometry lives in 2D"
            ],
            examples: [
                "Maps and blueprints of buildings",
                "Computer and phone screens",
                "Shadows cast on flat surfaces",
                "Chess boards and game grids"
            ],
            implications: [
                "Foundation of Euclidean geometry and trigonometry",
                "Essential for computer graphics and UI design",
                "2D topological spaces reveal deep mathematical structure",
                "Graphene is a real 2D material with quantum properties"
            ]
        ),
        Dimension(
            number: 3,
            name: "Spatial",
            shortTag: "Space · 3 coordinates",
            description: "Our familiar physical world with length, width, and height.",
            accentColor: Color(red: 1.0, green: 0.72, blue: 0.28),
            symbol: "🎲",
            properties: [
                "Movement in three independent directions (x, y, z)",
                "Objects have volume, surface area, and mass",
                "All of classical physics operates here",
                "Cross products and rotation are 3D-specific concepts"
            ],
            examples: [
                "Every physical object we can touch",
                "3D-printed models and CGI animation",
                "Architectural spaces and sculpture",
                "Molecules and crystal lattice structures"
            ],
            implications: [
                "The arena for all classical mechanics and thermodynamics",
                "3D topology underlies knot theory and string theory",
                "Why orbital mechanics and fluid dynamics have their specific forms",
                "Fundamental to understanding why atoms are stable"
            ]
        ),
        Dimension(
            number: 4,
            name: "Spacetime",
            shortTag: "Time as the 4th · 4 coordinates",
            description: "Einstein's unification of three spatial dimensions with time into a single curved fabric.",
            accentColor: Color(red: 0.78, green: 0.52, blue: 1.0),
            symbol: "⌛",
            properties: [
                "Events described by four coordinates (x, y, z, t)",
                "Time is not separate — it's a geometric dimension of the same fabric",
                "Massive objects curve 4D spacetime, producing gravity",
                "The speed of light is the conversion factor between space and time"
            ],
            examples: [
                "GPS satellite time corrections (general relativity)",
                "Black hole event horizons and Schwarzschild radius",
                "Gravitational waves detected by LIGO",
                "The cosmic expansion described by Friedmann equations"
            ],
            implications: [
                "Foundation of all of modern cosmology and astrophysics",
                "Time travel is theoretically possible under extreme curvature",
                "Causality is a geometric property of the spacetime cone structure",
                "Dark energy is a feature of spacetime's vacuum energy density"
            ]
        ),
        Dimension(
            number: 5,
            name: "Kaluza-Klein",
            shortTag: "Electromagnetism unified · Compactified",
            description: "A 5th dimension, compactified to Planck-scale radius, unifies gravity with electromagnetism — the first attempt at a Theory of Everything.",
            accentColor: Color(red: 1.0, green: 0.48, blue: 0.52),
            symbol: "🔵",
            properties: [
                "4D spacetime plus one circular compactified extra dimension",
                "The radius of the 5th circle encodes the electromagnetic charge",
                "Particles moving in the 5th dimension appear as electric charge in 4D",
                "Kaluza-Klein mass spectrum predicts heavy exotic particles"
            ],
            examples: [
                "Electromagnetic force emerges as 5D gravity",
                "Charge conservation is momentum conservation in the 5th direction",
                "Magnetic monopoles correspond to specific 5D topologies",
                "Foundation for all higher-dimensional unification attempts"
            ],
            implications: [
                "First hint that forces are geometric — they come from extra dimensions",
                "Seeds the idea behind all modern string and M-theory formulations",
                "Predicts Kaluza-Klein particle tower detectable at extreme energies",
                "Explains the deep similarity between gravitational and electrical laws"
            ]
        ),
        Dimension(
            number: 10,
            name: "String Theory",
            shortTag: "Superstring space · 10 dimensions",
            description: "Superstring theory requires exactly 10 dimensions — 4 large spacetime + 6 compactified on a Calabi-Yau manifold — to be mathematically consistent.",
            accentColor: Color(red: 0.38, green: 0.85, blue: 0.90),
            symbol: "〰",
            properties: [
                "Six extra dimensions compactified on Calabi-Yau shapes at Planck scale",
                "The geometry of the compact manifold determines particle properties",
                "Superpartners (SUSY particles) arise from the extra-dimensional structure",
                "Different string theories in 10D are related by duality transformations"
            ],
            examples: [
                "Five consistent superstring theories (Type I, IIA, IIB, HO, HE)",
                "Calabi-Yau manifolds encode the particle physics of each vacuum",
                "The 'string landscape' of ~10⁵⁰⁰ possible compact geometries",
                "D-branes are multi-dimensional objects living in the 10D space"
            ],
            implications: [
                "Potentially unifies all four fundamental forces including gravity",
                "Resolves ultraviolet divergences that plague quantum gravity",
                "Predicts supersymmetric partners for every known particle",
                "Landscape problem: enormous number of possible low-energy physics outcomes"
            ]
        ),
        Dimension(
            number: 11,
            name: "M-Theory",
            shortTag: "Mother of all theories · 11 dimensions",
            description: "M-Theory unifies all five superstring theories in 11 dimensions — one extra dimension beyond string theory, giving rise to membranes (M2 and M5 branes).",
            accentColor: Color(red: 0.62, green: 0.90, blue: 0.65),
            symbol: "Μ",
            properties: [
                "11-dimensional supergravity is the low-energy limit of M-theory",
                "Contains 2D membranes (M2-branes) and 5D objects (M5-branes)",
                "The 11th dimension appears when string coupling becomes large",
                "All five 10D string theories are limits of the single 11D M-theory"
            ],
            examples: [
                "Type IIA string theory emerges when the 11th dimension is circular",
                "Heterotic SO(32) emerges from a specific M-theory compactification",
                "Holographic duality (AdS/CFT) connects 11D M-theory to 10D quantum field theories",
                "Black hole entropy calculations match across all M-theory formulations"
            ],
            implications: [
                "Ultimate unified description of all fundamental physics if correct",
                "Braneworld scenarios: our universe could be a 4D brane in 11D space",
                "The Big Bang may be a collision between two branes",
                "Dark matter may consist of particles stuck on a parallel nearby brane"
            ]
        )
    ]

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
                            Image(systemName: "cube.transparent.fill")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, Color(red: 0.78, green: 0.52, blue: 1.0).opacity(0.85)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("Dimensions")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text("From a line to M-theory · \(dimensions.count) dimensions explored")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.55))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 14)

                    // Intro card
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(red: 0.65, green: 0.45, blue: 1.0).opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color(red: 0.65, green: 0.45, blue: 1.0).opacity(0.22), lineWidth: 1)
                            )

                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.65, green: 0.45, blue: 1.0).opacity(0.12))
                                    .frame(width: 64, height: 64)
                                Text("∞")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(Color(red: 0.65, green: 0.45, blue: 1.0))
                            }

                            VStack(alignment: .leading, spacing: 5) {
                                Text("Dimensions of Reality")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Our universe may contain far more dimensions than the three we experience. From lines to hyperspace, each dimension unlocks new physics.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.65))
                                    .lineSpacing(3)
                            }
                        }
                        .padding(16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 6)

                    VStack(spacing: 10) {
                        ForEach(dimensions) { dimension in
                            DimensionRowCard(dimension: dimension)
                        }
                    }
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

struct DimensionView_Previews: PreviewProvider {
    static var previews: some View {
        DimensionsView()
    }
}
