import SwiftUI

struct StreakBadge: View {
    let count: Int
    var color: Color = .orange

    var body: some View {
        HStack(spacing: 4) {
            Text("🔥")
                .font(.system(size: 13))
            Text("\(count)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            Text("day\(count == 1 ? "" : "s")")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(color.opacity(0.18))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.45), lineWidth: 1)
                )
        )
    }
}
