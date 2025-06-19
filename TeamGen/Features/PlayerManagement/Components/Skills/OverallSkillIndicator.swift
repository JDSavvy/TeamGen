import SwiftUI

// MARK: - Overall Skill Indicator Component
/// A comprehensive indicator showing overall skill with perfect synchronization between visual and text elements
struct OverallSkillIndicator: View {
    let overallSkill: Double
    let style: IndicatorStyle
    let showLabel: Bool
    let showValue: Bool
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    init(
        overallSkill: Double,
        style: IndicatorStyle = .standard,
        showLabel: Bool = true,
        showValue: Bool = true
    ) {
        self.overallSkill = overallSkill
        self.style = style
        self.showLabel = showLabel
        self.showValue = showValue
    }
    
    var body: some View {
        switch style {
        case .compact:
            compactView
        case .standard:
            standardView
        case .detailed:
            detailedView
        case .minimal:
            minimalView
        }
    }
    
    // MARK: - Style Variants
    
    private var compactView: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            // Skill indicator dot with continuous gradient
            Circle()
                .fill(continuousColor)
                .frame(width: 8, height: 8)
            
            if showValue {
                Text(String(format: "%.1f", overallSkill))
                    .font(DesignSystem.Typography.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(continuousTextColor)
            }
            
            if showLabel {
                Text(skillLevel.displayName)
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(continuousTextColor)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }
    
    private var standardView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack {
                if showLabel {
                    Text("Overall Skill")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
                
                if showValue {
                    Text(String(format: "%.1f", overallSkill))
                        .font(DesignSystem.Typography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(continuousTextColor)
                }
            }
            
            // Skill level badge with synchronized color
            SkillLevelBadge(skillLevel: skillLevel, size: .small)
            
            // Progress bar with continuous gradient
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.compact)
                        .fill(DesignSystem.Colors.separatorColor.opacity(DesignSystem.VisualConsistency.opacitySeparator))
                        .frame(height: DesignSystem.ComponentSize.progressBarCompact)
                    
                    // Filled portion with gradient color
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.compact)
                        .fill(continuousColor)
                        .frame(
                            width: geometry.size.width * fillPercentage,
                            height: DesignSystem.ComponentSize.progressBarCompact
                        )
                        .animation(DesignSystem.Animation.accessible(DesignSystem.Animation.standard, reduceMotion: reduceMotion), value: overallSkill)
                    
                    // Subtle highlight overlay
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.compact)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(DesignSystem.VisualConsistency.opacityWhiteOverlayMedium),
                                    Color.white.opacity(DesignSystem.VisualConsistency.opacityWhiteOverlayLight),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(
                            width: geometry.size.width * fillPercentage,
                            height: DesignSystem.ComponentSize.progressBarCompact
                        )
                }
            }
            .frame(height: DesignSystem.ComponentSize.progressBarCompact)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }
    
    private var detailedView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Header with value and level
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxxs) {
                    if showLabel {
                        Text("Overall Skill")
                            .font(DesignSystem.Typography.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                    }
                    
                    // Skill level badge with synchronized color
                    SkillLevelBadge(skillLevel: skillLevel, size: .medium)
                }
                
                Spacer()
                
                if showValue {
                    // Clean skill value display - modern, minimalist approach
                    Text(String(format: "%.1f", overallSkill))
                        .font(DesignSystem.Typography.title1)
                        .fontWeight(.bold)
                        .foregroundColor(continuousTextColor)
                        .monospacedDigit()
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                .fill(continuousBackgroundColor)
                                .shadow(
                                    color: continuousColor.opacity(0.2),
                                    radius: 4,
                                    x: 0,
                                    y: 2
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                .strokeBorder(
                                    continuousColor.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                }
            }
            
            // Enhanced progress visualization
            VStack(spacing: DesignSystem.Spacing.xs) {
                // Progress bar with continuous gradient
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track with subtle gradient
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.progressBar)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        DesignSystem.Colors.separatorColor.opacity(DesignSystem.VisualConsistency.opacitySkillBackground),
                                        DesignSystem.Colors.separatorColor.opacity(DesignSystem.VisualConsistency.opacitySeparator)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: DesignSystem.ComponentSize.progressBarStandard)
                        
                        // Filled portion with gradient color and glow effect
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.progressBar)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        continuousColor,
                                        continuousColor.opacity(DesignSystem.VisualConsistency.opacityDominant)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(
                                width: geometry.size.width * fillPercentage,
                                height: DesignSystem.ComponentSize.progressBarStandard
                            )
                            .animation(DesignSystem.Animation.accessible(DesignSystem.Animation.standard, reduceMotion: reduceMotion), value: overallSkill)
                        
                        // Highlight overlay
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.progressBar)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(DesignSystem.VisualConsistency.opacityWhiteOverlayStrong),
                                        Color.white.opacity(DesignSystem.VisualConsistency.opacityWhiteOverlayMedium),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(
                                width: geometry.size.width * fillPercentage,
                                height: DesignSystem.ComponentSize.progressBarStandard
                            )
                    }
                }
                .frame(height: DesignSystem.ComponentSize.progressBarStandard)
                
                // Scale markers
                HStack {
                    ForEach([1, 2.5, 5, 7.5, 10], id: \.self) { marker in
                        VStack(spacing: DesignSystem.Spacing.xxxs) {
                            Rectangle()
                                .fill(DesignSystem.Colors.tertiaryText)
                                .frame(width: DesignSystem.ComponentSize.scaleMarkerWidth, height: DesignSystem.ComponentSize.scaleMarkerHeight)
                            
                            Text(marker == 10 ? "10" : String(format: "%.1f", marker))
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(DesignSystem.Colors.tertiaryText)
                        }
                        
                        if marker != 10 {
                            Spacer()
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }
    
    private var minimalView: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            // Small skill indicator
            Circle()
                .fill(continuousColor)
                .frame(width: DesignSystem.ComponentSize.smallIndicator, height: DesignSystem.ComponentSize.smallIndicator)
            
            if showValue {
                Text(String(format: "%.1f", overallSkill))
                    .font(DesignSystem.Typography.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(continuousTextColor)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }
    
    // MARK: - Computed Properties
    
    private var skillLevel: SkillLevel {
        PlayerSkillPresentation.skillLevel(from: overallSkill)
    }
    
    private var continuousColor: Color {
        PlayerSkillPresentation.rankColor(overallSkill)
    }
    
    private var continuousTextColor: Color {
        PlayerSkillPresentation.textColor(for: overallSkill)
    }
    
    private var continuousBackgroundColor: Color {
        PlayerSkillPresentation.backgroundColorLight(for: overallSkill)
    }
    
    private var fillPercentage: Double {
        return overallSkill / 10.0
    }
    
    private var accessibilityDescription: String {
        let levelText = skillLevel.displayName
        let valueText = String(format: "%.1f", overallSkill)
        return "Overall skill: \(valueText), \(levelText) level"
    }
}

// MARK: - Indicator Style
enum IndicatorStyle {
    case minimal    // Just dot and value
    case compact    // Dot, value, and label in a row
    case standard   // Label, badge, and progress bar
    case detailed   // Full visualization with scale markers
}

// MARK: - Preview
#Preview("Overall Skill Indicators") {
    VStack(spacing: DesignSystem.Spacing.lg) {
        // Different skill levels
        ForEach([2.3, 4.7, 6.1, 8.4, 9.8], id: \.self) { skill in
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("Skill Level: \(String(format: "%.1f", skill))")
                    .font(DesignSystem.Typography.title3)
                
                OverallSkillIndicator(overallSkill: skill, style: .detailed)
                
                HStack {
                    OverallSkillIndicator(overallSkill: skill, style: .compact)
                    Spacer()
                    OverallSkillIndicator(overallSkill: skill, style: .minimal)
                }
            }
            .padding()
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.medium)
        }
    }
    .padding()
} 