import SwiftUI

// MARK: - Solar Flare Models and Data
struct SolarFlare: Identifiable {
    let id = UUID()
    let name: String
    let category: FlareCategory
    let peakTime: String
    let region: String
    let magnitude: String
    let impact: [String]
    let color: Color
}

enum FlareCategory: String {
    case X = "X-Class (Extreme)"
    case M = "M-Class (Medium)"
    case C = "C-Class (Small)"
    case B = "B-Class (Minor)"
    case A = "A-Class (Very Weak)"

    var description: String {
        rawValue
    }

    var severity: Int {
        switch self {
        case .X: return 4
        case .M: return 3
        case .C: return 2
        case .B: return 1
        case .A: return 0
        }
    }
}

// Solar Flares Data
let solarFlares = [
    SolarFlare(
        name: "X9.3 Flare",
        category: .X,
        peakTime: "September 6, 2017, 12:02 UTC",
        region: "AR12673",
        magnitude: "X9.3",
        impact: [
            "Severe geomagnetic storms",
            "GPS blackout for hours",
            "Astronauts at risk of radiation exposure",
            "Northern lights visible in unusual locations"
        ],
        color: .red
    ),
    SolarFlare(
        name: "M7.2 Flare",
        category: .M,
        peakTime: "May 15, 2024, 04:50 UTC",
        region: "AR2995",
        magnitude: "M7.2",
        impact: [
            "Moderate radio signal interruptions",
            "Mid-latitude auroras visible at night",
            "Affected aviation navigation systems",
            "Minor satellite anomalies detected"
        ],
        color: .orange
    ),
    SolarFlare(
        name: "C5.8 Flare",
        category: .C,
        peakTime: "August 20, 2025, 10:20 UTC",
        region: "AR3005",
        magnitude: "C5.8",
        impact: [
            "Minimal impacts on communication",
            "Slight solar wind increase",
            "Scientific interest for its symmetry",
            "Auroras rarely observed in polar regions"
        ],
        color: .yellow
    ),
    SolarFlare(
        name: "B2.1 Flare",
        category: .B,
        peakTime: "July 30, 2023, 08:40 UTC",
        region: "AR2920",
        magnitude: "B2.1",
        impact: [
            "Weakly emitted x-rays detected",
            "No surface effects observed",
            "Energy level barely exceeds solar background",
            "Study for evolutionary solar activity"
        ],
        color: .green
    ),
    SolarFlare(
        name: "A1.0 Flare",
        category: .A,
        peakTime: "March 10, 2024, 11:25 UTC",
        region: "AR2899",
        magnitude: "A1.0",
        impact: [
            "Detected only by instruments",
            "No practical impacts observed",
            "Weak fluctuations in Heliospheric pressure"
        ],
        color: .cyan
    )
]

// MARK: - Flare Animation Components
struct EnhancedFlareAnimation: View {
    @State private var isAnimating = false
    let flare: SolarFlare

    var body: some View {
        ZStack {
            // Sun Core
            Circle()
                .fill(flare.color)
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [flare.color.opacity(0.9), flare.color.opacity(0.2)]),
                                startPoint: .center,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 5
                        )
                        .blur(radius: 2)
                )

            // Radiating Solar Flare Effects
            ForEach(0..<6) { index in
                Circle()
                    .stroke(flare.color.opacity(0.6), lineWidth: CGFloat(index + 1) * 1.5)
                    .frame(width: CGFloat(60 + index * 15), height: CGFloat(60 + index * 15))
                    .scaleEffect(isAnimating ? 1.5 : 1)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        Animation.easeInOut(duration: 3.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.4),
                        value: isAnimating
                    )
            }

            // Dynamic Coronal Plasmic Burst for X-Class
            if flare.category == .X {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [flare.color.opacity(0.4), .clear]),
                            center: .center,
                            startRadius: 3,
                            endRadius: 40
                        )
                    )
                    .frame(width: 70, height: 70)
                    .scaleEffect(isAnimating ? 1.8 : 1.1)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
    }
}

// MARK: - Solar Flare Card
struct SolarFlareCard: View {
    let flare: SolarFlare
    @State private var showDetails = false

    var body: some View {
        Button(action: { showDetails.toggle() }) {
            VStack(spacing: 15) {
                EnhancedFlareAnimation(flare: flare)
                    .frame(height: 90)

                VStack(alignment: .leading, spacing: 8) {
                    Text(flare.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(flare.category.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text(flare.peakTime)
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
                    .stroke(flare.color.opacity(0.5), lineWidth: 2)
            )
        }
        .sheet(isPresented: $showDetails) {
            SolarFlareDetailView(flare: flare)
        }
    }
}

// MARK: - Solar Flare Detail View
struct SolarFlareDetailView: View {
    let flare: SolarFlare
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    EnhancedFlareAnimation(flare: flare)
                        .scaleEffect(2)
                        .frame(height: 200)

                    VStack(alignment: .leading, spacing: 15) {
                        InfoRow(title: "Category", value: flare.category.description)
                        InfoRow(title: "Peak Time", value: flare.peakTime)
                        InfoRow(title: "Region", value: flare.region)
                        InfoRow(title: "Magnitude", value: flare.magnitude)
                    }
                    .padding()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Key Impacts")
                            .font(.headline)
                            .foregroundColor(.white)

                        ForEach(flare.impact, id: \.self) { impact in
                            HStack(alignment: .top) {
                                Text("•")
                                    .foregroundColor(flare.color)
                                Text(impact)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(flare.name)
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

// MARK: - Main Solar Flare View
struct SolarFlareView: View {
    @State private var selectedCategory: FlareCategory?
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    @State private var zoomLevel: Double = 1.0

    var filteredFlares: [SolarFlare] {
        if let category = selectedCategory {
            return solarFlares.filter { $0.category == category }
        }
        return solarFlares
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 20) {
                    Text("Solar Flare Explorer")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)

                    Text("Explore the power of the Sun")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding()

                // Filter Buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        FilterButton(title: "All", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        FilterButton(title: "X-Class", isSelected: selectedCategory == .X) {
                            selectedCategory = .X
                        }
                        FilterButton(title: "M-Class", isSelected: selectedCategory == .M) {
                            selectedCategory = .M
                        }
                        FilterButton(title: "C-Class", isSelected: selectedCategory == .C) {
                            selectedCategory = .C
                        }
                        FilterButton(title: "B-Class", isSelected: selectedCategory == .B) {
                            selectedCategory = .B
                        }
                        FilterButton(title: "A-Class", isSelected: selectedCategory == .A) {
                            selectedCategory = .A
                        }
                    }
                    .padding(.horizontal)
                }

                // Flare Cards Grid
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(filteredFlares) { flare in
                        SolarFlareCard(flare: flare)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal)
                .animation(.spring(), value: selectedCategory)
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
        .navigationTitle("Solar Flares")
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview
struct SolarFlareView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SolarFlareView()
        }
    }
}
