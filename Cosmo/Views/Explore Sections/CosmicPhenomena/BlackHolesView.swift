import SwiftUI
// MARK: - Models
struct BlackHole: Identifiable {
    let id = UUID()
    let name: String
    let type: BlackHoleType
    let constellation: String
    let distance: String
    let mass: String
    let discovered: String
    let facts: [String]
    let color: Color
    let eventHorizonDiameter: String
}

enum BlackHoleType {
    case stellar
    case supermassive
    case intermediate
    
    var description: String {
        switch self {
        case .stellar: return "Stellar Black Hole"
        case .supermassive: return "Supermassive Black Hole"
        case .intermediate: return "Intermediate Mass Black Hole"
        }
    }
}

// MARK: - Black Hole Card
struct BlackHoleCard: View {
    let blackHole: BlackHole
    @State private var showDetails = false
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: { showDetails.toggle() }) {
            VStack(spacing: 15) {
                // Animated Black Hole Visualization
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 40, height: 40)
                        .overlay(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    blackHole.color.opacity(0.7),
                                    blackHole.color.opacity(0),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 5,
                                endRadius: 30
                            )
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        )
                        .overlay(
                            Circle()
                                .stroke(blackHole.color.opacity(0.5), lineWidth: 2)
                        )
                }
                .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(blackHole.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(blackHole.type.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(blackHole.constellation)
                        .font(.caption)
                        .foregroundColor(.gray)
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
                    .stroke(blackHole.color.opacity(0.5), lineWidth: 2)
            )
        }
        .sheet(isPresented: $showDetails) {
            BlackHoleDetailView(blackHole: blackHole)
        }
        .onAppear {
            withAnimation(
                .linear(duration: 20)
                .repeatForever(autoreverses: false)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Black Hole Detail View
struct BlackHoleDetailView: View {
    let blackHole: BlackHole
    @Environment(\.presentationMode) var presentationMode
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Animated Black Hole Visualization
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 100, height: 100)
                            .overlay(
                                ZStack {
                                    ForEach(0..<3) { index in
                                        Circle()
                                            .stroke(blackHole.color.opacity(0.3), lineWidth: 2)
                                            .scaleEffect(isAnimating ? 2 : 1)
                                            .opacity(isAnimating ? 0 : 1)
                                            .animation(
                                                Animation.easeOut(duration: 2)
                                                    .repeatForever(autoreverses: false)
                                                    .delay(Double(index) * 0.5),
                                                value: isAnimating
                                            )
                                    }
                                }
                            )
                    }
                    .frame(height: 200)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        InfoRow(title: "Type", value: blackHole.type.description)
                        InfoRow(title: "Constellation", value: blackHole.constellation)
                        InfoRow(title: "Distance", value: blackHole.distance)
                        InfoRow(title: "Mass", value: blackHole.mass)
                        InfoRow(title: "Discovered", value: blackHole.discovered)
                        InfoRow(title: "Event Horizon", value: blackHole.eventHorizonDiameter)
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Interesting Facts")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ForEach(blackHole.facts, id: \.self) { fact in
                            HStack(alignment: .top) {
                                Text("•")
                                    .foregroundColor(blackHole.color)
                                Text(fact)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(blackHole.name)
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

// MARK: - Black Hole Intro View
struct BlackHoleIntroView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🕳️")
                .font(.system(size: 60))
                .padding()
            
            Text("Black Holes")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Regions of spacetime where gravity is so strong that nothing, not even light, can escape from them.")
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.gray)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                BlackHoleFactCard(emoji: "🌌", text: "Point of no return")
                BlackHoleFactCard(emoji: "⏰", text: "Time dilation")
                BlackHoleFactCard(emoji: "🌠", text: "Extreme gravity")
                BlackHoleFactCard(emoji: "🔄", text: "Space distortion")
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

struct BlackHoleFactCard: View {
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

// MARK: - Main Black Hole View
struct BlackHoleView: View {
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    
    let blackHoles = [
        BlackHole(
            name: "Sagittarius A*",
            type: .supermassive,
            constellation: "Sagittarius",
            distance: "26,000 light-years",
            mass: "4.3 million solar masses",
            discovered: "1974",
            facts: [
                "Center of the Milky Way galaxy",
                "First directly imaged in 2022",
                "Shows periodic flares",
                "Surrounded by dense star cluster",
                "Affects orbits of nearby stars"
            ],
            color: .purple,
            eventHorizonDiameter: "23.6 million km"
        ),
        BlackHole(
            name: "M87*",
            type: .supermassive,
            constellation: "Virgo",
            distance: "55 million light-years",
            mass: "6.5 billion solar masses",
            discovered: "1918",
            facts: [
                "First ever photographed black hole",
                "Powers massive relativistic jet",
                "Center of Messier 87 galaxy",
                "Event horizon larger than solar system",
                "Rotates clockwise"
            ],
            color: .orange,
            eventHorizonDiameter: "38 billion km"
        ),
        BlackHole(
            name: "Cygnus X-1",
            type: .stellar,
            constellation: "Cygnus",
            distance: "6,070 light-years",
            mass: "21.2 solar masses",
            discovered: "1964",
            facts: [
                "First black hole candidate discovered",
                "Forms binary system with blue supergiant",
                "Produces powerful X-ray emissions",
                "Subject of famous scientific bet",
                "Formed from supernova explosion"
            ],
            color: .blue,
            eventHorizonDiameter: "124 km"
        ),
        BlackHole(
            name: "TON 618",
            type: .supermassive,
            constellation: "Canes Venatici",
            distance: "10.4 billion light-years",
            mass: "66 billion solar masses",
            discovered: "1970",
            facts: [
                "Most massive known black hole",
                "Powers extremely luminous quasar",
                "Located in early universe",
                "Bigger than our solar system",
                "Growth mechanism unknown"
            ],
            color: .red,
            eventHorizonDiameter: "390 billion km"
        ),
        BlackHole(
            name: "GW150914",
            type: .stellar,
            constellation: "Southern Sky",
            distance: "1.3 billion light-years",
            mass: "62 solar masses",
            discovered: "2015",
            facts: [
                "First detected gravitational waves",
                "Formed by merging black holes",
                "Released energy of 3 solar masses",
                "Confirmed Einstein's predictions",
                "Changed astronomy forever"
            ],
            color: .green,
            eventHorizonDiameter: "366 km"
        ),
        // Add more black holes...
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                BlackHoleIntroView()
                
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(blackHoles) { blackHole in
                        BlackHoleCard(blackHole: blackHole)
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
        .navigationTitle("Black Holes")
    }
}

struct BlackHoleView_Previews: PreviewProvider {
    static var previews: some View {
        BlackHoleView()
    }
}
