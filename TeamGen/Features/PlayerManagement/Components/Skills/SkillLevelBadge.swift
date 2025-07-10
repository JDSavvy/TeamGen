import SwiftUI

// MARK: - Skill Level Badge Component
struct SkillLevelBadge: View {
    let skillLevel: SkillLevel
    let size: BadgeSize

    init(skillLevel: SkillLevel, size: BadgeSize = .small) {
        self.skillLevel = skillLevel
        self.size = size
    }

    var body: some View {
        HStack(spacing: size.iconSpacing) {
            // Shape indicator for accessibility (color-blind support)
            skillLevelIcon
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundColor(continuousTextColor)

            Text(skillLevel.displayName)
                .font(size.font)
                .foregroundColor(continuousTextColor)
        }
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(
            Capsule()
                .fill(continuousBackgroundColor)
        )
        .overlay(
            Capsule()
                .strokeBorder(
                    continuousColor.opacity(DesignSystem.VisualConsistency.opacityMedium),
                    lineWidth: DesignSystem.VisualConsistency.borderThin
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Skill level: \(skillLevel.displayName)")
        .accessibilityValue(skillLevel.accessibilityDescription)
    }

    // MARK: - Continuous Gradient Colors
    /// Uses the skill level's representative value for perfect gradient synchronization
    private var continuousColor: Color {
        skillLevel.designSystemColor
    }

    private var continuousTextColor: Color {
        skillLevel.textColor
    }

    private var continuousBackgroundColor: Color {
        skillLevel.backgroundColorLight
    }

    // MARK: - Skill Level Icon (Shape Differentiation)
    private var skillLevelIcon: Image {
        switch skillLevel {
        case .beginner:
            return Image(systemName: "triangle.fill")
        case .novice:
            return Image(systemName: "diamond.fill")
        case .intermediate:
            return Image(systemName: "circle.fill")
        case .advanced:
            return Image(systemName: "square.fill")
        case .expert:
            return Image(systemName: "star.fill")
        }
    }
}



