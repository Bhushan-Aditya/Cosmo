import SwiftUI
// MARK: - Models
struct Dimension: Identifiable {
    let id = UUID()
    let number: Int
    let name: String
    let description: String
    let properties: [String]
    let physicalManifestation: String
    let theoreticalImplications: [String]
    let visualizationChallenges: String
    let realWorldExamples: [String]
    let scientificSignificance: String
    let visualRepresentation: String
    let color: Color
}

// MARK: - Dimension Card
struct DimensionCard: View {
    let dimension: Dimension
    @State private var showDetails = false
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: { showDetails.toggle() }) {
            VStack(spacing: 15) {
                // Animated Dimension Visualization
                ZStack {
                    ForEach(0..<dimension.number) { index in
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(dimension.color.opacity(0.3))
                            .frame(width: 40 + CGFloat(index * 10),
                                   height: 40 + CGFloat(index * 10))
                            .rotationEffect(.degrees(isAnimating ? Double(index) * 30 : 0))
                    }
                    
                    Text(dimension.visualRepresentation)
                        .font(.system(size: 30))
                }
                .frame(height: 80)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(dimension.number)D: \(dimension.name)") // String interpolation fix
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(dimension.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
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
                    .stroke(dimension.color.opacity(0.5), lineWidth: 2)
            )
        }
        .sheet(isPresented: $showDetails) {
            DimensionDetailView(dimension: dimension)
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 10)
                .repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Dimension Detail View
struct DimensionDetailView: View {
    let dimension: Dimension
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Animated Dimension Visualization
                    ZStack {
                        ForEach(0..<dimension.number) { index in
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(dimension.color.opacity(0.3), lineWidth: 2)
                                .frame(width: 100 + CGFloat(index * 20),
                                       height: 100 + CGFloat(index * 20))
                                .rotation3DEffect(
                                    .degrees(Double(index) * 15),
                                    axis: (x: 1, y: 1, z: 0)
                                )
                        }
                        
                        Text(dimension.visualRepresentation)
                            .font(.system(size: 50))
                    }
                    .frame(height: 200)
                    
                    // Properties Section
                    GroupBox(label: Text("Properties").foregroundColor(.white)) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(dimension.properties, id: \.self) { property in
                                HStack(alignment: .top) {
                                    Text("•")
                                        .foregroundColor(dimension.color)
                                    Text(property)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    // Physical Manifestation
                    GroupBox(label: Text("Physical Manifestation").foregroundColor(.white)) {
                        Text(dimension.physicalManifestation)
                            .foregroundColor(.gray)
                            .padding(.vertical)
                    }
                    
                    // Theoretical Implications
                    GroupBox(label: Text("Theoretical Implications").foregroundColor(.white)) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(dimension.theoreticalImplications, id: \.self) { implication in
                                HStack(alignment: .top) {
                                    Text("•")
                                        .foregroundColor(dimension.color)
                                    Text(implication)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    // Examples
                    GroupBox(label: Text("Real World Examples").foregroundColor(.white)) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(dimension.realWorldExamples, id: \.self) { example in
                                HStack(alignment: .top) {
                                    Text("•")
                                        .foregroundColor(dimension.color)
                                    Text(example)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
                .padding()
            }
            .navigationTitle("\(dimension.number)D: \(dimension.name)") // String interpolation fix
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Main Dimensions View
struct DimensionsView: View {
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    
    let dimensions = [
        Dimension(
            number: 1,
            name: "Linear Dimension",
            description: "A single line extending infinitely in both directions",
            properties: [
                "Only movement along a line is possible",
                "No concept of width or height",
                "Can only move forward or backward",
                "Position described by a single coordinate"
            ],
            physicalManifestation: "Mathematical concept of a line with no width or height",
            theoreticalImplications: [
                "Fundamental to understanding higher dimensions",
                "Basic building block of geometry",
                "Used in linear measurements",
                "Critical in vector calculations"
            ],
            visualizationChallenges: "Purely theoretical as all real objects have multiple dimensions",
            realWorldExamples: [
                "Number line in mathematics",
                "Distance measurement along a path",
                "Timeline representations",
                "Linear progress bars"
            ],
            scientificSignificance: "Forms the basis for understanding spatial relationships and measurement",
            visualRepresentation: "↔️",
            color: .blue
        ),
        Dimension(
            number: 2,
            name: "Planar Dimension",
            description: "A flat surface extending infinitely in all directions",
            properties: [
                "Movement possible in two directions",
                "Has length and width",
                "No concept of height or depth",
                "Position described by two coordinates (x,y)"
            ],
            physicalManifestation: "Flat surfaces like paper or computer screens",
            theoreticalImplications: [
                "Fundamental to Euclidean geometry",
                "Basis for mapping and navigation",
                "Essential in computer graphics",
                "Used in architectural planning"
            ],
            visualizationChallenges: "True 2D objects don't exist in our 3D world",
            realWorldExamples: [
                "Maps and blueprints",
                "Computer screens",
                "Shadows",
                "Geometric shapes"
            ],
            scientificSignificance: "Essential for representing spatial relationships and geometric patterns",
            visualRepresentation: "⬛",
            color: .green
        ),
        Dimension(
            number: 3,
            name: "Spatial Dimension",
            description: "Our physical world with length, width, and height",
            properties: [
                "Movement in three directions",
                "Has length, width, and height",
                "Objects have volume",
                "Position described by three coordinates (x,y,z)"
            ],
            physicalManifestation: "The physical world we live in",
            theoreticalImplications: [
                "Basis for classical physics",
                "Fundamental to understanding space",
                "Essential for engineering",
                "Used in 3D modeling"
            ],
            visualizationChallenges: "Easily visualized as it's our natural environment",
            realWorldExamples: [
                "Physical objects",
                "Buildings and structures",
                "Natural landscapes",
                "3D printed objects"
            ],
            scientificSignificance: "Describes our physical reality and most natural phenomena",
            visualRepresentation: "🎲",
            color: .orange
        ),
        Dimension(
            number: 4,
            name: "Spacetime",
            description: "Three spatial dimensions plus time",
            properties: [
                "Combines space and time",
                "Events have four coordinates (x,y,z,t)",
                "Time acts as fourth dimension",
                "Basis for special relativity"
            ],
            physicalManifestation: "The fabric of our universe including time",
            theoreticalImplications: [
                "Einstein's theory of relativity",
                "Time dilation effects",
                "Gravitational time dilation",
                "Speed of light limitation"
            ],
            visualizationChallenges: "Difficult to visualize time as a spatial dimension",
            realWorldExamples: [
                "GPS time corrections",
                "Relativistic effects in satellites",
                "Cosmic events",
                "Particle physics"
            ],
            scientificSignificance: "Foundation of modern physics and understanding of the universe",
            visualRepresentation: "⌛",
            color: .purple
        ),
        // Additional dimensions can be added here
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Intro section
                VStack(spacing: 20) {
                    Text("🌌")
                        .font(.system(size: 60))
                        .padding()
                    
                    Text("Dimensions of Reality")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("From points to hyperspace, explore how dimensions shape our understanding of reality")
                        .multilineTextAlignment(.center)
                        .padding()
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.3))
                )
                .padding()
                
                // Dimensions Grid
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(dimensions) { dimension in
                        DimensionCard(dimension: dimension)
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
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Dimensions")
    }
}
struct DimensionView_Previews: PreviewProvider {
    static var previews: some View {
        DimensionsView()
            .preferredColorScheme(.dark) // Adding preferredColorScheme for consistency with rest of the app
    }
}
// MARK: -  Placeholder Views from Constellation (if needed and if you reuse background directly, else remove if not needed)
struct StarFieldView: View { // Placeholder if EnhancedCosmicBackground needs it - if not, and if not used, you can remove.
    var body: some View {
        // Replace with your StarFieldView implementation or remove if not using it in Dimensions Background
        Text("StarFieldView Placeholder")
    }
}

struct ConstellationAnimatedBackground: View { // Placeholder if EnhancedCosmicBackground needs it - if not, and if not used, you can remove.
    var body: some View {
         // Replace with your ConstellationAnimatedBackground implementation or remove if not using it in Dimensions Background
        Text("ConstellationAnimatedBackground Placeholder")
    }
}
