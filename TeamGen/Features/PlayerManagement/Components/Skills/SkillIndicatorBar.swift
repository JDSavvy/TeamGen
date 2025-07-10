import SwiftUI

// MARK: - Skill Indicator Bar Component

/// A visual indicator showing individual skill levels with continuous gradient colors
struct SkillIndicatorBar: View {
    let skillName: String
    let skillValue: Int
    let maxValue: Int
    let showLabel: Bool
    let size: IndicatorSize

    init(
        skillName: String,
        skillValue: Int,
        maxValue: Int = 10,
        showLabel: Bool = true,
        size: IndicatorSize = .medium
    ) {
        self.skillName = skillName
        self.skillValue = skillValue
        self.maxValue = maxValue
        self.showLabel = showLabel
        self.size = size
    }

    var body: some View {
        VStack(alignment: .leading, spacing: size.spacing) {
            if showLabel {
                HStack {
                    Text(skillName)
                        .font(size.labelFont)
                        .foregroundColor(DesignSystem.Colors.primaryText)

                    Spacer()

                    Text("\(skillValue)")
                        .font(size.valueFont)
                        .fontWeight(.medium)
                        .foregroundColor(PlayerSkillPresentation.textColor(for: Double(skillValue)))
                }
            }

            // Skill bar with continuous gradient
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                        .fill(DesignSystem.Colors.separatorColor.opacity(0.2))
                        .frame(height: size.barHeight)

                    // Filled portion with gradient color
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                        .fill(PlayerSkillPresentation.skillColor(for: skillValue))
                        .frame(
                            width: geometry.size.width * fillPercentage,
                            height: size.barHeight
                        )
                        .accessibleAnimation(DesignSystem.Animation.standard, value: skillValue)

                    // Subtle highlight overlay
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(
                            width: geometry.size.width * fillPercentage,
                            height: size.barHeight
                        )
                }
            }
            .frame(height: size.barHeight)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(skillName): \(skillValue) out of \(maxValue)")
        .accessibilityValue("Skill level: \(PlayerSkillPresentation.skillLevelText(Double(skillValue)))")
    }

    // MARK: - Computed Properties

    private var fillPercentage: Double {
        guard maxValue > 0 else { return 0 }
        return Double(skillValue) / Double(maxValue)
    }
}

// MARK: - Skill Indicator Dots Component

/// A compact dot-based indicator for skill levels
struct SkillIndicatorDots: View {
    let skillValue: Int
    let maxValue: Int
    let size: IndicatorSize

    init(skillValue: Int, maxValue: Int = 10, size: IndicatorSize = .small) {
        self.skillValue = skillValue
        self.maxValue = maxValue
        self.size = size
    }

    var body: some View {
        HStack(spacing: size.dotSpacing) {
            ForEach(1 ... maxValue, id: \.self) { index in
                Circle()
                    .fill(dotColor(for: index))
                    .frame(width: size.dotSize, height: size.dotSize)
                    .scaleEffect(index <= skillValue ? 1.0 : 0.7)
                    .animation(DesignSystem.Animation.staggeredSpring(for: index, baseDelay: 0.02), value: skillValue)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Skill level: \(skillValue) out of \(maxValue)")
    }

    private func dotColor(for index: Int) -> Color {
        if index <= skillValue {
            PlayerSkillPresentation.skillColor(for: index)
        } else {
            DesignSystem.Colors.separatorColor.opacity(0.3)
        }
    }
}

// MARK: - Indicator Size Configuration

enum IndicatorSize {
    case small
    case medium
    case large

    var barHeight: CGFloat {
        switch self {
        case .small: 4
        case .medium: 6
        case .large: 8
        }
    }

    var cornerRadius: CGFloat {
        barHeight / 2
    }

    var spacing: CGFloat {
        switch self {
        case .small: DesignSystem.Spacing.xxs
        case .medium: DesignSystem.Spacing.xs
        case .large: DesignSystem.Spacing.sm
        }
    }

    var labelFont: Font {
        switch self {
        case .small: DesignSystem.Typography.caption2
        case .medium: DesignSystem.Typography.caption1
        case .large: DesignSystem.Typography.subheadline
        }
    }

    var valueFont: Font {
        switch self {
        case .small: DesignSystem.Typography.caption1
        case .medium: DesignSystem.Typography.subheadline
        case .large: DesignSystem.Typography.body
        }
    }

    var dotSize: CGFloat {
        switch self {
        case .small: 6
        case .medium: 8
        case .large: 10
        }
    }

    var dotSpacing: CGFloat {
        switch self {
        case .small: 2
        case .medium: 3
        case .large: 4
        }
    }
}

// MARK: - Preview

#Preview("Skill Indicator Bars") {
    VStack(spacing: DesignSystem.Spacing.md) {
        SkillIndicatorBar(skillName: "Technical", skillValue: 8)
        SkillIndicatorBar(skillName: "Agility", skillValue: 6)
        SkillIndicatorBar(skillName: "Endurance", skillValue: 4)
        SkillIndicatorBar(skillName: "Teamwork", skillValue: 9)
    }
    .padding()
}

#Preview("Skill Indicator Dots") {
    VStack(spacing: DesignSystem.Spacing.md) {
        SkillIndicatorDots(skillValue: 8)
        SkillIndicatorDots(skillValue: 6)
        SkillIndicatorDots(skillValue: 4)
        SkillIndicatorDots(skillValue: 9)
    }
    .padding()
}
