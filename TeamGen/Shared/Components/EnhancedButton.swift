import SwiftUI

// MARK: - AnyShape Helper

struct AnyShape: Shape {
    private let _path: @Sendable (CGRect) -> Path

    init(_ shape: some Shape) {
        _path = { rect in
            shape.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

// MARK: - Enhanced Button Style Enums (iOS 18)

public enum ButtonStyle {
    case primary
    case secondary
    case tertiary
    case destructive
    case ghost
    case success
    case warning

    var semanticRole: ButtonRole? {
        switch self {
        case .destructive: .destructive
        default: nil
        }
    }
}

public enum ButtonSize {
    case small
    case medium
    case large
    case extraLarge

    var height: CGFloat {
        switch self {
        case .small: DesignSystem.ButtonStyles.smallHeight
        case .medium: DesignSystem.ButtonStyles.secondaryHeight
        case .large: DesignSystem.ButtonStyles.primaryHeight
        case .extraLarge: DesignSystem.ButtonStyles.extraLargeHeight
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .small: DesignSystem.IconSize.sm
        case .medium: DesignSystem.IconSize.md
        case .large: DesignSystem.IconSize.lg
        case .extraLarge: DesignSystem.IconSize.xl
        }
    }
}

public enum ButtonVariant {
    case filled
    case outlined
    case plain
    case capsule
}

// MARK: - Enhanced Button Component (iOS 18)

struct EnhancedButton: View {
    let title: String
    let systemImage: String?
    let style: ButtonStyle
    let variant: ButtonVariant
    let size: ButtonSize
    let isEnabled: Bool
    let isLoading: Bool
    let fullWidth: Bool
    let action: () async -> Void

    @Environment(\.dependencies) private var dependencies
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    @State private var isHovered = false

    init(
        _ title: String,
        systemImage: String? = nil,
        style: ButtonStyle = .primary,
        variant: ButtonVariant = .filled,
        size: ButtonSize = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        fullWidth: Bool = true,
        action: @escaping () async -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.variant = variant
        self.size = size
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.fullWidth = fullWidth
        self.action = action
    }

    var body: some View {
        Button(role: style.semanticRole) {
            Task {
                await dependencies.hapticService.impact(.medium)
                await action()
            }
        } label: {
            buttonContent
        }
        .buttonStyle(ModernButtonStyle(
            style: style,
            variant: variant,
            size: size,
            isPressed: $isPressed,
            isHovered: $isHovered,
            reduceMotion: reduceMotion
        ))
        .disabled(!isEnabled || isLoading)
        .opacity(effectiveOpacity)
        .scaleEffect(effectiveScale)
        .animation(
            DesignSystem.Animation.accessible(
                .interactiveSpring(response: 0.3, dampingFraction: 0.7),
                reduceMotion: reduceMotion
            ),
            value: isPressed
        )
        .animation(
            DesignSystem.Animation.accessible(.easeInOut(duration: 0.2), reduceMotion: reduceMotion),
            value: isHovered
        )
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityAddTraits(accessibilityTraits)
        .onHover { hovering in
            withAnimation(DesignSystem.Animation.accessible(.easeInOut(duration: 0.2), reduceMotion: reduceMotion)) {
                isHovered = hovering
            }
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) {
            // Gesture completion
        } onPressingChanged: { pressing in
            withAnimation(DesignSystem.Animation.accessible(
                .interactiveSpring(response: 0.3, dampingFraction: 0.7),
                reduceMotion: reduceMotion
            )) {
                isPressed = pressing
            }
        }
    }

    // MARK: - Button Content

    @ViewBuilder
    private var buttonContent: some View {
        HStack(spacing: iconSpacing) {
            if isLoading {
                loadingIndicator
            } else if let systemImage {
                iconView(systemImage)
            }

            if !title.isEmpty {
                textView
            }
        }
        .padding(.horizontal, horizontalPadding)
        .frame(height: size.height)
        .frame(maxWidth: fullWidth ? .infinity : nil)
    }

    @ViewBuilder
    private func iconView(_ systemImage: String) -> some View {
        Image(systemName: systemImage)
            .font(iconFont)
            .fontWeight(iconWeight)
            .foregroundStyle(iconColor)
            .symbolRenderingMode(.hierarchical)
            .contentTransition(.symbolEffect(.replace))
    }

    @ViewBuilder
    private var textView: some View {
        Text(title)
            .font(buttonFont)
            .fontWeight(textWeight)
            .foregroundStyle(textColor)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }

    @ViewBuilder
    private var loadingIndicator: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: textColor))
            .scaleEffect(loadingScale)
            .controlSize(.small)
    }

    // MARK: - Computed Properties

    private var iconSpacing: CGFloat {
        switch size {
        case .small: DesignSystem.Spacing.xxs
        case .medium: DesignSystem.Spacing.xs
        case .large: DesignSystem.Spacing.sm
        case .extraLarge: DesignSystem.Spacing.md
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .small: DesignSystem.Spacing.sm
        case .medium: DesignSystem.Spacing.md
        case .large: DesignSystem.Spacing.lg
        case .extraLarge: DesignSystem.Spacing.xl
        }
    }

    private var buttonFont: Font {
        switch size {
        case .small: DesignSystem.Typography.footnote
        case .medium: DesignSystem.Typography.callout
        case .large: DesignSystem.Typography.body
        case .extraLarge: DesignSystem.Typography.title3
        }
    }

    private var textWeight: Font.Weight {
        switch style {
        case .primary, .destructive, .success: .semibold
        case .secondary: .medium
        case .tertiary, .ghost, .warning: .medium
        }
    }

    private var iconWeight: Font.Weight {
        switch style {
        case .primary, .destructive, .success: .semibold
        case .secondary, .tertiary, .ghost, .warning: .medium
        }
    }

    private var loadingScale: CGFloat {
        switch size {
        case .small: 0.7
        case .medium: 0.8
        case .large: 0.9
        case .extraLarge: 1.0
        }
    }

    private var textColor: Color {
        switch (style, variant) {
        case (.primary, .filled): .white
        case (.primary, .outlined), (.primary, .plain), (.primary, .capsule): DesignSystem.Colors.primary
        case (.secondary, .filled): DesignSystem.Colors.primaryText
        case (.secondary, .outlined), (.secondary, .plain), (.secondary, .capsule): DesignSystem.Colors.secondaryText
        case (.tertiary, _): DesignSystem.Colors.tertiaryText
        case (.destructive, .filled): .white
        case (.destructive, .outlined), (.destructive, .plain), (.destructive, .capsule): DesignSystem.Colors.error
        case (.ghost, _): DesignSystem.Colors.primary
        case (.success, .filled): .white
        case (.success, .outlined), (.success, .plain), (.success, .capsule): DesignSystem.Colors.success
        case (.warning, .filled): .white
        case (.warning, .outlined), (.warning, .plain), (.warning, .capsule): DesignSystem.Colors.warning
        }
    }

    private var iconColor: Color {
        textColor
    }

    private var effectiveOpacity: Double {
        if !isEnabled {
            DesignSystem.VisualConsistency.opacityDisabled
        } else if isLoading {
            DesignSystem.VisualConsistency.opacityGlassmorphism
        } else {
            1.0
        }
    }

    private var effectiveScale: CGFloat {
        if isPressed, isEnabled {
            DesignSystem.VisualConsistency.scalePressed
        } else if isHovered, isEnabled {
            DesignSystem.VisualConsistency.scaleHover
        } else {
            1.0
        }
    }

    private var iconFont: Font {
        switch size {
        case .small: DesignSystem.Typography.tinyIcon
        case .medium: DesignSystem.Typography.smallIcon
        case .large: DesignSystem.Typography.mediumIcon
        case .extraLarge: DesignSystem.Typography.largeControl
        }
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        if isLoading {
            "\(title), Loading"
        } else {
            title
        }
    }

    private var accessibilityHint: String? {
        if !isEnabled {
            "Button is disabled"
        } else if isLoading {
            "Please wait while the action completes"
        } else {
            nil
        }
    }

    private var accessibilityTraits: AccessibilityTraits {
        var traits: AccessibilityTraits = [.isButton]

        if !isEnabled {
            _ = traits.insert(.isStaticText)
        }

        return traits
    }
}

// MARK: - Modern Button Style (iOS 18)

struct ModernButtonStyle: SwiftUI.ButtonStyle {
    let style: ButtonStyle
    let variant: ButtonVariant
    let size: ButtonSize
    @Binding var isPressed: Bool
    @Binding var isHovered: Bool
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(backgroundView)
            .overlay(overlayView)
            .clipShape(clipShapeForVariant())
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowOffset
            )
            .onChange(of: configuration.isPressed) { _, newValue in
                withAnimation(DesignSystem.Animation.accessible(
                    .interactiveSpring(response: 0.3, dampingFraction: 0.7),
                    reduceMotion: reduceMotion
                )) {
                    isPressed = newValue
                }
            }
    }

    // MARK: - Background View

    @ViewBuilder
    private var backgroundView: some View {
        switch (style, variant) {
        case (.primary, .filled):
            LinearGradient(
                colors: [
                    DesignSystem.Colors.primary,
                    DesignSystem.Colors.primary.opacity(DesignSystem.VisualConsistency.opacityNearlyOpaque),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case (.secondary, .filled):
            DesignSystem.Colors.cardBackground
        case (.tertiary, .filled):
            DesignSystem.Colors.tertiaryBackground
        case (.destructive, .filled):
            LinearGradient(
                colors: [
                    DesignSystem.Colors.error,
                    DesignSystem.Colors.error.opacity(DesignSystem.VisualConsistency.opacityNearlyOpaque),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case (.success, .filled):
            LinearGradient(
                colors: [
                    DesignSystem.Colors.success,
                    DesignSystem.Colors.success.opacity(DesignSystem.VisualConsistency.opacityNearlyOpaque),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case (.warning, .filled):
            LinearGradient(
                colors: [
                    DesignSystem.Colors.warning,
                    DesignSystem.Colors.warning.opacity(DesignSystem.VisualConsistency.opacityNearlyOpaque),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case (_, .outlined), (_, .plain), (_, .capsule):
            Color.clear
        case (.ghost, _):
            Color.clear
        }
    }

    // MARK: - Overlay View

    @ViewBuilder
    private var overlayView: some View {
        switch variant {
        case .outlined:
            Group {
                switch variant {
                case .capsule:
                    Capsule()
                        .stroke(strokeColor, lineWidth: strokeWidth)
                default:
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(strokeColor, lineWidth: strokeWidth)
                }
            }
        case .filled, .plain, .capsule:
            EmptyView()
        }
    }

    // MARK: - Clip Shape

    @ViewBuilder
    private func clipShapeView() -> some View {
        switch variant {
        case .capsule:
            Capsule()
        case .filled, .outlined, .plain:
            RoundedRectangle(cornerRadius: cornerRadius)
        }
    }

    private func clipShapeForVariant() -> AnyShape {
        switch variant {
        case .capsule:
            AnyShape(Capsule())
        case .filled, .outlined, .plain:
            AnyShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    // MARK: - Style Properties

    private var cornerRadius: CGFloat {
        switch size {
        case .small: DesignSystem.CornerRadius.small
        case .medium: DesignSystem.CornerRadius.button
        case .large: DesignSystem.CornerRadius.medium
        case .extraLarge: DesignSystem.CornerRadius.large
        }
    }

    private var strokeColor: Color {
        switch style {
        case .primary: DesignSystem.Colors.primary
        case .secondary: DesignSystem.Colors.separatorColor
        case .tertiary: DesignSystem.Colors.tertiaryText
        case .destructive: DesignSystem.Colors.error
        case .ghost: DesignSystem.Colors.primary.opacity(DesignSystem.VisualConsistency.opacityLoading)
        case .success: DesignSystem.Colors.success
        case .warning: DesignSystem.Colors.warning
        }
    }

    private var strokeWidth: CGFloat {
        switch style {
        case .primary, .destructive, .success, .warning: DesignSystem.VisualConsistency.borderThick
        case .secondary: DesignSystem.VisualConsistency.borderStandard
        case .tertiary, .ghost: DesignSystem.VisualConsistency.borderThin
        }
    }

    private var shadowColor: Color {
        switch (style, variant) {
        case (.primary, .filled), (.destructive, .filled), (.success, .filled), (.warning, .filled):
            Color.black.opacity(DesignSystem.VisualConsistency.opacityIconBackground)
        case (.secondary, .filled):
            Color.black.opacity(DesignSystem.VisualConsistency.opacityOverlay)
        default:
            Color.clear
        }
    }

    private var shadowRadius: CGFloat {
        switch variant {
        case .filled: isPressed ? 2 : 4
        default: 0
        }
    }

    private var shadowOffset: CGFloat {
        switch variant {
        case .filled: isPressed ? 1 : 2
        default: 0
        }
    }
}

// MARK: - Enhanced Button Factory Methods

extension EnhancedButton {
    // MARK: - Primary Buttons

    static func primary(
        _ title: String,
        systemImage: String? = nil,
        size: ButtonSize = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        fullWidth: Bool = true,
        action: @escaping () async -> Void
    ) -> EnhancedButton {
        EnhancedButton(
            title,
            systemImage: systemImage,
            style: .primary,
            variant: .filled,
            size: size,
            isEnabled: isEnabled,
            isLoading: isLoading,
            fullWidth: fullWidth,
            action: action
        )
    }

    // MARK: - Secondary Buttons

    static func secondary(
        _ title: String,
        systemImage: String? = nil,
        size: ButtonSize = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        fullWidth: Bool = true,
        action: @escaping () async -> Void
    ) -> EnhancedButton {
        EnhancedButton(
            title,
            systemImage: systemImage,
            style: .secondary,
            variant: .outlined,
            size: size,
            isEnabled: isEnabled,
            isLoading: isLoading,
            fullWidth: fullWidth,
            action: action
        )
    }

    // MARK: - Tertiary Buttons

    static func tertiary(
        _ title: String,
        systemImage: String? = nil,
        size: ButtonSize = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        fullWidth: Bool = false,
        action: @escaping () async -> Void
    ) -> EnhancedButton {
        EnhancedButton(
            title,
            systemImage: systemImage,
            style: .tertiary,
            variant: .plain,
            size: size,
            isEnabled: isEnabled,
            isLoading: isLoading,
            fullWidth: fullWidth,
            action: action
        )
    }

    // MARK: - Destructive Buttons

    static func destructive(
        _ title: String,
        systemImage: String? = nil,
        size: ButtonSize = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        fullWidth: Bool = true,
        action: @escaping () async -> Void
    ) -> EnhancedButton {
        EnhancedButton(
            title,
            systemImage: systemImage,
            style: .destructive,
            variant: .filled,
            size: size,
            isEnabled: isEnabled,
            isLoading: isLoading,
            fullWidth: fullWidth,
            action: action
        )
    }

    // MARK: - Success Buttons

    static func success(
        _ title: String,
        systemImage: String? = nil,
        size: ButtonSize = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        fullWidth: Bool = true,
        action: @escaping () async -> Void
    ) -> EnhancedButton {
        EnhancedButton(
            title,
            systemImage: systemImage,
            style: .success,
            variant: .filled,
            size: size,
            isEnabled: isEnabled,
            isLoading: isLoading,
            fullWidth: fullWidth,
            action: action
        )
    }

    // MARK: - Warning Buttons

    static func warning(
        _ title: String,
        systemImage: String? = nil,
        size: ButtonSize = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        fullWidth: Bool = true,
        action: @escaping () async -> Void
    ) -> EnhancedButton {
        EnhancedButton(
            title,
            systemImage: systemImage,
            style: .warning,
            variant: .filled,
            size: size,
            isEnabled: isEnabled,
            isLoading: isLoading,
            fullWidth: fullWidth,
            action: action
        )
    }

    // MARK: - Ghost Buttons

    static func ghost(
        _ title: String,
        systemImage: String? = nil,
        size: ButtonSize = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        fullWidth: Bool = false,
        action: @escaping () async -> Void
    ) -> EnhancedButton {
        EnhancedButton(
            title,
            systemImage: systemImage,
            style: .ghost,
            variant: .plain,
            size: size,
            isEnabled: isEnabled,
            isLoading: isLoading,
            fullWidth: fullWidth,
            action: action
        )
    }

    // MARK: - Capsule Buttons

    static func capsule(
        _ title: String,
        systemImage: String? = nil,
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        fullWidth: Bool = false,
        action: @escaping () async -> Void
    ) -> EnhancedButton {
        EnhancedButton(
            title,
            systemImage: systemImage,
            style: style,
            variant: .capsule,
            size: size,
            isEnabled: isEnabled,
            isLoading: isLoading,
            fullWidth: fullWidth,
            action: action
        )
    }
}

// MARK: - Preview

#if DEBUG
    struct EnhancedButton_Previews: PreviewProvider {
        static var previews: some View {
            VStack(spacing: DesignSystem.Spacing.md) {
                // Primary buttons
                EnhancedButton.primary("Primary Button", systemImage: "star.fill") {}

                // Secondary buttons
                EnhancedButton.secondary("Secondary Button", systemImage: "heart") {}

                // Tertiary buttons
                EnhancedButton.tertiary("Tertiary Button", systemImage: "info.circle") {}

                // Destructive buttons
                EnhancedButton.destructive("Delete", systemImage: "trash") {}

                // Success buttons
                EnhancedButton.success("Save", systemImage: "checkmark") {}

                // Warning buttons
                EnhancedButton.warning("Warning", systemImage: "exclamationmark.triangle") {}

                // Ghost buttons
                EnhancedButton.ghost("Ghost Button", systemImage: "eye") {}

                // Capsule buttons
                EnhancedButton.capsule("Capsule", systemImage: "plus") {}

                // Loading state
                EnhancedButton.primary("Loading", isLoading: true) {}

                // Disabled state
                EnhancedButton.primary("Disabled", isEnabled: false) {}
            }
            .padding()
        }
    }
#endif
