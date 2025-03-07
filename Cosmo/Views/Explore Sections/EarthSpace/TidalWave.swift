import SwiftUI

// MARK: - Tide Models and Data
struct Tide: Identifiable {
    let id = UUID()
    let name: String
    let type: TideType
    let location: String
    let dateTime: String
    let height: String
    let causes: [String]
    let color: Color
}

enum TideType: String {
    case high = "High Tide"
    case low = "Low Tide"
    case neap = "Neap Tide"
    case spring = "Spring Tide"

    var description: String {
        rawValue
    }
}

let tides = [
    Tide(
        name: "Morning High Tide",
        type: .high,
        location: "San Francisco Bay",
        dateTime: "March 3, 2025, 06:50 AM",
        height: "5.8 ft",
        causes: [
            "Strong gravitational pull by the moon",
            "Earth's rotation aligning with moon's orbit",
            "Influence of ocean basin topography"
        ],
        color: .blue
    ),
    Tide(
        name: "Evening Low Tide",
        type: .low,
        location: "Miami Beach",
        dateTime: "March 3, 2025, 08:15 PM",
        height: "0.9 ft",
        causes: [
            "Gravitational pull at weakest alignment",
            "Opposite moon position relative to Earth's rotation"
        ],
        color: .cyan
    ),
    Tide(
        name: "Spring Tide Peak",
        type: .spring,
        location: "Sydney Harbour",
        dateTime: "March 10, 2025, 01:30 PM",
        height: "6.5 ft",
        causes: [
            "Sun, moon, and Earth aligned (New Moon phase)",
            "Gravitational forces combine (syzygy event)"
        ],
        color: .purple
    ),
    Tide(
        name: "Neap Tide Minimum",
        type: .neap,
        location: "North Sea Coast",
        dateTime: "March 17, 2025, 03:40 PM",
        height: "1.5 ft",
        causes: [
            "Sun and moon at right angles (quarter moon phase)",
            "Gravitational forces counteract each other"
        ],
        color: .green
    )
]

// MARK: - Advanced Tide Animation Components
struct AdvancedTideAnimation: View {
    @State private var phase1: CGFloat = 0
    @State private var phase2: CGFloat = .pi / 2
    @State private var phase3: CGFloat = .pi
    @State private var moonRotation: Double = 0
    @State private var particlePhase: CGFloat = 0
    let tide: Tide

    var body: some View {
        ZStack {
            // Ocean Background
            LinearGradient(
                gradient: Gradient(colors: [
                    tide.color.opacity(0.8),
                    tide.color.opacity(0.4),
                    tide.color.opacity(0.2)
                ]),
                startPoint: .bottom,
                endPoint: .top
            )

            // Multiple Layer Wave System
            Group {
                // Deep Wave Layer
                ComplexWaveShape(phase: phase1, amplitude: 8, frequency: 2)
                    .fill(tide.color.opacity(0.4))
                    .animation(
                        Animation.linear(duration: 4).repeatForever(autoreverses: false),
                        value: phase1
                    )

                // Middle Wave Layer
                ComplexWaveShape(phase: phase2, amplitude: 12, frequency: 1.5)
                    .fill(tide.color.opacity(0.3))
                    .animation(
                        Animation.linear(duration: 3).repeatForever(autoreverses: false),
                        value: phase2
                    )

                // Surface Wave Layer
                ComplexWaveShape(phase: phase3, amplitude: 10, frequency: 2.5)
                    .fill(tide.color.opacity(0.5))
                    .animation(
                        Animation.linear(duration: 2).repeatForever(autoreverses: false),
                        value: phase3
                    )
            }

            // Particle Effects
            ForEach(0..<15) { index in
                ParticleEffect(phase: particlePhase + CGFloat(index))
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 4, height: 4)
                    .blur(radius: 1)
            }

            // Celestial Bodies (Based on tide type)
            if tide.type == .spring || tide.type == .neap {
                CelestialBodiesView(tide: tide, moonRotation: moonRotation)
            }

            // Tidal Force Indicators
            TidalForceIndicators(tide: tide)
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                phase1 += 2 * .pi
                phase2 += 2 * .pi
                phase3 += 2 * .pi
                particlePhase += 2 * .pi
                moonRotation += 360
            }
        }
    }
}

// MARK: - Complex Wave Shape
struct ComplexWaveShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat
    var frequency: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midHeight = rect.height / 2

        path.move(to: CGPoint(x: 0, y: rect.height))

        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / rect.width
            let sine = sin(relativeX * frequency * .pi * 2 + phase)
            let cosine = cos(relativeX * frequency * .pi * 2 + phase)
            let combined = sine + cosine

            let y = midHeight + combined * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

// MARK: - Particle Effect
struct ParticleEffect: Shape {
    var phase: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let xOffset = sin(phase) * rect.width/2 + rect.width/2
        let yOffset = cos(phase) * rect.height/3 + rect.height/2

        var path = Path()
        path.addEllipse(in: CGRect(x: xOffset, y: yOffset, width: 2, height: 2))
        return path
    }
}

// MARK: - Celestial Bodies View
struct CelestialBodiesView: View {
    let tide: Tide
    var moonRotation: Double

    var body: some View {
        ZStack {
            // Sun
            Circle()
                .fill(Color.yellow)
                .frame(width: 20, height: 20)
                .blur(radius: 2)
                .overlay(
                    Circle()
                        .stroke(Color.orange, lineWidth: 1)
                        .blur(radius: 1)
                )
                .position(x: tide.type == .spring ? 40 : 120, y: 30)

            // Moon
            Circle()
                .fill(Color.gray)
                .frame(width: 15, height: 15)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                        .blur(radius: 1)
                )
                .rotationEffect(.degrees(moonRotation))
                .position(x: tide.type == .spring ? 40 : 40, y: 30)
        }
    }
}

// MARK: - Tidal Force Indicators
struct TidalForceIndicators: View {
    let tide: Tide
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<6) { index in
                let position = CGFloat(index) * (geometry.size.width / 5)

                Rectangle()
                    .fill(tide.color)
                    .frame(width: 2, height: getTidalHeight(for: index))
                    .offset(x: position, y: isAnimating ? -5 : 5)
                    .opacity(0.6)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }

    private func getTidalHeight(for index: Int) -> CGFloat {
        let baseHeight: CGFloat = 20
        switch tide.type {
        case .high, .spring:
            return baseHeight + CGFloat(sin(Double(index) * .pi / 3) * 10)
        case .low:
            return baseHeight - CGFloat(sin(Double(index) * .pi / 3) * 5)
        case .neap:
            return baseHeight
        }
    }
}

// MARK: - Tide Card
struct TideCard: View {
    let tide: Tide
    @State private var showDetails = false

    var body: some View {
        Button(action: { showDetails.toggle() }) {
            VStack(spacing: 15) {
                AdvancedTideAnimation(tide: tide)

                VStack(alignment: .leading, spacing: 8) {
                    Text(tide.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(tide.dateTime)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text(tide.location)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(tide.color.opacity(0.5), lineWidth: 2)
            )
        }
        .sheet(isPresented: $showDetails) {
            TideDetailView(tide: tide)
        }
    }
}

// MARK: - Tide Detail View
struct TideDetailView: View {
    let tide: Tide
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    AdvancedTideAnimation(tide: tide)
                        .scaleEffect(2)
                        .frame(height: 200)

                    VStack(alignment: .leading, spacing: 15) {
                        InfoRow(title: "Type", value: tide.type.description)
                        InfoRow(title: "Location", value: tide.location)
                        InfoRow(title: "Date & Time", value: tide.dateTime)
                        InfoRow(title: "Height", value: tide.height)
                    }
                    .padding()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Key Causes")
                            .font(.headline)
                            .foregroundColor(.white)

                        ForEach(tide.causes, id: \.self) { cause in
                            HStack(alignment: .top) {
                                Text("•")
                                    .foregroundColor(tide.color)
                                Text(cause)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(tide.name)
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

// MARK: - Main Tide View
struct TideExplorerView: View {
    @State private var selectedType: TideType?
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    @State private var zoomLevel: Double = 1.0

    var filteredTides: [Tide] {
        if let type = selectedType {
            return tides.filter { $0.type == type }
        }
        return tides
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                VStack(spacing: 20) {
                    Text("Tide Explorer")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)

                    Text("Understand how moon, sun, and gravity affect oceans!")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding()

                // Filter Buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        FilterButton(title: "All", isSelected: selectedType == nil) {
                            selectedType = nil
                        }
                        FilterButton(title: "High Tide", isSelected: selectedType == .high) {
                            selectedType = .high
                        }
                        FilterButton(title: "Low Tide", isSelected: selectedType == .low) {
                            selectedType = .low
                        }
                        FilterButton(title: "Spring Tide", isSelected: selectedType == .spring) {
                            selectedType = .spring
                        }
                        FilterButton(title: "Neap Tide", isSelected: selectedType == .neap) {
                            selectedType = .neap
                        }
                    }
                    .padding(.horizontal)
                }

                // Tide Cards Grid
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(filteredTides) { tide in
                        TideCard(tide: tide)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal)
                .animation(.spring(), value: selectedType)
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
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Tides")
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview
struct TideExplorerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TideExplorerView()
        }
    }
}

