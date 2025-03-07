import SwiftUI

struct TimeDelayView: View {
    @State private var selectedSection = 0
    @State private var isAnimating = false
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    @State private var zoomLevel: Double = 1.0
    
    let sections = ["Overview", "Effects", "Space Impact", "Future"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Hero Section
                heroSection
                
                // Section Selector
                sectionSelector
                
                // Content Section
                contentSection
                
                Spacer(minLength: 50)
            }
        }
        .background(
            EnhancedCosmicBackground(
                parallaxOffset: parallaxOffset,
                starfieldRotation: starfieldRotation,
                zoomLevel: zoomLevel
            )
        )
        .onAppear(perform: startAnimations)
        .gesture(createParallaxGesture())
    }
    
    private var heroSection: some View {
        ZStack {
            Circle()
                .fill(Color.purple.opacity(0.1))
                .frame(width: 200, height: 200)
                .blur(radius: 20)
            
            VStack(spacing: 15) {
                Text("⏰")
                    .font(.system(size: 60))
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                
                Text("Time Delay")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Relativistic Effects in Space")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 20)
    }
    
    private var sectionSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(0..<sections.count, id: \.self) { index in
                    Button(action: {
                        withAnimation {
                            selectedSection = index
                        }
                    }) {
                        Text(sections[index])
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedSection == index ?
                                          Color.purple.opacity(0.3) :
                                          Color.black.opacity(0.3))
                            )
                            .foregroundColor(selectedSection == index ?
                                           .white : .gray)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 25) {
            switch selectedSection {
            case 0:
                overviewSection
            case 1:
                effectsSection
            case 2:
                spaceImpactSection
            case 3:
                futureSection
            default:
                EmptyView()
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut, value: selectedSection)
    }
    
    private func startAnimations() {
        withAnimation(Animation.easeInOut(duration: 2.0).repeatForever()) {
            isAnimating = true
        }
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            starfieldRotation = 360
        }
    }
    
    private func createParallaxGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                parallaxOffset = value.translation.width
            }
            .onEnded { _ in
                withAnimation(.spring()) {
                    parallaxOffset = 0
                }
            }
    }
}

// MARK: - Content Sections
extension TimeDelayView {
    var overviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Understanding Time Delay")
            
            InfoCard(
                icon: "⏱️",
                title: "Basic Concept",
                content: "Time dilation occurs due to both velocity (special relativity) and gravity (general relativity)"
            )
            
            InfoCard(
                icon: "🌍",
                title: "Earth's Influence",
                content: "Earth's gravity causes measurable time differences between sea level and higher altitudes" // Changed 'text' to 'content'
            )
            
            InfoCard(
                icon: "⚡",
                title: "Speed Effects",
                content: "Time passes more slowly for objects moving at high velocities relative to stationary observers"
            )
        }
    }

    var effectsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Observable Effects")
            
            InfoCard(
                icon: "🛰️",
                title: "Satellite Systems",
                content: "GPS satellites must account for time dilation to maintain accurate positioning"
            )
            
            InfoCard(
                icon: "🔬",
                title: "Atomic Clocks",
                content: "Precise atomic clocks can measure time differences at different altitudes"
            )
            
            InfoCard(
                icon: "🚀",
                title: "Space Travel",
                content: "Astronauts experience slight time dilation during space missions"
            )
            
            InfoCard(
                icon: "📡",
                title: "Communication",
                content: "Signal delays affect deep space communication and navigation"
            )
        }
    }
    
    var spaceImpactSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Impact on Space Exploration")
            
            InfoCard(
                icon: "🌌",
                title: "Deep Space Missions",
                content: "Time delays affect communication and coordination with distant spacecraft"
            )
            
            InfoCard(
                icon: "👨‍🚀",
                title: "Human Factors",
                content: "Psychological impact of communication delays on space crews"
            )
            
            InfoCard(
                icon: "🤖",
                title: "Autonomous Systems",
                content: "Need for autonomous operation due to communication delays"
            )
            
            InfoCard(
                icon: "📊",
                title: "Mission Planning",
                content: "Time delay considerations in space mission planning and execution"
            )
        }
    }
    
    var futureSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Future Implications")
            
            InfoCard(
                icon: "🔮",
                title: "Research Directions",
                content: "Ongoing research into methods to minimize or compensate for time delays"
            )
            
            InfoCard(
                icon: "🌟",
                title: "Interstellar Travel",
                content: "Time dilation effects on potential future interstellar missions"
            )
            
            InfoCard(
                icon: "💻",
                title: "Technology Development",
                content: "Advanced systems for managing time delay challenges"
            )
            
            InfoCard(
                icon: "🎯",
                title: "Navigation Systems",
                content: "Next-generation navigation accounting for relativistic effects"
            )
        }
    }
}

// MARK: - Preview
struct TimeDelayView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimeDelayView()
        }
        .preferredColorScheme(.dark)
    }
}
