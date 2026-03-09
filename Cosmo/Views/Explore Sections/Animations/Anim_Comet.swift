import SwiftUI

struct CometAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let prog = (t*0.22).truncatingRemainder(dividingBy: 1)
                drawAnimStars(&ctx, size: size)
                let cx = size.width*(1.1-prog*1.5), cy = size.height*(prog*1.2-0.05)
                for i in 0..<18 {
                    let f = Double(i)/17, tr = max(0.5, 4-f*3.8)
                    ctx.opacity = 0.8-f*0.75
                    ctx.fill(Circle().path(in: CGRect(x: cx+f*52-tr, y: cy-f*40-tr, width: tr*2, height: tr*2)),
                             with: .color(Color(red:0.7,green:0.88,blue:1)))
                }
                for (r, op): (Double, Double) in [(8,0.15),(5.5,0.35),(3.5,1)] {
                    ctx.opacity = op
                    ctx.fill(Circle().path(in: CGRect(x: cx-r, y: cy-r, width: r*2, height: r*2)), with: .color(.white))
                }
                ctx.opacity = 1
            }
            .drawingGroup()
        }
    }
}
