import SwiftUI

// MARK: - Portrait-Optimized Team Card Component
/// Completely optimized for portrait mode with responsive design
/// Features clean visual hierarchy, minimalist design, and perfect accessibility
/// Adapts seamlessly to all iPhone screen sizes in portrait orientation
struct TeamCard: View {
    let team: TeamEntity
    let teamNumber: Int
    let maxPlayersPerTeam: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPlayersExpanded: Bool = false
    @State private var showPlayerName: Bool = false

    // Intelligent initial state: expand automatically if 6 or fewer players
    init(team: TeamEntity, teamNumber: Int, maxPlayersPerTeam: Int = 0) {
        self.team = team
        self.teamNumber = teamNumber
        self.maxPlayersPerTeam = maxPlayersPerTeam
        self._isPlayersExpanded = State(initialValue: false)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with team identity and strength
            headerSection



            // Expandable player roster
            if !team.players.isEmpty {
                expandablePlayersSection
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)  // Prevent horizontal compression
        .frame(minHeight: 120)  // Ensure minimum height to prevent vertical squashing
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .center, spacing: DesignSystem.Spacing.md) {
            // Expanded tappable area for team name switching - follows iOS best practices
            Button {
                withAnimation(DesignSystem.Animation.accessible(.spring(response: 0.4, dampingFraction: 0.8), reduceMotion: reduceMotion)) {
                    showPlayerName.toggle()
                }
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    // Team number with distinctive styling
                    Text("\(teamNumber)")
                        .font(DesignSystem.Typography.teamNumber)
                        .foregroundColor(.white)
                        .frame(width: DesignSystem.ComponentSize.largeIcon, height: DesignSystem.ComponentSize.largeIcon)
                        .background(
                            Circle()
                                .fill(teamAccentColor)
                                .shadow(color: teamAccentColor.opacity(DesignSystem.VisualConsistency.opacityMedium), radius: DesignSystem.CornerRadius.compact, x: 0, y: DesignSystem.Spacing.single)
                        )

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.single) {
                        Text(teamDisplayName)
                            .font(DesignSystem.Typography.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                            .fixedSize(horizontal: false, vertical: true)  // Prevent text compression
                            .contentTransition(.opacity)

                        Text(playerCountText)
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)  // Prevent text compression
                    }

                    // Extended spacer to expand tappable area significantly
                    Spacer(minLength: DesignSystem.Spacing.xl)
                }
                .frame(maxWidth: .infinity, alignment: .leading)  // Expand to fill available space
                .frame(minHeight: 44)  // Ensure minimum touch target size (iOS guidelines)
                .contentShape(Rectangle())  // Make entire area tappable
            }
            .buttonStyle(.plain)
            .accessibilityLabel(showPlayerName ? "Switch to team number view" : "Switch to strongest player view")
            .accessibilityHint("Tap to toggle between team number and strongest player name")

            // Average skill metric (not tappable)
            MetricView(
                title: "AVG SKILL",
                value: String(format: "%.1f", team.averageRank),
                color: PlayerSkillPresentation.rankColor(team.averageRank),
                icon: "target"
            )
        }
        .frame(minHeight: DesignSystem.ComponentSize.standardRowHeight)  // Ensure adequate height for header
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, DesignSystem.Spacing.lg)
        .padding(.bottom, DesignSystem.Spacing.sm)
    }



    // MARK: - Expandable Players Section
    private var expandablePlayersSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section divider
            Rectangle()
                .fill(DesignSystem.Colors.separatorColor.opacity(DesignSystem.VisualConsistency.opacityModerate))
                .frame(height: DesignSystem.VisualConsistency.borderThin)
                .padding(.horizontal, DesignSystem.Spacing.lg)

            // Entire players section is clickable
            Button {
                withAnimation(DesignSystem.Animation.accessible(.interactiveSpring(response: 0.4, dampingFraction: 0.8), reduceMotion: reduceMotion)) {
                    isPlayersExpanded.toggle()
                }
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    // Players header
                    playersHeaderContent

                    // Stable unified players list - no conditional rendering
                    stablePlayersView
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isPlayersExpanded ? "Collapse players list" : "Expand players list")
            .accessibilityHint("Shows all \(team.players.count) players in this team")
        }
    }

    // MARK: - Players Header Content (without button wrapper)
    private var playersHeaderContent: some View {
        HStack(alignment: .center, spacing: DesignSystem.Spacing.sm) {
            Text("Players")
                .font(DesignSystem.Typography.callout)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText)

            Spacer()

            // Chevron with smooth rotation
            Image(systemName: "chevron.down")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.tertiaryText)
                .rotationEffect(.degrees(isPlayersExpanded ? 180 : 0))
                .animation(DesignSystem.Animation.accessible(.interactiveSpring(response: 0.25, dampingFraction: 0.92), reduceMotion: reduceMotion), value: isPlayersExpanded)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }



    // MARK: - Stable Players View (unified approach)
    private var stablePlayersView: some View {
        LazyVStack(alignment: .leading, spacing: 0) { // Remove automatic spacing
            // Always render all players, control visibility with height and opacity
            ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                VStack(spacing: 0) {
                    // Add spacing before player (except for first player) only when expanded
                    if index > 0 && isPlayersExpanded {
                        Color.clear.frame(height: DesignSystem.Spacing.xs)
                    }

                    ModernPlayerRow(player: player)
                        .frame(height: isPlayersExpanded ? nil : 0) // Height: normal when expanded, 0 when collapsed
                        .opacity(isPlayersExpanded ? 1 : 0) // Opacity: visible when expanded, hidden when collapsed
                        .clipped() // Prevent content overflow when height is 0
                }
                .animation(
                    DesignSystem.Animation.accessible(
                        .spring(response: 0.4, dampingFraction: 0.9),
                        reduceMotion: reduceMotion
                    ),
                    value: isPlayersExpanded
                )
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.bottom, isPlayersExpanded ? DesignSystem.Spacing.sm : 0) // Only add bottom padding when expanded
    }

    // MARK: - Card Background
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(DesignSystem.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .strokeBorder(
                        DesignSystem.Colors.separatorColor.opacity(DesignSystem.VisualConsistency.opacityLight),
                        lineWidth: DesignSystem.VisualConsistency.borderThin
                    )
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? DesignSystem.VisualConsistency.shadowDarkMode : DesignSystem.VisualConsistency.shadowLightMode),
                radius: DesignSystem.VisualConsistency.shadowRadius,
                x: 0,
                y: DesignSystem.VisualConsistency.shadowOffsetY
            )
    }

    // MARK: - Computed Properties
    private var sortedPlayers: [PlayerEntity] {
        team.players.sorted { $0.skills.overall > $1.skills.overall }
    }

    private var strongestPlayer: PlayerEntity? {
        sortedPlayers.first
    }

    private var teamDisplayName: String {
        if showPlayerName, let strongestPlayer = strongestPlayer {
            return "Team \(strongestPlayer.name)"
        }
        return "Team \(teamNumber)"
    }

    private var teamAccentColor: Color {
        switch teamNumber % 5 {
        case 1: return DesignSystem.Colors.primary
        case 2: return DesignSystem.Colors.success
        case 3: return DesignSystem.Colors.warning
        case 4: return DesignSystem.Colors.accent
        default: return DesignSystem.Colors.info
        }
    }

    private var playerCountText: String {
        let count = team.players.count
        return "\(count) player\(count == 1 ? "" : "s")"
    }

    private var accessibilityDescription: String {
        let playerNames = sortedPlayers.map(\.name).joined(separator: ", ")
        return "Team \(teamNumber), \(team.players.count) players, average skill \(String(format: "%.1f", team.averageRank)). Players: \(playerNames)"
    }
}

// MARK: - Modern Metric View
/// Clean, focused metric display with proper visual hierarchy
private struct MetricView: View {
    let title: String
    let value: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .trailing, spacing: DesignSystem.Spacing.single) {
            // Metric label
            Text(title)
                .font(DesignSystem.Typography.caption1)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.tertiaryText)
                .tracking(0.3)
                .fixedSize(horizontal: false, vertical: true)  // Prevent compression

            // Icon and metric value
            HStack(alignment: .center, spacing: DesignSystem.Spacing.sm) {
                // Icon with consistent sizing
                Image(systemName: icon)
                    .font(DesignSystem.Typography.smallIcon)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                    .frame(width: DesignSystem.ComponentSize.smallIcon, height: DesignSystem.ComponentSize.smallIcon)

                // Metric value with proper color mapping
                Text(value)
                    .font(DesignSystem.Typography.metricValue)
                    .foregroundColor(color)
                    .contentTransition(.numericText())
                    .fixedSize()  // Prevent compression of numeric values
            }
        }
        .frame(minHeight: DesignSystem.ComponentSize.metricHeight)  // Ensure adequate height for metrics
    }
}



// MARK: - Modern Player Row
/// Streamlined player display with essential information only
/// Fixed color consistency for skill values - NEVER defaults to black
private struct ModernPlayerRow: View {
    let player: PlayerEntity

    var body: some View {
        HStack(alignment: .center, spacing: DesignSystem.Spacing.sm) {
            // Skill indicator dot with consistent color
            Circle()
                .fill(PlayerSkillPresentation.rankColor(player.skills.overall))
                .frame(width: DesignSystem.ComponentSize.tinyIndicator, height: DesignSystem.ComponentSize.tinyIndicator)

            // Player name
            Text(player.name)
                .font(DesignSystem.Typography.subheadline)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .lineLimit(1)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)  // Prevent vertical compression

            Spacer(minLength: DesignSystem.Spacing.sm)

            // Skill value with CONSISTENT color mapping (never black)
            Text(String(format: "%.1f", player.skills.overall))
                .font(DesignSystem.Typography.skillValue)
                .foregroundColor(PlayerSkillPresentation.rankColor(player.skills.overall))
                .monospacedDigit()
                .fixedSize()  // Prevent compression of numeric values
        }
        .frame(minHeight: DesignSystem.ComponentSize.minRowHeight)  // Ensure minimum row height
        .padding(.vertical, DesignSystem.Spacing.single)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

