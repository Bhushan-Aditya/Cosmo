import SwiftUI

struct TelescopeAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                drawAnimStars(&ctx, size: size)
                let cx = size.width/2, cy = size.height*0.58
                let dishW = 46.0, dishH = 22.0
                var dish = Path()
                dish.move(to: CGPoint(x: cx-dishW/2, y: cy-dishH))
                dish.addQuadCurve(to: CGPoint(x: cx+dishW/2, y: cy-dishH), control: CGPoint(x: cx, y: cy+dishH))
                dish.closeSubpath()
                ctx.opacity = 0.18; ctx.fill(dish, with: .color(.blue))
                ctx.opacity = 0.7;  ctx.stroke(dish, with: .color(Color(red:0.4,green:0.7,blue:1)), lineWidth: 1.5)
                var stand = Path()
                stand.move(to: CGPoint(x: cx, y: cy-2)); stand.addLine(to: CGPoint(x: cx, y: cy+20))
                ctx.opacity = 0.6; ctx.stroke(stand, with: .color(Color(white:0.6)), lineWidth: 2)
                let sigProg = (t*0.4).truncatingRemainder(dividingBy: 1)
                for i in 0..<4 {
                    let sp = (sigProg+Double(i)/3).truncatingRemainder(dividingBy: 1)
                    ctx.opacity = max(0, 0.6-sp*0.55)
                    var arc = Path()
                    arc.addArc(center: CGPoint(x: cx, y: cy-dishH), radius: 10+sp*50,
                               startAngle: .radians(-.pi*0.7), endAngle: .radians(-.pi*0.3), clockwise: false)
                    ctx.stroke(arc, with: .color(Color(red:0.3,green:0.7,blue:1)), lineWidth: 1.2)
                }
                ctx.opacity = 1
            }
            .drawingGroup()
        }
    }
}
