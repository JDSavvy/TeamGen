import SwiftUI

// MARK: - Player List Content View

/// Handles the main player list display logic with optimized List rendering
/// Enhanced with single-expansion accordion behavior and refined animations
struct PlayerListContentView: View {
    let viewModel: PlayerManagementViewModel
    @Binding var presentationState: PlayerPresentationState
    @Binding var expandedPlayerIDs: Set<UUID>

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if viewModel.filteredPlayers.isEmpty, !viewModel.searchQuery.isEmpty {
                EmptySearchStateView()
            } else if viewModel.filteredPlayers.isEmpty {
                EmptyPlayersStateView(presentationState: $presentationState)
            } else {
                // Use List for optimal performance with large datasets
                List {
                    ForEach(viewModel.filteredPlayers, id: \.id) { player in
                        RefinedPlayerRow(
                            player: player,
                            isExpanded: expandedPlayerIDs.contains(player.id),
                            onTap: {
                                performAccordionExpansion(for: player.id)
                            },
                            onEdit: {
                                presentationState.editingPlayer = player
                                presentationState.showingEditPlayer = true
                            },
                            onDelete: {
                                // Set up for safe deletion with confirmation
                                presentationState.playerToDelete = player
                                presentationState.showingDeleteConfirmation = true
                            }
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    }
                    // Remove .onDelete to prevent SwiftUI collection view crashes
                    // Deletion will be handled through edit actions in RefinedPlayerRow
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    // MARK: - Enhanced Accordion Animation Logic

    /// Performs single-expansion accordion behavior with simultaneous animations
    /// Implements iOS 18 best practices for layout preservation and smooth state coordination
    private func performAccordionExpansion(for playerID: UUID) {
        let isCurrentlyExpanded = expandedPlayerIDs.contains(playerID)

        // Use iOS 18 interactive spring with enhanced physics
        // Coordinated timing ensures smooth simultaneous animations
        let simultaneousAnimation = DesignSystem.Animation.accessible(
            .interactiveSpring(
                response: 0.42,
                dampingFraction: 0.78,
                blendDuration: 0.12
            ),
            reduceMotion: reduceMotion
        )

        if isCurrentlyExpanded {
            // Simple collapse - single animation block
            _ = withAnimation(simultaneousAnimation) {
                expandedPlayerIDs.remove(playerID)
            }
        } else {
            // Sophisticated simultaneous expand/collapse coordination
            // This ensures smooth accordion behavior without sequential delays
            withAnimation(simultaneousAnimation) {
                // Clear all existing expansions and set new one atomically
                // This creates smooth simultaneous collapse/expand animations
                expandedPlayerIDs.removeAll()
                expandedPlayerIDs.insert(playerID)
            }
        }
    }
}

// MARK: - Empty Search State View

private struct EmptySearchStateView: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Refined search empty state
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.tertiaryText.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "magnifyingglass")
                    .font(DesignSystem.Typography.largeDisplay)
                    .fontWeight(.light)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }

            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("No Results Found")
                    .font(DesignSystem.Typography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Text("Try adjusting your search terms or check the spelling")
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DesignSystem.Spacing.xxxl)
    }
}

// MARK: - Empty Players State View

private struct EmptyPlayersStateView: View {
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
                        .fontWeight(.light)
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
                // Add Player Button
                Button {
                    presentationState.showingAddPlayer = true
                } label: {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Your First Player")
                    }
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.primary)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                }
                .accessibilityLabel("Add your first player")

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
    }
}

// MARK: - Helpful Tip Component

private struct HelpfulTip: View {
    let icon: String
    let iconColor: Color
    let text: String

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 20, height: 20)

                Image(systemName: icon)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(iconColor)
            }

            Text(text)
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.secondaryText)

            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(DesignSystem.Colors.tertiaryBackground.opacity(0.5))
        )
    }
}

// MARK: - Player List Header

/// Informative header showing player count and current sort status
struct PlayerListHeader: View {
    let totalCount: Int
    let filteredCount: Int
    let sortOption: PlayerSortOption
    let isSearchActive: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                if isSearchActive {
                    Text("\(filteredCount) of \(totalCount) players")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                } else {
                    Text("\(filteredCount) players")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 4) {
                    Image(systemName: sortOption.systemImage)
                        .font(DesignSystem.Typography.tinyIcon)
                        .fontWeight(.medium)
                    Text("Sorted by \(sortOption.rawValue)")
                        .font(.caption2)
                }
                .foregroundColor(DesignSystem.Colors.tertiaryText)
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isSearchActive ?
            "Showing \(filteredCount) of \(totalCount) players, sorted by \(sortOption.rawValue)" :
            "\(filteredCount) players, sorted by \(sortOption.rawValue)")
    }
}
