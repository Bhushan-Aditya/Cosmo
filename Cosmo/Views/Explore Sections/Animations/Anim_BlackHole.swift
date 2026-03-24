import SwiftUI

struct BlackHoleAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let cx = size.width/2, cy = size.height/2
                ctx.withCGContext { cg in
                    for i in 0..<9 {
                        let fi = Double(i)/8, r = 13+fi*26, ry = r*0.32
                        let angle = CGFloat(t*0.45+fi*1.1)
                        cg.saveGState()
                        cg.translateBy(x: cx, y: cy); cg.rotate(by: angle); cg.scaleBy(x: 1, y: ry/r)
                        let stroke = UIColor(
                            hue: max(0, 0.08 - fi * 0.04),
                            saturation: 0.9,
                            brightness: 1 - fi * 0.3,
                            alpha: 0.7 - fi * 0.06
                        )
                        cg.setStrokeColor(stroke.cgColor)
                        cg.setLineWidth(2 - fi * 0.15)
                        cg.strokeEllipse(in: CGRect(x: -r, y: -r, width: r * 2, height: r * 2))
                        cg.restoreGState()
                    }
                }
                ctx.opacity = 0.9
                ctx.stroke(Circle().path(in: CGRect(x: cx-12.5, y: cy-12.5, width: 25, height: 25)), with: .color(.white), lineWidth: 1.2)
                ctx.opacity = 1
                ctx.fill(Circle().path(in: CGRect(x: cx-11, y: cy-11, width: 22, height: 22)), with: .color(.black))
            }
            .drawingGroup()
        }
    }
}
