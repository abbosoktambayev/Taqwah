import SwiftUI

struct ScreenshotShareBanner: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let onDismiss: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 38, height: 38)
                .background(
                    Circle()
                        .fill(iconColor.opacity(scheme == .light ? 0.10 : 0.12))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(textColor)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(textColor.opacity(0.68))
            }

            Spacer(minLength: 10)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundColor(textColor.opacity(0.62))
                    .frame(width: 32, height: 32)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss")
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: 88)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(scheme == .light ? 0.08 : 0.16),
            radius: 14,
            y: 8
        )
        .gesture(
            DragGesture(minimumDistance: 12)
                .onEnded { value in
                    guard value.translation.height < -18 else { return }
                    onDismiss()
                }
        )
    }

    @ViewBuilder
    private var cardBackground: some View {
        if scheme == .dark {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.goldFill.opacity(0.88))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.softIvory)
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.goldDim)
            }
        }
    }

    private var textColor: Color {
        scheme == .dark ? .onGold : .ink
    }

    private var iconColor: Color {
        scheme == .dark ? .onGold : .prayerAccent
    }

    private var borderColor: Color {
        scheme == .dark ? Color.onGold.opacity(0.08) : Color.gold.opacity(0.18)
    }
}

#Preview("Dark") {
    ZStack(alignment: .top) {
        AppBackground()
        ScreenshotShareBanner(
            title: "Sharing Taqwah?",
            subtitle: "Tag @abbos.dev",
            onDismiss: {}
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
    .preferredColorScheme(.dark)
}

#Preview("Light") {
    ZStack(alignment: .top) {
        AppBackground()
        ScreenshotShareBanner(
            title: "Sharing Taqwah?",
            subtitle: "Tag @abbos.dev",
            onDismiss: {}
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
    .preferredColorScheme(.light)
}
