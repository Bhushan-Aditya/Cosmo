import SwiftUI

struct TidalWaveAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let moonX = size.width*0.75, moonY = size.height*0.2
                ctx.opacity = 0.18; ctx.fill(Circle().path(in: CGRect(x: moonX-18, y: moonY-18, width: 36, height: 36)), with: .color(.gray))
                ctx.opacity = 0.85; ctx.fill(Circle().path(in: CGRect(x: moonX-13, y: moonY-13, width: 26, height: 26)), with: .color(Color(white:0.82))); ctx.opacity = 1
                for i in 0..<3 {
                    let layerY = size.height*(0.52+Double(i)*0.12)
                    let shift = t*(1.2-Double(i)*0.3)+Double(i)*1.2
                    let amp = 14.0+sin(t*0.8)*5
                    var wave = Path()
                    wave.move(to: CGPoint(x: 0, y: layerY))
                    for x in stride(from: 0.0, through: Double(size.width), by: 2) {
                        wave.addLine(to: CGPoint(x: x, y: layerY+amp*sin((x/40+shift) * .pi)))
                    }
                    wave.addLine(to: CGPoint(x: size.width, y: size.height)); wave.addLine(to: CGPoint(x: 0, y: size.height)); wave.closeSubpath()
                    let lop = 0.7-Double(i)*0.2
                    ctx.opacity = lop*0.35; ctx.fill(wave, with: .color(Color(red:0.15,green:0.55,blue:0.95)))
                    ctx.opacity = lop;     ctx.stroke(wave, with: .color(Color(red:0.3,green:0.7,blue:1)), lineWidth: 1)
                }
                ctx.opacity = 1
            }
            .drawingGroup()
        }
    }
}
