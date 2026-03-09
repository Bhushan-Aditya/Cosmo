import SwiftUI

struct HyperloopAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let cy = size.height/2, tubeH = 14.0
                ctx.opacity = 0.3;  ctx.fill(Path(CGRect(x: 0, y: cy-tubeH, width: size.width, height: tubeH*2)), with: .color(Color(white:0.15)))
                ctx.opacity = 0.55; ctx.stroke(Path(CGRect(x: 0, y: cy-tubeH, width: size.width, height: tubeH*2)), with: .color(Color(white:0.35)), lineWidth: 1)
                let prog = (t*0.5).truncatingRemainder(dividingBy: 1)
                let podW = 36.0, podH = 10.0
                let podX = -podW+Double(size.width+podW)*prog
                let visibility = min(1.0, min(prog*5, (1-prog)*5))
                for j in 0..<8 {
                    ctx.opacity = (0.5-Double(j)*0.06)*visibility
                    ctx.fill(Path(CGRect(x: podX-Double(j)*8, y: cy-podH/2, width: podW, height: podH)),
                             with: .color(Color(red:0.9,green:0.3,blue:0.8)))
                }
                ctx.opacity = visibility
                ctx.fill(Path(roundedRect: CGRect(x: podX, y: cy-podH/2, width: podW, height: podH), cornerRadius: 5),
                         with: .color(Color(red:1,green:0.4,blue:0.9)))
                ctx.opacity = 1
            }
            .drawingGroup()
        }
    }
}
