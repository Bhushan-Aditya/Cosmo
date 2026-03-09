import SwiftUI

struct EclipseAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                Self.draw(&ctx, size: size, t: tl.date.timeIntervalSinceReferenceDate)
            }
            .drawingGroup()
        }
    }

    private static func draw(_ ctx: inout GraphicsContext, size: CGSize, t: TimeInterval) {
        let cy: CGFloat   = size.height / 2
        let sunX: CGFloat = size.width * 0.4
        let cycle: Double = (t * 0.18).truncatingRemainder(dividingBy: 1)
        let moonX: CGFloat = size.width * CGFloat(1.3 - cycle * 1.1)
        let sunR: Double  = 22.0

        // Corona rays
        for i in 0..<12 {
            let a: Double   = Double(i) * .pi / 6 + t * 0.12
            let innerR: Double = sunR + 4
            let outerR: Double = sunR + 12 + sin(t * 2 + Double(i)) * 4
            let p1 = CGPoint(x: sunX + innerR * cos(a), y: cy + innerR * sin(a))
            let p2 = CGPoint(x: sunX + outerR * cos(a), y: cy + outerR * sin(a))
            var ray = Path(); ray.move(to: p1); ray.addLine(to: p2)
            ctx.opacity = 0.35
            ctx.stroke(ray, with: .color(.yellow), lineWidth: 1.2)
        }

        // Sun glow layers
        let sunLayers: [(Double, Double)] = [(sunR+8, 0.1), (sunR+4, 0.25), (sunR, 1.0)]
        for (r, op) in sunLayers {
            ctx.opacity = op
            let col: Color = r > sunR ? .yellow : Color(red: 1, green: 0.85, blue: 0.2)
            ctx.fill(Circle().path(in: CGRect(x: sunX-r, y: cy-r, width: r*2, height: r*2)),
                     with: .color(col))
        }

        // Moon
        let moonR: Double = 20.0
        ctx.opacity = 0.1
        ctx.fill(Circle().path(in: CGRect(x: moonX-moonR-5, y: cy-moonR-5, width: (moonR+5)*2, height: (moonR+5)*2)),
                 with: .color(.gray))
        ctx.opacity = 1
        ctx.fill(Circle().path(in: CGRect(x: moonX-moonR, y: cy-moonR, width: moonR*2, height: moonR*2)),
                 with: .color(Color(white: 0.08)))
    }
}
