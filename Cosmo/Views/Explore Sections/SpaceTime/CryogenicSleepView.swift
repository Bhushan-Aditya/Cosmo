import SwiftUI

// MARK: - Shared Components (used by tab-based concept views)

struct InfoCard: View {
    let icon: String
    let title: String
    let content: String
    var accentColor: Color = Color(red: 0.45, green: 0.75, blue: 1.0)

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.14))
                    .frame(width: 44, height: 44)
                Text(icon)
                    .font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(content)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.72))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(accentColor.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(accentColor.opacity(0.22), lineWidth: 1)
                )
        )
    }
}

struct SectionHeader: View {
    let title: String
    var color: Color = .white

    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(color.opacity(0.8))
                .frame(width: 3, height: 20)
                .cornerRadius(2)
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}

// MARK: - Concept Hero View
struct ConceptHeroView: View {
    let emoji: String
    let title: String
    let subtitle: String
    let color: Color

    @State private var pulse = false
    @State private var rotate = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.18), color.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(color.opacity(0.28), lineWidth: 1)
                )

            HStack(spacing: 20) {
                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(color.opacity(0.12 - Double(i) * 0.03))
                            .frame(
                                width: 80 + CGFloat(i * 22),
                                height: 80 + CGFloat(i * 22)
                            )
                            .scaleEffect(pulse ? 1 + Double(i) * 0.04 : 1)
                            .animation(
                                .easeInOut(duration: 2.0 + Double(i) * 0.5)
                                    .repeatForever(autoreverses: true),
                                value: pulse
                            )
                    }
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.14))
                            .frame(width: 72, height: 72)
                            .overlay(Circle().stroke(color.opacity(0.32), lineWidth: 1))
                        Text(emoji)
                            .font(.system(size: 34))
                    }
                }
                .frame(width: 120)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.58))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(20)
        }
        .onAppear { pulse = true }
    }
}

// MARK: - Concept Tab Selector
struct ConceptTabBar: View {
    let tabs: [String]
    @Binding var selected: Int
    let color: Color

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tabs.indices, id: \.self) { i in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                            selected = i
                        }
                    } label: {
                        Text(tabs[i])
                            .font(.system(size: 13, weight: selected == i ? .semibold : .regular))
                            .foregroundColor(selected == i ? .black : .white.opacity(0.65))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(selected == i ? color : Color.white.opacity(0.08))
                                    .overlay(
                                        Capsule(style: .continuous)
                                            .stroke(
                                                selected == i ? color.opacity(0) : Color.white.opacity(0.14),
                                                lineWidth: 1
                                            )
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Cryogenic Sleep View
struct CryogenicSleepView: View {
    private let themeColor = Color(red: 0.52, green: 0.92, blue: 0.96)
    @State private var selectedTab = 0
    @State private var starfieldRotation: Double = 0
    @State private var cardsVisible = false

    let tabs = ["Overview", "Technology", "Challenges", "Future"]

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
                            Image(systemName: "snowflake")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, themeColor.opacity(0.85)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("Cryogenic Sleep")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text("Suspended animation for deep-space travel")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.55))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 14)

                    // Hero
                    ConceptHeroView(
                        emoji: "❄️",
                        title: "Suspended Animation",
                        subtitle: "A proposed technology to preserve human life by dramatically reducing metabolic activity during long space voyages.",
                        color: themeColor
                    )
                    .padding(.horizontal, 16)

                    // Tab selector
                    ConceptTabBar(tabs: tabs, selected: $selectedTab, color: themeColor)

                    // Content
                    VStack(alignment: .leading, spacing: 10) {
                        switch selectedTab {
                        case 0: overviewCards
                        case 1: techCards
                        case 2: challengeCards
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
            SectionHeader(title: "What is Cryogenic Sleep?", color: themeColor)
            InfoCard(icon: "❄️", title: "Definition",
                content: "A proposed method to preserve human life by cooling the body to near-freezing temperatures, dramatically slowing metabolism and aging.",
                accentColor: themeColor)
            InfoCard(icon: "🚀", title: "Purpose",
                content: "Enable human missions beyond our solar system by placing crew in suspended animation — crossing light-years without aging.",
                accentColor: themeColor)
            InfoCard(icon: "⏰", title: "Duration",
                content: "Theoretically capable of maintaining suspension from months to decades while consuming minimal power and resources.",
                accentColor: themeColor)
            InfoCard(icon: "🧊", title: "Current State",
                content: "Therapeutic hypothermia already exists in medicine. True stasis remains theoretical, but NASA and private companies are funding research.",
                accentColor: themeColor)
        }
    }

    private var techCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Core Technologies", color: themeColor)
            InfoCard(icon: "🌡️", title: "Temperature Control",
                content: "Precision cooling systems lower core body temperature to ~10 °C without causing fatal ice crystal formation in cells.",
                accentColor: themeColor)
            InfoCard(icon: "🧬", title: "Cryoprotectants",
                content: "Chemical agents (like DMSO or glycerol) infiltrate cells and prevent ice formation — the key challenge in vitrification.",
                accentColor: themeColor)
            InfoCard(icon: "💓", title: "Metabolic Suppression",
                content: "Drugs or genetic modifications could reduce metabolic rates below 10% of normal, dramatically slowing aging and resource consumption.",
                accentColor: themeColor)
            InfoCard(icon: "🤖", title: "AI Life Monitoring",
                content: "Autonomous systems continuously monitor vital signs, adjust cooling, and can revive crew if anomalies are detected.",
                accentColor: themeColor)
        }
    }

    private var challengeCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Current Challenges", color: themeColor)
            InfoCard(icon: "🧊", title: "Ice Crystal Damage",
                content: "Even with cryoprotectants, ice crystals can rupture cell membranes. Vitrification (glass-like solidification) is the leading solution.",
                accentColor: themeColor)
            InfoCard(icon: "🩺", title: "Organ Integrity",
                content: "Different organs cool at different rates. Maintaining simultaneous whole-body integrity during cooling and rewarming is unresolved.",
                accentColor: themeColor)
            InfoCard(icon: "🧠", title: "Neural Preservation",
                content: "The brain's complex synaptic network is especially vulnerable. Memory and cognitive function preservation during stasis is unknown.",
                accentColor: themeColor)
            InfoCard(icon: "⚡", title: "Power Demand",
                content: "Maintaining stable sub-zero temperatures for years requires reliable power — a critical constraint on deep-space missions.",
                accentColor: themeColor)
        }
    }

    private var futureCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Future Prospects", color: themeColor)
            InfoCard(icon: "🌌", title: "Interstellar Missions",
                content: "With cryosleep, a 40-year journey to Proxima Centauri becomes viable — crew arrive physiologically no older than when they left.",
                accentColor: themeColor)
            InfoCard(icon: "🏥", title: "Emergency Medicine",
                content: "Near-term applications include trauma preservation — keeping patients in stasis during transport to advanced surgical facilities.",
                accentColor: themeColor)
            InfoCard(icon: "🛸", title: "Colony Ships",
                content: "Generational colony missions could carry thousands of settlers in stasis, reducing life-support demands by 95% or more.",
                accentColor: themeColor)
            InfoCard(icon: "🔬", title: "Longevity Research",
                content: "Understanding cryopreservation may unlock breakthroughs in aging, organ storage, and the treatment of degenerative diseases.",
                accentColor: themeColor)
        }
    }
}

struct CryogenicSleepView_Previews: PreviewProvider {
    static var previews: some View {
        CryogenicSleepView()
    }
}
