import SwiftUI

struct GravitationalDelayView: View {
    @State private var selectedSection = 0
    @State private var isAnimating = false
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    @State private var zoomLevel: Double = 1.0
    
    let sections = ["Overview", "Effects", "Applications", "Research"]
    
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
                
                Text("Gravitational Delay")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Time Dilation in Space")
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
                applicationsSection
            case 3:
                researchSection
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
extension GravitationalDelayView {
    var overviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Understanding Gravitational Delay")
            
            InfoCard(
                icon: "⏱️",
                title: "What is it?",
                content: "Gravitational time dilation is the difference in elapsed time between two events as measured by observers at different distances from a gravitational mass."
            )
            
            InfoCard(
                icon: "🌍",
                title: "Einstein's Theory",
                content: "According to General Relativity, gravity can bend space-time, causing time to pass at different rates depending on the strength of the gravitational field."
            )
            
            InfoCard(
                icon: "⚖️",
                title: "Basic Principle",
                content: "The stronger the gravitational field (closer to a massive object), the slower time passes relative to a point with a weaker gravitational field."
            )
        }
    }
    
    var effectsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Observable Effects")
            
            InfoCard(
                icon: "🛰️",
                title: "Satellite Time Drift",
                content: "GPS satellites experience time passing faster than on Earth's surface by about 45 microseconds per day."
            )
            
            InfoCard(
                icon: "⚫",
                title: "Black Holes",
                content: "Near black holes, gravitational time dilation becomes extreme, leading to dramatic differences in the passage of time."
            )
            
            InfoCard(
                icon: "🚀",
                title: "Space Travel",
                content: "Astronauts in orbit experience time slightly faster than people on Earth, though the effect is minimal at typical orbital altitudes."
            )
        }
    }
    
    var applicationsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Practical Applications")
            
            InfoCard(
                icon: "📍",
                title: "GPS Systems",
                content: "GPS satellites must account for both gravitational and velocity-based time dilation to maintain accurate positioning."
            )
            
            InfoCard(
                icon: "🛸",
                title: "Space Navigation",
                content: "Space missions consider gravitational time dilation in their calculations for precise navigation and timing."
            )
            
            InfoCard(
                icon: "📡",
                title: "Communication",
                content: "Deep space communications must account for gravitational time effects in signal transmission and reception."
            )
        }
    }
    
    var researchSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Current Research")
            
            InfoCard(
                icon: "🔬",
                title: "Precision Tests",
                content: "Scientists use atomic clocks to measure and verify gravitational time dilation with increasing precision."
            )
            
            InfoCard(
                icon: "🌌",
                title: "Cosmological Studies",
                content: "Research into how gravitational time dilation affects our understanding of the early universe and cosmic evolution."
            )
            
            InfoCard(
                icon: "🧪",
                title: "New Applications",
                content: "Exploring potential applications in quantum computing and next-generation navigation systems."
            )
        }
    }
}

// MARK: - Preview
struct GravitationalDelayView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GravitationalDelayView()
        }
        .preferredColorScheme(.dark)
    }
}
