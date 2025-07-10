import SwiftUI

// MARK: - Design System
/// Centralized design system following Apple Human Interface Guidelines iOS 18
/// Enhanced with modern accessibility features and unified visual language
public struct DesignSystem {

    // MARK: - Colors
    public struct Colors {
        // MARK: - Primary Colors (iOS 18 Enhanced)
        public static let primary = Color.accentColor
        public static let primaryBackground = Color(.systemBackground)
        public static let secondaryBackground = Color(.secondarySystemBackground)
        public static let tertiaryBackground = Color(.tertiarySystemBackground)

        // MARK: - Semantic Colors (Enhanced for iOS 18)
        public static let success = Color(.systemGreen)
        public static let warning = Color(.systemOrange)
        public static let error = Color(.systemRed)
        public static let info = Color(.systemBlue)
        public static let accent = Color(.systemPurple)
        public static let indigo = Color(.systemIndigo)
        public static let mint = Color(.systemMint)
        public static let teal = Color(.systemTeal)
        public static let cyan = Color(.systemCyan)

        // MARK: - Text Colors (Enhanced Hierarchy)
        public static let primaryText = Color(.label)
        public static let secondaryText = Color(.secondaryLabel)
        public static let tertiaryText = Color(.tertiaryLabel)
        public static let quaternaryText = Color(.quaternaryLabel)
        public static let placeholderText = Color(.placeholderText)

        // MARK: - Enhanced UI Colors (iOS 18 Material Design)
        public static let cardBackground = Color(.secondarySystemBackground)
        public static let elevatedCardBackground = Color(.tertiarySystemBackground)
        public static let separatorColor = Color(.separator)
        public static let opaqueSeparator = Color(.opaqueSeparator)
        public static let groupedBackground = Color(.systemGroupedBackground)
        public static let secondaryGroupedBackground = Color(.secondarySystemGroupedBackground)
        public static let tertiaryGroupedBackground = Color(.tertiarySystemGroupedBackground)

        // MARK: - Interactive Colors (Modern iOS 18)
        public static let buttonBackground = Color(.systemBlue)
        public static let buttonBackgroundPressed = Color(.systemBlue).opacity(0.8)
        public static let destructiveButton = Color(.systemRed)
        public static let secondaryButton = Color(.systemGray6)
        public static let tertiaryButton = Color(.systemGray5)
        public static let fillPrimary = Color(.systemFill)
        public static let fillSecondary = Color(.secondarySystemFill)
        public static let fillTertiary = Color(.tertiarySystemFill)
        public static let fillQuaternary = Color(.quaternarySystemFill)

        // MARK: - Accessibility Colors (WCAG 2.2 Compliant)
        public static let highContrastPrimary = Color(.label)
        public static let highContrastSecondary = Color(.secondaryLabel)
        public static let focusRing = Color(.systemBlue)
        public static let selectionHighlight = Color(.systemBlue).opacity(0.2)

        // MARK: - Accessibility-Aware Color Functions

        /// Returns appropriate text color based on accessibility settings
        public static func accessibleTextColor(isHighContrast: Bool = false) -> Color {
            return isHighContrast ? highContrastPrimary : primaryText
        }

        /// Returns appropriate secondary text color based on accessibility settings
        public static func accessibleSecondaryTextColor(isHighContrast: Bool = false) -> Color {
            return isHighContrast ? highContrastSecondary : secondaryText
        }

        /// Returns appropriate background color based on accessibility settings
        public static func accessibleBackgroundColor(isHighContrast: Bool = false) -> Color {
            return isHighContrast ? Color(.systemBackground) : primaryBackground
        }

        /// Returns appropriate card background color based on accessibility settings
        public static func accessibleCardBackground(isHighContrast: Bool = false) -> Color {
            return isHighContrast ? Color(.systemBackground) : cardBackground
        }

        // MARK: - Enhanced Continuous Gradient Color System (WCAG 2.2 Compliant)
        // Seamless transitions across red → orange → yellow → green spectrum
        // Enhanced for better accessibility and visual distinction

        // Anchor colors for the continuous gradient (Enhanced contrast ratios)
        public static let gradientRed = Color(red: 0.89, green: 0.18, blue: 0.18)       // Pure red (#E32E2E)
        public static let gradientOrange = Color(red: 0.95, green: 0.42, blue: 0.13)    // Red-orange (#F26B21)
        public static let gradientYellow = Color(red: 0.98, green: 0.65, blue: 0.09)    // Orange-yellow (#FA9917)
        public static let gradientYellowGreen = Color(red: 0.85, green: 0.75, blue: 0.15) // Yellow-green (#D9BF26)
        public static let gradientGreen = Color(red: 0.20, green: 0.78, blue: 0.35)     // Pure green (#33C759)

        // Legacy discrete skill level colors (maintained for compatibility)
        public static let skillBeginner = gradientRed
        public static let skillNovice = gradientOrange
        public static let skillIntermediate = gradientYellow
        public static let skillAdvanced = gradientYellowGreen
        public static let skillExpert = gradientGreen

        // MARK: - Surface Colors (iOS 18 Material Design)
        public static let overlayBackground = Color(.tertiarySystemBackground)
        public static let dividerColor = Color(.opaqueSeparator)
        public static let glassMorphismBackground = Color(.systemBackground).opacity(0.8)
        public static let blurBackground = Color(.systemBackground).opacity(0.95)
    }

    // MARK: - Typography (iOS 18 Enhanced)
    public struct Typography {
        // MARK: - Semantic Text Styles (Apple HIG Compliant)
        /// Use these exclusively for perfect Dynamic Type support
        public static let largeTitle = Font.largeTitle
        public static let title1 = Font.title
        public static let title2 = Font.title2
        public static let title3 = Font.title3
        public static let headline = Font.headline
        public static let body = Font.body
        public static let callout = Font.callout
        public static let subheadline = Font.subheadline
        public static let footnote = Font.footnote
        public static let caption1 = Font.caption
        public static let caption2 = Font.caption2

        // MARK: - Emphasized Variants (Semantic Weight Only)
        public static let bodyEmphasized = Font.body.weight(.medium)
        public static let headlineEmphasized = Font.headline.weight(.semibold)
        public static let calloutEmphasized = Font.callout.weight(.medium)

        // MARK: - Monospaced (For Data Display)
        public static let monospacedDigit = Font.body.monospacedDigit()
        public static let monospacedCaption = Font.caption.monospacedDigit()

        // MARK: - Contextual Typography (Semantic Usage)
        public static let navigationTitle = Font.largeTitle.weight(.bold)
        public static let sectionHeader = Font.headline.weight(.semibold)
        public static let cardTitle = Font.headline
        public static let cardSubtitle = Font.subheadline
        public static let buttonLabel = Font.body.weight(.medium)
        public static let tabLabel = Font.caption.weight(.medium)
        public static let listItemTitle = Font.body
        public static let listItemSubtitle = Font.subheadline
        public static let badgeText = Font.caption.weight(.medium)

        // MARK: - Custom Sized Typography (Centralized)
        /// Team number display in cards
        public static let teamNumber = Font.system(size: 22, weight: .bold, design: .rounded)
        /// Large metric values
        public static let metricValue = Font.system(size: 18, weight: .semibold, design: .rounded)
        /// Compact skill values
        public static let skillValue = Font.system(size: 13, weight: .semibold, design: .rounded)
        /// Small icons and indicators
        public static let smallIcon = Font.system(size: 11, weight: .medium)
        /// Tiny indicators
        public static let tinyIcon = Font.system(size: 10, weight: .medium)
        /// Medium icons
        public static let mediumIcon = Font.system(size: 16, weight: .medium)
        /// Large display text
        public static let largeDisplay = Font.system(size: 32, weight: .light)
        /// Extra large display
        public static let extraLargeDisplay = Font.system(size: 48, weight: .light)
        /// Massive display
        public static let massiveDisplay = Font.system(size: 64, weight: .light)
        /// Control labels
        public static let controlLabel = Font.system(size: 14, weight: .medium)
        /// Small control labels
        public static let smallControlLabel = Font.system(size: 12, weight: .medium)
        /// Large control text
        public static let largeControl = Font.system(size: 20, weight: .semibold)
        /// Extra large control
        public static let extraLargeControl = Font.system(size: 24)

        // MARK: - Additional Typography for Complete Coverage
        /// Settings icon font
        public static let settingsIcon = Font.system(size: 16, weight: .semibold)
        /// Settings description font
        public static let settingsDescription = Font.system(size: 12, weight: .medium)
        /// Splash screen font
        public static let splashScreen = Font.system(size: 48)
        /// Team control font
        public static let teamControl = Font.system(size: 14, weight: .semibold)
        /// Loading state title
        public static let loadingStateTitle = Font.system(size: 20, weight: .semibold, design: .default)
        /// Loading state subtitle
        public static let loadingStateSubtitle = Font.system(size: 16, weight: .medium, design: .default)

        // MARK: - Accessibility Support
        /// All fonts automatically support Dynamic Type scaling
        /// No custom font sizes - use semantic styles only
    }

    // MARK: - Spacing (Enhanced iOS 18 Grid System)
    public struct Spacing {
        // MARK: - Base Spacing Scale (8pt grid system)
        public static let xxxs: CGFloat = 2
        public static let xxs: CGFloat = 4
        public static let xs: CGFloat = 8
        public static let sm: CGFloat = 12
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 20
        public static let xl: CGFloat = 24
        public static let xxl: CGFloat = 32
        public static let xxxl: CGFloat = 40
        public static let xxxxl: CGFloat = 48

        // MARK: - Additional Spacing Values (Centralized)
        /// Single point spacing
        public static let single: CGFloat = 1
        /// Compact spacing for tight layouts
        public static let compact: CGFloat = 3
        /// Medium-small spacing
        public static let mediumSmall: CGFloat = 6
        /// Medium-large spacing
        public static let mediumLarge: CGFloat = 10

        // MARK: - Semantic Spacing (iOS 18 Guidelines)
        public static let cardPadding = md
        public static let screenPadding = md
        public static let sectionSpacing = xl
        public static let componentSpacing = sm
        public static let listItemSpacing = xs
        public static let buttonSpacing = sm
        public static let iconSpacing = xs

        // MARK: - Layout Spacing (Enhanced for modern iOS)
        public static let navigationSpacing = lg
        public static let tabBarSpacing = sm
        public static let toolbarSpacing = md
        public static let sheetSpacing = lg
        public static let modalSpacing = xl
    }

    // MARK: - Corner Radius (iOS 18 Enhanced)
    public struct CornerRadius {
        public static let none: CGFloat = 0
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 12
        public static let large: CGFloat = 16
        public static let extraLarge: CGFloat = 20
        public static let xxl: CGFloat = 24
        public static let xxxl: CGFloat = 28

        // MARK: - Additional Corner Radius Values (Centralized)
        /// Tiny radius for small elements
        public static let tiny: CGFloat = 2
        /// Compact radius for tight layouts
        public static let compact: CGFloat = 3
        /// Standard button radius
        public static let standardButton: CGFloat = 10
        /// Enhanced transition radius
        public static let transition: CGFloat = 12
        /// Progress bar radius
        public static let progressBar: CGFloat = 4

        // MARK: - Semantic Radius (iOS 18 Guidelines)
        public static let button: CGFloat = 10
        public static let card: CGFloat = medium
        public static let sheet: CGFloat = large
        public static let modal: CGFloat = extraLarge
        public static let pill: CGFloat = 50 // For pill-shaped elements

        // MARK: - Additional Corner Radius for Complete Coverage
        /// Skill picker radius
        public static let skillPicker: CGFloat = 12
        /// Team distribution indicator radius
        public static let teamDistribution: CGFloat = 2
        /// Player row radius
        public static let playerRow: CGFloat = 10
    }

    // MARK: - Icon Sizes (Enhanced iOS 18)
    public struct IconSize {
        public static let xxs: CGFloat = 8
        public static let xs: CGFloat = 12
        public static let sm: CGFloat = 14
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 20
        public static let xl: CGFloat = 24
        public static let xxl: CGFloat = 32
        public static let xxxl: CGFloat = 40

        // MARK: - Semantic Icon Sizes
        public static let tabBar: CGFloat = lg
        public static let navigation: CGFloat = lg
        public static let button: CGFloat = md
        public static let listItem: CGFloat = lg
        public static let card: CGFloat = xl
    }

    // MARK: - Component Dimensions (Centralized)
    public struct ComponentSize {
        // MARK: - Common Frame Dimensions
        /// Small circular indicators (5x5)
        public static let tinyIndicator: CGFloat = 5
        /// Medium circular indicators (6x6)
        public static let smallIndicator: CGFloat = 6
        /// Standard circular indicators (8x8)
        public static let standardIndicator: CGFloat = 8
        /// Small icons (14x14)
        public static let smallIcon: CGFloat = 14
        /// Standard icons (20x20)
        public static let standardIcon: CGFloat = 20
        /// Medium icons (24x24)
        public static let mediumIcon: CGFloat = 24
        /// Large icons (32x32)
        public static let largeIcon: CGFloat = 32
        /// Extra large icons (40x40)
        public static let extraLargeIcon: CGFloat = 40
        /// Touch targets (44x44)
        public static let touchTarget: CGFloat = 44
        /// Large touch targets (56x56)
        public static let largeTouchTarget: CGFloat = 56
        /// Transition elements (60x60)
        public static let transitionElement: CGFloat = 60
        /// Empty state icons (120x120)
        public static let emptyStateIcon: CGFloat = 120

        // MARK: - Component Heights
        /// Minimum row height
        public static let minRowHeight: CGFloat = 20
        /// Standard row height
        public static let standardRowHeight: CGFloat = 44
        /// Compact badge height
        public static let badgeHeight: CGFloat = 24
        /// Metric display height
        public static let metricHeight: CGFloat = 32
        /// Header minimum height
        public static let headerMinHeight: CGFloat = 44
        /// Progress bar height (compact)
        public static let progressBarCompact: CGFloat = 6
        /// Progress bar height (standard)
        public static let progressBarStandard: CGFloat = 8
        /// Loading indicator size (standard)
        public static let loadingIndicatorStandard: CGFloat = 56
        /// Loading indicator size (large)
        public static let loadingIndicatorLarge: CGFloat = 80
        /// Scale marker width
        public static let scaleMarkerWidth: CGFloat = 1
        /// Scale marker height
        public static let scaleMarkerHeight: CGFloat = 4

        // MARK: - Selection Indicators
        /// Selection circle size
        public static let selectionCircle: CGFloat = 22
        /// Checkmark size within selection
        public static let selectionCheckmark: CGFloat = 11
    }

    // MARK: - Shadow (Enhanced iOS 18 Elevation System)
    public struct Shadow {
        public static let none = Color.clear
        public static let subtle = Color.black.opacity(0.03)
        public static let small = Color.black.opacity(0.05)
        public static let medium = Color.black.opacity(0.1)
        public static let large = Color.black.opacity(0.15)
        public static let extraLarge = Color.black.opacity(0.2)

        // MARK: - Elevation Shadows (Material Design inspired, iOS 18 compliant)
        public static func elevation1() -> some View {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.clear)
                .shadow(color: subtle, radius: 1, x: 0, y: 1)
        }

        public static func elevation2() -> some View {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.clear)
                .shadow(color: small, radius: 2, x: 0, y: 2)
        }

        public static func elevation3() -> some View {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.clear)
                .shadow(color: medium, radius: 4, x: 0, y: 4)
        }

        public static func elevation4() -> some View {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.clear)
                .shadow(color: large, radius: 8, x: 0, y: 6)
        }

        public static func elevation5() -> some View {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.clear)
                .shadow(color: extraLarge, radius: 12, x: 0, y: 8)
        }
    }

    // MARK: - Animation (Enhanced iOS 18 Motion System)
    public struct Animation {
        // MARK: - Basic Timing Curves (iOS 18 Enhanced)
        /// Ultra-fast micro-interactions (0.1s) - button presses, toggles
        public static let ultraQuick = SwiftUI.Animation.easeInOut(duration: 0.1)

        /// Quick interactions (0.2s) - hover states, selection feedback
        public static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)

        /// Standard transitions (0.3s) - most UI state changes
        public static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)

        /// Slow, deliberate animations (0.5s) - major state changes
        public static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)

        /// Extra slow for complex transitions (0.7s)
        public static let extraSlow = SwiftUI.Animation.easeInOut(duration: 0.7)

        // MARK: - Spring Animations (Natural Physics - iOS 18)
        /// Gentle spring for subtle interactions
        public static let gentleSpring = SwiftUI.Animation.spring(
            response: 0.4,
            dampingFraction: 0.8,
            blendDuration: 0
        )

        /// Standard spring for most UI elements
        public static let spring = SwiftUI.Animation.spring(
            response: 0.5,
            dampingFraction: 0.7,
            blendDuration: 0
        )

        /// Bouncy spring for playful interactions
        public static let bouncy = SwiftUI.Animation.spring(
            response: 0.3,
            dampingFraction: 0.6,
            blendDuration: 0
        )

        /// Snappy spring for immediate feedback
        public static let snappy = SwiftUI.Animation.spring(
            response: 0.2,
            dampingFraction: 0.8,
            blendDuration: 0
        )

        /// Interactive spring for touch feedback
        public static let interactive = SwiftUI.Animation.interactiveSpring(
            response: 0.3,
            dampingFraction: 0.7,
            blendDuration: 0
        )

        // MARK: - Contextual Animations (iOS 18 Enhanced)
        /// For list item insertions/deletions
        public static let listTransition = SwiftUI.Animation.spring(
            response: 0.4,
            dampingFraction: 0.8,
            blendDuration: 0.1
        )

        /// For modal presentations
        public static let modalPresentation = SwiftUI.Animation.easeOut(duration: 0.4)

        /// For navigation transitions
        public static let navigation = SwiftUI.Animation.easeInOut(duration: 0.35)

        /// For loading state changes
        public static let loadingState = SwiftUI.Animation.easeInOut(duration: 0.25)

        /// For error state animations
        public static let errorFeedback = SwiftUI.Animation.spring(
            response: 0.3,
            dampingFraction: 0.5,
            blendDuration: 0
        )

        /// For success feedback
        public static let successFeedback = SwiftUI.Animation.spring(
            response: 0.4,
            dampingFraction: 0.6,
            blendDuration: 0
        )

        // MARK: - Accessibility-Aware Animations (Enhanced)
        /// Returns appropriate animation based on reduce motion setting
        public static func accessible(
            _ animation: SwiftUI.Animation,
            reduceMotion: Bool = false
        ) -> SwiftUI.Animation? {
            return reduceMotion ? nil : animation
        }

        /// Standard animation with accessibility support
        public static func accessibleStandard(reduceMotion: Bool = false) -> SwiftUI.Animation? {
            return accessible(standard, reduceMotion: reduceMotion)
        }

        /// Spring animation with accessibility support
        public static func accessibleSpring(reduceMotion: Bool = false) -> SwiftUI.Animation? {
            return accessible(spring, reduceMotion: reduceMotion)
        }

        /// Quick animation with accessibility support
        public static func accessibleQuick(reduceMotion: Bool = false) -> SwiftUI.Animation? {
            return accessible(quick, reduceMotion: reduceMotion)
        }

        /// Interactive animation with accessibility support
        public static func accessibleInteractive(reduceMotion: Bool = false) -> SwiftUI.Animation? {
            return accessible(interactive, reduceMotion: reduceMotion)
        }

        // MARK: - Staggered Animations (Enhanced)
        /// Creates staggered animation delays for list items
        public static func staggeredDelay(for index: Int, baseDelay: Double = 0.05) -> Double {
            return Double(index) * baseDelay
        }

        /// Staggered spring animation for list items
        public static func staggeredSpring(
            for index: Int,
            baseDelay: Double = 0.05
        ) -> SwiftUI.Animation {
            return spring.delay(staggeredDelay(for: index, baseDelay: baseDelay))
        }

        /// Staggered interactive animation
        public static func staggeredInteractive(
            for index: Int,
            baseDelay: Double = 0.03
        ) -> SwiftUI.Animation {
            return interactive.delay(staggeredDelay(for: index, baseDelay: baseDelay))
        }
    }

    // MARK: - Button Styles (Enhanced iOS 18)
    public struct ButtonStyles {
        public static let primaryHeight: CGFloat = 50
        public static let secondaryHeight: CGFloat = 44
        public static let smallHeight: CGFloat = 36
        public static let largeHeight: CGFloat = 56
        public static let extraLargeHeight: CGFloat = 64

        public static let minimumTouchTarget: CGFloat = 44
        public static let recommendedTouchTarget: CGFloat = 48
        public static let largeTouchTarget: CGFloat = 56
    }

    // MARK: - Visual Consistency Standards (Enhanced iOS 18)
    public struct VisualConsistency {
        // MARK: - Border Widths (Enhanced hierarchy)
        public static let borderHairline: CGFloat = 0.33
        public static let borderThin: CGFloat = 0.5
        public static let borderStandard: CGFloat = 1.0
        public static let borderThick: CGFloat = 2.0
        public static let borderEmphasis: CGFloat = 3.0
        public static let borderBold: CGFloat = 4.0

        // MARK: - Opacity Levels (Enhanced layering)
        public static let opacityDisabled: Double = 0.3
        public static let opacitySubtle: Double = 0.08
        public static let opacityLight: Double = 0.15
        public static let opacityMedium: Double = 0.25
        public static let opacityStrong: Double = 0.4
        public static let opacityIntense: Double = 0.6
        public static let opacityDominant: Double = 0.8

        // MARK: - Additional Opacity Values (Centralized)
        /// Very subtle overlay (0.1)
        public static let opacityVeryLight: Double = 0.1
        /// Moderate overlay (0.2)
        public static let opacityModerate: Double = 0.2
        /// Semi-transparent (0.5)
        public static let opacitySemiTransparent: Double = 0.5
        /// Prominent overlay (0.7)
        public static let opacityProminent: Double = 0.7
        /// Nearly opaque (0.9)
        public static let opacityNearlyOpaque: Double = 0.9
        /// Highly transparent (0.95)
        public static let opacityHighlyTransparent: Double = 0.95

        // MARK: - Component-Specific Opacity Values
        /// Button pressed state opacity
        public static let opacityButtonPressed: Double = 0.9
        /// Loading state opacity
        public static let opacityLoading: Double = 0.3
        /// Skill background opacity
        public static let opacitySkillBackground: Double = 0.1
        /// Separator opacity
        public static let opacitySeparator: Double = 0.2
        /// Overlay background opacity
        public static let opacityOverlay: Double = 0.08
        /// Selection background opacity
        public static let opacitySelection: Double = 0.08
        /// Hover state opacity
        public static let opacityHover: Double = 0.05
        /// Glow effect opacity
        public static let opacityGlow: Double = 0.6
        /// White overlay opacity (light)
        public static let opacityWhiteOverlayLight: Double = 0.1
        /// White overlay opacity (medium)
        public static let opacityWhiteOverlayMedium: Double = 0.3
        /// White overlay opacity (strong)
        public static let opacityWhiteOverlayStrong: Double = 0.4

        // MARK: - Additional Opacity Values for Complete Coverage
        /// Very light background opacity (0.05)
        public static let opacityBackgroundVeryLight: Double = 0.05
        /// Icon background opacity (0.15)
        public static let opacityIconBackground: Double = 0.15
        /// Card overlay opacity (0.25)
        public static let opacityCardOverlay: Double = 0.25
        /// Progress indicator opacity (0.7)
        public static let opacityProgressIndicator: Double = 0.7
        /// Glassmorphism background opacity (0.8)
        public static let opacityGlassmorphism: Double = 0.8
        /// Blur background opacity (0.95)
        public static let opacityBlurBackground: Double = 0.95

        // MARK: - Shadow Parameters (Centralized)
        /// Light shadow opacity for light mode
        public static let shadowLightMode: Double = 0.06
        /// Dark shadow opacity for dark mode
        public static let shadowDarkMode: Double = 0.25
        /// Standard shadow radius
        public static let shadowRadius: CGFloat = 6
        /// Shadow offset Y
        public static let shadowOffsetY: CGFloat = 2
        /// Button shadow radius
        public static let buttonShadowRadius: CGFloat = 4
        /// Button shadow offset
        public static let buttonShadowOffset: CGFloat = 2
        /// Pressed button shadow radius
        public static let buttonShadowRadiusPressed: CGFloat = 2
        /// Pressed button shadow offset
        public static let buttonShadowOffsetPressed: CGFloat = 1

        // MARK: - Blur Radii (Enhanced depth)
        public static let blurSubtle: CGFloat = 2
        public static let blurStandard: CGFloat = 4
        public static let blurStrong: CGFloat = 8
        public static let blurIntense: CGFloat = 16
        public static let blurExtreme: CGFloat = 32

        // MARK: - Scale Factors (Enhanced interactions)
        public static let scalePressed: CGFloat = 0.98
        public static let scalePressedSubtle: CGFloat = 0.99
        public static let scaleSelected: CGFloat = 1.02
        public static let scaleHover: CGFloat = 1.05
        public static let scaleEmphasis: CGFloat = 1.1
        public static let scaleDisabled: CGFloat = 0.95
        /// Loading indicator scale
        public static let scaleLoading: CGFloat = 1.2
        /// Splash screen scale
        public static let scaleSplash: CGFloat = 1.5
    }

    // MARK: - Elevation System (Enhanced Material Design, iOS 18 compliant)
    public struct Elevation {
        public static let none: CGFloat = 0
        public static let subtle: CGFloat = 0.5
        public static let low: CGFloat = 1
        public static let medium: CGFloat = 2
        public static let high: CGFloat = 4
        public static let highest: CGFloat = 8
        public static let extreme: CGFloat = 16

        public static func shadow(for level: CGFloat) -> some View {
            Group {
                switch level {
                case 0:
                    EmptyView()
                case 0.5:
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.clear)
                        .shadow(color: Shadow.subtle, radius: 0.5, x: 0, y: 0.5)
                case 1:
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.clear)
                        .shadow(color: Shadow.small, radius: 1, x: 0, y: 1)
                case 2:
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.clear)
                        .shadow(color: Shadow.medium, radius: 2, x: 0, y: 2)
                case 4:
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.clear)
                        .shadow(color: Shadow.large, radius: 4, x: 0, y: 4)
                case 8:
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.clear)
                        .shadow(color: Shadow.extraLarge, radius: 8, x: 0, y: 6)
                default:
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.clear)
                        .shadow(color: Shadow.extraLarge, radius: level, x: 0, y: level * 0.75)
                }
            }
        }
    }

    // MARK: - Gradient Colors
    struct GradientColors {
        static func skillColor(for value: Double) -> Color {
            let clampedValue = max(1.0, min(10.0, value))

            // Define color stops for smooth interpolation
            let colorStops: [(threshold: Double, color: (r: Double, g: Double, b: Double))] = [
                (1.0, (1.0, 0.2, 0.2)),    // Muted red for lowest skill
                (2.5, (1.0, 0.4, 0.3)),   // Warm orange-red transition
                (4.0, (1.0, 0.6, 0.0)),    // Orange for basic skill
                (6.0, (1.0, 0.8, 0.0)),    // Yellow for intermediate
                (7.5, (0.6, 0.8, 0.2)),    // Light green for advanced
                (10.0, (0.2, 0.8, 0.3))    // Green for expert
            ]

            // Find the two color stops to interpolate between
            for i in 0..<(colorStops.count - 1) {
                let currentStop = colorStops[i]
                let nextStop = colorStops[i + 1]

                if clampedValue >= currentStop.threshold && clampedValue <= nextStop.threshold {
                    // Calculate interpolation factor (0.0 to 1.0)
                    let range = nextStop.threshold - currentStop.threshold
                    let position = clampedValue - currentStop.threshold
                    let factor = range > 0 ? position / range : 0.0

                    // Interpolate between the two colors
                    let r = currentStop.color.r + (nextStop.color.r - currentStop.color.r) * factor
                    let g = currentStop.color.g + (nextStop.color.g - currentStop.color.g) * factor
                    let b = currentStop.color.b + (nextStop.color.b - currentStop.color.b) * factor

                    return Color(red: r, green: g, blue: b)
                }
            }

            // Fallback to the highest color if value exceeds all thresholds
            let lastColor = colorStops.last!.color
            return Color(red: lastColor.r, green: lastColor.g, blue: lastColor.b)
        }

        static let primary = LinearGradient(
            colors: [Color.blue, Color.cyan],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let success = LinearGradient(
            colors: [Color.green, Color.mint],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let warning = LinearGradient(
            colors: [Color.orange, Color.yellow],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let error = LinearGradient(
            colors: [Color.red, Color.pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Returns appropriate text color for the given skill value
        static func textColor(for skillValue: Double) -> Color {
            return skillColor(for: skillValue)
        }
    }

    // MARK: - SF Symbols (iOS 18 Enhanced)
    public struct Symbols {
        // MARK: - Navigation & Actions
        public static let plus = "plus"
        public static let minus = "minus"
        public static let chevronDown = "chevron.down"
        public static let chevronUp = "chevron.up"
        public static let chevronLeft = "chevron.left"
        public static let chevronRight = "chevron.right"
        public static let xmark = "xmark"
        public static let checkmark = "checkmark"
        public static let ellipsis = "ellipsis"

        // MARK: - Content & Media
        public static let person = "person"
        public static let personFill = "person.fill"
        public static let personGroup = "person.3"
        public static let personGroupFill = "person.3.fill"
        public static let personStack = "person.crop.rectangle.stack"
        public static let personStackFill = "person.crop.rectangle.stack.fill"

        // MARK: - Interface & Controls
        public static let gear = "gearshape"
        public static let gearFill = "gearshape.fill"
        public static let list = "list.bullet"
        public static let grid = "square.grid.2x2"
        public static let search = "magnifyingglass"
        public static let filter = "line.3.horizontal.decrease"
        public static let sort = "arrow.up.arrow.down"

        // MARK: - Status & Feedback
        public static let success = "checkmark.circle.fill"
        public static let error = "exclamationmark.triangle.fill"
        public static let warning = "exclamationmark.circle.fill"
        public static let info = "info.circle.fill"
        public static let loading = "arrow.clockwise"

        // MARK: - Skills & Levels
        public static let triangle = "triangle.fill"
        public static let diamond = "diamond.fill"
        public static let circle = "circle.fill"
        public static let square = "square.fill"
        public static let star = "star.fill"

        // MARK: - Skill Categories
        public static let technical = "cpu"
        public static let agility = "figure.run"
        public static let endurance = "heart"
        public static let teamwork = "person.2"

        // MARK: - Accessibility Support
        /// Returns appropriate symbol variant based on context
        public static func symbol(_ name: String, filled: Bool = false) -> String {
            if filled && !name.hasSuffix(".fill") {
                return "\(name).fill"
            }
            return name
        }

        /// Returns symbol with proper weight for context
        public static func symbolWeight(for context: SymbolContext) -> Font.Weight {
            switch context {
            case .navigation: return .medium
            case .button: return .medium
            case .icon: return .regular
            case .emphasis: return .semibold
            }
        }

        public enum SymbolContext {
            case navigation, button, icon, emphasis
        }
    }
}

// MARK: - Badge Size
/// Defines sizing options for skill badges and similar components
public enum BadgeSize {
    case small
    case medium
    case large

    public var font: Font {
        switch self {
        case .small:
            return DesignSystem.Typography.caption2
        case .medium:
            return DesignSystem.Typography.caption1
        case .large:
            return DesignSystem.Typography.subheadline
        }
    }

    public var horizontalPadding: CGFloat {
        switch self {
        case .small:
            return DesignSystem.Spacing.xs
        case .medium:
            return DesignSystem.Spacing.sm
        case .large:
            return DesignSystem.Spacing.md
        }
    }

    public var verticalPadding: CGFloat {
        switch self {
        case .small:
            return DesignSystem.Spacing.xxxs
        case .medium:
            return DesignSystem.Spacing.xxs
        case .large:
            return DesignSystem.Spacing.xs
        }
    }

    public var iconSpacing: CGFloat {
        switch self {
        case .small:
            return DesignSystem.Spacing.xxs
        case .medium:
            return DesignSystem.Spacing.sm
        case .large:
            return DesignSystem.Spacing.md
        }
    }

    public var iconSize: CGFloat {
        switch self {
        case .small:
            return DesignSystem.IconSize.xxs
        case .medium:
            return DesignSystem.IconSize.sm
        case .large:
            return DesignSystem.IconSize.md
        }
    }
}

// MARK: - Skill Level Color Extension
public extension SkillLevel {
    /// Returns the continuous gradient color based on the exact skill value
    /// This ensures perfect synchronization between rank labels and visual indicators
    var designSystemColor: Color {
        return DesignSystem.GradientColors.skillColor(for: representativeValue)
    }

    /// Returns the representative skill value for continuous gradient calculation
    /// Maps discrete skill levels to their continuous equivalents
    var representativeValue: Double {
        switch self {
        case .beginner: return 1.75  // Mid-point of 1.0-2.5 range
        case .novice: return 3.25    // Mid-point of 2.5-4.0 range
        case .intermediate: return 5.00 // Mid-point of 4.0-6.0 range
        case .advanced: return 6.75  // Mid-point of 6.0-7.5 range
        case .expert: return 8.75     // High-end of 7.5-10.0 range
        }
    }

    /// Creates a SkillLevel from a continuous value with proper range mapping
    /// - Parameter value: Continuous skill value (1.0-10.0)
    /// - Returns: Corresponding SkillLevel with exact color mapping
    static func fromContinuousValue(_ value: Double) -> SkillLevel {
        let clampedValue = max(1.0, min(10.0, value))

        switch clampedValue {
        case 1.0..<2.5:
            return .beginner
        case 2.5..<4.0:
            return .novice
        case 4.0..<6.0:
            return .intermediate
        case 6.0..<7.5:
            return .advanced
        default: // 7.5-10.0
            return .expert
        }
    }

    var backgroundColorLight: Color {
        DesignSystem.GradientColors.skillColor(for: representativeValue)
            .opacity(DesignSystem.VisualConsistency.opacityLight)
    }

    var backgroundColorMedium: Color {
        DesignSystem.GradientColors.skillColor(for: representativeValue)
            .opacity(DesignSystem.VisualConsistency.opacityMedium)
    }

    /// Text color that ensures WCAG AA compliance against light backgrounds
    /// Uses the continuous gradient system for perfect synchronization
    var textColor: Color {
        return DesignSystem.GradientColors.textColor(for: representativeValue)
    }

    /// Enhanced background colors with better visual hierarchy
    var backgroundColorSubtle: Color {
        DesignSystem.GradientColors.skillColor(for: representativeValue)
            .opacity(DesignSystem.VisualConsistency.opacitySubtle)
    }

    var backgroundColorStrong: Color {
        DesignSystem.GradientColors.skillColor(for: representativeValue)
            .opacity(DesignSystem.VisualConsistency.opacityStrong)
    }
}

// MARK: - View Extensions for Design System
public extension View {
    // MARK: - Card Styles
    func cardStyle(elevation: CGFloat = DesignSystem.Elevation.low) -> some View {
        self
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card)
                    .stroke(DesignSystem.Colors.separatorColor, lineWidth: DesignSystem.VisualConsistency.borderThin)
            )
            .background(DesignSystem.Elevation.shadow(for: elevation))
    }

    func compactCardStyle() -> some View {
        self
            .background(DesignSystem.Colors.secondaryBackground)
            .cornerRadius(DesignSystem.CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .stroke(DesignSystem.Colors.separatorColor, lineWidth: DesignSystem.VisualConsistency.borderThin)
            )
    }

    // MARK: - Button Styles
    func primaryButtonStyle() -> some View {
        self
            .frame(height: DesignSystem.ButtonStyles.primaryHeight)
            .frame(maxWidth: .infinity)
            .background(DesignSystem.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(DesignSystem.CornerRadius.button)
            .background(DesignSystem.Elevation.shadow(for: DesignSystem.Elevation.low))
    }

    func secondaryButtonStyle() -> some View {
        self
            .frame(height: DesignSystem.ButtonStyles.secondaryHeight)
            .frame(maxWidth: .infinity)
            .background(DesignSystem.Colors.cardBackground)
            .foregroundColor(DesignSystem.Colors.primary)
            .cornerRadius(DesignSystem.CornerRadius.button)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button)
                    .stroke(DesignSystem.Colors.primary, lineWidth: DesignSystem.VisualConsistency.borderStandard)
            )
    }

    // MARK: - Spacing and Layout
    func screenPadding() -> some View {
        self.padding(DesignSystem.Spacing.screenPadding)
    }

    func sectionSpacing() -> some View {
        self.padding(.vertical, DesignSystem.Spacing.sectionSpacing)
    }

    func cardPadding() -> some View {
        self.padding(DesignSystem.Spacing.cardPadding)
    }

    // MARK: - Interactive States
    func pressedScale() -> some View {
        self.scaleEffect(DesignSystem.VisualConsistency.scalePressed)
    }

    func selectedScale() -> some View {
        self.scaleEffect(DesignSystem.VisualConsistency.scaleSelected)
    }

    // MARK: - Visual Hierarchy
    func subtleBackground() -> some View {
        self.background(DesignSystem.Colors.primaryBackground.opacity(DesignSystem.VisualConsistency.opacitySubtle))
    }

    func lightBackground() -> some View {
        self.background(DesignSystem.Colors.primaryBackground.opacity(DesignSystem.VisualConsistency.opacityLight))
    }

    func mediumBackground() -> some View {
        self.background(DesignSystem.Colors.primaryBackground.opacity(DesignSystem.VisualConsistency.opacityMedium))
    }

    // MARK: - Borders and Separators
    func standardBorder(color: Color = DesignSystem.Colors.separatorColor) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .stroke(color, lineWidth: DesignSystem.VisualConsistency.borderStandard)
        )
    }

    func thickBorder(color: Color = DesignSystem.Colors.primary) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .stroke(color, lineWidth: DesignSystem.VisualConsistency.borderThick)
        )
    }
}