import SwiftUI

struct ConstellationAnim: View {
    private let sPos: [(CGFloat,CGFloat)] = [(0.2,0.25),(0.48,0.15),(0.76,0.3),(0.62,0.55),(0.35,0.65),(0.15,0.72),(0.82,0.7),(0.5,0.45)]
    private let lines: [(Int,Int)] = [(0,1),(1,2),(2,7),(7,3),(3,4),(4,5),(2,6),(6,3)]

    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let pts = sPos.map { CGPoint(x: $0.0*size.width, y: $0.1*size.height) }
                let cycle = t.truncatingRemainder(dividingBy: 5)/5
                for (idx, (a, b)) in lines.enumerated() {
                    let thr = Double(idx)/Double(lines.count)
                    guard cycle >= thr else { continue }
                    let lp = min(1.0, (cycle-thr)*Double(lines.count))
                    let p1 = pts[a], p2 = pts[b]
                    var path = Path()
                    path.move(to: p1)
                    path.addLine(to: CGPoint(x: p1.x+(p2.x-p1.x)*lp, y: p1.y+(p2.y-p1.y)*lp))
                    ctx.opacity = 0.55
                    ctx.stroke(path, with: .color(Color.yellow.opacity(0.65)), lineWidth: 0.8)
                }
                for (i, pt) in pts.enumerated() {
                    let tw = 0.6+0.4*sin(t*1.5+Double(i)*0.9), r = 3.0
                    ctx.opacity = tw*0.28; ctx.fill(Circle().path(in: CGRect(x: pt.x-r*2, y: pt.y-r*2, width: r*4, height: r*4)), with: .color(.yellow))
                    ctx.opacity = tw;     ctx.fill(Circle().path(in: CGRect(x: pt.x-r, y: pt.y-r, width: r*2, height: r*2)), with: .color(.white))
                }
                ctx.opacity = 1
            }
            .drawingGroup()
        }
    }
}
