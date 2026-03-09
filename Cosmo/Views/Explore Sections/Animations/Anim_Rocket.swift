import SwiftUI

struct RocketAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let cycle = (t*0.35).truncatingRemainder(dividingBy: 1)
                let rY = size.height*(0.7-cycle*0.85), cx = size.width/2
                // Star streaks moving down
                for i in 0..<16 {
                    let sx = CGFloat((Double(i)*43.7).truncatingRemainder(dividingBy: size.width))
                    let phase = (Double(i)*17.3).truncatingRemainder(dividingBy: 1)
                    let sp = (t*0.55+phase).truncatingRemainder(dividingBy: 1)
                    var streak = Path()
                    streak.move(to: CGPoint(x: sx, y: sp*size.height))
                    streak.addLine(to: CGPoint(x: sx, y: sp*size.height+12))
                    ctx.opacity = 0.5-abs(sp-0.5); ctx.stroke(streak, with: .color(.white), lineWidth: 0.7)
                }
                // Flame particles
                for i in 0..<10 {
                    let fi = Double(i)/10, fp = (t*2+fi).truncatingRemainder(dividingBy: 1)
                    let fx = cx+(fi-0.5)*20, fy = rY+22+fp*28, fr = (1-fp)*5
                    ctx.opacity = (1-fp)*0.85
                    ctx.fill(Circle().path(in: CGRect(x: fx-fr, y: fy-fr, width: fr*2, height: fr*2)),
                             with: .color(Color(hue:0.05+fp*0.04, saturation:0.9, brightness:1)))
                }
                // Body
                var body = Path()
                body.move(to: CGPoint(x: cx, y: rY-22))
                body.addLine(to: CGPoint(x: cx+8, y: rY+8))
                body.addLine(to: CGPoint(x: cx-8, y: rY+8))
                body.closeSubpath()
                ctx.opacity = 1; ctx.fill(body, with: .color(Color(white:0.88)))
                // Fins
                for sign in [-1.0, 1.0] {
                    var fin = Path()
                    fin.move(to: CGPoint(x: cx+sign*8, y: rY+4))
                    fin.addLine(to: CGPoint(x: cx+sign*16, y: rY+16))
                    fin.addLine(to: CGPoint(x: cx+sign*8, y: rY+16))
                    fin.closeSubpath()
                    ctx.fill(fin, with: .color(Color(red:0.4,green:0.8,blue:0.3)))
                }
                ctx.opacity = 0.85
                ctx.fill(Circle().path(in: CGRect(x: cx-3, y: rY-8, width: 6, height: 6)), with: .color(Color(red:0.5,green:0.8,blue:1)))
                ctx.opacity = 1
            }
            .drawingGroup()
        }
    }
}

// MARK: - Default fallback
struct DefaultSpaceAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                drawAnimStars(&ctx, size: size)
                let cx = size.width/2, cy = size.height/2
                for i in 0..<5 {
                    let a = Double(i) * .pi*2/5+t*0.4, ps = 4.0
                    let pt = animOrbitPt(cx, cy, r: 26, a: a)
                    ctx.opacity = 0.7
                    ctx.fill(Circle().path(in: CGRect(x: pt.x-ps, y: pt.y-ps, width: ps*2, height: ps*2)), with: .color(.white))
                }
                ctx.opacity = 1
            }
            .drawingGroup()
        }
    }
}
