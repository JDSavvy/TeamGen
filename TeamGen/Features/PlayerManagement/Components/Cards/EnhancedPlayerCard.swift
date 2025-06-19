import SwiftUI

// MARK: - Enhanced Player Card Component
/// A comprehensive player card showcasing continuous gradient colors for skills and overall rating
struct EnhancedPlayerCard: View {
    let player: PlayerEntity
    let style: PlayerCardStyle
    let showDetailedSkills: Bool
    
    init(player: PlayerEntity, style: PlayerCardStyle = .detailed, showDetailedSkills: Bool = true) {
        self.player = player
        self.style = style
        self.showDetailedSkills = showDetailedSkills
    }
    
    var body: some View {
        EnhancedCard(style: CardStyle.default, elevation: CardElevation.low) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                // Header with player name and overall score
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxxs) {
                        Text(player.name)
                            .font(DesignSystem.Typography.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        
                        // Overall skill level badge with synchronized color
                        SkillLevelBadge(
                            skillLevel: PlayerSkillPresentation.skillLevel(from: player.skills.overall),
                            size: .small
                        )
                    }
                    
                    Spacer()
                    
                    // Overall skill indicator with perfect synchronization
                    OverallSkillIndicator(
                        overallSkill: player.skills.overall,
                        style: .compact,
                        showLabel: false,
                        showValue: true
                    )
                }
                
                if showDetailedSkills {
                    Divider()
                        .background(DesignSystem.Colors.separatorColor)
                    
                    // Individual skill indicators
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        SkillIndicatorBar(
                            skillName: "Technical",
                            skillValue: player.skills.technical,
                            size: .medium
                        )
                        
                        SkillIndicatorBar(
                            skillName: "Agility",
                            skillValue: player.skills.agility,
                            size: .medium
                        )
                        
                        SkillIndicatorBar(
                            skillName: "Endurance",
                            skillValue: player.skills.endurance,
                            size: .medium
                        )
                        
                        SkillIndicatorBar(
                            skillName: "Teamwork",
                            skillValue: player.skills.teamwork,
                            size: .medium
                        )
                    }
                }
            }
        }
        .accessibilityElement(children: AccessibilityChildBehavior.combine)
        .accessibilityLabel("Player: \(player.name), Overall skill: \(String(format: "%.1f", player.skills.overall))")
    }
}

// MARK: - Compact Player Score Component
/// A compact component showing just the player's overall score with gradient color
struct CompactPlayerScore: View {
    let player: PlayerEntity
    let size: ScoreSize
    
    init(player: PlayerEntity, size: ScoreSize = .medium) {
        self.player = player
        self.size = size
    }
    
    var body: some View {
        HStack(spacing: size.spacing) {
            // Skill indicator dot
            Circle()
                .fill(PlayerSkillPresentation.rankColor(player.skills.overall))
                .frame(width: size.dotSize, height: size.dotSize)
            
            // Player name
            Text(player.name)
                .font(size.nameFont)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .lineLimit(1)
            
            Spacer()
            
            // Score with synchronized color
            Text(String(format: "%.1f", player.skills.overall))
                .font(size.scoreFont)
                .fontWeight(.semibold)
                .foregroundColor(PlayerSkillPresentation.textColor(for: player.skills.overall))
        }
        .padding(.horizontal, size.padding)
        .padding(.vertical, size.padding * 0.75)
        .background(
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .fill(PlayerSkillPresentation.backgroundColorLight(for: player.skills.overall))
        )
        .overlay(
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .strokeBorder(
                    PlayerSkillPresentation.rankColor(player.skills.overall)
                        .opacity(DesignSystem.VisualConsistency.opacityLight),
                    lineWidth: DesignSystem.VisualConsistency.borderThin
                )
        )
        .accessibilityElement(children: AccessibilityChildBehavior.combine)
        .accessibilityLabel("\(player.name): \(String(format: "%.1f", player.skills.overall))")
    }
}

// MARK: - Player Card Style Configuration
enum PlayerCardStyle {
    case compact
    case detailed
    case minimal
}

// MARK: - Score Size Configuration
enum ScoreSize {
    case small
    case medium
    case large
    
    var dotSize: CGFloat {
        switch self {
        case .small: return 6
        case .medium: return 8
        case .large: return 10
        }
    }
    
    var spacing: CGFloat {
        switch self {
        case .small: return DesignSystem.Spacing.xs
        case .medium: return DesignSystem.Spacing.sm
        case .large: return DesignSystem.Spacing.md
        }
    }
    
    var padding: CGFloat {
        switch self {
        case .small: return DesignSystem.Spacing.xs
        case .medium: return DesignSystem.Spacing.sm
        case .large: return DesignSystem.Spacing.md
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small: return DesignSystem.CornerRadius.small
        case .medium: return DesignSystem.CornerRadius.medium
        case .large: return DesignSystem.CornerRadius.large
        }
    }
    
    var nameFont: Font {
        switch self {
        case .small: return DesignSystem.Typography.caption1
        case .medium: return DesignSystem.Typography.subheadline
        case .large: return DesignSystem.Typography.body
        }
    }
    
    var scoreFont: Font {
        switch self {
        case .small: return DesignSystem.Typography.caption1
        case .medium: return DesignSystem.Typography.subheadline
        case .large: return DesignSystem.Typography.title3
        }
    }
}

// MARK: - Preview
#Preview("Enhanced Player Card") {
    let samplePlayer = PlayerEntity(
        id: UUID(),
        name: "Alex Johnson",
        skills: PlayerSkills(technical: 8, agility: 6, endurance: 7, teamwork: 9),
        isSelected: true
    )
    
    VStack(spacing: DesignSystem.Spacing.lg) {
        EnhancedPlayerCard(player: samplePlayer)
        
        CompactPlayerScore(player: samplePlayer)
        
        HStack {
            CompactPlayerScore(player: samplePlayer, size: .small)
            CompactPlayerScore(player: samplePlayer, size: .large)
        }
    }
    .padding()
} 