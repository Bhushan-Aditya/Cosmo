import SwiftUI
import UIKit

// MARK: - Model

enum ToastStyle {
    case success, error, info

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error:   return "exclamationmark.triangle.fill"
        case .info:    return "info.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .success: return Color.green
        case .error:   return Color.red.opacity(0.9)
        case .info:    return Color.white.opacity(0.75)
        }
    }
}

struct Toast: Identifiable {
    let id = UUID()
    let message: String
    let style: ToastStyle
}

// MARK: - Manager

@MainActor
final class ToastManager: ObservableObject {
    static let shared = ToastManager()

    @Published private(set) var current: Toast?
    private var dismissTask: Task<Void, Never>?

    private init() {}

    func show(_ message: String, style: ToastStyle = .info) {
        dismissTask?.cancel()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            current = Toast(message: message, style: style)
        }
        playHaptic(for: style)
        dismissTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                current = nil
            }
        }
    }

    func dismiss() {
        dismissTask?.cancel()
        withAnimation(.easeOut(duration: 0.25)) {
            current = nil
        }
    }

    private func playHaptic(for style: ToastStyle) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        switch style {
        case .success:
            generator.notificationOccurred(.success)
        case .error:
            generator.notificationOccurred(.error)
        case .info:
            generator.notificationOccurred(.warning)
        }
    }
}

// MARK: - Overlay View

struct ToastOverlayView: View {
    @ObservedObject var manager: ToastManager

    var body: some View {
        GeometryReader { proxy in
            VStack {
                if let toast = manager.current {
                    HStack(spacing: 10) {
                        Image(systemName: toast.style.icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(toast.style.tint)
                            .frame(width: 22, height: 22)
                            .background(Color.white.opacity(0.14))
                            .clipShape(Circle())

                        Text(toast.message)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.regularMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 0.8)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.22), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    .padding(.top, max(proxy.safeAreaInsets.top + 12, 30))
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .opacity
                    ))
                    .onTapGesture { manager.dismiss() }
                }
                Spacer()
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: manager.current?.id)
    }
}
