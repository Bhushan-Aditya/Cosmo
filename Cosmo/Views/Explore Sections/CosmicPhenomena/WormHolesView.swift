import SwiftUI

// MARK: - Model
struct Wormhole: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let tagline: String
    let accentColor: Color
    let icon: String
    let description: String
    let characteristics: [String]
    let requirements: [String]
    let uses: [String]
    let challenges: [String]
}

// MARK: - Animated Wormhole Tunnel
struct WormholeTunnel: View {
    let color: Color
    let size: CGFloat
    @State private var phase: Double = 0

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, canvasSize in
                let cx = canvasSize.width / 2
                let cy = canvasSize.height / 2
                let rings = 7
                for i in 0..<rings {
                    let frac = Double(i) / Double(rings)
                    let r = (size / 2) * (1 - frac * 0.88)
                    let alpha = (1 - frac) * 0.55
                    let scale = 1 + sin(t * 1.4 + frac * .pi * 2) * 0.06
                    let rect = CGRect(
                        x: cx - r * scale,
                        y: cy - r * scale,
                        width: r * 2 * scale,
                        height: r * 2 * scale
                    )
                    ctx.stroke(
                        Path(ellipseIn: rect),
                        with: .color(color.opacity(alpha)),
                        lineWidth: 1.5
                    )
                }
                // Central glow dot
                let dotR: Double = 5
                ctx.fill(
                    Path(ellipseIn: CGRect(x: cx - dotR, y: cy - dotR, width: dotR * 2, height: dotR * 2)),
                    with: .color(color.opacity(0.9))
                )
                ctx.fill(
                    Path(ellipseIn: CGRect(x: cx - dotR * 2.5, y: cy - dotR * 2.5, width: dotR * 5, height: dotR * 5)),
                    with: .color(color.opacity(0.25))
                )
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Wormhole Row Card
struct WormholeRowCard: View {
    let wormhole: Wormhole
    @State private var showDetails = false

    var body: some View {
        Button(action: { showDetails = true }) {
            HStack(spacing: 14) {
                WormholeTunnel(color: wormhole.accentColor, size: 62)
                    .frame(width: 62, height: 62)

                VStack(alignment: .leading, spacing: 5) {
                    Text(wormhole.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(wormhole.tagline)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.52))
                        .lineLimit(1)

                    Text(wormhole.type)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(wormhole.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(wormhole.accentColor.opacity(0.12)))
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
                            colors: [wormhole.accentColor.opacity(0.08), Color.black.opacity(0.22)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(wormhole.accentColor.opacity(0.22), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetails) {
            WormholeDetailView(wormhole: wormhole)
        }
    }
}

// MARK: - Wormhole Detail Sheet
struct WormholeDetailView: View {
    let wormhole: Wormhole
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSection = 0

    let sections = ["Characteristics", "Requirements", "Uses", "Challenges"]

    var sectionData: [String] {
        switch selectedSection {
        case 0: return wormhole.characteristics
        case 1: return wormhole.requirements
        case 2: return wormhole.uses
        case 3: return wormhole.challenges
        default: return []
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, wormhole.accentColor.opacity(0.10), Color.black],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Hero tunnel
                    ZStack {
                        Circle()
                            .fill(wormhole.accentColor.opacity(0.08))
                            .frame(width: 200, height: 200)
                            .blur(radius: 40)
                        WormholeTunnel(color: wormhole.accentColor, size: 130)
                    }
                    .frame(height: 160)
                    .padding(.top, 28)

                    // Name + type
                    VStack(spacing: 10) {
                        Text(wormhole.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text(wormhole.type)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(wormhole.accentColor)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                Capsule().fill(wormhole.accentColor.opacity(0.14))
                                    .overlay(Capsule().stroke(wormhole.accentColor.opacity(0.4), lineWidth: 1))
                            )
                    }
                    .padding(.horizontal, 24)

                    // Description
                    Text(wormhole.description)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 28)

                    // Section tabs
                    ConceptTabBar(
                        tabs: sections,
                        selected: Binding(
                            get: { selectedSection },
                            set: { selectedSection = $0 }
                        ),
                        color: wormhole.accentColor
                    )

                    // Section items
                    VStack(spacing: 8) {
                        ForEach(Array(sectionData.enumerated()), id: \.element) { idx, item in
                            HStack(alignment: .top, spacing: 13) {
                                ZStack {
                                    Circle()
                                        .fill(wormhole.accentColor.opacity(0.18))
                                        .frame(width: 32, height: 32)
                                    Text("\(idx + 1)")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(wormhole.accentColor)
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
                                            colors: [wormhole.accentColor.opacity(0.11), wormhole.accentColor.opacity(0.04)],
                                            startPoint: .topLeading, endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(wormhole.accentColor.opacity(0.20), lineWidth: 1)
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
struct WormholeView: View {
    @State private var starfieldRotation: Double = 0

    let wormholes: [Wormhole] = [
        Wormhole(
            name: "Einstein-Rosen Bridge",
            type: "Einstein-Rosen Bridge",
            tagline: "The original spacetime shortcut",
            accentColor: Color(red: 0.55, green: 0.42, blue: 1.0),
            icon: "🌀",
            description: "Predicted by Einstein and Rosen in 1935 as a solution to general relativity, connecting two separate points in spacetime through a curved tunnel.",
            characteristics: [
                "Connects two distant regions of spacetime or separate universes",
                "Emerges naturally from Schwarzschild black hole solutions",
                "Theoretically forms at the singularity of every black hole",
                "Quantum-mechanically unstable — collapses before anything can traverse it"
            ],
            requirements: [
                "Exotic matter with negative energy density to hold throat open",
                "Extremely strong gravitational fields at both endpoints",
                "Quantum stabilisation mechanisms not yet understood",
                "Energy scale likely at or above Planck energy (~10¹⁹ GeV)"
            ],
            uses: [
                "Instantaneous travel between distant cosmic locations",
                "Potential shortcut for interstellar or intergalactic missions",
                "Laboratory for studying quantum gravity effects",
                "Probe the topology of spacetime"
            ],
            challenges: [
                "Quantum instability destroys the throat near-instantaneously",
                "Hawking radiation at the throat would be lethal",
                "No known source of exotic matter with negative energy density",
                "Causality violations could create paradoxes"
            ]
        ),
        Wormhole(
            name: "Morris-Thorne Wormhole",
            type: "Traversable",
            tagline: "The first human-passable design",
            accentColor: Color(red: 0.72, green: 0.38, blue: 1.0),
            icon: "🕳️",
            description: "In 1988, physicists Morris and Thorne designed the first wormhole theoretically traversable by humans — requiring exotic matter but surviving long enough to pass through.",
            characteristics: [
                "Two-way passage — travellers can enter and exit at either mouth",
                "Large enough throat to allow human-scale objects to pass",
                "Requires continuous exotic matter to prevent collapse",
                "Tidal forces can be tuned to survivable levels"
            ],
            requirements: [
                "Steady supply of exotic matter with negative energy density",
                "Active stabilisation against vacuum energy fluctuations",
                "Radiation shielding for extreme energy conditions at throat",
                "Precise engineering of spacetime geometry"
            ],
            uses: [
                "Rapid interstellar transit bypassing light-speed limits",
                "Potential time travel if one mouth is accelerated",
                "Instantaneous communication network across the galaxy",
                "Scientific platform for studying extreme gravity"
            ],
            challenges: [
                "Exotic matter has never been observed in sufficient quantities",
                "Casimir effect produces tiny negative energy — orders of magnitude too small",
                "Feedback instability may destroy it when any mass enters",
                "Energy requirements exceed current theoretical bounds"
            ]
        ),
        Wormhole(
            name: "ER = EPR Wormhole",
            type: "Quantum / Lorentzian",
            tagline: "Entanglement is a wormhole",
            accentColor: Color(red: 0.88, green: 0.42, blue: 1.0),
            icon: "🔗",
            description: "Proposed by Maldacena and Susskind in 2013: quantum entangled particles (EPR pairs) are connected by a microscopic wormhole (ER bridge) — unifying quantum mechanics and general relativity.",
            characteristics: [
                "Microscopic wormholes connecting entangled quantum particles",
                "Non-traversable — information cannot pass through classically",
                "Provides a geometric interpretation of quantum entanglement",
                "Central to holographic theories of spacetime"
            ],
            requirements: [
                "Quantum entanglement between two regions",
                "Holographic duality (AdS/CFT correspondence) to hold",
                "No classical information transfer — only quantum correlations",
                "Understanding of quantum gravity at Planck scales"
            ],
            uses: [
                "Unifying quantum mechanics with general relativity",
                "Understanding black hole information paradox",
                "Foundation for quantum gravity theories",
                "Potential insight into quantum computing architectures"
            ],
            challenges: [
                "No classical signal can travel through it — not useful for transport",
                "Only applies rigorously in highly symmetric mathematical universes",
                "Physical reality of the connection is still debated",
                "Requires a complete theory of quantum gravity to fully verify"
            ]
        ),
        Wormhole(
            name: "Casimir Wormhole",
            type: "Exotic Matter",
            tagline: "The vacuum energy shortcut",
            accentColor: Color(red: 0.45, green: 0.62, blue: 1.0),
            icon: "⚡",
            description: "Proposed to use the Casimir effect — the real negative energy produced between closely-spaced metal plates — as the exotic matter source needed to stabilise a traversable wormhole.",
            characteristics: [
                "Uses measured negative Casimir energy as exotic matter",
                "Only viable at microscopic (sub-Planck) scales currently",
                "Theoretically self-consistent within quantum field theory",
                "First wormhole concept grounded in observed physics"
            ],
            requirements: [
                "Engineered Casimir plates at nanometre separation",
                "Scaling the effect up by ~60 orders of magnitude",
                "Novel materials with extreme electromagnetic properties",
                "Room-temperature quantum coherence maintenance"
            ],
            uses: [
                "Proof of concept that exotic matter exists in nature",
                "Foundation for laboratory-scale wormhole experiments",
                "Quantum vacuum engineering for energy applications",
                "Testing ground for traversable wormhole theories"
            ],
            challenges: [
                "Current Casimir energy is ~10⁶⁰× too small for any macroscopic wormhole",
                "Scaling laws work against larger implementations",
                "Boundary conditions destroy the effect at large scales",
                "No known path from micro to macro wormhole"
            ]
        ),
        Wormhole(
            name: "Lorentzian Wormhole",
            type: "Lorentzian",
            tagline: "Time travel made mathematical",
            accentColor: Color(red: 0.38, green: 0.75, blue: 0.95),
            icon: "🌐",
            description: "A class of wormholes existing in Lorentzian spacetime (our universe's geometry) that, unlike Euclidean wormholes, could persist and potentially allow time travel.",
            characteristics: [
                "Exists in real Lorentzian (not imaginary Euclidean) spacetime",
                "Both mouths age differently if one is accelerated or placed near gravity",
                "Time travel possible if mouth separation exceeds travel time",
                "Chronology protection conjecture may prevent stable creation"
            ],
            requirements: [
                "Traversable throat maintenance (exotic matter)",
                "Controlled acceleration of one wormhole mouth",
                "Shielding from chronic particle production at closed timelike curves",
                "Hawking's chronology protection to not trigger"
            ],
            uses: [
                "Time travel to the past after mouth age differential accumulates",
                "Connecting different epochs of the same universe",
                "Testing the limits of causality in physics",
                "Hypothetical grandfather-paradox resolution research"
            ],
            challenges: [
                "Hawking's chronology protection conjecture may prevent it",
                "Quantum vacuum fluctuations grow catastrophically near closed timelike curves",
                "Causal paradoxes may be self-consistently forbidden by physics",
                "Energy required to keep one mouth younger is enormous"
            ]
        ),
        Wormhole(
            name: "Microscopic Quantum Wormhole",
            type: "Planck-Scale",
            tagline: "Spacetime foam portals",
            accentColor: Color(red: 0.62, green: 0.90, blue: 0.65),
            icon: "🔬",
            description: "At the Planck scale (~10⁻³⁵ m), spacetime itself becomes a turbulent quantum foam of tiny wormholes spontaneously appearing and disappearing — Wheeler's vision of spacetime topology.",
            characteristics: [
                "Size: Planck length (~10⁻³⁵ m) — 10²⁰ times smaller than a proton",
                "Spontaneously appear and vanish in quantum vacuum",
                "Carry no macroscopic information or matter",
                "May be fundamental to the structure of spacetime"
            ],
            requirements: [
                "A correct theory of quantum gravity to describe them",
                "Physics at energy scales 10¹⁵ times above LHC capabilities",
                "Understanding of spacetime topology at the Planck scale",
                "No practical requirements — they already exist spontaneously"
            ],
            uses: [
                "Virtual carrier of quantum information between distant points",
                "Building block of the ER=EPR wormhole network",
                "Potential basis for spacetime itself in quantum gravity theories",
                "Research window into the Planck-scale structure of reality"
            ],
            challenges: [
                "Completely inaccessible to current or foreseeable technology",
                "No experimental way to detect them currently",
                "Quantum gravity theory needed to describe them is incomplete",
                "Enlarging one requires Planck-scale energy — beyond any known physics"
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
                            Image(systemName: "circle.dotted.and.circle")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, Color(red: 0.72, green: 0.45, blue: 1.0).opacity(0.85)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("Wormholes")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text("\(wormholes.count) types of spacetime tunnels · Tap to explore")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.55))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 14)

                    // Intro card
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.22), lineWidth: 1)
                            )

                        HStack(spacing: 16) {
                            WormholeTunnel(color: Color(red: 0.65, green: 0.42, blue: 1.0), size: 80)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Bridges in Spacetime")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Wormholes are hypothetical tunnels through the fabric of spacetime that could connect distant regions — or even different universes — in an instant.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.68))
                                    .lineSpacing(3)
                            }
                        }
                        .padding(16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 6)

                    // Wormhole cards
                    VStack(spacing: 10) {
                        ForEach(wormholes) { wormhole in
                            WormholeRowCard(wormhole: wormhole)
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

struct WormHoleView_Previews: PreviewProvider {
    static var previews: some View {
        WormholeView()
    }
}
