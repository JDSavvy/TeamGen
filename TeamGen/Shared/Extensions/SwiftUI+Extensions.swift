import SwiftUI

// MARK: - View Extensions
extension View {
    /// Applies conditional modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Applies conditional modifier with else clause
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if trueTransform: (Self) -> TrueContent,
        else falseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }

    /// Applies standard card styling
    func cardStyle() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(AppConstants.UI.cornerRadius)
            .shadow(radius: AppConstants.UI.shadowRadius)
    }

    /// Applies standard button styling
    func buttonStyle(isEnabled: Bool = true) -> some View {
        self
            .foregroundColor(isEnabled ? .accentColor : .secondary)
            .opacity(isEnabled ? 1.0 : 0.6)
    }

    /// Applies accessibility minimum tap target
    func accessibleTapTarget() -> some View {
        self
            .frame(minWidth: AppConstants.Accessibility.minimumTapTargetSize,
                   minHeight: AppConstants.Accessibility.minimumTapTargetSize)
    }

    /// Applies standard spacing
    func standardSpacing() -> some View {
        self.padding(AppConstants.UI.Spacing.md)
    }

    /// Applies loading state overlay
    func loadingOverlay(isLoading: Bool) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                        .background(DesignSystem.Colors.primaryBackground.opacity(DesignSystem.VisualConsistency.opacitySkillBackground))
                }
            }
        )
    }
}

// MARK: - Color Extensions
extension Color {
    /// Dynamic color that adapts to color scheme
    static func dynamic(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    /// Skill level color based on value
    static func skillLevel(_ value: Int) -> Color {
        let normalizedValue = Double(value) / Double(AppConstants.Player.maxSkillLevel)

        switch normalizedValue {
        case 0.0..<0.3:
            return .red
        case 0.3..<0.6:
            return .orange
        case 0.6..<0.8:
            return .yellow
        default:
            return .green
        }
    }
}

// MARK: - Font Extensions
extension Font {
    /// Standard app fonts
    static let appCaption = Font.system(size: AppConstants.UI.FontSize.caption)
    static let appBody = Font.system(size: AppConstants.UI.FontSize.body)
    static let appTitle = Font.system(size: AppConstants.UI.FontSize.title, weight: .semibold)
    static let appLargeTitle = Font.system(size: AppConstants.UI.FontSize.largeTitle, weight: .bold)
}

// MARK: - Animation Extensions
extension Animation {
    /// Standard app animation
    static let appDefault = Animation.easeInOut(duration: AppConstants.UI.animationDuration)

    /// Spring animation for interactive elements
    static let appSpring = Animation.spring(response: 0.5, dampingFraction: 0.8)

    /// Quick animation for state changes
    static let appQuick = Animation.easeInOut(duration: 0.15)
}

// MARK: - EdgeInsets Extensions
extension EdgeInsets {
    /// Standard app padding
    static let appStandard = EdgeInsets(
        top: AppConstants.UI.Spacing.md,
        leading: AppConstants.UI.Spacing.md,
        bottom: AppConstants.UI.Spacing.md,
        trailing: AppConstants.UI.Spacing.md
    )

    /// Compact padding for dense layouts
    static let appCompact = EdgeInsets(
        top: AppConstants.UI.Spacing.sm,
        leading: AppConstants.UI.Spacing.sm,
        bottom: AppConstants.UI.Spacing.sm,
        trailing: AppConstants.UI.Spacing.sm
    )
}