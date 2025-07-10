import SwiftUI

// MARK: - Enhanced Transitions (iOS 18)

/// A comprehensive collection of HIG-compliant transitions for various UI contexts
/// Enhanced with modern iOS 18 motion design principles and accessibility features
public enum EnhancedTransitions {
    // MARK: - List Transitions (Enhanced)

    /// Smooth slide transition for list items with improved physics
    public static let listItemSlide: AnyTransition = .asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.95)),
        removal: .move(edge: .leading).combined(with: .opacity).combined(with: .scale(scale: 0.95))
    )

    /// Scale and fade for new items with enhanced spring animation
    public static let listItemAppear: AnyTransition = .scale(scale: 0.8, anchor: .center)
        .combined(with: .opacity)
        .animation(DesignSystem.Animation.spring)

    /// Staggered list transition with improved timing
    public static func staggeredListItem(index: Int, baseDelay: Double = 0.03) -> AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.9, anchor: .center)
                .combined(with: .opacity)
                .combined(with: .move(edge: .top))
                .animation(DesignSystem.Animation.staggeredSpring(for: index, baseDelay: baseDelay)),
            removal: .opacity
                .combined(with: .scale(scale: 0.95))
                .animation(DesignSystem.Animation.quick.delay(Double(index) * 0.02))
        )
    }

    /// Enhanced list item removal with physics-based animation
    public static let listItemRemoval: AnyTransition = .asymmetric(
        insertion: .identity,
        removal: .move(edge: .trailing)
            .combined(with: .opacity)
            .combined(with: .scale(scale: 0.8))
            .animation(DesignSystem.Animation.spring)
    )

    // MARK: - Modal Transitions (Enhanced)

    /// Smooth modal presentation with improved spring physics
    public static let modalPresentation: AnyTransition = .asymmetric(
        insertion: .move(edge: .bottom)
            .combined(with: .opacity)
            .combined(with: .scale(scale: 0.95, anchor: .bottom))
            .animation(DesignSystem.Animation.modalPresentation),
        removal: .move(edge: .bottom)
            .combined(with: .opacity)
            .combined(with: .scale(scale: 0.95, anchor: .bottom))
            .animation(DesignSystem.Animation.standard)
    )

    /// Card-style modal with enhanced depth perception
    public static let cardModal: AnyTransition = .scale(scale: 0.9, anchor: .center)
        .combined(with: .opacity)
        .animation(DesignSystem.Animation.modalPresentation)

    /// Sheet-style modal with natural physics
    public static let sheetModal: AnyTransition = .asymmetric(
        insertion: .move(edge: .bottom)
            .combined(with: .scale(scale: 0.98, anchor: .bottom))
            .animation(DesignSystem.Animation.interactive),
        removal: .move(edge: .bottom)
            .combined(with: .scale(scale: 0.98, anchor: .bottom))
            .animation(DesignSystem.Animation.standard)
    )

    // MARK: - Content State Transitions (Enhanced)

    /// Loading to content transition with improved visual continuity
    public static let contentAppear: AnyTransition = .asymmetric(
        insertion: .scale(scale: 0.95, anchor: .center)
            .combined(with: .opacity)
            .animation(DesignSystem.Animation.standard),
        removal: .scale(scale: 1.05, anchor: .center)
            .combined(with: .opacity)
            .animation(DesignSystem.Animation.quick)
    )

    /// Error state transition with attention-grabbing animation
    public static let errorState: AnyTransition = .scale(scale: 0.9, anchor: .center)
        .combined(with: .opacity)
        .combined(with: .offset(y: -10))
        .animation(DesignSystem.Animation.errorFeedback)

    /// Empty state transition with gentle appearance
    public static let emptyState: AnyTransition = .scale(scale: 0.95, anchor: .center)
        .combined(with: .opacity)
        .animation(DesignSystem.Animation.standard)

    /// Success state transition with celebratory feel
    public static let successState: AnyTransition = .scale(scale: 0.8, anchor: .center)
        .combined(with: .opacity)
        .animation(DesignSystem.Animation.successFeedback)

    // MARK: - Navigation Transitions (Enhanced)

    /// Forward navigation with improved depth perception
    public static let navigationForward: AnyTransition = .asymmetric(
        insertion: .move(edge: .trailing)
            .combined(with: .opacity)
            .combined(with: .scale(scale: 0.95, anchor: .leading))
            .animation(DesignSystem.Animation.navigation),
        removal: .move(edge: .leading)
            .combined(with: .opacity)
            .combined(with: .scale(scale: 1.05, anchor: .trailing))
            .animation(DesignSystem.Animation.navigation)
    )

    /// Backward navigation with natural feel
    public static let navigationBackward: AnyTransition = .asymmetric(
        insertion: .move(edge: .leading)
            .combined(with: .opacity)
            .combined(with: .scale(scale: 0.95, anchor: .trailing))
            .animation(DesignSystem.Animation.navigation),
        removal: .move(edge: .trailing)
            .combined(with: .opacity)
            .combined(with: .scale(scale: 1.05, anchor: .leading))
            .animation(DesignSystem.Animation.navigation)
    )

    /// Tab transition with smooth cross-fade
    public static let tabTransition: AnyTransition = .asymmetric(
        insertion: .opacity.combined(with: .scale(scale: 0.98))
            .animation(DesignSystem.Animation.standard),
        removal: .opacity.combined(with: .scale(scale: 1.02))
            .animation(DesignSystem.Animation.quick)
    )

    // MARK: - Contextual Transitions (Enhanced)

    /// Skill expansion transition with natural unfold
    public static let skillExpansion: AnyTransition = .asymmetric(
        insertion: .move(edge: .top)
            .combined(with: .opacity)
            .combined(with: .scale(scale: 0.95, anchor: .top))
            .animation(DesignSystem.Animation.spring),
        removal: .move(edge: .top)
            .combined(with: .opacity)
            .combined(with: .scale(scale: 0.95, anchor: .top))
            .animation(DesignSystem.Animation.quick)
    )

    /// Team generation result with celebratory animation
    public static let teamResult: AnyTransition = .scale(scale: 0.8, anchor: .center)
        .combined(with: .opacity)
        .animation(DesignSystem.Animation.bouncy)

    /// Player card flip transition
    public static let playerCardFlip: AnyTransition = .asymmetric(
        insertion: .scale(scale: 0.1, anchor: .center)
            .combined(with: .opacity)
            .animation(DesignSystem.Animation.spring),
        removal: .scale(scale: 0.1, anchor: .center)
            .combined(with: .opacity)
            .animation(DesignSystem.Animation.quick)
    )

    /// Settings panel slide
    public static let settingsPanel: AnyTransition = .asymmetric(
        insertion: .move(edge: .trailing)
            .combined(with: .opacity)
            .animation(DesignSystem.Animation.standard),
        removal: .move(edge: .trailing)
            .combined(with: .opacity)
            .animation(DesignSystem.Animation.quick)
    )
}

// MARK: - Interactive Feedback Modifiers (Enhanced iOS 18)

/// Provides consistent interactive feedback across the app with modern iOS 18 patterns
public struct InteractiveFeedbackModifier: ViewModifier {
    let style: FeedbackStyle
    let isEnabled: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false
    @State private var isHovered = false

    public enum FeedbackStyle {
        case subtle, standard, prominent, dramatic

        var pressedScale: CGFloat {
            switch self {
            case .subtle: DesignSystem.VisualConsistency.scalePressedSubtle
            case .standard: DesignSystem.VisualConsistency.scalePressed
            case .prominent: 0.96
            case .dramatic: 0.94
            }
        }

        var hoverScale: CGFloat {
            switch self {
            case .subtle: 1.01
            case .standard: DesignSystem.VisualConsistency.scaleHover
            case .prominent: 1.08
            case .dramatic: 1.12
            }
        }

        var animation: SwiftUI.Animation {
            switch self {
            case .subtle: DesignSystem.Animation.ultraQuick
            case .standard: DesignSystem.Animation.interactive
            case .prominent: DesignSystem.Animation.spring
            case .dramatic: DesignSystem.Animation.bouncy
            }
        }

        var shadowIntensity: Double {
            switch self {
            case .subtle: 0.05
            case .standard: 0.1
            case .prominent: 0.15
            case .dramatic: 0.2
            }
        }
    }

    public func body(content: Content) -> some View {
        content
            .scaleEffect(effectiveScale)
            .shadow(
                color: Color.black.opacity(effectiveShadowOpacity),
                radius: effectiveShadowRadius,
                x: 0,
                y: effectiveShadowOffset
            )
            .animation(
                DesignSystem.Animation.accessible(style.animation, reduceMotion: reduceMotion),
                value: isPressed
            )
            .animation(
                DesignSystem.Animation.accessible(.easeInOut(duration: 0.2), reduceMotion: reduceMotion),
                value: isHovered
            )
            .onHover { hovering in
                guard isEnabled else { return }
                withAnimation(DesignSystem.Animation.accessible(
                    .easeInOut(duration: 0.2),
                    reduceMotion: reduceMotion
                )) {
                    isHovered = hovering
                }
            }
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) {
                // Gesture completion
            } onPressingChanged: { pressing in
                guard isEnabled else { return }
                withAnimation(DesignSystem.Animation.accessible(style.animation, reduceMotion: reduceMotion)) {
                    isPressed = pressing
                }
            }
    }

    private var effectiveScale: CGFloat {
        if isPressed, isEnabled {
            style.pressedScale
        } else if isHovered, isEnabled {
            style.hoverScale
        } else {
            1.0
        }
    }

    private var effectiveShadowOpacity: Double {
        if isPressed, isEnabled {
            style.shadowIntensity * 0.5
        } else if isHovered, isEnabled {
            style.shadowIntensity * 1.5
        } else {
            style.shadowIntensity
        }
    }

    private var effectiveShadowRadius: CGFloat {
        if isPressed, isEnabled {
            2
        } else if isHovered, isEnabled {
            8
        } else {
            4
        }
    }

    private var effectiveShadowOffset: CGFloat {
        if isPressed, isEnabled {
            1
        } else if isHovered, isEnabled {
            4
        } else {
            2
        }
    }
}

// MARK: - Hover Effect Modifier (Enhanced iOS 18)

/// Provides smooth hover effects for interactive elements with modern physics
public struct HoverEffectModifier: ViewModifier {
    let style: HoverStyle
    let isEnabled: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isHovered = false

    public enum HoverStyle {
        case lift, scale, glow, float, pulse

        var hoverScale: CGFloat {
            switch self {
            case .lift, .glow, .float, .pulse: 1.0
            case .scale: DesignSystem.VisualConsistency.scaleHover
            }
        }

        var shadowRadius: CGFloat {
            switch self {
            case .lift: 12
            case .scale: 6
            case .glow: 16
            case .float: 20
            case .pulse: 8
            }
        }

        var shadowOpacity: Double {
            switch self {
            case .lift: 0.15
            case .scale: 0.1
            case .glow: 0.2
            case .float: 0.25
            case .pulse: 0.12
            }
        }

        var yOffset: CGFloat {
            switch self {
            case .lift: -2
            case .float: -4
            case .scale, .glow, .pulse: 0
            }
        }
    }

    public func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered && isEnabled ? style.hoverScale : 1.0)
            .offset(y: isHovered && isEnabled ? style.yOffset : 0)
            .shadow(
                color: isHovered && isEnabled ? Color.black.opacity(style.shadowOpacity) : Color.clear,
                radius: isHovered && isEnabled ? style.shadowRadius : 0,
                x: 0,
                y: isHovered && isEnabled ? style.shadowRadius * 0.3 : 0
            )
            .overlay(
                // Glow effect for glow style
                Group {
                    if style == .glow, isHovered, isEnabled {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.transition)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        DesignSystem.Colors.primary.opacity(0.6),
                                        DesignSystem.Colors.primary.opacity(0.2),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .blur(radius: 4)
                    }
                }
            )
            .animation(
                DesignSystem.Animation.accessible(
                    .interactiveSpring(response: 0.4, dampingFraction: 0.7),
                    reduceMotion: reduceMotion
                ),
                value: isHovered
            )
            .onHover { hovering in
                guard isEnabled else { return }
                withAnimation(DesignSystem.Animation.accessible(
                    .interactiveSpring(response: 0.4, dampingFraction: 0.7),
                    reduceMotion: reduceMotion
                )) {
                    isHovered = hovering
                }
            }
    }
}

// MARK: - Shimmer Loading Effect (Enhanced iOS 18)

/// Creates a smooth shimmer effect for loading states with modern design
public struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let duration: Double
    let angle: Double
    let opacity: Double

    init(duration: Double = 1.5, angle: Double = 70, opacity: Double = 0.3) {
        self.duration = duration
        self.angle = angle
        self.opacity = opacity
    }

    public func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(opacity),
                                Color.clear,
                            ],
                            startPoint: .init(x: phase - 0.3, y: 0),
                            endPoint: .init(x: phase + 0.3, y: 0)
                        )
                    )
                    .rotationEffect(.degrees(angle))
                    .mask(content)
                    .opacity(reduceMotion ? 0 : 1)
            )
            .onAppear {
                if !reduceMotion {
                    withAnimation(
                        .linear(duration: duration)
                            .repeatForever(autoreverses: false)
                    ) {
                        phase = 2.0
                    }
                }
            }
    }
}

// MARK: - Pulse Effect Modifier (iOS 18)

/// Creates a subtle pulse effect for attention-grabbing elements
public struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let intensity: Double
    let duration: Double

    init(intensity: Double = 0.05, duration: Double = 1.0) {
        self.intensity = intensity
        self.duration = duration
    }

    public func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1 + intensity : 1)
            .animation(
                reduceMotion ? nil : .easeInOut(duration: duration).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                if !reduceMotion {
                    isPulsing = true
                }
            }
    }
}

// MARK: - Breathing Effect Modifier (iOS 18)

/// Creates a gentle breathing effect for ambient animations
public struct BreathingModifier: ViewModifier {
    @State private var isBreathing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let intensity: Double
    let duration: Double

    init(intensity: Double = 0.03, duration: Double = 2.0) {
        self.intensity = intensity
        self.duration = duration
    }

    public func body(content: Content) -> some View {
        content
            .scaleEffect(isBreathing ? 1 + intensity : 1 - intensity)
            .opacity(isBreathing ? 1.0 : 0.95)
            .animation(
                reduceMotion ? nil : .easeInOut(duration: duration).repeatForever(autoreverses: true),
                value: isBreathing
            )
            .onAppear {
                if !reduceMotion {
                    isBreathing = true
                }
            }
    }
}

// MARK: - Smooth Appearance Modifier (iOS 18)

/// Creates smooth appearance animations for views with staggered timing
public struct SmoothAppearanceModifier: ViewModifier {
    @State private var hasAppeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let delay: Double
    let duration: Double
    let transition: AnyTransition

    init(
        delay: Double = 0,
        duration: Double = 0.5,
        transition: AnyTransition = .opacity.combined(with: .scale(scale: 0.95))
    ) {
        self.delay = delay
        self.duration = duration
        self.transition = transition
    }

    public func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            .scaleEffect(hasAppeared ? 1 : 0.95)
            .animation(
                DesignSystem.Animation.accessible(
                    .easeOut(duration: duration).delay(delay),
                    reduceMotion: reduceMotion
                ),
                value: hasAppeared
            )
            .onAppear {
                hasAppeared = true
            }
    }
}

// MARK: - View Extensions for Enhanced Transitions

public extension View {
    /// Applies interactive feedback with specified style
    func interactiveFeedback(
        style: InteractiveFeedbackModifier.FeedbackStyle = .standard,
        isEnabled: Bool = true
    ) -> some View {
        modifier(InteractiveFeedbackModifier(style: style, isEnabled: isEnabled))
    }

    /// Applies hover effect with specified style
    func hoverEffect(
        style: HoverEffectModifier.HoverStyle = .lift,
        isEnabled: Bool = true
    ) -> some View {
        modifier(HoverEffectModifier(style: style, isEnabled: isEnabled))
    }

    /// Applies shimmer loading effect
    func shimmer(
        duration: Double = 1.5,
        angle: Double = 70,
        opacity: Double = 0.3
    ) -> some View {
        modifier(ShimmerModifier(duration: duration, angle: angle, opacity: opacity))
    }

    /// Applies pulse effect
    func pulse(
        intensity: Double = 0.05,
        duration: Double = 1.0
    ) -> some View {
        modifier(PulseModifier(intensity: intensity, duration: duration))
    }

    /// Applies breathing effect
    func breathing(
        intensity: Double = 0.03,
        duration: Double = 2.0
    ) -> some View {
        modifier(BreathingModifier(intensity: intensity, duration: duration))
    }

    /// Applies smooth appearance animation
    func smoothAppearance(
        delay: Double = 0,
        duration: Double = 0.5,
        transition: AnyTransition = .opacity.combined(with: .scale(scale: 0.95))
    ) -> some View {
        modifier(SmoothAppearanceModifier(delay: delay, duration: duration, transition: transition))
    }

    /// Applies accessibility-aware animation
    func accessibleAnimation(
        _ animation: SwiftUI.Animation?,
        value: some Equatable,
        reduceMotion: Bool = false
    ) -> some View {
        self.animation(
            DesignSystem.Animation.accessible(animation ?? .default, reduceMotion: reduceMotion),
            value: value
        )
    }
}

// MARK: - Preview

#if DEBUG
    struct EnhancedTransitions_Previews: PreviewProvider {
        static var previews: some View {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Interactive feedback examples
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Text("Interactive Feedback")
                            .font(DesignSystem.Typography.headline)

                        HStack(spacing: DesignSystem.Spacing.md) {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.transition)
                                .fill(DesignSystem.Colors.primary)
                                .frame(width: 60, height: 60)
                                .interactiveFeedback(style: .subtle)

                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.transition)
                                .fill(DesignSystem.Colors.success)
                                .frame(width: 60, height: 60)
                                .interactiveFeedback(style: .standard)

                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.transition)
                                .fill(DesignSystem.Colors.warning)
                                .frame(width: 60, height: 60)
                                .interactiveFeedback(style: .prominent)

                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.transition)
                                .fill(DesignSystem.Colors.error)
                                .frame(width: 60, height: 60)
                                .interactiveFeedback(style: .dramatic)
                        }
                    }

                    // Hover effects examples
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Text("Hover Effects")
                            .font(DesignSystem.Typography.headline)

                        HStack(spacing: DesignSystem.Spacing.md) {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.transition)
                                .fill(DesignSystem.Colors.accent)
                                .frame(width: 60, height: 60)
                                .hoverEffect(style: .lift)

                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.transition)
                                .fill(DesignSystem.Colors.mint)
                                .frame(width: 60, height: 60)
                                .hoverEffect(style: .scale)

                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.transition)
                                .fill(DesignSystem.Colors.teal)
                                .frame(width: 60, height: 60)
                                .hoverEffect(style: .glow)

                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.transition)
                                .fill(DesignSystem.Colors.indigo)
                                .frame(width: 60, height: 60)
                                .hoverEffect(style: .float)
                        }
                    }

                    // Animation effects examples
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Text("Animation Effects")
                            .font(DesignSystem.Typography.headline)

                        HStack(spacing: DesignSystem.Spacing.md) {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.transition)
                                .fill(DesignSystem.Colors.primary.opacity(0.7))
                                .frame(width: 60, height: 60)
                                .shimmer()

                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.transition)
                                .fill(DesignSystem.Colors.success.opacity(0.7))
                                .frame(width: 60, height: 60)
                                .pulse()

                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.transition)
                                .fill(DesignSystem.Colors.warning.opacity(0.7))
                                .frame(width: 60, height: 60)
                                .breathing()
                        }
                    }

                    // Smooth appearance examples
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Text("Smooth Appearance")
                            .font(DesignSystem.Typography.headline)

                        ForEach(0 ..< 3, id: \.self) { index in
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.transition)
                                .fill(DesignSystem.Colors.cardBackground)
                                .frame(height: 60)
                                .overlay(
                                    Text("Item \(index + 1)")
                                        .font(DesignSystem.Typography.body)
                                )
                                .smoothAppearance(delay: Double(index) * 0.1)
                        }
                    }
                }
                .padding()
            }
        }
    }
#endif
