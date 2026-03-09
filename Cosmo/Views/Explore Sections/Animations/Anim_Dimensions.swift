import SwiftUI

struct DimensionsAnim: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let cx = size.width/2, cy = size.height/2
                drawAnimStars(&ctx, size: size)
                let ry = Float(t*0.5), rx = Float(t*0.32)
                let verts: [SIMD3<Float>] = [[-1,-1,-1],[1,-1,-1],[1,1,-1],[-1,1,-1],[-1,-1,1],[1,-1,1],[1,1,1],[-1,1,1]]
                let edges = [(0,1),(1,2),(2,3),(3,0),(4,5),(5,6),(6,7),(7,4),(0,4),(1,5),(2,6),(3,7)]
                func proj(_ p: SIMD3<Float>) -> CGPoint {
                    let x1 = p.x*cos(ry)+p.z*sin(ry)
                    let z1 = -p.x*sin(ry)+p.z*cos(ry)
                    let y2 = p.y*cos(rx)-z1*sin(rx)
                    let z2 = p.y*sin(rx)+z1*cos(rx)
                    let s: Float = 1/(z2+4.2)
                    return CGPoint(x: cx+CGFloat(x1*s*72), y: cy+CGFloat(y2*s*72))
                }
                for (a, b) in edges {
                    var path = Path()
                    path.move(to: proj(verts[a])); path.addLine(to: proj(verts[b]))
                    ctx.opacity = 0.75; ctx.stroke(path, with: .color(.mint), lineWidth: 1.2)
                }
                for v in verts {
                    let pt = proj(v); ctx.opacity = 0.9
                    ctx.fill(Circle().path(in: CGRect(x: pt.x-2, y: pt.y-2, width: 4, height: 4)), with: .color(.white))
                }
                ctx.opacity = 1
            }
            .drawingGroup()
        }
    }
}
