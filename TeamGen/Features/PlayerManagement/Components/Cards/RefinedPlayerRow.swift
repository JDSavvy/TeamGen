import SwiftUI

// MARK: - Refined Player Row

/// Minimalist player row following Apple's design principles
/// Enhanced with guaranteed static header using ZStack-based fixed positioning
/// Implements iOS 18 best practices for completely flicker-free header layout
struct RefinedPlayerRow: View {
    let player: PlayerEntity
    let isExpanded: Bool
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @Environment(\.dependencies) private var dependencies
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Constants for consistent layout
    private let headerHeight: CGFloat = 72

    var body: some View {
        VStack(spacing: 0) {
            // Header that's always visible
            headerView

            // Expandable content - only shows when expanded
            if isExpanded {
                expandableContent
            }
        }
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }

    // MARK: - Header View

    private var headerView: some View {
        Button(action: {
            withAnimation(
                DesignSystem.Animation.accessible(
                    .interactiveSpring(response: 0.32, dampingFraction: 0.88, blendDuration: 0.06),
                    reduceMotion: reduceMotion
                )
            ) {
                onTap()
            }
        }) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Player initial with skill color
                playerInitial

                // Player information - clean hierarchy
                VStack(alignment: .leading, spacing: 2) {
                    Text(player.name)
                        .font(DesignSystem.Typography.listItemTitle)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .lineLimit(1)

                    Text(skillLevelText)
                        .font(DesignSystem.Typography.listItemSubtitle)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }

                Spacer()

                // Skill score - prominent but not overwhelming
                Text(String(format: "%.1f", player.skills.overall))
                    .font(DesignSystem.Typography.headlineEmphasized)
                    .foregroundColor(skillColor)
                    .monospacedDigit()

                // Enhanced expansion indicator with smooth rotation
                Image(systemName: DesignSystem.Symbols.chevronDown)
                    .font(.system(
                        size: DesignSystem.IconSize.sm,
                        weight: DesignSystem.Symbols.symbolWeight(for: .icon)
                    ))
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(
                        DesignSystem.Animation.accessible(
                            .interactiveSpring(response: 0.25, dampingFraction: 0.92, blendDuration: 0.04),
                            reduceMotion: reduceMotion
                        ),
                        value: isExpanded
                    )
            }
            .padding(DesignSystem.Spacing.md)
            .frame(height: headerHeight)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Edit Player", systemImage: "pencil")
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete Player", systemImage: "trash")
            }
        }
    }

    // MARK: - Expandable Content

    private var expandableContent: some View {
        ExpandedSkillsView(player: player, onEdit: onEdit, onDelete: onDelete)
    }

    // MARK: - Component Views

    private var playerInitial: some View {
        Text(String(player.name.prefix(1).uppercased()))
            .font(DesignSystem.Typography.headlineEmphasized)
            .foregroundColor(.white)
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(skillColor)
            )
    }

    // MARK: - Computed Properties

    private var skillColor: Color {
        PlayerSkillPresentation.rankColor(player.skills.overall)
    }

    private var skillLevelText: String {
        PlayerSkillPresentation.skillLevelText(player.skills.overall)
    }

    private var accessibilityLabel: String {
        "\(player.name), skill level \(skillLevelText), overall score \(String(format: "%.1f", player.skills.overall))"
    }

    private var accessibilityHint: String {
        "Tap to expand skill details"
    }
}

// MARK: - Expanded Skills View

/// Simple and reliable expanded content without state modification issues
struct ExpandedSkillsView: View {
    let player: PlayerEntity
    let onEdit: () -> Void
    let onDelete: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            // Simple divider
            Rectangle()
                .fill(DesignSystem.Colors.separatorColor)
                .frame(height: 0.5)
                .padding(.horizontal, DesignSystem.Spacing.md)

            // Content container with skills and actions
            VStack(spacing: DesignSystem.Spacing.sm) {
                // Skills list
                VStack(spacing: DesignSystem.Spacing.xs) {
                    SkillRowView(
                        name: "Technical",
                        value: player.skills.technical,
                        icon: DesignSystem.Symbols.technical
                    )
                    SkillRowView(name: "Agility", value: player.skills.agility, icon: DesignSystem.Symbols.agility)
                    SkillRowView(
                        name: "Endurance",
                        value: player.skills.endurance,
                        icon: DesignSystem.Symbols.endurance
                    )
                    SkillRowView(name: "Teamwork", value: player.skills.teamwork, icon: DesignSystem.Symbols.teamwork)
                }

                // Action buttons
                HStack(spacing: DesignSystem.Spacing.md) {
                    SimpleActionButton(title: "Edit", icon: "pencil", color: .blue, action: onEdit)
                    SimpleActionButton(title: "Delete", icon: "trash", color: .red, action: onDelete)
                    Spacer()
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(DesignSystem.Colors.tertiaryBackground.opacity(0.3))
            )
        }
        .padding(.top, DesignSystem.Spacing.xxs)
    }
}

// MARK: - Simple Skill Row

/// Simple skill row without complex animations that cause state modification warnings
struct SkillRowView: View {
    let name: String
    let value: Int
    let icon: String

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: DesignSystem.IconSize.sm, weight: .medium))
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .frame(width: 20)

            // Skill name
            Text(name)
                .font(DesignSystem.Typography.subheadline)
                .foregroundColor(DesignSystem.Colors.primaryText)

            Spacer()

            // Progress indicator
            HStack(spacing: 4) {
                ForEach(1 ... 10, id: \.self) { index in
                    Circle()
                        .fill(index <= value ? skillColor : DesignSystem.Colors.separatorColor.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }

            // Numeric value
            Text("\(value)")
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .monospacedDigit()
                .frame(minWidth: 16)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name): \(value) out of 10")
    }

    private var skillColor: Color {
        PlayerSkillPresentation.skillColor(for: value)
    }
}

// MARK: - Simple Action Button

/// Simple action button without complex animations
struct SimpleActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                            .strokeBorder(color.opacity(0.2), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
