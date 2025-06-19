import SwiftUI

// MARK: - Player Form View
/// Dedicated view for player form operations (Add/Edit)
/// Extracted from PlayerView.swift for better modularity and maintainability
struct PlayerFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dependencies) private var dependencies
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var formModel: PlayerFormModel
    @FocusState private var isNameFieldFocused: Bool
    
    let mode: FormMode
    let onCompletion: () async -> Void
    
    enum FormMode {
        case add
        case edit(PlayerEntity)
        
        var title: String {
            switch self {
            case .add: return "Add Player"
            case .edit: return "Edit Player"
            }
        }
        
        var confirmationButtonTitle: String {
            switch self {
            case .add: return "Add"
            case .edit: return "Save"
            }
        }
    }
    
    init(mode: FormMode, onCompletion: @escaping () async -> Void) {
        self.mode = mode
        self.onCompletion = onCompletion
        
        switch mode {
        case .add:
            self._formModel = State(wrappedValue: PlayerFormModel())
        case .edit(let player):
            self._formModel = State(wrappedValue: PlayerFormModel(player: player))
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    PlayerFormSection(
                        formModel: $formModel,
                        isNameFieldFocused: $isNameFieldFocused
                    )
                    
                    if case .edit(let player) = mode, player.statistics.gamesPlayed > 0 {
                        PlayerStatisticsSection(player: player)
                    }
                    
                    if case .edit = mode {
                        EnhancedButton.destructive("Delete Player", systemImage: "trash") {
                            await deletePlayer()
                        }
                    }
                }
                .padding(DesignSystem.Spacing.screenPadding)
            }
            .background(DesignSystem.Colors.primaryBackground)
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(mode.confirmationButtonTitle) {
                        Task { await savePlayer() }
                    }
                    .fontWeight(.semibold)
                    .disabled(!formModel.isValid)
                }
            }
            .onAppear {
                if case .add = mode {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isNameFieldFocused = true
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func savePlayer() async {
        guard formModel.isValid else { return }
        
        do {
            let skills = PlayerSkills(
                technical: formModel.technicalSkill,
                agility: formModel.agilityLevel,
                endurance: formModel.enduranceLevel,
                teamwork: formModel.teamworkRating
            )
            
            switch mode {
            case .add:
                _ = try await dependencies.managePlayersUseCase.addPlayer(
                    name: formModel.name.trimmingCharacters(in: .whitespacesAndNewlines),
                    skills: skills
                )
            case .edit(let player):
                var updatedPlayer = player
                updatedPlayer.name = formModel.name
                updatedPlayer.skills = skills
                try await dependencies.managePlayersUseCase.updatePlayer(updatedPlayer)
            }
            
            await dependencies.hapticService.success()
            await onCompletion()
            dismiss()
        } catch {
            await dependencies.hapticService.error()
            formModel.errorMessage = error.localizedDescription
        }
    }
    
    private func deletePlayer() async {
        guard case .edit(let player) = mode else { return }
        
        do {
            try await dependencies.managePlayersUseCase.deletePlayer(id: player.id)
            await dependencies.hapticService.impact(.medium)
            await onCompletion()
            dismiss()
        } catch {
            await dependencies.hapticService.error()
            formModel.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Player Form Model
@Observable
@MainActor
final class PlayerFormModel {
    var name: String = ""
    var technicalSkill: Int = 5
    var agilityLevel: Int = 5
    var enduranceLevel: Int = 5
    var teamworkRating: Int = 5
    var errorMessage: String?
    
    init() {}
    
    init(player: PlayerEntity) {
        self.name = player.name
        self.technicalSkill = player.skills.technical
        self.agilityLevel = player.skills.agility
        self.enduranceLevel = player.skills.endurance
        self.teamworkRating = player.skills.teamwork
    }
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Form Components

/// Modern Player Form Section with iOS 18 design standards
private struct PlayerFormSection: View {
    @Binding var formModel: PlayerFormModel
    var isNameFieldFocused: FocusState<Bool>.Binding?
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var internalFocus: Bool
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Enhanced Name Input Section with modern design
            modernNameInputSection
            
            // Enhanced Skills Section with improved visual design
            modernSkillsSection
        }
    }
    
    // MARK: - Modern Name Input Section
    
    private var modernNameInputSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Section header with icon
            sectionHeader(
                title: "Player Information",
                icon: "person.fill",
                description: "Basic player details and identification"
            )
            
            // Enhanced text field container
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                // Field label with enhanced typography
                                 Label("Player Name", systemImage: "person.text.rectangle")
                     .font(DesignSystem.Typography.subheadline)
                     .fontWeight(.semibold)
                     .foregroundStyle(DesignSystem.Colors.primaryText)
                     .labelStyle(.titleAndIcon)
                
                // Modern text field with enhanced styling
                ZStack(alignment: .leading) {
                    // Enhanced background with adaptive styling
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .fill(textFieldBackgroundColor)
                        .stroke(textFieldBorderColor, lineWidth: textFieldBorderWidth)
                                                 .shadow(
                             color: textFieldShadowColor,
                             radius: 2,
                             x: 0,
                             y: 1
                         )
                    
                    // Text field with modern styling
                    TextField("Enter player name", text: $formModel.name, prompt: textFieldPrompt)
                        .font(DesignSystem.Typography.body)
                        .foregroundStyle(DesignSystem.Colors.primaryText)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .focused(isNameFieldFocused ?? $internalFocus)
                        .submitLabel(.done)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(false)
                        .accessibilityLabel("Player name input field")
                        .accessibilityHint("Enter the player's name")
                }
                .frame(height: 44) // Standard iOS touch target
                .animation(DesignSystem.Animation.accessible(DesignSystem.Animation.spring, reduceMotion: reduceMotion), value: formModel.name.isEmpty)
                
                // Character count indicator
                if !formModel.name.isEmpty {
                    HStack {
                        Spacer()
                        Text("\(formModel.name.count) characters")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundStyle(DesignSystem.Colors.tertiaryText)
                            .transition(.opacity)
                    }
                    .animation(DesignSystem.Animation.accessible(DesignSystem.Animation.standard, reduceMotion: reduceMotion), value: formModel.name.count)
                }
                
                // Enhanced error display
                if let errorMessage = formModel.errorMessage {
                    modernErrorDisplay(message: errorMessage)
                }
            }
        }
                 .padding(DesignSystem.Spacing.lg)
         .background(
             RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                 .fill(DesignSystem.Colors.cardBackground)
                 .stroke(DesignSystem.Colors.separatorColor.opacity(0.3), lineWidth: 1)
                 .shadow(
                     color: Color.black.opacity(0.08),
                     radius: 8,
                     x: 0,
                     y: 4
                 )
         )
    }
    
    // MARK: - Modern Skills Section
    
    private var modernSkillsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Enhanced skills header
            sectionHeader(
                title: "Player Skills",
                icon: "star.circle.fill",
                description: "Rate the player's abilities across different areas"
            )
            
            // Skills picker with enhanced spacing
            MultiSkillPicker(
                technicalSkill: $formModel.technicalSkill,
                agilityLevel: $formModel.agilityLevel,
                enduranceLevel: $formModel.enduranceLevel,
                teamworkRating: $formModel.teamworkRating
            )
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(DesignSystem.Colors.cardBackground)
                .stroke(DesignSystem.Colors.separatorColor.opacity(0.3), lineWidth: 1)
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(title: String, icon: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            // Title with icon
            Label(title, systemImage: icon)
                .font(DesignSystem.Typography.title3)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Colors.primaryText)
                .symbolRenderingMode(.hierarchical)
            
            // Description text
            Text(description)
                .font(DesignSystem.Typography.caption1)
                .foregroundStyle(DesignSystem.Colors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func modernErrorDisplay(message: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(DesignSystem.Colors.error)
                .font(DesignSystem.Typography.caption1)
            
            Text(message)
                .font(DesignSystem.Typography.caption1)
                .foregroundStyle(DesignSystem.Colors.error)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(DesignSystem.Colors.error.opacity(0.1))
        )
        .transition(.scale.combined(with: .opacity))
    }
    
    // MARK: - Computed Properties
    
    private var textFieldBackgroundColor: Color {
        formModel.name.isEmpty 
            ? DesignSystem.Colors.fillSecondary
            : DesignSystem.Colors.fillTertiary
    }
    
    private var textFieldBorderColor: Color {
        if formModel.errorMessage != nil {
            return DesignSystem.Colors.error.opacity(0.6)
        } else if !formModel.name.isEmpty {
            return DesignSystem.Colors.primary.opacity(0.3)
        } else {
            return DesignSystem.Colors.separatorColor
        }
    }
    
    private var textFieldBorderWidth: CGFloat {
        formModel.errorMessage != nil ? 1.5 : 1.0
    }
    
    private var textFieldShadowColor: Color {
        formModel.errorMessage != nil 
            ? DesignSystem.Colors.error.opacity(0.2)
            : Color.black.opacity(0.1)
    }
    
    private var textFieldPrompt: Text {
        Text("Enter player name")
            .foregroundStyle(DesignSystem.Colors.placeholderText)
    }
}

/// Enhanced Player Statistics Section with modern design
private struct PlayerStatisticsSection: View {
    let player: PlayerEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Enhanced header
            sectionHeader
            
            // Statistics grid with modern design
            statisticsGrid
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(DesignSystem.Colors.cardBackground)
                .stroke(DesignSystem.Colors.separatorColor.opacity(0.3), lineWidth: 1)
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
    }
    
    // MARK: - Header
    
    private var sectionHeader: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Label("Player Statistics", systemImage: "chart.bar.fill")
                .font(DesignSystem.Typography.title3)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Colors.primaryText)
                .symbolRenderingMode(.hierarchical)
            
            Text("Performance history and game participation")
                .font(DesignSystem.Typography.caption1)
                .foregroundStyle(DesignSystem.Colors.secondaryText)
        }
    }
    
    // MARK: - Statistics Grid
    
    private var statisticsGrid: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Games played stat
            modernStatCard(
                title: "Games Played",
                value: "\(player.statistics.gamesPlayed)",
                icon: "gamecontroller.fill",
                color: DesignSystem.Colors.primary
            )
            
            Spacer()
            
            // Teams joined stat
            modernStatCard(
                title: "Teams Joined",
                value: "\(player.statistics.teamsJoined)",
                icon: "person.2.fill",
                color: DesignSystem.Colors.accent
            )
        }
    }
    
    private func modernStatCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Icon with background
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
                    .symbolRenderingMode(.hierarchical)
            }
            
            // Value and title
            VStack(spacing: DesignSystem.Spacing.xxxs) {
                Text(value)
                    .font(DesignSystem.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Colors.primaryText)
                    .monospacedDigit()
                
                Text(title)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2, reservesSpace: true)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
} 