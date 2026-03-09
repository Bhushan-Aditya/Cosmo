import SwiftUI

// Single shared implementation used across the app.
struct EnhancedCosmicBackground: View {
    private struct Star: Identifiable {
        let id: Int
        let x: CGFloat
        let y: CGFloat
        let vx: CGFloat
        let vy: CGFloat
        let radius: CGFloat
        let baseOpacity: Double
        let twinkleSpeed: Double
        let phase: Double
    }

    let parallaxOffset: CGFloat
    let starfieldRotation: Double
    let zoomLevel: Double

    @State private var stars: [Star] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.15, green: 0.1, blue: 0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let time = timeline.date.timeIntervalSinceReferenceDate
                        let center = CGPoint(x: size.width / 2, y: size.height / 2)

                        context.translateBy(x: center.x, y: center.y)
                        context.rotate(by: .degrees(starfieldRotation))
                        context.translateBy(x: -center.x, y: -center.y)

                        for star in stars {
                            let nx = (star.x + (star.vx * CGFloat(time))).truncatingRemainder(dividingBy: 1.0)
                            let ny = (star.y + (star.vy * CGFloat(time))).truncatingRemainder(dividingBy: 1.0)
                            let px = nx >= 0 ? nx : (nx + 1.0)
                            let py = ny >= 0 ? ny : (ny + 1.0)

                            let twinkle = 0.5 + 0.5 * sin((time * star.twinkleSpeed) + star.phase)
                            let opacity = min(1.0, max(0.0, star.baseOpacity * (0.65 + 0.7 * twinkle)))
                            context.opacity = opacity

                            context.fill(
                                Circle().path(
                                    in: CGRect(
                                        x: px * size.width,
                                        y: py * size.height,
                                        width: star.radius * 2,
                                        height: star.radius * 2
                                    )
                                ),
                                with: .color(.white)
                            )
                        }
                    }
                }
                .onAppear {
                    regenerateStars(for: geometry.size)
                }
                .onChange(of: geometry.size) { _, newSize in
                    regenerateStars(for: newSize)
                }

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.blue.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 250
                        )
                    )
                    .scaleEffect(max(0.8, min(1.2, zoomLevel)))
                    .offset(
                        x: parallaxOffset * 0.5,
                        y: parallaxOffset * 0.3
                    )
                    .blur(radius: 25)
            }
        }
    }

    private func regenerateStars(for size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }

        let count = 90
        stars = (0..<count).map { index in
            Star(
                id: index,
                x: CGFloat.random(in: 0.0...1.0),
                y: CGFloat.random(in: 0.0...1.0),
                vx: CGFloat.random(in: -0.0015...0.0015),
                vy: CGFloat.random(in: 0.003...0.010),
                radius: CGFloat.random(in: 0.6...1.8),
                baseOpacity: Double.random(in: 0.12...0.6),
                twinkleSpeed: Double.random(in: 0.8...2.4),
                phase: Double.random(in: 0...(2 * .pi))
            )
        }
    }
}
