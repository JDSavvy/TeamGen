import SwiftUI

// MARK: - View Extensions

extension View {
    /// Applies conditional modifier
    @ViewBuilder
    func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Applies conditional modifier with else clause
    @ViewBuilder
    func `if`(
        _ condition: Bool,
        if trueTransform: (Self) -> some View,
        else falseTransform: (Self) -> some View
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }

    /// Applies standard card styling
    func cardStyle() -> some View {
        background(Color(.systemBackground))
            .cornerRadius(AppConstants.UserInterface.cornerRadius)
            .shadow(radius: AppConstants.UserInterface.shadowRadius)
    }

    /// Applies standard button styling
    func buttonStyle(isEnabled: Bool = true) -> some View {
        foregroundColor(isEnabled ? .accentColor : .secondary)
            .opacity(isEnabled ? 1.0 : 0.6)
    }

    /// Applies accessibility minimum tap target
    func accessibleTapTarget() -> some View {
        frame(minWidth: AppConstants.Accessibility.minimumTapTargetSize,
              minHeight: AppConstants.Accessibility.minimumTapTargetSize)
    }

    /// Applies standard spacing
    func standardSpacing() -> some View {
        padding(AppConstants.UserInterface.Spacing.md)
    }

    /// Applies loading state overlay
    func loadingOverlay(isLoading: Bool) -> some View {
        overlay(
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                        .background(DesignSystem.Colors.primaryBackground
                            .opacity(DesignSystem.VisualConsistency.opacitySkillBackground))
                }
            }
        )
    }
}

// MARK: - Color Extensions

extension Color {
    /// Dynamic color that adapts to color scheme
    static func dynamic(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    /// Skill level color based on value
    static func skillLevel(_ value: Int) -> Color {
        let normalizedValue = Double(value) / Double(AppConstants.Player.maxSkillLevel)

        switch normalizedValue {
        case 0.0 ..< 0.3:
            return .red
        case 0.3 ..< 0.6:
            return .orange
        case 0.6 ..< 0.8:
            return .yellow
        default:
            return .green
        }
    }
}

// MARK: - Font Extensions

extension Font {
    /// Standard app fonts
    static let appCaption = Font.system(size: AppConstants.UserInterface.FontSize.caption)
    static let appBody = Font.system(size: AppConstants.UserInterface.FontSize.body)
    static let appTitle = Font.system(size: AppConstants.UserInterface.FontSize.title, weight: .semibold)
    static let appLargeTitle = Font.system(size: AppConstants.UserInterface.FontSize.largeTitle, weight: .bold)
}

// MARK: - Animation Extensions

extension Animation {
    /// Standard app animation
    static let appDefault = Animation.easeInOut(duration: AppConstants.UserInterface.animationDuration)

    /// Spring animation for interactive elements
    static let appSpring = Animation.spring(response: 0.5, dampingFraction: 0.8)

    /// Quick animation for state changes
    static let appQuick = Animation.easeInOut(duration: 0.15)
}

// MARK: - EdgeInsets Extensions

extension EdgeInsets {
    /// Standard app padding
    static let appStandard = EdgeInsets(
        top: AppConstants.UserInterface.Spacing.md,
        leading: AppConstants.UserInterface.Spacing.md,
        bottom: AppConstants.UserInterface.Spacing.md,
        trailing: AppConstants.UserInterface.Spacing.md
    )

    /// Compact padding for dense layouts
    static let appCompact = EdgeInsets(
        top: AppConstants.UserInterface.Spacing.sm,
        leading: AppConstants.UserInterface.Spacing.sm,
        bottom: AppConstants.UserInterface.Spacing.sm,
        trailing: AppConstants.UserInterface.Spacing.sm
    )
}
