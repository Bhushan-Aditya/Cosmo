import SwiftUI

struct SatelliteAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let cx = size.width/2, cy = size.height/2
                drawAnimStars(&ctx, size: size)
                for (r, op, col): (Double, Double, Color) in [(14,0.12,.blue),(10,1,Color(red:0.2,green:0.5,blue:0.9))] {
                    ctx.opacity = op
                    ctx.fill(Circle().path(in: CGRect(x: cx-r, y: cy-r, width: r*2, height: r*2)), with: .color(col))
                }
                ctx.opacity = 0.14
                ctx.stroke(Circle().path(in: CGRect(x: cx-36, y: cy-36, width: 72, height: 72)), with: .color(.white), lineWidth: 0.7)
                let a = t*0.6, sx = cx+36*cos(a), sy = cy+36*sin(a)*0.55
                let sp = (t*0.5).truncatingRemainder(dividingBy: 1)
                for i in 0..<3 {
                    let sr = 5+Double(i)*6+sp*18
                    let op = max(0, 0.5-sp*0.4-Double(i)*0.12)
                    ctx.opacity = op
                    var arc = Path()
                    arc.addArc(center: CGPoint(x:sx,y:sy), radius: sr, startAngle: .radians(a-0.9), endAngle: .radians(a+0.9), clockwise: false)
                    ctx.stroke(arc, with: .color(.cyan), lineWidth: 0.8)
                }
                ctx.opacity = 0.9
                ctx.fill(Path(CGRect(x: sx-3, y: sy-2, width: 6, height: 4)), with: .color(.cyan))
                ctx.fill(Path(CGRect(x: sx-10, y: sy-1, width: 20, height: 2)), with: .color(Color(red:0.3,green:0.6,blue:1)))
                ctx.opacity = 1
            }
            .drawingGroup()
        }
    }
}
