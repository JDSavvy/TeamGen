import SwiftUI

// MARK: - Color Scheme Aware View Modifier

/// A view modifier that applies color scheme and accessibility settings system-wide
/// Ensures consistent appearance across all views with proper accessibility support
struct ColorSchemeAwareModifier: ViewModifier {
    @Environment(\.dependencies) private var dependencies
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityInvertColors) private var invertColors

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(dependencies.colorSchemeService.effectiveColorScheme)
            .animation(
                shouldReduceMotion ? nil : DesignSystem.Animation.standard,
                value: dependencies.colorSchemeService.effectiveColorScheme
            )
            .accessibilityElement(children: .contain)
    }

    // MARK: - Computed Properties

    private var shouldReduceMotion: Bool {
        dependencies.colorSchemeService.isReduceMotionEnabled || systemReduceMotion
    }

    private var shouldUseHighContrast: Bool {
        dependencies.colorSchemeService.isHighContrastEnabled || differentiateWithoutColor
    }
}

// MARK: - View Extension

public extension View {
    /// Applies system-wide color scheme and accessibility settings
    func colorSchemeAware() -> some View {
        modifier(ColorSchemeAwareModifier())
    }
}

// MARK: - Environment Values Extension

/// Custom environment values for color scheme and accessibility state
private struct ColorSchemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: (any ColorSchemeServiceProtocol)? = nil
}

private struct HighContrastEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var colorSchemeService: (any ColorSchemeServiceProtocol)? {
        get { self[ColorSchemeEnvironmentKey.self] }
        set { self[ColorSchemeEnvironmentKey.self] = newValue }
    }

    var isHighContrastEnabled: Bool {
        get { self[HighContrastEnvironmentKey.self] }
        set { self[HighContrastEnvironmentKey.self] = newValue }
    }
}

// MARK: - Accessibility-Aware Color Provider

/// Provides colors that automatically adapt to accessibility settings
@MainActor
public struct AccessibilityAwareColors {
    private let colorSchemeService: any ColorSchemeServiceProtocol

    public init(colorSchemeService: any ColorSchemeServiceProtocol) {
        self.colorSchemeService = colorSchemeService
    }

    // MARK: - Text Colors

    public var primaryText: Color {
        DesignSystem.Colors.accessibleTextColor(
            isHighContrast: colorSchemeService.isHighContrastEnabled
        )
    }

    public var secondaryText: Color {
        DesignSystem.Colors.accessibleSecondaryTextColor(
            isHighContrast: colorSchemeService.isHighContrastEnabled
        )
    }

    // MARK: - Background Colors

    public var primaryBackground: Color {
        DesignSystem.Colors.accessibleBackgroundColor(
            isHighContrast: colorSchemeService.isHighContrastEnabled
        )
    }

    public var cardBackground: Color {
        DesignSystem.Colors.accessibleCardBackground(
            isHighContrast: colorSchemeService.isHighContrastEnabled
        )
    }

    // MARK: - Interactive Colors

    public var buttonBackground: Color {
        colorSchemeService.isHighContrastEnabled
            ? DesignSystem.Colors.highContrastPrimary
            : DesignSystem.Colors.buttonBackground
    }

    public var focusRing: Color {
        DesignSystem.Colors.focusRing
    }
}

// MARK: - Smooth Color Transition View Modifier

/// Provides smooth transitions between color schemes
struct SmoothColorTransitionModifier: ViewModifier {
    @Environment(\.dependencies) private var dependencies

    func body(content: Content) -> some View {
        content
            .animation(
                dependencies.colorSchemeService.isReduceMotionEnabled
                    ? nil
                    : .easeInOut(duration: 0.3),
                value: dependencies.colorSchemeService.effectiveColorScheme
            )
            .animation(
                dependencies.colorSchemeService.isReduceMotionEnabled
                    ? nil
                    : .easeInOut(duration: 0.2),
                value: dependencies.colorSchemeService.isHighContrastEnabled
            )
    }
}

public extension View {
    /// Applies smooth color transitions when color scheme changes
    func smoothColorTransitions() -> some View {
        modifier(SmoothColorTransitionModifier())
    }
}
