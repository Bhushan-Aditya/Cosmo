import SwiftUI

struct SpaceStationAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let cx = size.width/2, cy = size.height/2
                drawAnimStars(&ctx, size: size)
                let rotation = t*0.5, ringR = 34.0
                // Central hub
                ctx.opacity = 0.9
                ctx.fill(Circle().path(in: CGRect(x: cx-7, y: cy-7, width: 14, height: 14)), with: .color(Color(white:0.75)))
                // Spokes + nodes
                for i in 0..<6 {
                    let a = Double(i) * .pi*2/6+rotation
                    let px = cx+ringR*cos(a), py = cy+ringR*sin(a)*0.55
                    var spoke = Path(); spoke.move(to: CGPoint(x: cx, y: cy)); spoke.addLine(to: CGPoint(x: px, y: py))
                    ctx.opacity = 0.55; ctx.stroke(spoke, with: .color(Color(white:0.65)), lineWidth: 1)
                    ctx.opacity = 0.9;  ctx.fill(Circle().path(in: CGRect(x: px-3.5, y: py-3.5, width: 7, height: 7)), with: .color(Color(white:0.8)))
                }
                // Elliptic outer ring
                ctx.withCGContext { cg in
                    cg.saveGState(); cg.translateBy(x: cx, y: cy); cg.rotate(by: CGFloat(rotation)); cg.scaleBy(x: 1, y: 0.55)
                    cg.setStrokeColor(UIColor(white: 0.65, alpha: 0.7).cgColor)
                    cg.setLineWidth(2.5)
                    cg.strokeEllipse(in: CGRect(x: -ringR, y: -ringR, width: ringR * 2, height: ringR * 2))
                    cg.restoreGState()
                }
                // Solar panels
                for sign in [-1.0, 1.0] {
                    ctx.opacity = 0.8
                    ctx.fill(Path(CGRect(x: cx+sign*11, y: cy-4, width: sign*15, height: 8).standardized),
                             with: .color(Color(red:0.2,green:0.5,blue:0.9)))
                }
                ctx.opacity = 1
            }
            .drawingGroup()
        }
    }
}
