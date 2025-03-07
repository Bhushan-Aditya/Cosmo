import SwiftUI

// MARK: - Info Card Component
struct InfoCard: View {
    let icon: String
    let title: String
    let content: String
    @State private var isHovered = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text(icon)
                .font(.title2)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(content)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.blue.opacity(isHovered ? 0.5 : 0.3), lineWidth: 1)
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
    }
}
struct CryogenicSleepView: View {
    @State private var selectedSection = 0
    @State private var isAnimating = false
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    @State private var zoomLevel: Double = 1.0
    
    let sections = ["Overview", "Technology", "Challenges", "Future"]
    
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
                .fill(Color.blue.opacity(0.1))
                .frame(width: 200, height: 200)
                .blur(radius: 20)
            
            VStack(spacing: 15) {
                Text("❄️")
                    .font(.system(size: 60))
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                
                Text("Cryogenic Sleep")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("The Future of Deep Space Travel")
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
                                          Color.blue.opacity(0.3) :
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
                technologySection
            case 2:
                challengesSection
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
extension CryogenicSleepView {
    var overviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "What is Cryogenic Sleep?")
            
            InfoCard(
                icon: "❄️",
                title: "Definition",
                content: "A proposed technology for preserving human life during long-duration space travel by significantly reducing metabolic activity."
            )
            
            InfoCard(
                icon: "🚀",
                title: "Purpose",
                content: "Enable human deep space exploration by placing crew members in a state of suspended animation."
            )
            
            InfoCard(
                icon: "⏰",
                title: "Duration",
                content: "Theoretical capability of maintaining suspension for months to years while consuming minimal resources."
            )
        }
    }
    
    var technologySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Core Technologies")
            
            InfoCard(
                icon: "🌡️",
                title: "Temperature Control",
                content: "Precise cooling systems to lower body temperature without causing cellular damage."
            )
            
            InfoCard(
                icon: "🧬",
                title: "Cellular Preservation",
                content: "Advanced cryoprotectants to prevent ice crystal formation in cells."
            )
            
            InfoCard(
                icon: "💓",
                title: "Metabolic Regulation",
                content: "Systems to safely reduce and monitor metabolic rates during suspension."
            )
            
            InfoCard(
                icon: "🤖",
                title: "AI Monitoring",
                content: "Artificial intelligence systems for continuous health monitoring and maintenance."
            )
        }
    }
    
    var challengesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Current Challenges")
            
            InfoCard(
                icon: "🧊",
                title: "Ice Formation",
                content: "Preventing damaging ice crystals from forming within cells during the cooling process."
            )
            
            InfoCard(
                icon: "🩺",
                title: "Organ Preservation",
                content: "Maintaining organ integrity during long-term metabolic suspension."
            )
            
            InfoCard(
                icon: "🧠",
                title: "Neural Protection",
                content: "Ensuring brain function and memory preservation during suspension and revival."
            )
            
            InfoCard(
                icon: "⚡",
                title: "Energy Requirements",
                content: "Maintaining stable power supply for life support systems during extended periods."
            )
        }
    }
    
    var futureSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Future Prospects")
            
            InfoCard(
                icon: "🌌",
                title: "Deep Space Travel",
                content: "Enable human missions to distant planets and solar systems."
            )
            
            InfoCard(
                icon: "🏥",
                title: "Medical Applications",
                content: "Emergency preservation of critically ill patients during transport."
            )
            
            InfoCard(
                icon: "🛸",
                title: "Space Colonization",
                content: "Efficient transport of colonists to distant space settlements."
            )
            
            InfoCard(
                icon: "🔬",
                title: "Research Advancement",
                content: "Development of new preservation technologies and understanding of human physiology."
            )
        }
    }
}

// MARK: - Preview
struct CryogenicSleepView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CryogenicSleepView()
        }
        .preferredColorScheme(.dark)
    }
}
