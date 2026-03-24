import SwiftUI

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
}

// MARK: - Overlay View

struct ToastOverlayView: View {
    @ObservedObject var manager: ToastManager

    var body: some View {
        VStack {
            if let toast = manager.current {
                HStack(spacing: 10) {
                    Image(systemName: toast.style.icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(toast.style.tint)

                    Text(toast.message)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)

                    Button {
                        manager.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(toast.style.tint.opacity(0.4), lineWidth: 1)
                        )
                )
                .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 4)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onTapGesture { manager.dismiss() }
            }
            Spacer()
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: manager.current?.id)
    }
}
