import SwiftUI

struct GravitationalDelayView: View {
    private let themeColor = Color(red: 1.0, green: 0.72, blue: 0.28)
    @State private var selectedTab = 0
    @State private var starfieldRotation: Double = 0

    let tabs = ["Overview", "Effects", "Applications", "Research"]

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
                            Image(systemName: "waveform.path.ecg")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, themeColor.opacity(0.85)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("Gravitational Delay")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text("How gravity bends the flow of time itself")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.55))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 14)

                    // Hero
                    ConceptHeroView(
                        emoji: "⚖️",
                        title: "Gravity & Time",
                        subtitle: "Massive objects don't just warp space — they stretch time itself. The stronger the gravitational field, the slower time flows. This is measurable and real.",
                        color: themeColor
                    )
                    .padding(.horizontal, 16)

                    ConceptTabBar(tabs: tabs, selected: $selectedTab, color: themeColor)

                    VStack(alignment: .leading, spacing: 10) {
                        switch selectedTab {
                        case 0: overviewCards
                        case 1: effectsCards
                        case 2: applicationCards
                        case 3: researchCards
                        default: EmptyView()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 36)
                    .animation(.easeInOut(duration: 0.25), value: selectedTab)
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

    private var overviewCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Understanding Gravitational Delay", color: themeColor)
            InfoCard(icon: "⏱️", title: "What is it?",
                content: "Gravitational time dilation: the closer an object is to a massive body, the slower time passes for it — relative to observers in weaker gravitational fields.",
                accentColor: themeColor)
            InfoCard(icon: "🌍", title: "Einstein's Insight",
                content: "General Relativity (1915) predicted that mass curves spacetime. The greater the curvature, the slower time flows — confirmed by every GPS satellite in orbit.",
                accentColor: themeColor)
            InfoCard(icon: "📐", title: "The Formula",
                content: "Time dilation factor = √(1 – 2GM/rc²). Near a black hole's event horizon, this factor approaches zero — time nearly stops for outside observers.",
                accentColor: themeColor)
            InfoCard(icon: "🏔️", title: "Everyday Reality",
                content: "Your feet age measurably slower than your head — Earth's gravity is slightly stronger at sea level. The difference is ~10 ns per year per metre of height.",
                accentColor: themeColor)
        }
    }

    private var effectsCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Observable Effects", color: themeColor)
            InfoCard(icon: "🛰️", title: "GPS Time Drift",
                content: "GPS satellites at 20,200 km experience weaker gravity — their clocks run 45 µs/day faster than Earth clocks. This is corrected continuously.",
                accentColor: themeColor)
            InfoCard(icon: "⚫", title: "Near Black Holes",
                content: "An observer near a stellar black hole would age years while distant observers age decades. Near supermassive black holes, the effect is extreme.",
                accentColor: themeColor)
            InfoCard(icon: "☀️", title: "Solar Gravity",
                content: "Clocks on the Sun's surface run ~2.1 ms/day slower than on Earth due to the Sun's much stronger gravity field.",
                accentColor: themeColor)
            InfoCard(icon: "🌊", title: "Shapiro Delay",
                content: "Radar signals passing near the Sun are measurably delayed by solar gravity — first confirmed in 1966 by bouncing signals off Mercury.",
                accentColor: themeColor)
        }
    }

    private var applicationCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Practical Applications", color: themeColor)
            InfoCard(icon: "📍", title: "GPS Accuracy",
                content: "Modern GPS must account for both gravitational (+45 µs/day) and velocity-based (−7 µs/day) time dilation. Net correction: +38 µs/day per satellite.",
                accentColor: themeColor)
            InfoCard(icon: "🛸", title: "Spacecraft Navigation",
                content: "Deep-space probes like New Horizons require relativistic corrections in trajectory calculations when passing near large planets.",
                accentColor: themeColor)
            InfoCard(icon: "📡", title: "Pulsar Timing",
                content: "Astronomers use pulsars as cosmic clocks. Gravitational time dilation near companion stars produces measurable pulse-arrival-time shifts.",
                accentColor: themeColor)
            InfoCard(icon: "🔭", title: "Gravitational Lensing",
                content: "Related to time dilation, gravitational lensing bends light around massive objects — used to discover exoplanets and distant galaxies.",
                accentColor: themeColor)
        }
    }

    private var researchCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Current Research", color: themeColor)
            InfoCard(icon: "⏱️", title: "Optical Clocks",
                content: "Next-generation optical atomic clocks can measure 1 cm altitude changes through gravitational time dilation — a new form of geodesy.",
                accentColor: themeColor)
            InfoCard(icon: "🌌", title: "Cosmological Tests",
                content: "Studying gravitational time dilation in galaxy clusters tests General Relativity at the largest scales and probes dark matter distribution.",
                accentColor: themeColor)
            InfoCard(icon: "🔬", title: "Quantum Gravity",
                content: "The intersection of quantum mechanics and gravitational time dilation is one of physics' greatest open questions — and a route to a Theory of Everything.",
                accentColor: themeColor)
            InfoCard(icon: "🧪", title: "Laboratory Tests",
                content: "Experiments at CERN and NIST confirm gravitational time dilation at centimetre scales, validating General Relativity with unprecedented precision.",
                accentColor: themeColor)
        }
    }
}

struct GravitationalDelayView_Previews: PreviewProvider {
    static var previews: some View {
        GravitationalDelayView()
    }
}
