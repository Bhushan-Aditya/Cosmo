import SwiftUI

// MARK: - Models
struct Constellation: Identifiable {
    let id = UUID()
    let name: String
    let latinName: String
    let abbreviation: String
    let season: String
    let mainStars: [String]
    let brightestStar: String
    let magnitude: String
    let symbolism: String
    let facts: [String]
    let color: Color
    let rightAscension: String
    let declination: String
    let visibleLatitudes: String
}

// MARK: - Constellation Card and Detail Views
struct ConstellationCard: View {
    let constellation: Constellation
    @State private var showDetails = false
    @State private var starOpacities: [Double]

    init(constellation: Constellation) {
        self.constellation = constellation
        _starOpacities = State(initialValue: Array(repeating: 0.3, count: 7))
    }

    var body: some View {
        Button(action: { showDetails.toggle() }) {
            VStack(spacing: 15) {
                // Constellation Star Pattern
                ZStack {
                    ForEach(0..<7) { index in
                        Circle()
                            .fill(constellation.color)
                            .frame(width: 3, height: 3)
                            .offset(
                                x: CGFloat.random(in: -25...25),
                                y: CGFloat.random(in: -25...25)
                            )
                            .opacity(starOpacities[index])
                    }
                }
                .frame(width: 60, height: 60)
                .onAppear {
                    animateStars()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(constellation.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(constellation.latinName)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text("Season: \(constellation.season)") // String interpolation fix
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
                    .stroke(constellation.color.opacity(0.5), lineWidth: 2)
            )
        }
        .sheet(isPresented: $showDetails) {
            ConstellationDetailView(constellation: constellation)
        }
    }

    private func animateStars() {
        for index in starOpacities.indices {
            withAnimation(
                Animation.easeInOut(duration: Double.random(in: 1.0...2.0))
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...2))
            ) {
                starOpacities[index] = Double.random(in: 0.3...1.0)
            }
        }
    }
}

struct ConstellationDetailView: View {
    let constellation: Constellation
    @Environment(\.presentationMode) var presentationMode
    @State private var starOpacities: [Double]

    init(constellation: Constellation) {
        self.constellation = constellation
        _starOpacities = State(initialValue: Array(repeating: 0.3, count: 15))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Animated Star Pattern
                    ZStack {
                        ForEach(0..<15) { index in
                            Circle()
                                .fill(constellation.color)
                                .frame(width: 4, height: 4)
                                .offset(
                                    x: CGFloat.random(in: -50...50),
                                    y: CGFloat.random(in: -50...50)
                                )
                                .opacity(starOpacities[index])
                        }
                    }
                    .frame(height: 150)
                    .onAppear {
                        animateStars()
                    }

                    // Constellation Information
                    VStack(alignment: .leading, spacing: 15) {
                        Group {
                            InfoRow(title: "Latin Name", value: constellation.latinName)
                            InfoRow(title: "Abbreviation", value: constellation.abbreviation)
                            InfoRow(title: "Season", value: constellation.season)
                            InfoRow(title: "Brightest Star", value: constellation.brightestStar)
                            InfoRow(title: "Magnitude", value: constellation.magnitude)
                            InfoRow(title: "Right Ascension", value: constellation.rightAscension)
                            InfoRow(title: "Declination", value: constellation.declination)
                            InfoRow(title: "Visible From", value: constellation.visibleLatitudes)
                        }
                        .padding(.horizontal)
                    }

                    // Main Stars Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Main Stars")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        ForEach(constellation.mainStars, id: \.self) { star in
                            HStack {
                                Text("⭐️")
                                    .font(.caption)
                                Text(star)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)

                    // Mythology Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Mythology & Symbolism")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        Text(constellation.symbolism)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)

                    // Facts Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Interesting Facts")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        ForEach(constellation.facts, id: \.self) { fact in
                            HStack(alignment: .top) {
                                Text("•")
                                    .foregroundColor(constellation.color)
                                Text(fact)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.vertical)
            }
            .navigationTitle(constellation.name)
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

    private func animateStars() {
        for index in starOpacities.indices {
            withAnimation(
                Animation.easeInOut(duration: Double.random(in: 1.0...2.0))
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...2))
            ) {
                starOpacities[index] = Double.random(in: 0.3...1.0)
            }
        }
    }
}

// MARK: - Constellation Intro View
struct ConstellationIntroView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("✨")
                .font(.system(size: 60))
                .padding()

            Text("Constellations")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Ancient patterns of stars that tell stories of mythology, guide navigation, and help map the night sky.")
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.gray)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ConstellationFactCard(emoji: "🌟", text: "88 official constellations")
                ConstellationFactCard(emoji: "🗺️", text: "Map the night sky")
                ConstellationFactCard(emoji: "🧭", text: "Guide navigation")
                ConstellationFactCard(emoji: "📚", text: "Tell ancient stories")
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

struct ConstellationFactCard: View {
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
// MARK: - Main Constellation View
struct ConstellationView: View {
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    @State private var searchText = ""
    @State private var selectedSeason: String = "All"

    let seasons = ["All", "Spring", "Summer", "Autumn", "Winter", "Year-round"]

    var filteredConstellations: [Constellation] {
        constellationsData.filter { constellation in // Corrected to use 'constellationsData'
            let matchesSearch = searchText.isEmpty ||
                constellation.name.localizedCaseInsensitiveContains(searchText) ||
                constellation.latinName.localizedCaseInsensitiveContains(searchText)

            let matchesSeason = selectedSeason == "All" || constellation.season == selectedSeason

            return matchesSearch && matchesSeason
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                ConstellationIntroView()

                // Search and Filter Section
                VStack(spacing: 10) {
                    TextField("Search constellations...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(seasons, id: \.self) { season in
                                Button(action: {
                                    selectedSeason = season
                                }) {
                                    Text(season)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(selectedSeason == season ?
                                                      Color.blue.opacity(0.3) :
                                                        Color.black.opacity(0.3))
                                        )
                                        .foregroundColor(selectedSeason == season ?
                                                             .white : .gray)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Constellations Grid
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(filteredConstellations) { constellation in
                        ConstellationCard(constellation: constellation)
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
            withAnimation(.linear(duration: 20)
                .repeatForever(autoreverses: false)) {
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
        .navigationTitle("Constellations")
    }

    // MARK: - Constellation Data  - Moved data here and corrected type
     let constellationsData: [Constellation] = [ // Explicitly typed as [Constellation]
        Constellation(
            name: "Ursa Major",
            latinName: "Ursa Major",
            abbreviation: "UMa",
            season: "Year-round",
            mainStars: ["Dubhe", "Merak", "Phecda", "Megrez", "Alioth", "Mizar", "Alkaid"],
            brightestStar: "Alioth",
            magnitude: "1.8",
            symbolism: "The Great Bear",
            facts: [
                "Contains the Big Dipper asterism.",
                "Third largest constellation.",
                "Visible throughout the year in the Northern Hemisphere."
            ],
            color: .blue,
            rightAscension: "11h",
            declination: "+50°",
            visibleLatitudes: "+90° to -30°"
        ),
        Constellation(
            name: "Cassiopeia",
            latinName: "Cassiopeia",
            abbreviation: "Cas",
            season: "Autumn",
            mainStars: ["Schedar", "Caph", "Tsih", "Ruchbah", "Segin"],
            brightestStar: "Schedar",
            magnitude: "2.2",
            symbolism: "The Queen",
            facts: [
                "Easily recognized by its 'W' shape.",
                "Named after the vain queen Cassiopeia in Greek mythology.",
                "Contains several bright open clusters."
            ],
            color: .purple,
            rightAscension: "01h",
            declination: "+60°",
            visibleLatitudes: "+90° to -20°"
        ),
        Constellation(
            name: "Orion",
            latinName: "Orion",
            abbreviation: "Ori",
            season: "Winter",
            mainStars: ["Betelgeuse", "Rigel", "Bellatrix", "Alnitak", "Alnilam", "Mintaka", "Saiph"],
            brightestStar: "Rigel",
            magnitude: "0.5",
            symbolism: "The Hunter",
            facts: [
                "One of the most conspicuous and recognizable constellations.",
                "Features the Orion Nebula (M42), a famous star-forming region.",
                "Home to several bright stars like Betelgeuse and Rigel."
            ],
            color: .orange,
            rightAscension: "05h",
            declination: "+05°",
            visibleLatitudes: "+85° to -75°"
        ),
        Constellation(
            name: "Cygnus",
            latinName: "Cygnus",
            abbreviation: "Cyg",
            season: "Summer",
            mainStars: ["Deneb", "Albireo", "Sadr", "Ruch", "Gienah"],
            brightestStar: "Deneb",
            magnitude: "1.3",
            symbolism: "The Swan",
            facts: [
                "Also known as the Northern Cross.",
                "Deneb is part of the Summer Triangle asterism.",
                "Contains the North America Nebula."
            ],
            color: .mint,
            rightAscension: "20h",
            declination: "+40°",
            visibleLatitudes: "+90° to -40°"
        ),
        Constellation(
            name: "Leo",
            latinName: "Leo",
            abbreviation: "Leo",
            season: "Spring",
            mainStars: ["Regulus", "Denebola", "Algieba", "Zosma", "Adhafera"],
            brightestStar: "Regulus",
            magnitude: "1.4",
            symbolism: "The Lion",
            facts: [
                "One of the zodiac constellations.",
                "Features the Sickle asterism.",
                "Associated with the Nemean Lion in Greek mythology."
            ],
            color: .yellow,
            rightAscension: "11h",
            declination: "+15°",
            visibleLatitudes: "+90° to -65°"
        ),
        Constellation(
            name: "Taurus",
            latinName: "Taurus",
            abbreviation: "Tau",
            season: "Winter",
            mainStars: ["Aldebaran", "El Nath", "Alcyone", "Atlas", "Electra", "Maia", "Merope", "Taygeta", "Pleione", "Celaeno", "Sterope"],
            brightestStar: "Aldebaran",
            magnitude: "0.9",
            symbolism: "The Bull",
            facts: [
                "Zodiac constellation.",
                "Contains the Pleiades and Hyades star clusters.",
                "Aldebaran is a red giant star."
            ],
            color: .red,
            rightAscension: "04h",
            declination: "+15°",
            visibleLatitudes: "+90° to -65°"
        ),
        Constellation(
            name: "Gemini",
            latinName: "Gemini",
            abbreviation: "Gem",
            season: "Winter",
            mainStars: ["Castor", "Pollux", "Alhena", "Tejat Posterior", "Mebsuta", "Propus"],
            brightestStar: "Pollux",
            magnitude: "1.2",
            symbolism: "The Twins",
            facts: [
                "Zodiac constellation.",
                "Represents the twins Castor and Pollux from Greek mythology.",
                "Home to the Geminids meteor shower."
            ],
            color: .cyan,
            rightAscension: "07h",
            declination: "+22°",
            visibleLatitudes: "+90° to -60°"
        ),
        Constellation(
            name: "Cancer",
            latinName: "Cancer",
            abbreviation: "Cnc",
            season: "Winter",
            mainStars: ["Altarf", "Asellus Borealis", "Asellus Australis", "Acubens"],
            brightestStar: "Altarf",
            magnitude: "3.5",
            symbolism: "The Crab",
            facts: [
                "Faintest of the zodiac constellations.",
                "Contains the Beehive Cluster (M44).",
                "Associated with the crab in Greek mythology that Hercules fought."
            ],
            color: .gray,
            rightAscension: "08h",
            declination: "+20°",
            visibleLatitudes: "+90° to -60°"
        ),
        Constellation(
            name: "Aries",
            latinName: "Aries",
            abbreviation: "Ari",
            season: "Autumn",
            mainStars: ["Hamal", "Sheratan", "Mesarthim", "Botein"],
            brightestStar: "Hamal",
            magnitude: "2.0",
            symbolism: "The Ram",
            facts: [
                "Zodiac constellation.",
                "Represents the ram with the Golden Fleece in Greek mythology.",
                "Relatively faint constellation."
            ],
            color: .brown,
            rightAscension: "02h",
            declination: "+20°",
            visibleLatitudes: "+90° to -60°"
        ),
        Constellation(
            name: "Virgo",
            latinName: "Virgo",
            abbreviation: "Vir",
            season: "Spring",
            mainStars: ["Spica", "Zavijava", "Porrima", "Vindemiatrix", "Heze", "Zaniah"],
            brightestStar: "Spica",
            magnitude: "1.0",
            symbolism: "The Virgin",
            facts: [
                "Second largest constellation in the sky.",
                "Represents the goddess of justice or agriculture.",
                "Contains part of the Virgo Supercluster of galaxies."
            ],
            color: .pink,
            rightAscension: "13h",
            declination: "-05°",
            visibleLatitudes: "+80° to -80°"
        ),
        Constellation(
            name: "Libra",
            latinName: "Libra",
            abbreviation: "Lib",
            season: "Summer",
            mainStars: ["Zubeneschamali", "Zubenelgenubi", "Zubenelakrab", "Brachium"],
            brightestStar: "Zubeneschamali",
            magnitude: "2.6",
            symbolism: "The Scales",
            facts: [
                "Zodiac constellation.",
                "Only zodiac sign representing an object, not a being.",
                "Represents the scales of justice."
            ],
            color: .indigo,
            rightAscension: "15h",
            declination: "-15°",
            visibleLatitudes: "+65° to -90°"
        ),
        Constellation(
            name: "Scorpius",
            latinName: "Scorpius",
            abbreviation: "Sco",
            season: "Summer",
            mainStars: ["Antares", "Shaula", "Sargas", "Dschubba", "Acrab", "Larawag", "Girtab"],
            brightestStar: "Antares",
            magnitude: "0.96",
            symbolism: "The Scorpion",
            facts: [
                "Zodiac constellation.",
                "Contains the bright red supergiant star Antares.",
                "Represents the scorpion that stung Orion in mythology."
            ],
            color: .red,
            rightAscension: "17h",
            declination: "-40°",
            visibleLatitudes: "+40° to -90°"
        ),
        Constellation(
            name: "Sagittarius",
            latinName: "Sagittarius",
            abbreviation: "Sgr",
            season: "Summer",
            mainStars: ["Rukbat", "Alrami", "Arkab Prior", "Arkab Posterior", "Alnasl", "Kaus Media", "Kaus Australis", "Kaus Borealis", "Ascella", "Nunki"],
            brightestStar: "Rukbat",
            magnitude: "1.85",
            symbolism: "The Archer",
            facts: [
                "Zodiac constellation.",
                "Represents a centaur archer in mythology.",
                "The center of the Milky Way galaxy is located in Sagittarius."
            ],
            color: .brown,
            rightAscension: "19h",
            declination: "-25°",
            visibleLatitudes: "+55° to -90°"
        ),
        Constellation(
            name: "Capricornus",
            latinName: "Capricornus",
            abbreviation: "Cap",
            season: "Autumn",
            mainStars: ["Deneb Algedi", "Algedi", "Nashira", " سعدالسعود", "Dabih"],
            brightestStar: "Deneb Algedi",
            magnitude: "2.85",
            symbolism: "The Sea Goat",
            facts: [
                "Faintest zodiac constellation.",
                "Represents a sea goat in mythology.",
                "Indicates the winter solstice in the Northern Hemisphere."
            ],
            color: .gray,
            rightAscension: "21h",
            declination: "-20°",
            visibleLatitudes: "+60° to -90°"
        ),
        Constellation(
            name: "Aquarius",
            latinName: "Aquarius",
            abbreviation: "Aqr",
            season: "Autumn",
            mainStars: ["Sadalsuud", "Sadalmelik", "Sadalachbia", "Albali", "Ancha"],
            brightestStar: "Sadalsuud",
            magnitude: "2.9",
            symbolism: "The Water Bearer",
            facts: [
                "Zodiac constellation.",
                "Represents a man pouring water from a jar.",
                "Associated with floods in ancient cultures."
            ],
            color: .cyan,
            rightAscension: "22h",
            declination: "-10°",
            visibleLatitudes: "+65° to -90°"
        ),
        Constellation(
            name: "Pisces",
            latinName: "Pisces",
            abbreviation: "Psc",
            season: "Winter",
            mainStars: ["Alpherg", "Fumalsamakah", "Alrescha", "Kullat Nunu"],
            brightestStar: "Alpherg",
            magnitude: "3.6",
            symbolism: "The Fishes",
            facts: [
                "Zodiac constellation.",
                "Represents two fish tied together in mythology.",
                "Located in the region of the celestial sea."
            ],
            color: .mint,
            rightAscension: "01h",
            declination: "+15°",
            visibleLatitudes: "+90° to -65°"
        )
    ]
}


// MARK: - Preview Provider
struct ConstellationView_Previews: PreviewProvider {
    static var previews: some View {
        ConstellationView()
    }
}

// MARK: - View Extensions
extension View {
    func glowEffect(color: Color = .blue, radius: CGFloat = 20) -> some View {
        self
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
    }
}
