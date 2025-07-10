import SwiftUI

// MARK: - Team Count Control
struct TeamCountControl: View {
    @Binding var teamCount: Int
    let maxPlayers: Int
    let isEnabled: Bool

    private var maxTeams: Int {
        min(maxPlayers / 2, 8)
    }

    var body: some View {
        if maxPlayers >= 2 && maxTeams <= 4 {
            Picker("Teams", selection: $teamCount) {
                ForEach(2...maxTeams, id: \.self) { count in
                    Text("\(count)")
                        .tag(count)
                }
            }
            .pickerStyle(.segmented)
            .disabled(!isEnabled)
        } else if maxPlayers >= 2 {
            HStack(spacing: DesignSystem.Spacing.sm) {
                StepperButton(
                    systemImage: "minus",
                    isEnabled: isEnabled && teamCount > 2
                ) {
                    if teamCount > 2 {
                        teamCount -= 1
                    }
                }

                Text("\(teamCount)")
                    .font(DesignSystem.Typography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(isEnabled ? DesignSystem.Colors.primaryText : DesignSystem.Colors.tertiaryText)
                    .frame(minWidth: 32)
                    .contentTransition(.numericText())

                StepperButton(
                    systemImage: "plus",
                    isEnabled: isEnabled && teamCount < maxTeams
                ) {
                    if teamCount < maxTeams {
                        teamCount += 1
                    }
                }
            }
        } else {
            Text("Need 2+ players")
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.tertiaryText)
        }
    }
}

// MARK: - Generation Mode Control
struct GenerationModeControl: View {
    @Binding var mode: TeamGenerationMode
    let isEnabled: Bool

    var body: some View {
        Picker("Generation Mode", selection: $mode) {
            Text("Fair")
                .tag(TeamGenerationMode.fair)
            Text("Random")
                .tag(TeamGenerationMode.random)
        }
        .pickerStyle(.segmented)
        .disabled(!isEnabled)
        .accessibilityLabel("Team generation mode")
        .accessibilityHint("Choose between fair balanced teams or random distribution")
    }
}

// MARK: - Stepper Button
struct StepperButton: View {
    let systemImage: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(DesignSystem.Typography.teamControl)
                .foregroundColor(isEnabled ? DesignSystem.Colors.primary : DesignSystem.Colors.tertiaryText)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(DesignSystem.Colors.secondaryBackground)
                )
                .overlay(
                    Circle()
                        .strokeBorder(isEnabled ? DesignSystem.Colors.primary.opacity(DesignSystem.VisualConsistency.opacitySeparator) : DesignSystem.Colors.separatorColor, lineWidth: 1)
                )
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(DesignSystem.Animation.quick, value: isEnabled)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(.isButton)
    }

    private var accessibilityLabel: String {
        switch systemImage {
        case "plus": return "Increase team count"
        case "minus": return "Decrease team count"
        default: return "Adjust team count"
        }
    }

    private var accessibilityHint: String {
        if !isEnabled { return "Button is disabled" }
        switch systemImage {
        case "plus": return "Adds one more team to the configuration"
        case "minus": return "Removes one team from the configuration"
        default: return "Changes the number of teams"
        }
    }
}