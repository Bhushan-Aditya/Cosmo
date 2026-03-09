import SwiftUI

// MARK: - Shared Animation Helpers
// These are module-internal so each individual animation file can access them.

let sectionAnimStars: [(CGFloat, CGFloat, CGFloat)] = {
    var s: UInt64 = 0x9e37_79b9_7f4a_7c15
    return (0..<14).map { _ in
        s = s &* 6364136223846793005 &+ 1442695040888963407
        let x = CGFloat(s >> 33) / CGFloat(1 << 31)
        s = s &* 6364136223846793005 &+ 1442695040888963407
        let y = CGFloat(s >> 33) / CGFloat(1 << 31)
        s = s &* 6364136223846793005 &+ 1442695040888963407
        let r = CGFloat(s >> 33) / CGFloat(1 << 31) * 0.9 + 0.4
        return (x, y, r)
    }
}()

func drawAnimStars(_ ctx: inout GraphicsContext, size: CGSize) {
    for (fx, fy, r) in sectionAnimStars {
        ctx.opacity = 0.45
        ctx.fill(
            Circle().path(in: CGRect(x: fx*size.width-r, y: fy*size.height-r, width: r*2, height: r*2)),
            with: .color(.white)
        )
    }
    ctx.opacity = 1
}

func animOrbitPt(_ cx: CGFloat, _ cy: CGFloat, r: Double, a: Double, ry: Double = 1.0) -> CGPoint {
    CGPoint(x: cx + r * cos(a), y: cy + r * sin(a) * ry)
}

// 30fps schedule for card animations — smooth but lightweight
let cardAnimSchedule = Animation.easeInOut(duration: 0).repeatForever()
