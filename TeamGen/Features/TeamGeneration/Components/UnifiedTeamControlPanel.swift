import SwiftUI

// MARK: - Unified Team Control Panel

/// Modern, unified interface combining player selection and team configuration
/// Follows Apple's design principles for clarity and purposeful interaction
struct UnifiedTeamControlPanel: View {
    let viewModel: TeamGenerationViewModel
    let onSelectPlayers: () -> Void
    let onGenerateTeams: () async -> Void

    @Bindable private var bindableViewModel: TeamGenerationViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        viewModel: TeamGenerationViewModel,
        onSelectPlayers: @escaping () -> Void,
        onGenerateTeams: @escaping () async -> Void
    ) {
        self.viewModel = viewModel
        self.onSelectPlayers = onSelectPlayers
        self.onGenerateTeams = onGenerateTeams
        bindableViewModel = viewModel
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Streamlined Player-Team Configuration
            playerSelectionSection

            // Team distribution visualization and generation mode
            if viewModel.selectedPlayersCount >= 2 {
                teamConfigurationSection
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }

            // Generate Button with validation feedback
            generateButton
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .animation(reduceMotion ? nil : DesignSystem.Animation.standard, value: viewModel.selectedPlayersCount)
        .animation(reduceMotion ? nil : DesignSystem.Animation.standard, value: viewModel.teamCount)
    }

    // MARK: - Streamlined Player-Team Configuration

    private var playerSelectionSection: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Players button
            Button(action: onSelectPlayers) {
                Text("\(viewModel.selectedPlayersCount) Players")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(playerCountColor)
                    .contentTransition(.numericText())
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)

            // Connector text
            Text("in")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.secondaryText)

            // Team count display
            Text("\(viewModel.validatedTeamCount)")
                .font(DesignSystem.Typography.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Colors.primary)
                .monospacedDigit()
                .contentTransition(.numericText())
                .accessibilityLabel("\(viewModel.validatedTeamCount) teams")

            // Teams label
            Text("Teams")
                .font(DesignSystem.Typography.headline)
                .foregroundStyle(DesignSystem.Colors.secondaryText)
                .accessibilityHidden(true)

            Spacer()

            // Team count stepper
            if viewModel.selectedPlayersCount >= 2 {
                Stepper(
                    "",
                    value: $bindableViewModel.teamCount,
                    in: viewModel.validTeamCountRange,
                    step: 1
                )
                .accessibilityValue("Currently set to \(viewModel.validatedTeamCount) teams")
                .accessibilityHint("Swipe up or down to adjust team count")
                .onChange(of: bindableViewModel.teamCount) { _, newValue in
                    // Provide haptic feedback on value change
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()

                    // Update the view model
                    Task {
                        await viewModel.updateTeamCount(newValue)
                    }
                }
            }
        }
    }

    // MARK: - Team Configuration Section

    private var teamConfigurationSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Team Count Configuration
            teamCountSection

            // Generation Mode Picker
            generationModeSection
        }
    }

    private var teamCountSection: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            // Visual indicator for team distribution
            if viewModel.selectedPlayersCount > 0 {
                teamDistributionIndicator
            }
        }
    }

    private var teamDistributionIndicator: some View {
        let playersPerTeam = viewModel.selectedPlayersCount / viewModel.validatedTeamCount
        let remainingPlayers = viewModel.selectedPlayersCount % viewModel.validatedTeamCount
        let teamRows = calculateTeamRows(for: viewModel.validatedTeamCount)

        return VStack(spacing: DesignSystem.Spacing.xs) {
            // Multi-row team visualization
            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(0 ..< teamRows.count, id: \.self) { rowIndex in
                    let rowTeams = teamRows[rowIndex]

                    HStack(spacing: DesignSystem.Spacing.xs) {
                        ForEach(rowTeams, id: \.self) { teamIndex in
                            let teamSize = playersPerTeam + (teamIndex < remainingPlayers ? 1 : 0)

                            VStack(spacing: DesignSystem.Spacing.xxs) {
                                // Team card with enhanced visual design
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                                    .fill(DesignSystem.Colors.primary.gradient)
                                    .frame(height: 32)
                                    .overlay {
                                        // Team size number with better contrast
                                        Text("\(teamSize)")
                                            .font(DesignSystem.Typography.headlineEmphasized)
                                            .foregroundStyle(.white)
                                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                                    }
                                    .accessibilityLabel("Team \(teamIndex + 1): \(teamSize) players")

                                // Team label
                                Text("Team \(teamIndex + 1)")
                                    .font(DesignSystem.Typography.caption2)
                                    .foregroundStyle(DesignSystem.Colors.tertiaryText)
                                    .accessibilityHidden(true)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Team distribution: \(viewModel.validatedTeamCount) teams")
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, DesignSystem.Spacing.xxs)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(DesignSystem.Colors.fillTertiary)
            )
        }
    }

    /// Calculates how to distribute teams across rows based on the specified rules
    /// - Parameter teamCount: Total number of teams
    /// - Returns: Array of arrays, where each inner array contains the team indices for that row
    private func calculateTeamRows(for teamCount: Int) -> [[Int]] {
        guard teamCount > 6 else {
            // Single row for 6 or fewer teams
            return [Array(0 ..< teamCount)]
        }

        let (firstRowCount, _) = calculateRowDistribution(for: teamCount)
        let firstRow = Array(0 ..< firstRowCount)
        let secondRow = Array(firstRowCount ..< teamCount)

        return [firstRow, secondRow]
    }

    /// Calculates the distribution of teams between two rows
    /// - Parameter teamCount: Total number of teams
    /// - Returns: Tuple with (firstRowCount, secondRowCount)
    private func calculateRowDistribution(for teamCount: Int) -> (Int, Int) {
        switch teamCount {
        case 7: return (4, 3) // 7 teams: 4 + 3
        case 8: return (4, 4) // 8 teams: 4 + 4
        case 9: return (5, 4) // 9 teams: 5 + 4
        case 10: return (5, 5) // 10 teams: 5 + 5
        case 11: return (6, 5) // 11 teams: 6 + 5
        case 12: return (6, 6) // 12 teams: 6 + 6
        default:
            // For cases beyond 12, use a general rule: max 6 per row
            let firstRowCount = min(6, teamCount - teamCount / 2)
            return (firstRowCount, teamCount - firstRowCount)
        }
    }

    private var generationModeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Label("Generation Mode", systemImage: "gearshape.2.fill")
                .font(DesignSystem.Typography.bodyEmphasized)
                .foregroundColor(DesignSystem.Colors.primaryText)

            Picker("Generation Mode", selection: $bindableViewModel.generationMode) {
                Text("Fair").tag(TeamGenerationMode.fair)
                Text("Random").tag(TeamGenerationMode.random)
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        Button {
            Task { await onGenerateTeams() }
        } label: {
            HStack {
                if case .generating = viewModel.state {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: DesignSystem.Symbols.personGroup)
                }
                Text("Generate \(viewModel.validatedTeamCount) Teams")
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!canGenerateTeams)
    }

    // MARK: - Computed Properties

    private var playerCountColor: Color {
        switch viewModel.selectedPlayersCount {
        case 0:
            DesignSystem.Colors.tertiaryText
        case 1:
            DesignSystem.Colors.warning
        default:
            DesignSystem.Colors.success
        }
    }

    private var canGenerateTeams: Bool {
        viewModel.selectedPlayersCount >= 2 &&
            viewModel.validatedTeamCount >= 2 &&
            viewModel.validTeamCountRange.contains(viewModel.validatedTeamCount) &&
            viewModel.state != .generating
    }
}

// MARK: - Configuration Control Wrapper

struct ConfigurationControl<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(title)
                .font(DesignSystem.Typography.bodyEmphasized)
                .foregroundColor(DesignSystem.Colors.primaryText)

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
