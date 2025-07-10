import SwiftUI
import SwiftData

// MARK: - Team View
/// Main view for team generation and player management
/// Follows MVVM architecture with clean separation of concerns
/// NavigationStack and title handled at TabView level for proper isolation
/// Modern team generation view using @Observable ViewModels with automatic state updates
/// Features player selection, team generation, and results display
struct TeamView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var presentationState = PresentationState()
    @State private var isInitialized = false
    @Namespace private var animationNamespace

    // Tab selection binding for navigation
    @Binding var selectedTab: Int

    // Use the persistent ViewModel from dependency injection
    private var viewModel: TeamGenerationViewModel {
        dependencies.teamGenerationViewModel
    }

    init(selectedTab: Binding<Int> = .constant(0)) {
        self._selectedTab = selectedTab
    }

    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        baseContent
            .task {
                await initializeViewIfNeeded()
            }
            .onAppear {
                // Only refresh if needed
                Task {
                    await refreshViewDataIfNeeded()
                }
            }
            .modifier(SheetsModifier(presentationState: $presentationState, viewModel: viewModel))
            .modifier(AlertsModifier(presentationState: $presentationState, viewModel: viewModel))
            .modifier(ChangeHandlersModifier(
                presentationState: $presentationState,
                viewModel: viewModel,
                selectedTab: $selectedTab
            ))
    }

    @ViewBuilder
    private var baseContent: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.lg) {

                TeamContentView(
                    viewModel: viewModel,
                    presentationState: $presentationState
                )

            }
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            .padding(.bottom, DesignSystem.Spacing.xxxl)
        }
        .background(DesignSystem.Colors.primaryBackground)
        .scrollContentBackground(.hidden)
        .refreshable {
            await refreshViewDataIfNeeded()
        }
    }

    // MARK: - Private Methods

    private func initializeViewIfNeeded() async {
        guard !isInitialized else { return }

        await viewModel.refreshPlayerDataIfNeeded()
        isInitialized = true
    }

    private func refreshViewDataIfNeeded() async {
        await viewModel.refreshPlayerDataIfNeeded()
    }
}

// MARK: - Presentation State
/// Encapsulates all presentation-related state for better organization
fileprivate struct PresentationState {
    var showingPlayerSelection = false
}

// MARK: - Team Content View with Optimized State Observation
/// Separated content view to prevent navigation title conflicts
private struct TeamContentView: View {
    let viewModel: TeamGenerationViewModel
    @Binding var presentationState: PresentationState

    // Optimized state observation - only track what's needed
    @State private var lastPlayerCount: Int = 0
    @State private var lastTeamCount: Int = 2
    @State private var lastGenerationMode: TeamGenerationMode = .fair
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        // Unified Team Generation Interface
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Always show the unified control panel
            UnifiedTeamControlPanel(
                viewModel: viewModel,
                onSelectPlayers: { presentationState.showingPlayerSelection = true },
                onGenerateTeams: { await viewModel.generateTeams() }
            )

            // Content based on current state with optimized transitions
            Group {
                switch viewModel.state {
                case .idle:
                    if viewModel.selectedPlayersCount == 0 {
                        EmptyPlayerPrompt()
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    } else {
                        ReadyToGeneratePrompt(playerCount: viewModel.selectedPlayersCount)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                case .loading:
                    LoadingView()
                        .transition(.opacity)
                case .generating:
                    GeneratingView()
                        .transition(.opacity.combined(with: .scale(scale: 1.05)))
                case .success(let teams):
                    TeamsDisplayView(teams: teams, viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity.combined(with: .scale(scale: 0.95))
                        ))
                case .error(let error):
                    ErrorView(error: error, viewModel: viewModel)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(DesignSystem.Animation.accessibleStandard(reduceMotion: reduceMotion), value: viewModel.state)
        }
        .onAppear {
            // Initialize tracked state
            updateTrackedState()
        }
        .onChange(of: viewModel.selectedPlayersCount) { oldValue, newValue in
            if oldValue != newValue {
                withAnimation(DesignSystem.Animation.accessibleQuick(reduceMotion: reduceMotion)) {
                    lastPlayerCount = newValue
                }
            }
        }
        .onChange(of: viewModel.teamCount) { oldValue, newValue in
            if oldValue != newValue {
                withAnimation(DesignSystem.Animation.accessibleQuick(reduceMotion: reduceMotion)) {
                    lastTeamCount = newValue
                }
            }
        }
        .onChange(of: viewModel.generationMode) { oldValue, newValue in
            if oldValue != newValue {
                lastGenerationMode = newValue
            }
        }
    }

    private func updateTrackedState() {
        lastPlayerCount = viewModel.selectedPlayersCount
        lastTeamCount = viewModel.teamCount
        lastGenerationMode = viewModel.generationMode
    }
}

// MARK: - Optimized Modifiers with Reduced Change Handlers

fileprivate struct SheetsModifier: ViewModifier {
    @Binding fileprivate var presentationState: PresentationState
    fileprivate let viewModel: TeamGenerationViewModel

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $presentationState.showingPlayerSelection, onDismiss: {
                // Safety net: refresh when sheet is actually dismissed
                Task { @MainActor in
                    await viewModel.refreshPlayerDataIfNeeded()
                }
            }) {
                // Completion handler ensures immediate state refresh when sheet dismisses
                PlayerSelectionSheet { hasChanges in
                    if hasChanges {
                        Task { @MainActor in
                            await viewModel.loadSelectedPlayers() // Force refresh when changes are made
                        }
                    }
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
    }
}

fileprivate struct AlertsModifier: ViewModifier {
    @Binding fileprivate var presentationState: PresentationState
    fileprivate let viewModel: TeamGenerationViewModel

    func body(content: Content) -> some View {
        content
            .alert("Generation Error", isPresented: Binding(
                get: { viewModel.hasError },
                set: { _ in viewModel.dismissError() }
            )) {
                Button("OK") {
                    viewModel.dismissError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred during team generation")
            }
    }
}

// MARK: - Optimized Change Handlers with Debouncing
fileprivate struct ChangeHandlersModifier: ViewModifier {
    @Binding fileprivate var presentationState: PresentationState
    fileprivate let viewModel: TeamGenerationViewModel
    @Binding fileprivate var selectedTab: Int

    // Debouncing state
    @State private var navigationDebounceTask: Task<Void, Never>?
    @State private var lastNavigationTrigger: Date = Date()

    func body(content: Content) -> some View {
        content
            .onChange(of: viewModel.shouldNavigateToPlayers) { _, shouldNavigate in
                if shouldNavigate {
                    handleNavigationChange {
                        selectedTab = 1 // Navigate to Players tab
                        viewModel.resetNavigationFlags()
                    }
                }
            }
            .onChange(of: viewModel.shouldShowPlayerSelection) { _, shouldShow in
                if shouldShow {
                    presentationState.showingPlayerSelection = true
                    viewModel.resetNavigationFlags()
                }
            }
    }

    private func handleNavigationChange(_ action: @escaping () -> Void) {
        // Cancel previous task
        navigationDebounceTask?.cancel()

        // Debounce navigation changes to prevent rapid firing
        navigationDebounceTask = Task {
            let now = Date()
            let timeSinceLastTrigger = now.timeIntervalSince(lastNavigationTrigger)

            if timeSinceLastTrigger < 0.5 { // 500ms debounce
                try? await Task.sleep(nanoseconds: 500_000_000)
            }

            if !Task.isCancelled {
                await MainActor.run {
                    lastNavigationTrigger = Date()
                    action()
                }
            }
        }
    }
}

// MARK: - State-Specific Views

// Empty Player Prompt - Minimal guidance when no players are selected
private struct EmptyPlayerPrompt: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            VStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: DesignSystem.Symbols.personGroup)
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(DesignSystem.Colors.tertiaryText)

                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text("No Players Selected")
                        .font(DesignSystem.Typography.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.primaryText)

                    Text("Select players to start generating teams")
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xxxl)
    }
}

// Ready to Generate Prompt - Clean confirmation when players are selected
private struct ReadyToGeneratePrompt: View {
    let playerCount: Int

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                Image(systemName: DesignSystem.Symbols.success)
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.success)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Ready to Generate")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primaryText)

                    Text("\(playerCount) player\(playerCount == 1 ? "" : "s") selected")
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }

                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(DesignSystem.Colors.success.opacity(DesignSystem.VisualConsistency.opacityVeryLight))
            )
        }
    }
}

// Loading View
private struct LoadingView: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ProgressView()
                .controlSize(.large)
                .tint(DesignSystem.Colors.primary)

            Text("Loading players...")
                .font(DesignSystem.Typography.subheadline)
                .foregroundColor(DesignSystem.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xxxl)
    }
}

// Generating View
private struct GeneratingView: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            VStack(spacing: DesignSystem.Spacing.md) {
                ProgressView()
                    .controlSize(.large)
                    .tint(DesignSystem.Colors.primary)

                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text("Creating Teams")
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.primaryText)

                    Text("Balancing players into teams")
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xxxl)
    }
}

// Teams Display View with Optimized Rendering
private struct TeamsDisplayView: View {
    let teams: [TeamEntity]
    let viewModel: TeamGenerationViewModel



    private var adaptiveColumnCount: Int {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            // On iPad, use 2 columns for many teams to reduce scroll length
            return teams.count > 4 ? 2 : 3
        }
        #endif
        return 1  // Single column for portrait iPhone to prevent compression
    }

    private var maxPlayersPerTeam: Int {
        teams.map(\.players.count).max() ?? 0
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Teams summary header with expansion controls
            enhancedTeamsSummaryHeader

            // Teams Grid - Optimized for scroll efficiency
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: DesignSystem.Spacing.md), count: adaptiveColumnCount),
                spacing: DesignSystem.Spacing.lg
            ) {
                ForEach(teams.indices, id: \.self) { index in
                    let team = teams[index]
                    TeamCard(
                        team: team,
                        teamNumber: index + 1,
                        maxPlayersPerTeam: maxPlayersPerTeam
                    )
                    .frame(maxWidth: .infinity)  // Ensure full width usage
                    .id(team.id) // Explicit ID for better diffing
                }
            }
        }
    }

    // MARK: - Enhanced Header with Global Expansion Controls
    private var enhancedTeamsSummaryHeader: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Main summary row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Generated Teams")
                        .font(DesignSystem.Typography.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.primaryText)

                    Text("\(teams.count) balanced teams • \(totalPlayers) players")
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }

                Spacer()
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
    }



    // MARK: - Helper Properties

    private var totalPlayers: Int {
        teams.reduce(0) { $0 + $1.players.count }
    }
}



// Error View with Recovery Actions
private struct ErrorView: View {
    let error: TeamGenerationError
    let viewModel: TeamGenerationViewModel

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            VStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: DesignSystem.Symbols.error)
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(DesignSystem.Colors.error)

                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text("Generation Failed")
                        .font(DesignSystem.Typography.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.primaryText)

                    Text(error.localizedDescription)
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
            }

            // Recovery actions
            HStack(spacing: DesignSystem.Spacing.md) {
                EnhancedButton.primary("Retry", systemImage: DesignSystem.Symbols.loading) {
                    Task {
                        await viewModel.generateTeams()
                    }
                }

                EnhancedButton.secondary("Dismiss", systemImage: DesignSystem.Symbols.xmark) {
                    viewModel.dismissError()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xxxl)
    }
}

// MARK: - Player Selection Sheet
private struct PlayerSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dependencies) private var dependencies
    @State private var players: [PlayerEntity] = []
    @State private var isLoading = true
    @State private var searchText = ""

    let onDismiss: (Bool) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    loadingView
                } else if players.isEmpty {
                    emptyStateView
                } else {
                    playerListView
                }
            }
            .navigationTitle("Select Players")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                        onDismiss(false)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                        onDismiss(true)
                    }
                    .fontWeight(.semibold)
                }
            }
            .searchable(text: $searchText, prompt: "Search players...")
        }
        .task {
            await loadPlayers()
        }
    }

    private var loadingView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            ProgressView()
                .controlSize(.large)
                .tint(DesignSystem.Colors.primary)

            Text("Loading Players")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.primaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: DesignSystem.Symbols.personGroup)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(DesignSystem.Colors.tertiaryText)

            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("No Players Found")
                    .font(DesignSystem.Typography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Text("Add players in the Players tab to get started")
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DesignSystem.Spacing.xxxl)
    }

    private var playerListView: some View {
        List {
            ForEach(filteredPlayers) { player in
                PlayerSelectionRow(
                    player: player,
                    onSelectionChanged: { isSelected in
                        Task {
                            await updatePlayerSelection(player: player, isSelected: isSelected)
                        }
                    }
                )
            }
        }
        .listStyle(.insetGrouped)
    }

    private var filteredPlayers: [PlayerEntity] {
        if searchText.isEmpty {
            return players
        } else {
            return players.filter { player in
                player.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private func loadPlayers() async {
        do {
            let loadedPlayers = try await dependencies.managePlayersUseCase.getAllPlayers()
            await MainActor.run {
                self.players = loadedPlayers
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.players = []
                self.isLoading = false
            }
        }
    }

    private func updatePlayerSelection(player: PlayerEntity, isSelected: Bool) async {
        do {
            try await dependencies.managePlayersUseCase.updatePlayerSelection(id: player.id, isSelected: isSelected)

            // Update local state
            await MainActor.run {
                if let index = players.firstIndex(where: { $0.id == player.id }) {
                    players[index].isSelected = isSelected
                }
            }

            await dependencies.hapticService.selection()
        } catch {
            await dependencies.hapticService.error()
        }
    }
}

// MARK: - Player Selection Row
private struct PlayerSelectionRow: View {
    let player: PlayerEntity
    let onSelectionChanged: (Bool) -> Void

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Selection indicator
            Button {
                onSelectionChanged(!player.isSelected)
            } label: {
                Image(systemName: player.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(player.isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.tertiaryText)
            }
            .buttonStyle(.plain)

            // Player info
            HStack {
                Text(player.name)
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Spacer()

                // Overall skill indicator
                Circle()
                    .fill(PlayerSkillPresentation.rankColor(player.skills.overall))
                    .frame(width: 8, height: 8)

                Text("\(String(format: "%.1f", player.skills.overall))")
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }

            Spacer()
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelectionChanged(!player.isSelected)
        }
    }
}

// MARK: - Preview Support
#Preview {
    TeamView()
        .environment(\.dependencies, MockDependencyContainer())
}