import SwiftUI

// MARK: - Enhanced Card Style Enums (iOS 18)
public enum CardStyle {
    case `default`
    case compact
    case prominent
    case elevated
    case glassmorphism

    var padding: CGFloat {
        switch self {
        case .default: return DesignSystem.Spacing.md
        case .compact: return DesignSystem.Spacing.sm
        case .prominent: return DesignSystem.Spacing.lg
        case .elevated: return DesignSystem.Spacing.md
        case .glassmorphism: return DesignSystem.Spacing.lg
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .default, .elevated: return DesignSystem.CornerRadius.medium
        case .compact: return DesignSystem.CornerRadius.small
        case .prominent: return DesignSystem.CornerRadius.large
        case .glassmorphism: return DesignSystem.CornerRadius.extraLarge
        }
    }
}

public enum CardElevation {
    case none
    case subtle
    case low
    case medium
    case high
    case floating

    var shadowRadius: CGFloat {
        switch self {
        case .none: return 0
        case .subtle: return 1
        case .low: return 2
        case .medium: return 4
        case .high: return 8
        case .floating: return 16
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .none: return 0
        case .subtle: return 0.03
        case .low: return 0.05
        case .medium: return 0.1
        case .high: return 0.15
        case .floating: return 0.2
        }
    }

    var shadowOffset: CGSize {
        switch self {
        case .none: return .zero
        case .subtle: return CGSize(width: 0, height: 0.5)
        case .low: return CGSize(width: 0, height: 1)
        case .medium: return CGSize(width: 0, height: 2)
        case .high: return CGSize(width: 0, height: 4)
        case .floating: return CGSize(width: 0, height: 8)
        }
    }
}

public enum CardVariant {
    case filled
    case outlined
    case plain
    case gradient
    case glassmorphism
}

// MARK: - Enhanced Card Component (iOS 18)
struct EnhancedCard<Content: View>: View {
    let content: Content
    let style: CardStyle
    let variant: CardVariant
    let elevation: CardElevation
    let isInteractive: Bool
    let isSelected: Bool
    let onTap: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var isHovered = false
    @State private var isPressed = false

    init(
        style: CardStyle = .default,
        variant: CardVariant = .filled,
        elevation: CardElevation = .low,
        isInteractive: Bool = false,
        isSelected: Bool = false,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.style = style
        self.variant = variant
        self.elevation = elevation
        self.isInteractive = isInteractive
        self.isSelected = isSelected
        self.onTap = onTap
    }

    var body: some View {
        Group {
            if isInteractive, let onTap = onTap {
                Button(action: onTap) {
                    cardContent
                }
                .buttonStyle(InteractiveCardButtonStyle(
                    isHovered: $isHovered,
                    isPressed: $isPressed,
                    reduceMotion: reduceMotion
                ))
            } else {
                cardContent
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onTap?()
                    }
            }
        }
        .scaleEffect(effectiveScale)
        .animation(
            DesignSystem.Animation.accessible(.interactiveSpring(response: 0.3, dampingFraction: 0.7), reduceMotion: reduceMotion),
            value: isPressed
        )
        .animation(
            DesignSystem.Animation.accessible(.easeInOut(duration: 0.2), reduceMotion: reduceMotion),
            value: isHovered
        )
        .animation(
            DesignSystem.Animation.accessible(.easeInOut(duration: 0.3), reduceMotion: reduceMotion),
            value: isSelected
        )
        .onHover { hovering in
            if isInteractive {
                withAnimation(DesignSystem.Animation.accessible(.easeInOut(duration: 0.2), reduceMotion: reduceMotion)) {
                    isHovered = hovering
                }
            }
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) {
            // Gesture completion
        } onPressingChanged: { pressing in
            if isInteractive {
                withAnimation(DesignSystem.Animation.accessible(.interactiveSpring(response: 0.3, dampingFraction: 0.7), reduceMotion: reduceMotion)) {
                    isPressed = pressing
                }
            }
        }
    }

    // MARK: - Card Content
    @ViewBuilder
    private var cardContent: some View {
        content
            .padding(style.padding)
            .background(backgroundView)
            .overlay(overlayView)
            .clipShape(clipShape)
            .shadow(
                color: shadowColor,
                radius: effectiveShadowRadius,
                x: shadowOffset.width,
                y: shadowOffset.height
            )
    }

    // MARK: - Background View
    @ViewBuilder
    private var backgroundView: some View {
        switch (style, variant) {
        case (.glassmorphism, _):
            ZStack {
                // Glassmorphism background
                DesignSystem.Colors.glassMorphismBackground
                    .background(.ultraThinMaterial)

                // Subtle gradient overlay
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.1),
                        Color.white.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        case (_, .gradient):
            LinearGradient(
                colors: [
                    backgroundColor,
                    backgroundColor.opacity(0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case (_, .filled):
            backgroundColor
        case (_, .outlined), (_, .plain), (_, .glassmorphism):
            Color.clear
        }
    }

    // MARK: - Overlay View
    @ViewBuilder
    private var overlayView: some View {
        Group {
            switch variant {
            case .outlined:
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(strokeColor, lineWidth: strokeWidth)
            case .glassmorphism:
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.VisualConsistency.borderThin
                    )
            case .filled, .plain, .gradient:
                EmptyView()
            }

            // Selection indicator
            if isSelected {
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(
                        DesignSystem.Colors.primary,
                        lineWidth: DesignSystem.VisualConsistency.borderThick
                    )
            }
        }
    }

    // MARK: - Clip Shape
    @ViewBuilder
    private var clipShape: some Shape {
        RoundedRectangle(cornerRadius: style.cornerRadius)
    }

    // MARK: - Computed Properties

    private var backgroundColor: Color {
        switch style {
        case .default, .compact: return DesignSystem.Colors.cardBackground
        case .prominent: return DesignSystem.Colors.elevatedCardBackground
        case .elevated: return DesignSystem.Colors.secondaryBackground
        case .glassmorphism: return Color.clear
        }
    }

    private var strokeColor: Color {
        if isSelected {
            return DesignSystem.Colors.primary
        } else if isHovered && isInteractive {
            return DesignSystem.Colors.primary.opacity(0.3)
        } else {
            return DesignSystem.Colors.separatorColor.opacity(0.5)
        }
    }

    private var strokeWidth: CGFloat {
        if isSelected {
            return DesignSystem.VisualConsistency.borderThick
        } else {
            return DesignSystem.VisualConsistency.borderThin
        }
    }

    private var shadowColor: Color {
        switch elevation {
        case .none: return Color.clear
        case .subtle: return DesignSystem.Shadow.subtle
        case .low: return DesignSystem.Shadow.small
        case .medium: return DesignSystem.Shadow.medium
        case .high: return DesignSystem.Shadow.large
        case .floating: return DesignSystem.Shadow.extraLarge
        }
    }

    private var shadowOffset: CGSize {
        elevation.shadowOffset
    }

    private var effectiveShadowRadius: CGFloat {
        let baseRadius = elevation.shadowRadius

        if isPressed && isInteractive {
            return baseRadius * 0.5
        } else if isHovered && isInteractive {
            return baseRadius * 1.5
        } else if isSelected {
            return baseRadius * 1.2
        } else {
            return baseRadius
        }
    }

    private var effectiveScale: CGFloat {
        if isPressed && isInteractive {
            return DesignSystem.VisualConsistency.scalePressed
        } else if isHovered && isInteractive {
            return DesignSystem.VisualConsistency.scaleHover
        } else if isSelected {
            return DesignSystem.VisualConsistency.scaleSelected
        } else {
            return 1.0
        }
    }
}

// MARK: - Interactive Card Button Style (iOS 18)
struct InteractiveCardButtonStyle: SwiftUI.ButtonStyle {
    @Binding var isHovered: Bool
    @Binding var isPressed: Bool
    let reduceMotion: Bool

    func makeBody(configuration: SwiftUI.ButtonStyle.Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                withAnimation(DesignSystem.Animation.accessible(.interactiveSpring(response: 0.3, dampingFraction: 0.7), reduceMotion: reduceMotion)) {
                    isPressed = newValue
                }
            }
    }
}

// MARK: - Enhanced Card Factory Methods
extension EnhancedCard {
    // MARK: - Default Cards
    static func `default`<CardContent: View>(
        elevation: CardElevation = .low,
        isInteractive: Bool = false,
        isSelected: Bool = false,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> CardContent
    ) -> EnhancedCard<CardContent> {
        EnhancedCard<CardContent>(
            style: .default,
            variant: .filled,
            elevation: elevation,
            isInteractive: isInteractive,
            isSelected: isSelected,
            onTap: onTap,
            content: content
        )
    }

    // MARK: - Compact Cards
    static func compact<CardContent: View>(
        elevation: CardElevation = .subtle,
        isInteractive: Bool = false,
        isSelected: Bool = false,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> CardContent
    ) -> EnhancedCard<CardContent> {
        EnhancedCard<CardContent>(
            style: .compact,
            variant: .filled,
            elevation: elevation,
            isInteractive: isInteractive,
            isSelected: isSelected,
            onTap: onTap,
            content: content
        )
    }

    // MARK: - Prominent Cards
    static func prominent<CardContent: View>(
        elevation: CardElevation = .medium,
        isInteractive: Bool = false,
        isSelected: Bool = false,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> CardContent
    ) -> EnhancedCard<CardContent> {
        EnhancedCard<CardContent>(
            style: .prominent,
            variant: .gradient,
            elevation: elevation,
            isInteractive: isInteractive,
            isSelected: isSelected,
            onTap: onTap,
            content: content
        )
    }

    // MARK: - Elevated Cards
    static func elevated<CardContent: View>(
        elevation: CardElevation = .high,
        isInteractive: Bool = false,
        isSelected: Bool = false,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> CardContent
    ) -> EnhancedCard<CardContent> {
        EnhancedCard<CardContent>(
            style: .elevated,
            variant: .filled,
            elevation: elevation,
            isInteractive: isInteractive,
            isSelected: isSelected,
            onTap: onTap,
            content: content
        )
    }

    // MARK: - Glassmorphism Cards
    static func glassmorphism<CardContent: View>(
        elevation: CardElevation = .floating,
        isInteractive: Bool = false,
        isSelected: Bool = false,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> CardContent
    ) -> EnhancedCard<CardContent> {
        EnhancedCard<CardContent>(
            style: .glassmorphism,
            variant: .glassmorphism,
            elevation: elevation,
            isInteractive: isInteractive,
            isSelected: isSelected,
            onTap: onTap,
            content: content
        )
    }

    // MARK: - Outlined Cards
    static func outlined<CardContent: View>(
        style: CardStyle = .default,
        elevation: CardElevation = .none,
        isInteractive: Bool = false,
        isSelected: Bool = false,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> CardContent
    ) -> EnhancedCard<CardContent> {
        EnhancedCard<CardContent>(
            style: style,
            variant: .outlined,
            elevation: elevation,
            isInteractive: isInteractive,
            isSelected: isSelected,
            onTap: onTap,
            content: content
        )
    }

    // MARK: - Plain Cards
    static func plain<CardContent: View>(
        style: CardStyle = .default,
        isInteractive: Bool = false,
        isSelected: Bool = false,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> CardContent
    ) -> EnhancedCard<CardContent> {
        EnhancedCard<CardContent>(
            style: style,
            variant: .plain,
            elevation: .none,
            isInteractive: isInteractive,
            isSelected: isSelected,
            onTap: onTap,
            content: content
        )
    }

    // MARK: - Interactive Cards
    static func interactive<CardContent: View>(
        style: CardStyle = .default,
        elevation: CardElevation = .low,
        isSelected: Bool = false,
        onTap: @escaping () -> Void,
        @ViewBuilder content: () -> CardContent
    ) -> EnhancedCard<CardContent> {
        EnhancedCard<CardContent>(
            style: style,
            variant: .filled,
            elevation: elevation,
            isInteractive: true,
            isSelected: isSelected,
            onTap: onTap,
            content: content
        )
    }
}

// MARK: - Card Content Modifiers
extension View {
    /// Applies card styling to any view
    func cardStyle(
        _ style: CardStyle = .default,
        variant: CardVariant = .filled,
        elevation: CardElevation = .low,
        isInteractive: Bool = false,
        isSelected: Bool = false,
        onTap: (() -> Void)? = nil
    ) -> some View {
        EnhancedCard(
            style: style,
            variant: variant,
            elevation: elevation,
            isInteractive: isInteractive,
            isSelected: isSelected,
            onTap: onTap
        ) {
            self
        }
    }

    /// Applies interactive card styling with tap gesture
    func interactiveCard(
        style: CardStyle = .default,
        elevation: CardElevation = .low,
        isSelected: Bool = false,
        onTap: @escaping () -> Void
    ) -> some View {
        EnhancedCard<Self>.interactive(
            style: style,
            elevation: elevation,
            isSelected: isSelected,
            onTap: onTap
        ) {
            self
        }
    }

    /// Applies glassmorphism card styling
    func glassmorphismCard(
        elevation: CardElevation = .floating,
        isInteractive: Bool = false,
        isSelected: Bool = false,
        onTap: (() -> Void)? = nil
    ) -> some View {
        EnhancedCard<Self>.glassmorphism(
            elevation: elevation,
            isInteractive: isInteractive,
            isSelected: isSelected,
            onTap: onTap
        ) {
            self
        }
    }
}

// MARK: - Preview
#if DEBUG
struct EnhancedCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Using view modifiers instead of factory methods to avoid generic inference issues
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Default Card")
                        .font(DesignSystem.Typography.headline)
                    Text("This is a default card with standard styling and low elevation.")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                .cardStyle(.default, variant: .filled, elevation: .low)

                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(DesignSystem.Colors.warning)
                    Text("Compact Card")
                        .font(DesignSystem.Typography.subheadline)
                    Spacer()
                }
                .cardStyle(.compact, variant: .filled, elevation: .subtle)

                VStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 32))
                        .foregroundColor(DesignSystem.Colors.accent)
                    Text("Prominent Card")
                        .font(DesignSystem.Typography.title3)
                        .fontWeight(.semibold)
                    Text("Enhanced with gradient background and high elevation")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .cardStyle(.prominent, variant: .gradient, elevation: .high)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Interactive Card")
                            .font(DesignSystem.Typography.headline)
                        Text("Tap me!")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(DesignSystem.Colors.tertiaryText)
                }
                .interactiveCard(onTap: {})

                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("Glassmorphism Card")
                        .font(DesignSystem.Typography.headline)
                    Text("Modern glass effect with blur and transparency")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                .glassmorphismCard()
                .background(
                    LinearGradient(
                        colors: [DesignSystem.Colors.primary.opacity(0.3), DesignSystem.Colors.accent.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                Text("Outlined Card")
                    .font(DesignSystem.Typography.body)
                    .cardStyle(.default, variant: .outlined, elevation: .none)

                Text("Selected Card")
                    .font(DesignSystem.Typography.body)
                    .cardStyle(.default, variant: .filled, elevation: .low, isSelected: true)
            }
            .padding()
        }
    }
}
#endif