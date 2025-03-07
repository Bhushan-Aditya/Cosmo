import SwiftUI
// MARK: - Models
struct Comet: Identifiable {
    let id = UUID()
    let name: String
    let type: CometType
    let discovered: String
    let orbitalPeriod: String
    let lastSeen: String
    let nextAppearance: String
    let length: String
    let facts: [String]
    let color: Color
    let status: CometStatus
}

enum CometType {
    case shortPeriod
    case longPeriod
    case nonPeriodic
    
    var description: String {
        switch self {
        case .shortPeriod: return "Short-Period"
        case .longPeriod: return "Long-Period"
        case .nonPeriodic: return "Non-Periodic"
        }
    }
}

enum CometStatus {
    case active, inactive, fragmented
    
    var color: Color {
        switch self {
        case .active: return .green
        case .inactive: return .orange
        case .fragmented: return .red
        }
    }
}

// MARK: - Comet Card
struct CometCard: View {
    let comet: Comet
    @State private var showDetails = false
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: { showDetails.toggle() }) {
            VStack(spacing: 15) {
                ZStack {
                    // Comet tail effect
                    Path { path in
                        path.move(to: CGPoint(x: 40, y: 40))
                        path.addLine(to: CGPoint(x: 0, y: 40))
                    }
                    .stroke(
                        LinearGradient(
                            colors: [comet.color, comet.color.opacity(0)],
                            startPoint: .trailing,
                            endPoint: .leading
                        ),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .scaleEffect(isAnimating ? 1.2 : 1)
                    
                    Circle()
                        .fill(comet.color)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                }
                .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(comet.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(comet.type.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Circle()
                            .fill(comet.status.color)
                            .frame(width: 8, height: 8)
                        Text(comet.orbitalPeriod)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
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
                    .stroke(comet.color.opacity(0.5), lineWidth: 2)
            )
        }
        .sheet(isPresented: $showDetails) {
            CometDetailView(comet: comet)
        }
        .onAppear {
            withAnimation(
                .linear(duration: 3)
                .repeatForever(autoreverses: false)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Comet Detail View
struct CometDetailView: View {
    let comet: Comet
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Animated comet header
                    CometAnimationView(color: comet.color)
                        .frame(height: 150)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        InfoRow(title: "Discovered", value: comet.discovered)
                        InfoRow(title: "Type", value: comet.type.description)
                        InfoRow(title: "Orbital Period", value: comet.orbitalPeriod)
                        InfoRow(title: "Last Seen", value: comet.lastSeen)
                        InfoRow(title: "Next Appearance", value: comet.nextAppearance)
                        InfoRow(title: "Length", value: comet.length)
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Interesting Facts")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ForEach(comet.facts, id: \.self) { fact in
                            HStack(alignment: .top) {
                                Text("•")
                                    .foregroundColor(comet.color)
                                Text(fact)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(comet.name)
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
    }
}

// MARK: - Comet Animation View
struct CometAnimationView: View {
    let color: Color
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Stars background
                ForEach(0..<20) { index in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 2, height: 2)
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .opacity(Double.random(in: 0.2...0.7))
                }
                
                // Comet
                HStack(spacing: 0) {
                    Circle()
                        .fill(color)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                    
                    // Comet tail
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 100, height: 2)
                }
                .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                .rotationEffect(.degrees(-15))
            }
        }
        .onAppear {
            withAnimation(
                .linear(duration: 3)
                .repeatForever(autoreverses: false)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Comet Intro View
struct CometIntroView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("☄️")
                .font(.system(size: 60))
                .padding()
            
            Text("Comets")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Cosmic snowballs of frozen gases, rock, and dust that orbit the Sun. When frozen, they are the size of a small town.")
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.gray)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                CometFactCard(emoji: "💫", text: "Visible tail when near Sun")
                CometFactCard(emoji: "❄️", text: "Made of ice and dust")
                CometFactCard(emoji: "🌠", text: "Can create meteor showers")
                CometFactCard(emoji: "🌍", text: "Some orbit for centuries")
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
        )
        .padding()
    }
}

struct CometFactCard: View {
    let emoji: String
    let text: String
    
    var body: some View {
        HStack {
            Text(emoji)
                .font(.title2)
            Text(text)
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding(10)
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}

// MARK: - Main Comet View
struct CometView: View {
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    
    let comets = [
        Comet(
            name: "Halley's Comet",
            type: .shortPeriod,
            discovered: "240 BCE",
            orbitalPeriod: "76 years",
            lastSeen: "1986",
            nextAppearance: "2061",
            length: "15 km",
            facts: [
                "Most famous periodic comet",
                "Visible every 76 years",
                "Named after Edmund Halley",
                "First recognized periodic comet",
                "Mark Twain was born and died in Halley's Comet years"
            ],
            color: .blue,
            status: .active
        ),
        Comet(
            name: "Hale-Bopp",
            type: .longPeriod,
            discovered: "1995",
            orbitalPeriod: "2,533 years",
            lastSeen: "1997",
            nextAppearance: "4530",
            length: "60 km",
            facts: [
                "One of the brightest comets in history",
                "Visible to naked eye for 18 months",
                "Called the Great Comet of 1997",
                "Unusually large nucleus",
                "Visible even from bright cities"
            ],
            color: .purple,
            status: .active
        ),
        Comet(
            name: "Lovejoy",
            type: .longPeriod,
            discovered: "2011",
            orbitalPeriod: "622 years",
            lastSeen: "2011",
            nextAppearance: "2633",
            length: "500 m",
            facts: [
                "Survived close encounter with Sun",
                "Known as 'The Great Christmas Comet'",
                "Discovered by amateur astronomer",
                "Produced spectacular green tail",
                "One of five comets discovered by Terry Lovejoy"
            ],
            color: .green,
            status: .active
        ),
        Comet(
            name: "NEOWISE",
            type: .longPeriod,
            discovered: "2020",
            orbitalPeriod: "6,766 years",
            lastSeen: "2020",
            nextAppearance: "8786",
            length: "5 km",
            facts: [
                "Brightest comet visible from Northern Hemisphere since 1997",
                "Discovered by NASA's NEOWISE space telescope",
                "Survived close approach to Sun",
                "Visible to naked eye in 2020",
                "Shows both dust and ion tails"
            ],
            color: .orange,
            status: .active
        ),
        Comet(
            name: "Hyakutake",
            type: .longPeriod,
            discovered: "1996",
            orbitalPeriod: "17,000 years",
            lastSeen: "1996",
            nextAppearance: "18996",
            length: "4.8 km",
            facts: [
                "Made one of closest approaches to Earth",
                "Discovered by amateur astronomer",
                "Had extremely long tail",
                "Showed strong X-ray emissions",
                "Called 'The Great Comet of 1996'"
            ],
            color: .cyan,
            status: .active
        ),
        Comet(
            name: "Shoemaker-Levy 9",
            type: .shortPeriod,
            discovered: "1993",
            orbitalPeriod: "N/A",
            lastSeen: "1994",
            nextAppearance: "Destroyed",
            length: "1.8 km",
            facts: [
                "Collided with Jupiter in 1994",
                "First comet observed impacting planet",
                "Split into multiple fragments",
                "Impact visible from Earth",
                "Created dark spots on Jupiter"
            ],
            color: .red,
            status: .fragmented
        ),
        Comet(
            name: "McNaught",
            type: .longPeriod,
            discovered: "2006",
            orbitalPeriod: "92,600 years",
            lastSeen: "2007",
            nextAppearance: "94607",
            length: "20 km",
            facts: [
                "Brightest comet visible from Earth in 40 years",
                "Known as 'The Great Comet of 2007'",
                "Visible during daylight",
                "Spectacular dust tail display",
                "Named after astronomer Robert McNaught"
            ],
            color: .yellow,
            status: .active
        ),
        Comet(
            name: "Tempel 1",
            type: .shortPeriod,
            discovered: "1867",
            orbitalPeriod: "5.5 years",
            lastSeen: "2016",
            nextAppearance: "2022",
            length: "7.6 km",
            facts: [
                "Target of Deep Impact mission",
                "First comet nucleus photographed in detail",
                "Intentionally impacted by spacecraft",
                "Shows regular outbursts",
                "Named after Wilhelm Tempel"
            ],
            color: .gray,
            status: .active
        ),
        Comet(
            name: "Wild 2",
            type: .shortPeriod,
            discovered: "1978",
            orbitalPeriod: "6.4 years",
            lastSeen: "2016",
            nextAppearance: "2022",
            length: "5.2 km",
            facts: [
                "Target of Stardust mission",
                "Samples returned to Earth",
                "Surface covered in steep cliffs",
                "Changed orbit due to Jupiter",
                "Named after Paul Wild"
            ],
            color: .mint,
            status: .active
        ),
        Comet(
            name: "67P/Churyumov-Gerasimenko",
            type: .shortPeriod,
            discovered: "1969",
            orbitalPeriod: "6.45 years",
            lastSeen: "2021",
            nextAppearance: "2027",
            length: "4.3 km",
            facts: [
                "Target of Rosetta mission",
                "First comet landing by spacecraft",
                "Rubber duck shaped nucleus",
                "Produces its own aurora",
                "Active jets of material observed"
            ],
            color: .indigo,
            status: .active
        )
    ]

    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                CometIntroView()
                
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(comets) { comet in
                        CometCard(comet: comet)
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
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                starfieldRotation = 360
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    parallaxOffset = value.translation.width
                }
                .onEnded { _ in
                    withAnimation(.spring()) {
                        parallaxOffset = 0
                    }
                }
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Comets")
    }
}

// Preview
struct CometView_Previews: PreviewProvider {
    static var previews: some View {
        CometView()
    }
}
