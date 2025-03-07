import SwiftUI

// MARK: - Models
struct Planet: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let color: Color
    let facts: [String]
    let diameter: String
    let distance: String
    let orbitalPeriod: String
    let temperature: String
    let description: String
}

// MARK: - Planet Emoji View
struct PlanetEmoji: View {
    let emoji: String
    let color: Color
    @State private var isRotating = false

    var body: some View {
        Text(emoji)
            .font(.system(size: 60))
            .overlay(
                LinearGradient(
                    colors: [color.opacity(0.3), color.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .mask(Text(emoji).font(.system(size: 60)))
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(
                Animation.linear(duration: 20)
                    .repeatForever(autoreverses: false),
                value: isRotating
            )
            .onAppear { isRotating = true }
    }
}

// MARK: - Fact Card Views
struct FactCard: View {
    let fact: String
    let color: Color

    var body: some View {
        Text(fact)
            .font(.system(size: 16))
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(color.opacity(0.3))
            )
    }
}

struct QuickFactRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color.white.opacity(0.7))
                .frame(width: 30)

            Text(title)
                .foregroundColor(Color.white.opacity(0.7))

            Spacer()

            Text(value)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Planet Card
struct PlanetCard: View {
    let planet: Planet
    @State private var isExpanded = false
    @State private var currentFactIndex = 0
    @State private var showingDetails = false

    var body: some View {
        VStack {
            VStack(spacing: 15) {
                HStack {
                    PlanetEmoji(emoji: planet.emoji, color: planet.color)

                    VStack(alignment: .leading) {
                        Text(planet.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Button(action: { showingDetails.toggle() }) {
                        Image(systemName: "info.circle")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding()

                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        QuickFactRow(icon: "ruler", title: "Diameter", value: planet.diameter)
                        QuickFactRow(icon: "location", title: "Distance from Sun", value: planet.distance)
                        QuickFactRow(icon: "clock", title: "Orbital Period", value: planet.orbitalPeriod)
                        QuickFactRow(icon: "thermometer", title: "Temperature", value: planet.temperature)
                    }
                    .padding()
                    .transition(.opacity)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Fun Facts")
                        .font(.headline)
                        .foregroundColor(.white)

                    TabView(selection: $currentFactIndex) {
                        ForEach(planet.facts.indices, id: \.self) { index in
                            FactCard(fact: planet.facts[index], color: planet.color)
                                .tag(index)
                        }
                    }
                    .frame(height: 120)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                }
                .padding()
            }
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.black.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(planet.color.opacity(0.7), lineWidth: 2)
                    )
            )
            .onTapGesture {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showingDetails) {
            PlanetDetailView(planet: planet)
        }
    }
}

// MARK: - Planet Detail View
struct PlanetDetailView: View {
    let planet: Planet
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Planet Image and Description
                    VStack(spacing: 20) {
                        PlanetEmoji(emoji: planet.emoji, color: planet.color)
                            .frame(height: 120)

                        Text(planet.description)
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)

                    // Characteristics Sections
                    VStack(alignment: .leading, spacing: 32) {
                        // Physical Characteristics
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Physical Characteristics")
                                .font(.headline)
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("Diameter: \(planet.diameter)")
                                        .foregroundColor(.white.opacity(0.7))
                                }

                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("Temperature: \(planet.temperature)")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                        }

                        // Orbital Characteristics
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Orbital Characteristics")
                                .font(.headline)
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("Distance from Sun: \(planet.distance)")
                                        .foregroundColor(.white.opacity(0.7))
                                }

                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("Orbital Period: \(planet.orbitalPeriod)")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                        }

                        // Interesting Facts
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Interesting Facts")
                                .font(.headline)
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(planet.facts, id: \.self) { fact in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("•")
                                            .foregroundColor(.white.opacity(0.7))
                                        Text(fact)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .background(Color.black)
            .navigationTitle(planet.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Main View
struct SolarSystemView: View {
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    @State private var zoomLevel: Double = 1.0

    let planets = [
        Planet(
            name: "Mercury",
            emoji: "🌑",
            color: Color(red: 0.7, green: 0.7, blue: 0.7),
            facts: [
                "Smallest planet in our solar system",
                "Temperatures range from -180°C to 430°C",
                "A year on Mercury is just 88 Earth days",
                "Has no moons or rings"
            ],
            diameter: "4,879 km",
            distance: "57.9 million km",
            orbitalPeriod: "88 days",
            temperature: "-180°C to 430°C",
            description: "Mercury is the smallest planet in our solar system and closest to the Sun. It's a rocky world with a heavily cratered surface."
        ),
        Planet(
            name: "Venus",
            emoji: "🌕",
            color: Color(red: 0.9, green: 0.8, blue: 0.4),
            facts: [
                "Hottest planet in our solar system",
                "Rotates backwards compared to other planets",
                "Similar in size to Earth",
                "Often called Earth's twin"
            ],
            diameter: "12,104 km",
            distance: "108.2 million km",
            orbitalPeriod: "225 days",
            temperature: "462°C",
            description: "Venus is the second planet from the Sun and the hottest planet in our solar system. Its thick atmosphere traps heat in a runaway greenhouse effect."
        ),
        Planet(
            name: "Earth",
            emoji: "🌏",
            color: Color(red: 0.2, green: 0.5, blue: 0.8),
            facts: [
                "Only known planet with life",
                "71% of surface covered in water",
                "Has one natural satellite - the Moon",
                "Only planet not named after a god"
            ],
            diameter: "12,742 km",
            distance: "149.6 million km",
            orbitalPeriod: "365.25 days",
            temperature: "-88°C to 58°C",
            description: "Earth is our home planet and the only known planet to harbor life. It's the third planet from the Sun and the largest of the terrestrial planets."
        ),
        Planet(
            name: "Mars",
            emoji: "🔴",
            color: Color(red: 0.8, green: 0.2, blue: 0.2),
            facts: [
                "Known as the Red Planet",
                "Has the largest volcano in the solar system",
                "Has two small moons",
                "Potential for future human colonization"
            ],
            diameter: "6,779 km",
            distance: "227.9 million km",
            orbitalPeriod: "687 days",
            temperature: "-153°C to 20°C",
            description: "Mars is often called the Red Planet due to its reddish appearance. It's a dusty, cold desert world but is one of the most explored planets in our solar system."
        ),
        Planet(
            name: "Jupiter",
            emoji: "🌎",
            color: Color(red: 0.8, green: 0.6, blue: 0.3),
            facts: [
                "Largest planet in our solar system",
                "Has a Great Red Spot storm",
                "Has at least 79 moons",
                "Could fit 1,300 Earths inside it"
            ],
            diameter: "139,820 km",
            distance: "778.5 million km",
            orbitalPeriod: "11.8 years",
            temperature: "-110°C",
            description: "Jupiter is the largest planet in our solar system. It's a giant gas planet with a Great Red Spot that's actually a centuries-old storm."
        ),
        Planet(
            name: "Saturn",
            emoji: "🪐",
            color: Color(red: 0.9, green: 0.8, blue: 0.3),
            facts: [
                "Famous for its beautiful rings",
                "Has 82 confirmed moons",
                "Would float in a giant bathtub",
                "Winds reach 1,800 km per hour"
            ],
            diameter: "116,460 km",
            distance: "1.4 billion km",
            orbitalPeriod: "29.5 years",
            temperature: "-178°C",
            description: "Saturn is known for its stunning ring system and is the second-largest planet in our solar system. It's a gas giant with an average density less than water."
        ),
        Planet(
            name: "Uranus",
            emoji: "🌎",
            color: Color(red: 0.5, green: 0.8, blue: 0.9),
            facts: [
                "Rotates on its side",
                "First planet discovered by telescope",
                "Has 27 known moons",
                "Coldest planetary atmosphere"
            ],
            diameter: "50,724 km",
            distance: "2.9 billion km",
            orbitalPeriod: "84 years",
            temperature: "-224°C",
            description: "Uranus is the seventh planet from the Sun and rotates on its side. It's an ice giant with a unique sideways rotation that causes extreme seasons."
        ),
        Planet(
            name: "Neptune",
            emoji: "🌍",
            color: Color(red: 0.1, green: 0.4, blue: 0.9),
            facts: [
                "Windiest planet",
                "Has 14 known moons",
                "Last planet in our solar system",
                "Named after Roman god of the sea"
            ],
            diameter: "49,244 km",
            distance: "4.5 billion km",
            orbitalPeriod: "165 years",
            temperature: "-214°C",
            description: "Neptune is the eighth and most distant planet from the Sun. It's a dark, cold, and windy ice giant with powerful storms and supersonic winds."
        )
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Solar System")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)

                        Text("Swipe planets to explore")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.7))
                    }

                    Spacer()

                    Text("☀️")
                        .font(.system(size: 40))
                }
                .padding()

                ForEach(planets) { planet in
                    PlanetCard(planet: planet)
                }
            }
            .padding(.vertical)
        }
        .background(
            EnhancedCosmicBackground(
                parallaxOffset: parallaxOffset,
                starfieldRotation: starfieldRotation,
                zoomLevel: zoomLevel
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
        .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SolarSystemView()
    }
}
