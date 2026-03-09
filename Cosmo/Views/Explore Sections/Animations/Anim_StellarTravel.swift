import SwiftUI

struct StellarTravelAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let cx = size.width/2, cy = size.height/2
                for i in 0..<32 {
                    let angle = Double(i)*137.508 * .pi/180
                    let phase = (Double(i)*17.3).truncatingRemainder(dividingBy: 1)
                    let prog = (t*0.6+phase).truncatingRemainder(dividingBy: 1)
                    let maxR = max(size.width, size.height)*0.65
                    let r1 = phase*prog*maxR
                    let r2 = r1+maxR*max(0.01, prog)*0.12
                    var streak = Path()
                    streak.move(to: CGPoint(x: cx+r1*cos(angle), y: cy+r1*sin(angle)))
                    streak.addLine(to: CGPoint(x: cx+r2*cos(angle), y: cy+r2*sin(angle)))
                    ctx.opacity = min(1, prog*1.4)
                    ctx.stroke(streak, with: .color(.white), lineWidth: 0.7+prog*1.2)
                }
                ctx.opacity = 1
            }
            .drawingGroup()
        }
    }
}
