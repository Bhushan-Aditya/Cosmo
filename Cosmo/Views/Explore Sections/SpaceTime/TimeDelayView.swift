import SwiftUI

struct TimeDelayView: View {
    private let themeColor = Color(red: 0.78, green: 0.55, blue: 1.0)
    @State private var selectedTab = 0
    @State private var starfieldRotation: Double = 0

    let tabs = ["Overview", "Effects", "Space Impact", "Future"]

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
                            Image(systemName: "clock.arrow.2.circlepath")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, themeColor.opacity(0.85)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("Time Delay")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text("Relativistic time dilation across the cosmos")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.55))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 14)

                    // Hero
                    ConceptHeroView(
                        emoji: "⏰",
                        title: "Time Dilation",
                        subtitle: "Time passes at different rates depending on velocity and gravity — a proven consequence of Einstein's relativity confirmed by GPS satellites every day.",
                        color: themeColor
                    )
                    .padding(.horizontal, 16)

                    ConceptTabBar(tabs: tabs, selected: $selectedTab, color: themeColor)

                    VStack(alignment: .leading, spacing: 10) {
                        switch selectedTab {
                        case 0: overviewCards
                        case 1: effectsCards
                        case 2: spaceImpactCards
                        case 3: futureCards
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
            SectionHeader(title: "Understanding Time Delay", color: themeColor)
            InfoCard(icon: "⏱️", title: "Two Types of Dilation",
                content: "Time dilation has two causes: velocity (special relativity — fast-moving clocks tick slower) and gravity (general relativity — clocks near massive objects tick slower).",
                accentColor: themeColor)
            InfoCard(icon: "🌍", title: "Earth's Own Effect",
                content: "Earth's gravity causes measurable time differences between sea level and mountaintops. Clocks on a mountain tick faster by ~30 nanoseconds per day.",
                accentColor: themeColor)
            InfoCard(icon: "⚡", title: "Speed Effects",
                content: "At 90% of light speed, time passes ~2× slower on the moving object. At 99.9%, it's ~22× slower — the basis of the 'twin paradox'.",
                accentColor: themeColor)
            InfoCard(icon: "✅", title: "Confirmed Science",
                content: "Not theoretical speculation — time dilation has been measured with atomic clocks on aircraft, GPS satellites, and particle accelerators.",
                accentColor: themeColor)
        }
    }

    private var effectsCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Observable Effects", color: themeColor)
            InfoCard(icon: "🛰️", title: "GPS Satellites",
                content: "GPS satellites must correct for +45 µs/day (gravitational) and −7 µs/day (velocity) time shifts. Without these corrections, GPS would drift ~10 km/day.",
                accentColor: themeColor)
            InfoCard(icon: "🔬", title: "Atomic Clocks",
                content: "NIST atomic clocks have confirmed altitude-based time dilation. A clock on a 1-metre-higher shelf ticks measurably faster.",
                accentColor: themeColor)
            InfoCard(icon: "🚀", title: "Astronaut Aging",
                content: "Scott Kelly aged 5 ms less than his twin during a year on the ISS. Small, but perfectly predicted by relativity theory.",
                accentColor: themeColor)
            InfoCard(icon: "📡", title: "Deep Space Comms",
                content: "Signal delays from distant probes (Voyager 1 now has a 22-hour one-way delay) force missions to operate autonomously.",
                accentColor: themeColor)
        }
    }

    private var spaceImpactCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Impact on Exploration", color: themeColor)
            InfoCard(icon: "🌌", title: "Mars Communication",
                content: "Mars signals take 3–22 minutes one-way. Rovers can't be driven in real time — they use pre-programmed autonomous navigation.",
                accentColor: themeColor)
            InfoCard(icon: "👨‍🚀", title: "Crew Autonomy",
                content: "As missions go deeper, communication lag makes Earth-based control impossible. Crews must be trained to make all life-critical decisions independently.",
                accentColor: themeColor)
            InfoCard(icon: "🤖", title: "Autonomous Systems",
                content: "AI is essential for deep-space missions — onboard systems must detect faults, plan repairs, and execute emergency manoeuvres without Earth guidance.",
                accentColor: themeColor)
            InfoCard(icon: "📊", title: "Mission Architecture",
                content: "All deep-space missions must be designed with 'time delay windows' — pre-planned decision trees for scenarios where Earth contact is impossible.",
                accentColor: themeColor)
        }
    }

    private var futureCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Future Implications", color: themeColor)
            InfoCard(icon: "🔮", title: "Interstellar Clocks",
                content: "A crew travelling to Alpha Centauri at 50% light speed would return 4+ years younger than Earth colleagues — a real mission-design challenge.",
                accentColor: themeColor)
            InfoCard(icon: "🌟", title: "Time Banking",
                content: "Near-light-speed travel could allow explorers to 'bank' time — spending decades exploring while only aging months, returning to a far-future Earth.",
                accentColor: themeColor)
            InfoCard(icon: "💻", title: "Quantum Communication",
                content: "Research into quantum entanglement may eventually allow instant information transfer — bypassing the light-speed communication delay entirely.",
                accentColor: themeColor)
            InfoCard(icon: "🎯", title: "Navigation Precision",
                content: "Next-generation deep-space navigation will require relativistic corrections for spacecraft clocks, especially near Jupiter-mass gravity sources.",
                accentColor: themeColor)
        }
    }
}

struct TimeDelayView_Previews: PreviewProvider {
    static var previews: some View {
        TimeDelayView()
    }
}
