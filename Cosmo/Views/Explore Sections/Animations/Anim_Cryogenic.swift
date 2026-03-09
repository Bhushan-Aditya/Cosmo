import SwiftUI

struct CryogenicAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let cx = size.width/2, cy = size.height/2
                let rot = t*0.3
                let iceCol = Color(red:0.7, green:0.9, blue:1)
                for arm in 0..<6 {
                    let baseAngle = Double(arm) * .pi/3+rot
                    var armLine = Path()
                    armLine.move(to: CGPoint(x: cx, y: cy))
                    armLine.addLine(to: CGPoint(x: cx+30*cos(baseAngle), y: cy+30*sin(baseAngle)))
                    ctx.opacity = 0.6; ctx.stroke(armLine, with: .color(iceCol), lineWidth: 1.0)
                    for seg in 1...4 {
                        let f = Double(seg)/5, r = f*30
                        let ax = cx+r*cos(baseAngle), ay = cy+r*sin(baseAngle)
                        ctx.opacity = 0.8-f*0.3
                        ctx.fill(Circle().path(in: CGRect(x: ax-1.2, y: ay-1.2, width: 2.4, height: 2.4)), with: .color(iceCol))
                        let bLen = (1-f)*11
                        for sign in [-1.0, 1.0] {
                            var branch = Path()
                            branch.move(to: CGPoint(x: ax, y: ay))
                            branch.addLine(to: CGPoint(x: ax+bLen*cos(baseAngle+sign * .pi/3), y: ay+bLen*sin(baseAngle+sign * .pi/3)))
                            ctx.opacity = 0.5; ctx.stroke(branch, with: .color(iceCol), lineWidth: 0.8)
                        }
                    }
                }
                for i in 0..<8 {
                    let px = CGFloat((Double(i)*51.3).truncatingRemainder(dividingBy: size.width))
                    let py = CGFloat((Double(i)*31.7).truncatingRemainder(dividingBy: size.height))
                    let tw = sin(t*2+Double(i))*0.5+0.5
                    ctx.opacity = tw*0.35
                    ctx.fill(Circle().path(in: CGRect(x: px-1.2, y: py-1.2, width: 2.4, height: 2.4)), with: .color(.cyan))
                }
                ctx.opacity = 1
            }
            .drawingGroup()
        }
    }
}
