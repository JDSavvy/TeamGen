import SwiftUI

// MARK: - AnyShape Helper
struct AnyShape: Shape {
    private let _path: @Sendable (CGRect) -> Path
    
    init<S: Shape>(_ shape: S) {
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
        case .destructive: return .destructive
        default: return nil
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
        case .small: return DesignSystem.ButtonStyles.smallHeight
        case .medium: return DesignSystem.ButtonStyles.secondaryHeight
        case .large: return DesignSystem.ButtonStyles.primaryHeight
        case .extraLarge: return DesignSystem.ButtonStyles.extraLargeHeight
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .small: return DesignSystem.IconSize.sm
        case .medium: return DesignSystem.IconSize.md
        case .large: return DesignSystem.IconSize.lg
        case .extraLarge: return DesignSystem.IconSize.xl
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
            DesignSystem.Animation.accessible(.interactiveSpring(response: 0.3, dampingFraction: 0.7), reduceMotion: reduceMotion),
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
            withAnimation(DesignSystem.Animation.accessible(.interactiveSpring(response: 0.3, dampingFraction: 0.7), reduceMotion: reduceMotion)) {
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
            } else if let systemImage = systemImage {
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
        case .small: return DesignSystem.Spacing.xxs
        case .medium: return DesignSystem.Spacing.xs
        case .large: return DesignSystem.Spacing.sm
        case .extraLarge: return DesignSystem.Spacing.md
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .small: return DesignSystem.Spacing.sm
        case .medium: return DesignSystem.Spacing.md
        case .large: return DesignSystem.Spacing.lg
        case .extraLarge: return DesignSystem.Spacing.xl
        }
    }
    
    private var buttonFont: Font {
        switch size {
        case .small: return DesignSystem.Typography.footnote
        case .medium: return DesignSystem.Typography.callout
        case .large: return DesignSystem.Typography.body
        case .extraLarge: return DesignSystem.Typography.title3
        }
    }
    
    private var textWeight: Font.Weight {
        switch style {
        case .primary, .destructive, .success: return .semibold
        case .secondary: return .medium
        case .tertiary, .ghost, .warning: return .medium
        }
    }
    
    private var iconWeight: Font.Weight {
        switch style {
        case .primary, .destructive, .success: return .semibold
        case .secondary, .tertiary, .ghost, .warning: return .medium
        }
    }
    
    private var loadingScale: CGFloat {
        switch size {
        case .small: return 0.7
        case .medium: return 0.8
        case .large: return 0.9
        case .extraLarge: return 1.0
        }
    }
    
    private var textColor: Color {
        switch (style, variant) {
        case (.primary, .filled): return .white
        case (.primary, .outlined), (.primary, .plain), (.primary, .capsule): return DesignSystem.Colors.primary
        case (.secondary, .filled): return DesignSystem.Colors.primaryText
        case (.secondary, .outlined), (.secondary, .plain), (.secondary, .capsule): return DesignSystem.Colors.secondaryText
        case (.tertiary, _): return DesignSystem.Colors.tertiaryText
        case (.destructive, .filled): return .white
        case (.destructive, .outlined), (.destructive, .plain), (.destructive, .capsule): return DesignSystem.Colors.error
        case (.ghost, _): return DesignSystem.Colors.primary
        case (.success, .filled): return .white
        case (.success, .outlined), (.success, .plain), (.success, .capsule): return DesignSystem.Colors.success
        case (.warning, .filled): return .white
        case (.warning, .outlined), (.warning, .plain), (.warning, .capsule): return DesignSystem.Colors.warning
        }
    }
    
    private var iconColor: Color {
        return textColor
    }
    
    private var effectiveOpacity: Double {
        if !isEnabled {
            return DesignSystem.VisualConsistency.opacityDisabled
        } else if isLoading {
            return DesignSystem.VisualConsistency.opacityGlassmorphism
        } else {
            return 1.0
        }
    }
    
    private var effectiveScale: CGFloat {
        if isPressed && isEnabled {
            return DesignSystem.VisualConsistency.scalePressed
        } else if isHovered && isEnabled {
            return DesignSystem.VisualConsistency.scaleHover
        } else {
            return 1.0
        }
    }
    
    private var iconFont: Font {
        switch size {
        case .small: return DesignSystem.Typography.tinyIcon
        case .medium: return DesignSystem.Typography.smallIcon
        case .large: return DesignSystem.Typography.mediumIcon
        case .extraLarge: return DesignSystem.Typography.largeControl
        }
    }
    
    // MARK: - Accessibility
    
    private var accessibilityLabel: String {
        if isLoading {
            return "\(title), Loading"
        } else {
            return title
        }
    }
    
    private var accessibilityHint: String? {
        if !isEnabled {
            return "Button is disabled"
        } else if isLoading {
            return "Please wait while the action completes"
        } else {
            return nil
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
                withAnimation(DesignSystem.Animation.accessible(.interactiveSpring(response: 0.3, dampingFraction: 0.7), reduceMotion: reduceMotion)) {
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
                    DesignSystem.Colors.primary.opacity(DesignSystem.VisualConsistency.opacityNearlyOpaque)
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
                    DesignSystem.Colors.error.opacity(DesignSystem.VisualConsistency.opacityNearlyOpaque)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case (.success, .filled):
            LinearGradient(
                colors: [
                    DesignSystem.Colors.success,
                    DesignSystem.Colors.success.opacity(DesignSystem.VisualConsistency.opacityNearlyOpaque)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case (.warning, .filled):
            LinearGradient(
                colors: [
                    DesignSystem.Colors.warning,
                    DesignSystem.Colors.warning.opacity(DesignSystem.VisualConsistency.opacityNearlyOpaque)
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
            return AnyShape(Capsule())
        case .filled, .outlined, .plain:
            return AnyShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
    
    // MARK: - Style Properties
    
    private var cornerRadius: CGFloat {
        switch size {
        case .small: return DesignSystem.CornerRadius.small
        case .medium: return DesignSystem.CornerRadius.button
        case .large: return DesignSystem.CornerRadius.medium
        case .extraLarge: return DesignSystem.CornerRadius.large
        }
    }
    
    private var strokeColor: Color {
        switch style {
        case .primary: return DesignSystem.Colors.primary
        case .secondary: return DesignSystem.Colors.separatorColor
        case .tertiary: return DesignSystem.Colors.tertiaryText
        case .destructive: return DesignSystem.Colors.error
        case .ghost: return DesignSystem.Colors.primary.opacity(DesignSystem.VisualConsistency.opacityLoading)
        case .success: return DesignSystem.Colors.success
        case .warning: return DesignSystem.Colors.warning
        }
    }
    
    private var strokeWidth: CGFloat {
        switch style {
        case .primary, .destructive, .success, .warning: return DesignSystem.VisualConsistency.borderThick
        case .secondary: return DesignSystem.VisualConsistency.borderStandard
        case .tertiary, .ghost: return DesignSystem.VisualConsistency.borderThin
        }
    }
    
    private var shadowColor: Color {
        switch (style, variant) {
        case (.primary, .filled), (.destructive, .filled), (.success, .filled), (.warning, .filled):
            return Color.black.opacity(DesignSystem.VisualConsistency.opacityIconBackground)
        case (.secondary, .filled):
            return Color.black.opacity(DesignSystem.VisualConsistency.opacityOverlay)
        default:
            return Color.clear
        }
    }
    
    private var shadowRadius: CGFloat {
        switch variant {
        case .filled: return isPressed ? 2 : 4
        default: return 0
        }
    }
    
    private var shadowOffset: CGFloat {
        switch variant {
        case .filled: return isPressed ? 1 : 2
        default: return 0
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
            EnhancedButton.primary("Primary Button", systemImage: "star.fill") { }
            
            // Secondary buttons
            EnhancedButton.secondary("Secondary Button", systemImage: "heart") { }
            
            // Tertiary buttons
            EnhancedButton.tertiary("Tertiary Button", systemImage: "info.circle") { }
            
            // Destructive buttons
            EnhancedButton.destructive("Delete", systemImage: "trash") { }
            
            // Success buttons
            EnhancedButton.success("Save", systemImage: "checkmark") { }
            
            // Warning buttons
            EnhancedButton.warning("Warning", systemImage: "exclamationmark.triangle") { }
            
            // Ghost buttons
            EnhancedButton.ghost("Ghost Button", systemImage: "eye") { }
            
            // Capsule buttons
            EnhancedButton.capsule("Capsule", systemImage: "plus") { }
            
            // Loading state
            EnhancedButton.primary("Loading", isLoading: true) { }
            
            // Disabled state
            EnhancedButton.primary("Disabled", isEnabled: false) { }
        }
        .padding()
    }
}
#endif 