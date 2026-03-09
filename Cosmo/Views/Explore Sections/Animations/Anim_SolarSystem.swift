import SwiftUI

struct SolarSystemAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let cx = size.width/2, cy = size.height/2
                drawAnimStars(&ctx, size: size)
                for r in [20.0, 32.0, 44.0] {
                    ctx.opacity = 0.12
                    ctx.stroke(Circle().path(in: CGRect(x: cx-r, y: cy-r, width: r*2, height: r*2)), with: .color(.white), lineWidth: 0.7)
                }
                for (r, op): (Double, Double) in [(13,0.13),(9,0.35),(6,1)] {
                    ctx.opacity = op
                    ctx.fill(Circle().path(in: CGRect(x: cx-r, y: cy-r, width: r*2, height: r*2)), with: .color(.orange))
                }
                ctx.opacity = 1
                ctx.fill(Circle().path(in: CGRect(x: cx-3.5, y: cy-3.5, width: 7, height: 7)), with: .color(.yellow))
                for (r, spd, ps, col): (Double, Double, Double, Color) in [(20,1.3,3,.cyan),(32,0.75,4,.orange),(44,0.45,2.5,.mint)] {
                    let pt = animOrbitPt(cx, cy, r: r, a: t*spd)
                    ctx.opacity = 0.35; ctx.fill(Circle().path(in: CGRect(x: pt.x-ps*1.6, y: pt.y-ps*1.6, width: ps*3.2, height: ps*3.2)), with: .color(col))
                    ctx.opacity = 1;    ctx.fill(Circle().path(in: CGRect(x: pt.x-ps, y: pt.y-ps, width: ps*2, height: ps*2)), with: .color(col))
                }
            }
            .drawingGroup()
        }
    }
}
