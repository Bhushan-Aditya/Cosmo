import SwiftUI

struct MoonAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let cx = size.width/2, cy = size.height/2
                drawAnimStars(&ctx, size: size)
                for r in [28.0, 42.0] {
                    ctx.opacity = 0.11
                    ctx.stroke(Circle().path(in: CGRect(x: cx-r, y: cy-r, width: r*2, height: r*2)), with: .color(.white), lineWidth: 0.7)
                }
                for (r, op, col): (Double, Double, Color) in [(16,0.13,.blue),(11,1,Color(red:0.25,green:0.55,blue:0.95))] {
                    ctx.opacity = op
                    ctx.fill(Circle().path(in: CGRect(x: cx-r, y: cy-r, width: r*2, height: r*2)), with: .color(col))
                }
                for (r, spd, ms, col): (Double, Double, Double, Color) in [(28,0.9,3.5,Color(white:0.85)),(42,0.5,4,Color(white:0.65))] {
                    let pt = animOrbitPt(cx, cy, r: r, a: t*spd, ry: 0.65)
                    ctx.opacity = 0.3; ctx.fill(Circle().path(in: CGRect(x: pt.x-ms*1.6, y: pt.y-ms*1.6, width: ms*3.2, height: ms*3.2)), with: .color(col))
                    ctx.opacity = 1;   ctx.fill(Circle().path(in: CGRect(x: pt.x-ms, y: pt.y-ms, width: ms*2, height: ms*2)), with: .color(col))
                }
            }
            .drawingGroup()
        }
    }
}
