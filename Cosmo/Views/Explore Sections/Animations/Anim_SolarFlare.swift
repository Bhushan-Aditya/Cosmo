import SwiftUI

struct SolarFlareAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let cx = size.width/2, cy = size.height/2
                let sunR = 18.0
                for i in 0..<5 {
                    let fi = Double(i)
                    let baseA = fi*72 * .pi/180+t*0.25
                    let flareLen = 16+sin(t*1.5+fi)*12
                    let prog = (t*0.4+fi*0.3).truncatingRemainder(dividingBy: 1)
                    let arcR = sunR+flareLen*prog
                    var arc = Path()
                    arc.addArc(center: CGPoint(x: cx, y: cy), radius: arcR, startAngle: .radians(baseA-0.35), endAngle: .radians(baseA+0.35), clockwise: false)
                    ctx.opacity = (1-prog)*0.8
                    ctx.stroke(arc, with: .color(Color(hue:0.08+fi*0.01, saturation:0.9, brightness:1)), lineWidth: 2.5-prog*2)
                }
                for (r, op): (Double, Double) in [(sunR+8,0.12),(sunR+4,0.28),(sunR,1)] {
                    ctx.opacity = op
                    ctx.fill(Circle().path(in: CGRect(x: cx-r, y: cy-r, width: r*2, height: r*2)),
                             with: .color(r>sunR ? .yellow : Color(red:1,green:0.8,blue:0.1)))
                }
                ctx.opacity = 1
            }
            .drawingGroup()
        }
    }
}
