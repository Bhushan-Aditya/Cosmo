import SwiftUI

struct WormholeAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let cx = size.width/2, cy = size.height/2
                drawAnimStars(&ctx, size: size)
                for side in [-1.0, 1.0] {
                    let vc = CGPoint(x: cx+side*26, y: cy)
                    for i in 0..<12 {
                        let fi = Double(i)/11, r = 20-fi*18.5, a = t*1.3*side+fi * .pi*2.5
                        let px = vc.x+r*cos(a), py = vc.y+r*sin(a)*0.55, ps = 1.6-fi*1.1
                        ctx.opacity = 0.85-fi*0.55
                        ctx.fill(Circle().path(in: CGRect(x: px-ps, y: py-ps, width: ps*2, height: ps*2)),
                                 with: .color(Color(hue:0.75+fi*0.1, saturation:0.8, brightness:0.9)))
                    }
                }
                for i in 0..<8 {
                    let fi = Double(i)/7
                    let prog = (t*0.55+fi).truncatingRemainder(dividingBy: 1)
                    let px = cx+(prog-0.5)*65, py = cy+sin(prog * .pi*2)*5, ps = 1.5
                    ctx.opacity = max(0, 0.9-abs(prog-0.5)*1.7)
                    ctx.fill(Circle().path(in: CGRect(x: px-ps, y: py-ps, width: ps*2, height: ps*2)), with: .color(.white))
                }
                ctx.opacity = 1
            }
            .drawingGroup()
        }
    }
}
