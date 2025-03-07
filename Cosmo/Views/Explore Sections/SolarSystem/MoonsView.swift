import SwiftUI

// MARK: - Models
struct Moon: Identifiable {
    let id = UUID()
    let name: String
    let planet: String
    let discoveryDate: String
    let diameter: String
    let orbitalPeriod: String
    let gravity: String
    let facts: [String]
    let emoji: String
    let image: String
    let color: Color
    let surfaceType: String
    let atmosphere: String
}

// MARK: - Moon Card
struct MoonCard: View {
    let moon: Moon
    @State private var showDetails = false
    @State private var isRotating = false
    
    var body: some View {
        Button(action: { showDetails.toggle() }) {
            VStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(moon.color.opacity(0.3))
                        .frame(width: 70, height: 70)
                    
                    Text(moon.emoji)
                        .font(.system(size: 40))
                        .rotationEffect(.degrees(isRotating ? 360 : 0))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(moon.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Orbits: \(moon.planet)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(moon.diameter)
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
                    .stroke(moon.color.opacity(0.5), lineWidth: 2)
            )
        }
        .sheet(isPresented: $showDetails) {
            MoonDetailView(moon: moon)
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                isRotating = true
            }
        }
    }
}

// MARK: - Moon Detail View
struct MoonDetailView: View {
    let moon: Moon
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text(moon.emoji)
                        .font(.system(size: 80))
                        .padding()
                    
                    VStack(alignment: .leading, spacing: 15) {
                        DetailRow(title: "Planet", value: moon.planet)
                        DetailRow(title: "Discovery", value: moon.discoveryDate)
                        DetailRow(title: "Diameter", value: moon.diameter)
                        DetailRow(title: "Orbit Period", value: moon.orbitalPeriod)
                        DetailRow(title: "Gravity", value: moon.gravity)
                        DetailRow(title: "Surface", value: moon.surfaceType)
                        DetailRow(title: "Atmosphere", value: moon.atmosphere)
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Interesting Facts")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ForEach(moon.facts, id: \.self) { fact in
                            HStack(alignment: .top) {
                                Text("•")
                                    .foregroundColor(moon.color)
                                Text(fact)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle(moon.name)
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

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Moon Intro View
struct MoonIntroView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🌙")
                .font(.system(size: 60))
                .padding()
            
            Text("Natural Satellites")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Moons are natural satellites that orbit planets and dwarf planets in our solar system. Each has its unique characteristics and plays a crucial role in its planetary system.")
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.gray)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                MoonFactCard(emoji: "🌍", text: "Over 200 moons in our solar system")
                MoonFactCard(emoji: "🪨", text: "Various sizes and compositions")
                MoonFactCard(emoji: "🌋", text: "Some have active geology")
                MoonFactCard(emoji: "💧", text: "Potential for subsurface oceans")
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

struct MoonFactCard: View {
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

// MARK: - Main Moon View
struct MoonView: View {
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    
    let moons = [
        Moon(
            name: "Luna",
            planet: "Earth",
            discoveryDate: "Known to antiquity",
            diameter: "3,474.8 km",
            orbitalPeriod: "27.3 days",
            gravity: "1.62 m/s²",
            facts: [
                "Only natural satellite of Earth",
                "Controls Earth's tides",
                "Same side always faces Earth",
                "Has moonquakes"
            ],
            emoji: "🌕",
            image: "moon",
            color: .gray,
            surfaceType: "Rocky, cratered",
            atmosphere: "Very thin, negligible"
        ),
        Moon(
            name: "Phobos",
            planet: "Mars",
            discoveryDate: "August 17, 1877",
            diameter: "22.2 km",
            orbitalPeriod: "7.7 hours",
            gravity: "0.0057 m/s²",
            facts: [
                "Closest moon to its planet",
                "Will crash into Mars in ~50 million years",
                "Heavily cratered surface",
                "Named after the Greek god of fear"
            ],
            emoji: "🌑",
            image: "phobos",
            color: .red,
            surfaceType: "Rocky, cratered",
            atmosphere: "None"
        ),
        Moon(
            name: "Io",
            planet: "Jupiter",
            discoveryDate: "January 8, 1610",
            diameter: "3,642 km",
            orbitalPeriod: "1.77 days",
            gravity: "1.796 m/s²",
            facts: [
                "Most volcanic body in solar system",
                "Over 400 active volcanoes",
                "Surface temperature: -130°C to 2000°C",
                "Discovered by Galileo Galilei"
            ],
            emoji: "🌓",
            image: "io",
            color: .yellow,
            surfaceType: "Volcanic, sulfurous",
            atmosphere: "Thin sulfur dioxide"
        ),
        Moon(
            name: "Europa",
            planet: "Jupiter",
            discoveryDate: "January 8, 1610",
            diameter: "3,121.6 km",
            orbitalPeriod: "3.55 days",
            gravity: "1.314 m/s²",
            facts: [
                "Smoothest surface of any solid object",
                "Possible subsurface ocean",
                "Potential for extraterrestrial life",
                "Ice crust up to 30 km thick"
            ],
            emoji: "🌔",
            image: "europa",
            color: .blue,
            surfaceType: "Icy, cracked",
            atmosphere: "Thin oxygen"
        ),
        Moon(
            name: "Titan",
            planet: "Saturn",
            discoveryDate: "March 25, 1655",
            diameter: "5,149.5 km",
            orbitalPeriod: "15.95 days",
            gravity: "1.352 m/s²",
            facts: [
                "Largest moon of Saturn",
                "Only moon with dense atmosphere",
                "Has liquid methane lakes",
                "Larger than planet Mercury"
            ],
            emoji: "🌕",
            image: "titan",
            color: .orange,
            surfaceType: "Rocky with liquid methane",
            atmosphere: "Thick nitrogen and methane"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                MoonIntroView()
                
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(moons) { moon in
                        MoonCard(moon: moon)
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
        .navigationTitle("Moons")
    }
}

struct MoonView_Previews: PreviewProvider {
    static var previews: some View {
        MoonView()
    }
}
