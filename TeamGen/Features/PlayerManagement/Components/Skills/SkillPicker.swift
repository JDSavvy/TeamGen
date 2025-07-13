import SwiftUI

// MARK: - Modern Skill Picker (iOS 18 Design Standards)

/// Enhanced skill picker component following Apple's latest HIG standards
/// Features modern visual design, improved accessibility, and seamless animations
struct SkillPicker: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int> = 1 ... 10

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dependencies) private var dependencies
    @Environment(\.colorScheme) private var colorScheme

    @State private var isDragging = false
    @State private var lastHapticValue = 0

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Enhanced header with skill level indicator
            skillHeader

            // Modern skill value display
            skillValueDisplay

            // Enhanced slider with modern styling
            modernSlider

            // Skill level description
            skillLevelDescription
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) skill picker")
        .accessibilityValue("Level \(value) out of 10, \(skillLevelText)")
    }

    // MARK: - Header Section

    private var skillHeader: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            // Skill category with icon
            Label {
                Text(title)
                    .font(DesignSystem.Typography.headlineEmphasized)
                    .foregroundStyle(DesignSystem.Colors.primaryText)
            } icon: {
                Image(systemName: skillIcon)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(skillColor)
                    .symbolRenderingMode(.hierarchical)
            }

            Spacer()

            // Quick level indicators
            skillLevelIndicators
        }
    }

    // MARK: - Skill Value Display

    private var skillValueDisplay: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Large value display
            HStack(spacing: DesignSystem.Spacing.xs) {
                Text("\(value)")
                    .font(DesignSystem.Typography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(skillColor)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(DesignSystem.Animation.spring, value: value)

                Text("/ 10")
                    .font(DesignSystem.Typography.title3)
                    .foregroundStyle(DesignSystem.Colors.tertiaryText)
            }

            Spacer()

            // Skill badge
            skillBadge
        }
    }

    private var skillBadge: some View {
        Text(skillLevelText)
            .font(DesignSystem.Typography.caption1)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xxs)
            .background(
                Capsule()
                    .fill(skillColor.gradient)
                    .shadow(
                        color: skillColor.opacity(0.3),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
            )
            .animation(DesignSystem.Animation.spring, value: value)
    }

    // MARK: - Modern Slider

    private var modernSlider: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Slider track with custom styling
            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { newValue in
                        let rounded = Int(newValue.rounded())
                        if rounded != value {
                            value = rounded
                            provideTactileFeedback(for: rounded)
                        }
                    }
                ),
                in: Double(range.lowerBound) ... Double(range.upperBound),
                step: 1.0
            ) {
                Text(title)
                    .accessibilityHidden(true)
            } minimumValueLabel: {
                skillRangeLabel(range.lowerBound)
            } maximumValueLabel: {
                skillRangeLabel(range.upperBound)
            } onEditingChanged: { editing in
                withAnimation(DesignSystem.Animation.spring) {
                    isDragging = editing
                }
            }
            .tint(skillColor)
            .scaleEffect(isDragging ? 1.02 : 1.0)
            .animation(DesignSystem.Animation.spring, value: isDragging)

            // Value markers for precise selection
            valueMarkers
        }
    }

    private func skillRangeLabel(_ value: Int) -> some View {
        Text("\(value)")
            .font(DesignSystem.Typography.caption1)
            .fontWeight(.medium)
            .foregroundStyle(DesignSystem.Colors.secondaryText)
            .frame(minWidth: DesignSystem.ComponentSize.minRowHeight)
    }

    private var valueMarkers: some View {
        HStack {
            ForEach(range, id: \.self) { markerValue in
                Circle()
                    .fill(markerValue <= value ? skillColor : DesignSystem.Colors.separatorColor)
                    .frame(width: DesignSystem.ComponentSize.smallIndicator, height: DesignSystem.ComponentSize.smallIndicator)
                    .scaleEffect(markerValue == value ? 1.5 : 1.0)
                    .animation(
                        DesignSystem.Animation.accessible(
                            DesignSystem.Animation.interactive.delay(Double(markerValue) * 0.008),
                            reduceMotion: reduceMotion
                        ),
                        value: value
                    )
            }
        }
    }

    // MARK: - Skill Level Indicators

    private var skillLevelIndicators: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            ForEach(1 ... 5, id: \.self) { level in
                Circle()
                    .fill(level <= skillLevel ? skillColor : DesignSystem.Colors.fillSecondary)
                    .frame(width: DesignSystem.ComponentSize.standardIndicator, height: DesignSystem.ComponentSize.standardIndicator)
                    .scaleEffect(level == skillLevel ? 1.2 : 1.0)
                    .animation(
                        DesignSystem.Animation.accessible(
                            DesignSystem.Animation.snappy.delay(Double(level) * 0.015),
                            reduceMotion: reduceMotion
                        ),
                        value: value
                    )
            }
        }
        .accessibilityHidden(true)
    }

    private var skillLevelDescription: some View {
        Text(skillDescription)
            .font(DesignSystem.Typography.caption1)
            .foregroundStyle(DesignSystem.Colors.secondaryText)
            .animation(DesignSystem.Animation.standard, value: value)
    }

    // MARK: - Computed Properties

    private var skillColor: Color {
        DesignSystem.GradientColors.skillColor(for: Double(value))
    }

    private var skillLevel: Int {
        min(5, max(1, (value + 1) / 2))
    }

    private var skillLevelText: String {
        switch value {
        case 1 ... 2: String(localized: "Beginner")
        case 3 ... 4: String(localized: "Novice")
        case 5 ... 6: String(localized: "Intermediate")
        case 7 ... 8: String(localized: "Advanced")
        case 9 ... 10: String(localized: "Expert")
        default: String(localized: "Unknown")
        }
    }

    private var skillDescription: String {
        switch value {
        case 1 ... 2: String(localized: "Just starting out, learning the basics")
        case 3 ... 4: String(localized: "Getting comfortable with fundamentals")
        case 5 ... 6: String(localized: "Solid foundation, developing consistency")
        case 7 ... 8: String(localized: "Strong skills, ready for challenges")
        case 9 ... 10: String(localized: "Exceptional ability, natural talent")
        default: ""
        }
    }

    private var skillIcon: String {
        switch title.lowercased() {
        case "technical": "cpu"
        case "agility": "figure.run"
        case "endurance": "heart.fill"
        case "teamwork": "person.2.fill"
        default: "star.fill"
        }
    }

    // MARK: - Haptic Feedback

    private func provideTactileFeedback(for newValue: Int) {
        if abs(newValue - lastHapticValue) >= 1 {
            Task {
                await dependencies.hapticService.selection()
            }
            lastHapticValue = newValue
        }
    }
}

// MARK: - Enhanced Multi-Skill Picker

struct MultiSkillPicker: View {
    @Binding var technicalSkill: Int
    @Binding var agilityLevel: Int
    @Binding var enduranceLevel: Int
    @Binding var teamworkRating: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var overallRating: Double {
        Double(technicalSkill + agilityLevel + enduranceLevel + teamworkRating) / 4.0
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Enhanced overall skill display
            overallSkillDisplay

            // Individual skill pickers with modern design
            skillPickersSection
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Multi-skill picker")
    }

    // MARK: - Overall Skill Display

    private var overallSkillDisplay: some View {
        EnhancedCard(style: .prominent, elevation: .medium) {
            VStack(spacing: DesignSystem.Spacing.md) {
                // Header
                HStack {
                    Label("Overall Rating", systemImage: "star.circle.fill")
                        .font(DesignSystem.Typography.headlineEmphasized)
                        .foregroundStyle(DesignSystem.Colors.primaryText)

                    Spacer()

                    // Quick visual indicator
                    overallRatingIndicator
                }

                // Large rating display
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text(String(format: "%.1f", overallRating))
                        .font(DesignSystem.Typography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(overallRatingColor)
                        .monospacedDigit()
                        .contentTransition(.numericText())

                    Text("/ 10")
                        .font(DesignSystem.Typography.title2)
                        .foregroundStyle(DesignSystem.Colors.tertiaryText)

                    Spacer()

                    // Rating badge
                    Text(overallSkillLevelText)
                        .font(DesignSystem.Typography.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(
                            Capsule()
                                .fill(overallRatingColor.gradient)
                        )
                }

                // Progress bar
                overallRatingProgressBar
            }
            .animation(DesignSystem.Animation.spring, value: overallRating)
        }
    }

    private var overallRatingIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            ForEach(1 ... 10, id: \.self) { level in
                Circle()
                    .fill(Double(level) <= overallRating ? overallRatingColor : DesignSystem.Colors.fillSecondary)
                    .frame(width: DesignSystem.ComponentSize.smallIndicator, height: DesignSystem.ComponentSize.smallIndicator)
                    .scaleEffect(Double(level) <= overallRating ? 1.2 : 1.0)
                    .animation(
                        DesignSystem.Animation.accessible(
                            DesignSystem.Animation.interactive.delay(Double(level) * 0.005),
                            reduceMotion: reduceMotion
                        ),
                        value: overallRating
                    )
            }
        }
        .accessibilityHidden(true)
    }

    private var overallRatingProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(DesignSystem.Colors.fillSecondary)
                    .frame(height: DesignSystem.ComponentSize.progressBarStandard)

                // Progress fill
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(overallRatingColor.gradient)
                    .frame(
                        width: geometry.size.width * (overallRating / 10.0),
                        height: DesignSystem.ComponentSize.progressBarStandard
                    )
                    .animation(DesignSystem.Animation.spring, value: overallRating)
            }
        }
        .frame(height: DesignSystem.ComponentSize.progressBarStandard)
    }

    // MARK: - Skill Pickers Section

    private var skillPickersSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            SkillPicker(title: String(localized: "Technical"), value: $technicalSkill)
            SkillPicker(title: String(localized: "Agility"), value: $agilityLevel)
            SkillPicker(title: String(localized: "Endurance"), value: $enduranceLevel)
            SkillPicker(title: String(localized: "Teamwork"), value: $teamworkRating)
        }
    }

    // MARK: - Computed Properties

    private var overallRatingColor: Color {
        DesignSystem.GradientColors.skillColor(for: overallRating)
    }

    private var overallSkillLevelText: String {
        switch overallRating {
        case 1.0 ..< 2.5: String(localized: "Beginner")
        case 2.5 ..< 5.0: String(localized: "Novice")
        case 5.0 ..< 7.5: String(localized: "Intermediate")
        case 7.5 ..< 9.0: String(localized: "Advanced")
        default: String(localized: "Expert")
        }
    }
}

// MARK: - Preview

#if DEBUG
    struct SkillPicker_Previews: PreviewProvider {
        static var previews: some View {
            VStack(spacing: DesignSystem.Spacing.xl) {
                // Single skill picker
                SkillPicker(title: "Technical", value: .constant(7))

                Divider()

                // Multi-skill picker
                MultiSkillPicker(
                    technicalSkill: .constant(8),
                    agilityLevel: .constant(6),
                    enduranceLevel: .constant(7),
                    teamworkRating: .constant(9)
                )
            }
            .padding()
            .previewDisplayName("Modern Skill Pickers")
        }
    }
#endif
