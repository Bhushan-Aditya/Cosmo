import SwiftUI

struct TimeDelayAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let cy = size.height/2
                drawAnimStars(&ctx, size: size)
                for (cx, spd): (CGFloat, Double) in [(size.width*0.3, 0.3),(size.width*0.72, 2.4)] {
                    let r = 22.0
                    ctx.opacity = 0.11; ctx.fill(Circle().path(in: CGRect(x: cx-r, y: cy-r-4, width: r*2, height: r*2)), with: .color(.white))
                    ctx.opacity = 0.65; ctx.stroke(Circle().path(in: CGRect(x: cx-r, y: cy-r-4, width: r*2, height: r*2)), with: .color(.white), lineWidth: 1.2)
                    for h in 0..<12 {
                        let a = Double(h)/12.0 * .pi*2 - .pi/2
                        var tick = Path()
                        tick.move(to: CGPoint(x: cx+(r-5)*cos(a), y: cy-4+(r-5)*sin(a)))
                        tick.addLine(to: CGPoint(x: cx+(r-1)*cos(a), y: cy-4+(r-1)*sin(a)))
                        ctx.opacity = 0.35; ctx.stroke(tick, with: .color(.white), lineWidth: 0.7)
                    }
                    let ha = t*spd - .pi/2
                    var hand = Path()
                    hand.move(to: CGPoint(x: cx, y: cy-4))
                    hand.addLine(to: CGPoint(x: cx+(r-7)*cos(ha), y: cy-4+(r-7)*sin(ha)))
                    ctx.opacity = 0.9; ctx.stroke(hand, with: .color(spd < 1 ? .orange : .red), lineWidth: 1.6)
                    ctx.opacity = 1; ctx.fill(Circle().path(in: CGRect(x: cx-2, y: cy-6, width: 4, height: 4)), with: .color(.white))
                }
                ctx.opacity = 0.18
                var div = Path(); div.move(to: CGPoint(x: size.width/2, y: cy-28)); div.addLine(to: CGPoint(x: size.width/2, y: cy+20))
                ctx.stroke(div, with: .color(.white), lineWidth: 0.8)
                ctx.opacity = 1
            }
            .drawingGroup()
        }
    }
}
