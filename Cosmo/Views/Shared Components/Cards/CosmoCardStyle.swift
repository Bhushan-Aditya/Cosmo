import SwiftUI

struct CosmoCardStyle: ViewModifier {
    var cornerRadius: CGFloat = 18
    var strokeColor: Color = Color.white.opacity(0.14)
    var fillOpacity: Double = 0.28
    var shadowOpacity: Double = 0.22

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.black.opacity(fillOpacity))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(strokeColor, lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(shadowOpacity), radius: 14, x: 0, y: 8)
    }
}

extension View {
    func cosmoCard(
        cornerRadius: CGFloat = 18,
        strokeColor: Color = Color.white.opacity(0.14),
        fillOpacity: Double = 0.28
    ) -> some View {
        modifier(
            CosmoCardStyle(
                cornerRadius: cornerRadius,
                strokeColor: strokeColor,
                fillOpacity: fillOpacity
            )
        )
    }
}

