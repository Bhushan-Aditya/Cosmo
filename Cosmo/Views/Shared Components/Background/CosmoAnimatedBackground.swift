import SwiftUI

struct CosmoAnimatedBackground: View {
    var zoomLevel: Double = 1.0

    @State private var starfieldRotation: Double = 0

    var body: some View {
        EnhancedCosmicBackground(
            parallaxOffset: 0,
            starfieldRotation: starfieldRotation,
            zoomLevel: zoomLevel
        )
        .onAppear {
            starfieldRotation = 0
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                starfieldRotation = 360
            }
        }
    }
}

