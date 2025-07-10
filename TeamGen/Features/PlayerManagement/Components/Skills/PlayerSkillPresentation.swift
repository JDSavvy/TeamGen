import SwiftUI

// MARK: - Player Skill Presentation

enum PlayerSkillPresentation {
    /// Returns continuous gradient color for any rank value (1.0-10.0)
    static func rankColor(_ rank: Double) -> Color {
        DesignSystem.GradientColors.skillColor(for: rank)
    }

    /// Returns continuous gradient color for individual skill values (1-10)
    static func skillColor(for skillValue: Int) -> Color {
        DesignSystem.GradientColors.skillColor(for: Double(skillValue))
    }

    /// Returns WCAG-compliant text color synchronized with the skill value
    static func textColor(for skillValue: Double) -> Color {
        DesignSystem.GradientColors.textColor(for: skillValue)
    }

    /// Returns skill level text description with continuous gradient mapping
    static func skillLevelText(_ overallRank: Double) -> String {
        SkillLevel.fromContinuousValue(overallRank).rawValue
    }

    /// Returns SkillLevel enum mapped from continuous value for perfect synchronization
    static func skillLevel(from overallRank: Double) -> SkillLevel {
        SkillLevel.fromContinuousValue(overallRank)
    }

    /// Returns background color with appropriate opacity for skill indicators
    static func backgroundColorLight(for skillValue: Double) -> Color {
        DesignSystem.GradientColors.skillColor(for: skillValue)
            .opacity(DesignSystem.VisualConsistency.opacityLight)
    }

    /// Returns background color with medium opacity for skill indicators
    static func backgroundColorMedium(for skillValue: Double) -> Color {
        DesignSystem.GradientColors.skillColor(for: skillValue)
            .opacity(DesignSystem.VisualConsistency.opacityMedium)
    }
}
