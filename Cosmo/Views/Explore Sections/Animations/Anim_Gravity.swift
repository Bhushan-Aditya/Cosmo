import SwiftUI

struct GravityAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let cx = size.width/2, cy = size.height*0.65
                for (r, op): (Double, Double) in [(16,0.1),(11,0.3),(8,1)] {
                    ctx.opacity = op
                    ctx.fill(Circle().path(in: CGRect(x: cx-r, y: cy-r, width: r*2, height: r*2)),
                             with: .color(r>9 ? .red : Color(red:0.85,green:0.2,blue:0.1)))
                }
                for i in 0..<16 {
                    let seed = Double(i)*43.7
                    let ox = (seed.truncatingRemainder(dividingBy: size.width))-size.width/2
                    let phase = (seed*0.073).truncatingRemainder(dividingBy: 1)
                    let prog = (t*0.6+phase).truncatingRemainder(dividingBy: 1)
                    let px = cx+ox*(1-prog*prog)
                    let py = prog*prog*cy*1.05
                    ctx.opacity = min(1,(1-prog)*2)
                    ctx.fill(Circle().path(in: CGRect(x: px-2, y: py-2, width: 4, height: 4)), with: .color(.red))
                }
                ctx.opacity = 1
            }
            .drawingGroup()
        }
    }
}
