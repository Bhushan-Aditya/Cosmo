import SwiftUI


// MARK: - Models and Complete Systems Data
struct EclipseEvent: Identifiable {
    let id = UUID()
    let name: String
    let type: EclipseType
    let date: String
    let location: String
    let duration: String
    let magnitude: String
    let facts: [String]
    let color: Color
    let visibility: String
}

enum EclipseType {
    case total
    case partial
    case annular
    case hybrid

    var description: String {
        switch self {
        case .total: return "Total Eclipse"
        case .partial: return "Partial Eclipse"
        case .annular: return "Annular Eclipse"
        case .hybrid: return "Hybrid Eclipse"
        }
    }
}

// MARK: - All Eclipse Events
let eclipseEvents = [
    EclipseEvent(
        name: "Great North American Eclipse",
        type: .total,
        date: "April 8, 2024",
        location: "North America",
        duration: "4m 28s",
        magnitude: "1.0566",
        facts: [
            "Path through 13 U.S. states",
            "Visible from Mexico to Canada",
            "Over 31 million in path of totality",
            "First total eclipse in U.S. since 2017",
            "Maximum duration in Texas"
        ],
        color: .blue,
        visibility: "Total path: Mexico to Canada"
    ),
    EclipseEvent(
        name: "Eastern Pacific Eclipse",
        type: .total,
        date: "August 12, 2026",
        location: "Greenland, Iceland, Spain",
        duration: "2m 18s",
        magnitude: "1.0303",
        facts: [
            "Visible from Northern Europe",
            "Crosses Arctic regions",
            "Evening eclipse in Spain",
            "Partial visibility in UK",
            "Affects multiple time zones"
        ],
        color: .purple,
        visibility: "Northern hemisphere"
    ),
    EclipseEvent(
        name: "Asian Annular Eclipse",
        type: .annular,
        date: "October 2, 2024",
        location: "Pacific, Americas",
        duration: "7m 25s",
        magnitude: "0.9922",
        facts: [
            "Ring of fire effect",
            "Crosses multiple continents",
            "Longest annular of decade",
            "Visible from Chile to Brazil",
            "Pacific Ocean viewing"
        ],
        color: .orange,
        visibility: "Pacific and South America"
    ),
    EclipseEvent(
        name: "European Total Eclipse",
        type: .total,
        date: "August 2, 2027",
        location: "Mediterranean Region",
        duration: "6m 23s",
        magnitude: "1.0799",
        facts: [
            "Longest total eclipse until 2114",
            "Visible from Spain to Egypt",
            "Perfect viewing conditions expected",
            "Major scientific observation event",
            "Tourism surge anticipated"
        ],
        color: .red,
        visibility: "Southern Europe and North Africa"
    ),
    EclipseEvent(
            name: "Great North American Eclipse",
            type: .total,
            date: "April 8, 2024",
            location: "North America",
            duration: "4m 28s",
            magnitude: "1.0566",
            facts: [
                "Path through 13 U.S. states",
                "Visible from Mexico to Canada",
                "Over 31 million in path of totality",
                "First total eclipse in U.S. since 2017",
                "Maximum duration in Texas"
            ],
            color: .blue,
            visibility: "Total path: Mexico to Canada"
        ),
        EclipseEvent(
            name: "South Pacific Eclipse",
            type: .annular,
            date: "October 2, 2024",
            location: "South Pacific",
            duration: "7m 25s",
            magnitude: "0.9922",
            facts: [
                "Visible across South Pacific",
                "Ring of fire appearance",
                "Crosses Chilean coastline",
                "Easter Island visibility",
                "Perfect for maritime viewing"
            ],
            color: .green,
            visibility: "South Pacific and South America"
        ),
        EclipseEvent(
            name: "Saharan Total Eclipse",
            type: .total,
            date: "August 2, 2027",
            location: "North Africa",
            duration: "6m 23s",
            magnitude: "1.0799",
            facts: [
                "Crosses Sahara Desert",
                "Exceptional viewing conditions",
                "Longest duration of century",
                "Scientific research opportunity",
                "Multiple country visibility"
            ],
            color: .orange,
            visibility: "North Africa and Middle East"
        ),
        EclipseEvent(
            name: "Antarctic Eclipse",
            type: .total,
            date: "December 5, 2024",
            location: "Antarctica",
            duration: "1m 54s",
            magnitude: "1.0255",
            facts: [
                "Visible from Antarctica",
                "Challenging viewing conditions",
                "Research station observations",
                "Midnight sun phenomenon",
                "Limited accessibility"
            ],
            color: .cyan,
            visibility: "Antarctic region"
        ),
        EclipseEvent(
            name: "Asian Hybrid Eclipse",
            type: .hybrid,
            date: "April 20, 2023",
            location: "Southeast Asia",
            duration: "1m 16s",
            magnitude: "1.0013",
            facts: [
                "Transitions between total and annular",
                "Crosses Indonesia",
                "Complex shadow geometry",
                "Rare hybrid type",
                "Ocean viewing opportunities"
            ],
            color: .purple,
            visibility: "Southeast Asia and Pacific"
        ),
        EclipseEvent(
            name: "European Partial Eclipse",
            type: .partial,
            date: "October 25, 2022",
            location: "Europe",
            duration: "2h 07m",
            magnitude: "0.8623",
            facts: [
                "Visible across Europe",
                "Maximum in Russia",
                "Urban viewing event",
                "Scientific outreach",
                "Wide accessibility"
            ],
            color: .red,
            visibility: "Europe and Western Asia"
        ),
        EclipseEvent(
            name: "Pacific Ring Eclipse",
            type: .annular,
            date: "October 14, 2023",
            location: "Americas",
            duration: "5m 17s",
            magnitude: "0.9522",
            facts: [
                "Crosses North and South America",
                "Ring of fire visibility",
                "Major population centers",
                "Educational opportunity",
                "Cross-continental timing"
            ],
            color: .mint,
            visibility: "North and South America"
        ),
        EclipseEvent(
            name: "Arctic Midnight Eclipse",
            type: .total,
            date: "March 30, 2033",
            location: "Arctic Region",
            duration: "2m 37s",
            magnitude: "1.0459",
            facts: [
                "Polar viewing conditions",
                "Midnight sun phenomenon",
                "Aurora potential",
                "Limited accessibility",
                "Unique viewing angle"
            ],
            color: .indigo,
            visibility: "Arctic Circle"
        ),
        EclipseEvent(
            name: "Mediterranean Eclipse",
            type: .partial,
            date: "March 29, 2025",
            location: "Mediterranean",
            duration: "2h 45m",
            magnitude: "0.9322",
            facts: [
                "Visible from Southern Europe",
                "Coastal viewing spots",
                "Tourist attraction",
                "Multiple time zones",
                "Cultural significance"
            ],
            color: .yellow,
            visibility: "Mediterranean Region"
        ),
        EclipseEvent(
            name: "Trans-Siberian Eclipse",
            type: .total,
            date: "September 2, 2035",
            location: "Russia",
            duration: "3m 04s",
            magnitude: "1.0534",
            facts: [
                "Crosses Russian territory",
                "Remote viewing locations",
                "Wilderness experience",
                "Scientific expeditions",
                "Temperature drop phenomenon"
            ],
            color: .teal,
            visibility: "Northern Asia"
        )
    ]


// MARK: - Eclipse Card
struct EclipseCard: View {
    let eclipse: EclipseEvent
    @State private var showDetails = false
    @State private var isAnimating = false

    var body: some View {
        Button(action: { showDetails.toggle() }) {
            VStack(spacing: 15) {
                // Animated Eclipse Visualization
                ZStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .fill(Color.black)
                                .offset(x: isAnimating ? 20 : -20)
                                .animation(
                                    Animation.easeInOut(duration: 3)
                                        .repeatForever(autoreverses: true),
                                    value: isAnimating
                                )
                        )
                }
                .frame(width: 60, height: 60)

                VStack(alignment: .leading, spacing: 8) {
                    Text(eclipse.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(eclipse.type.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text(eclipse.date)
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
                    .stroke(eclipse.color.opacity(0.5), lineWidth: 2)
            )
        }
        .sheet(isPresented: $showDetails) {
            EclipseDetailView(eclipse: eclipse)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Eclipse Detail View
struct EclipseDetailView: View {
    let eclipse: EclipseEvent
    @Environment(\.presentationMode) var presentationMode
    @State private var isAnimating = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Animated Eclipse Visualization
                    ZStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 120, height: 120)
                        Circle()
                            .fill(Color.black)
                            .frame(width: 120, height: 120)
                            .offset(x: isAnimating ? 60 : -60)
                            .animation(
                                Animation.easeInOut(duration: 3)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                    }
                    .frame(height: 200)

                    VStack(alignment: .leading, spacing: 15) {
                        InfoRow(title: "Type", value: eclipse.type.description)
                        InfoRow(title: "Date", value: eclipse.date)
                        InfoRow(title: "Location", value: eclipse.location)
                        InfoRow(title: "Duration", value: eclipse.duration)
                        InfoRow(title: "Magnitude", value: eclipse.magnitude)
                        InfoRow(title: "Visibility", value: eclipse.visibility)
                    }
                    .padding()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Key Features")
                            .font(.headline)
                            .foregroundColor(.white)

                        ForEach(eclipse.facts, id: \.self) { fact in
                            HStack(alignment: .top) {
                                Text("•")
                                    .foregroundColor(eclipse.color)
                                Text(fact)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(eclipse.name)
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

// MARK: - Eclipse Intro View
struct EclipseIntroView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 20) {
            // Animated Logo
            ZStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 80, height: 80)
                Circle()
                    .fill(Color.black)
                    .frame(width: 80, height: 80)
                    .offset(x: isAnimating ? 30 : -30)
            }
            .padding()
            .animation(
                Animation.easeInOut(duration: 3)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )

            Text("Solar Eclipses")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)

            Text("Celestial Shadow Dance")
                .font(.title3)
                .foregroundColor(.gray)
                .padding(.bottom, 5)

            Text("Track upcoming solar eclipses, their paths, and essential viewing information across the globe.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.gray)

            // Quick Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                QuickStatView(value: "2-5", unit: "min", label: "Totality")
                QuickStatView(value: "400k", unit: "km", label: "Moon Distance")
                QuickStatView(value: "2024", unit: "", label: "Next Eclipse")
            }
            .padding()

            // Feature Cards Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                EclipseFeatureCard(emoji: "🌑", text: "Total Eclipse")
                EclipseFeatureCard(emoji: "🌓", text: "Partial Eclipse")
                EclipseFeatureCard(emoji: "⭕️", text: "Annular Eclipse")
                EclipseFeatureCard(emoji: "🌎", text: "Global Visibility")
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
        )
        .padding()
        .onAppear {
            isAnimating = true
        }
    }
}

struct EclipseFeatureCard: View {
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
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}

// MARK: - Main Eclipse View
struct EclipseView: View {
    @State private var selectedFilter: EclipseType?
    @State private var parallaxOffset: CGFloat = 0 // For parallax effect if you want to add drag gesture
    @State private var starfieldRotation: Double = 0 // For starfield rotation animation

    var filteredEvents: [EclipseEvent] {
        if let filter = selectedFilter {
            return eclipseEvents.filter { $0.type == filter }
        }
        return eclipseEvents
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                EclipseIntroView()

                // Filter Buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        FilterButton(title: "All", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        FilterButton(title: "Total", isSelected: selectedFilter == .total) {
                            selectedFilter = .total
                        }
                        FilterButton(title: "Partial", isSelected: selectedFilter == .partial) {
                            selectedFilter = .partial
                        }
                        FilterButton(title: "Annular", isSelected: selectedFilter == .annular) {
                            selectedFilter = .annular
                        }
                        FilterButton(title: "Hybrid", isSelected: selectedFilter == .hybrid) {
                            selectedFilter = .hybrid
                        }
                    }
                    .padding(.horizontal)
                }

                // Grid of Eclipse Events
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(filteredEvents) { event in
                        EclipseCard(eclipse: event)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal)
                .animation(.spring(), value: selectedFilter)
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
                starfieldRotation = 360 // Start starfield rotation animation
            }
        }
        // If you want to add drag gesture for parallax effect (optional)
        /*
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
        */
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Solar Eclipses")
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview
struct EclipseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EclipseView()
        }
    }
}
