import SwiftUI

struct GravTimeAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let cx = size.width/2, cy = size.height/2
                let massR = 11.0+sin(t*1.5)*1.5
                for row in 0...5 {
                    for col in 0...6 {
                        let fx = CGFloat(col)/6*size.width
                        let fy = CGFloat(row)/5*size.height
                        let dx = Double(fx-cx), dy = Double(fy-cy)
                        let dist = sqrt(dx*dx+dy*dy)
                        let strength = 550.0/max(1.0, dist)*(5.0+sin(t)*2.0)
                        let pull = min(22.0, strength)
                        let angle = atan2(dy, dx)
                        let wx = Double(fx)-pull*cos(angle)
                        let wy = Double(fy)-pull*sin(angle)
                        let r = 1.8
                        ctx.opacity = 0.38
                        ctx.fill(Circle().path(in: CGRect(x: wx-r, y: wy-r, width: r*2, height: r*2)), with: .color(.purple))
                    }
                }
                for (r, op): (Double, Double) in [(massR+5,0.07),(massR+2,0.22),(massR,1)] {
                    ctx.opacity = op
                    ctx.fill(Circle().path(in: CGRect(x: cx-r, y: cy-r, width: r*2, height: r*2)), with: .color(op<0.5 ? .purple : .black))
                }
                ctx.opacity = 0.7
                ctx.stroke(Circle().path(in: CGRect(x: cx-massR, y: cy-massR, width: massR*2, height: massR*2)),
                           with: .color(Color.purple.opacity(0.8)), lineWidth: 1.4)
                ctx.opacity = 1
            }
            .drawingGroup()
        }
    }
}
