import SwiftUI



// MARK: - Models
struct Satellite: Identifiable {
    let id = UUID()
    let name: String
    let type: SatelliteType
    let launchDate: String
    let operator_: String
    let purpose: String
    let emoji: String
    let facts: [String]
    let altitude: String
    let status: SatelliteStatus
    let image: String
}

enum SatelliteType {
    case communication, navigation, observation, weather, scientific, military
    
    var description: String {
        switch self {
        case .communication: return "Communication"
        case .navigation: return "Navigation"
        case .observation: return "Earth Observation"
        case .weather: return "Weather"
        case .scientific: return "Scientific Research"
        case .military: return "Military"
        }
    }
}

enum SatelliteStatus {
    case active, inactive, deorbited
    
    var color: Color {
        switch self {
        case .active: return .green
        case .inactive: return .orange
        case .deorbited: return .red
        }
    }
}

// MARK: - Supporting Views
struct SatelliteKeyPoint: View {
    let emoji: String
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Text(emoji)
                .font(.title2)
            Text(text)
                .foregroundColor(.white)
        }
    }
}

struct SatelliteIntroView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🛰️")
                .font(.system(size: 60))
                .padding()
            
            Text("What are Satellites?")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Satellites are objects that orbit around planets or stars. They can be natural, like the Moon, or artificial, like the ones launched by humans for various purposes.")
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 15) {
                SatelliteKeyPoint(emoji: "🌍", text: "Orbit at different heights above Earth")
                SatelliteKeyPoint(emoji: "📡", text: "Enable global communications")
                SatelliteKeyPoint(emoji: "🗺️", text: "Help in navigation and mapping")
                SatelliteKeyPoint(emoji: "🌤️", text: "Monitor weather patterns")
                SatelliteKeyPoint(emoji: "🔭", text: "Study space and Earth")
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

// MARK: - Satellite Card
struct SatelliteCard: View {
    let satellite: Satellite
    @State private var showDetails = false
    @State private var isRotating = false
    
    var body: some View {
        VStack {
            Button(action: { showDetails.toggle() }) {
                VStack(spacing: 15) {
                    Image(systemName: satellite.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isRotating ? 360 : 0))
                        .animation(
                            Animation.linear(duration: 20)
                                .repeatForever(autoreverses: false),
                            value: isRotating
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(satellite.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(satellite.type.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Circle()
                                .fill(satellite.status.color)
                                .frame(width: 10, height: 10)
                            Text(satellite.launchDate)
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
                        .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                )
            }
        }
        .sheet(isPresented: $showDetails) {
            SatelliteDetailView(satellite: satellite)
        }
        .onAppear {
            isRotating = true
        }
    }
}

// MARK: - Detail Views

struct SatelliteDetailView: View {
    let satellite: Satellite
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: satellite.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        InfoRow(title: "Operator", value: satellite.operator_)
                        InfoRow(title: "Type", value: satellite.type.description)
                        InfoRow(title: "Launch Date", value: satellite.launchDate)
                        InfoRow(title: "Altitude", value: satellite.altitude)
                        InfoRow(title: "Purpose", value: satellite.purpose)
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Fun Facts")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ForEach(satellite.facts, id: \.self) { fact in
                            HStack(alignment: .top) {
                                Text("•")
                                    .foregroundColor(.blue)
                                Text(fact)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(satellite.name)
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

// MARK: - Main View
// [Previous code remains the same until the SatelliteView struct]

struct SatelliteView: View {
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    @State private var zoomLevel: Double = 1.0
    
    let satellites = [
        Satellite(
            name: "Hubble Space Telescope",
            type: .scientific,
            launchDate: "April 24, 1990",
            operator_: "NASA",
            purpose: "Space observation and research",
            emoji: "🔭",
            facts: [
                "Has made more than 1.5 million observations",
                "Travels at 17,000 mph",
                "Has helped determine the age of the universe",
                "Orbits Earth every 95 minutes"
            ],
            altitude: "540 kilometers",
            status: .active,
            image: "telescope.fill"
        ),
        Satellite(
            name: "International Space Station",
            type: .scientific,
            launchDate: "November 20, 1998",
            operator_: "Multinational",
            purpose: "Space research and international cooperation",
            emoji: "🛸",
            facts: [
                "Largest artificial object in space",
                "Has been continuously occupied since 2000",
                "Travels at 7.66 kilometers per second",
                "Visible from Earth with naked eye"
            ],
            altitude: "408 kilometers",
            status: .active,
            image: "airplane.circle.fill"
        ),
        Satellite(
            name: "Starlink-1",
            type: .communication,
            launchDate: "May 23, 2019",
            operator_: "SpaceX",
            purpose: "Global internet coverage",
            emoji: "📡",
            facts: [
                "Part of massive satellite constellation",
                "Provides internet to remote areas",
                "Uses laser inter-satellite links",
                "Designed to avoid space debris"
            ],
            altitude: "550 kilometers",
            status: .active,
            image: "network"
        ),
        Satellite(
            name: "GOES-16",
            type: .weather,
            launchDate: "November 19, 2016",
            operator_: "NOAA",
            purpose: "Weather monitoring and forecasting",
            emoji: "🌤️",
            facts: [
                "Provides continuous weather imagery",
                "Tracks severe storms and hurricanes",
                "Monitors solar activity",
                "Takes full Earth disk image every 15 minutes"
            ],
            altitude: "35,786 kilometers",
            status: .active,
            image: "cloud.sun.fill"
        ),
        Satellite(
            name: "GPS III SV05",
            type: .navigation,
            launchDate: "June 17, 2021",
            operator_: "US Space Force",
            purpose: "Global positioning services",
            emoji: "📍",
            facts: [
                "Latest GPS satellite generation",
                "3x more accurate than older GPS satellites",
                "Enhanced anti-jamming capabilities",
                "Expected 15-year lifespan"
            ],
            altitude: "20,200 kilometers",
            status: .active,
            image: "location.fill"
        ),
        Satellite(
            name: "Landsat 9",
            type: .observation,
            launchDate: "September 27, 2021",
            operator_: "NASA/USGS",
            purpose: "Earth observation and monitoring",
            emoji: "🌍",
            facts: [
                "Images entire Earth every 16 days",
                "Monitors forest cover changes",
                "Tracks urban expansion",
                "Studies water quality"
            ],
            altitude: "705 kilometers",
            status: .active,
            image: "camera.fill"
        ),
        Satellite(
            name: "James Webb Space Telescope",
            type: .scientific,
            launchDate: "December 25, 2021",
            operator_: "NASA/ESA/CSA",
            purpose: "Deep space observation",
            emoji: "✨",
            facts: [
                "Largest space telescope ever built",
                "Observes in infrared spectrum",
                "Located 1.5 million kilometers from Earth",
                "Can study exoplanet atmospheres"
            ],
            altitude: "1,500,000 kilometers",
            status: .active,
            image: "sparkles"
        ),
        Satellite(
            name: "Galileo FOC-M9",
            type: .navigation,
            launchDate: "December 4, 2021",
            operator_: "European Union",
            purpose: "European navigation system",
            emoji: "🛰️",
            facts: [
                "Part of EU's navigation constellation",
                "Provides precise positioning services",
                "Independent from GPS",
                "Serves civilian and military purposes"
            ],
            altitude: "23,222 kilometers",
            status: .active,
            image: "network"
        ),
        Satellite(
            name: "WorldView-3",
            type: .observation,
            launchDate: "August 13, 2014",
            operator_: "Maxar Technologies",
            purpose: "High-resolution Earth imaging",
            emoji: "📸",
            facts: [
                "Highest resolution commercial satellite",
                "Can spot objects 31cm in size",
                "Used for mapping and security",
                "Has short-wave infrared sensing"
            ],
            altitude: "617 kilometers",
            status: .active,
            image: "camera.circle.fill"
        ),
        Satellite(
            name: "TDRS-M",
            type: .communication,
            launchDate: "August 18, 2017",
            operator_: "NASA",
            purpose: "Satellite communication relay",
            emoji: "📡",
            facts: [
                "Part of NASA's space network",
                "Provides continuous communication",
                "Supports space missions",
                "Covers communication dead zones"
            ],
            altitude: "35,786 kilometers",
            status: .active,
            image: "antenna.radiowaves.left.and.right"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                SatelliteIntroView()
                
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(satellites) { satellite in
                        SatelliteCard(satellite: satellite)
                    }
                }
                .padding()
            }
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
    }
}
struct SatelliteView_Previews: PreviewProvider {
    static var previews: some View {
        SatelliteView()
    }
}

