import SwiftUI

// MARK: - Player Empty State View

/// Empty state view for when no players exist
struct PlayerEmptyStateView: View {
    @Binding var presentationState: PlayerPresentationState

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xxxl) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                // Refined empty state illustration
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.primary
                            .opacity(DesignSystem.VisualConsistency.opacitySkillBackground))
                        .frame(
                            width: DesignSystem.ComponentSize.emptyStateIcon,
                            height: DesignSystem.ComponentSize.emptyStateIcon
                        )

                    Image(systemName: "person.3.fill")
                        .font(DesignSystem.Typography.extraLargeDisplay)
                        .foregroundColor(DesignSystem.Colors.primary
                            .opacity(DesignSystem.VisualConsistency.opacityIntense))
                }

                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("No Players Yet")
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.primaryText)

                    Text(
                        """
                        Add your first player to start creating balanced teams.
                        You can manage their skills and track their performance.
                        """
                    )
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                }
            }

            VStack(spacing: DesignSystem.Spacing.md) {
                EnhancedButton.primary(
                    "Add Your First Player",
                    systemImage: "plus.circle.fill"
                ) {
                    presentationState.presentAddPlayer()
                }

                // Helpful tips
                VStack(spacing: DesignSystem.Spacing.xs) {
                    HelpfulTip(
                        icon: "lightbulb.fill",
                        iconColor: DesignSystem.Colors.accent,
                        text: "Tip: Add at least 4 players for team generation"
                    )

                    HelpfulTip(
                        icon: "star.fill",
                        iconColor: DesignSystem.Colors.warning,
                        text: "Rate skills from 1-10 for balanced teams"
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DesignSystem.Spacing.xxxl)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No players found")
        .accessibilityHint("Add your first player to start creating teams")
    }
}

// MARK: - Helpful Tip Component

private struct HelpfulTip: View {
    let icon: String
    let iconColor: Color
    let text: String

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(DesignSystem.Typography.controlLabel)
                .foregroundColor(iconColor)

            Text(text)
                .font(DesignSystem.Typography.controlLabel)
                .foregroundColor(DesignSystem.Colors.secondaryText)

            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(DesignSystem.Colors.tertiaryBackground)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }
}

// MARK: - Preview

#if DEBUG
    struct PlayerEmptyStateView_Previews: PreviewProvider {
        static var previews: some View {
            PlayerEmptyStateView(presentationState: .constant(PlayerPresentationState()))
        }
    }
#endif
