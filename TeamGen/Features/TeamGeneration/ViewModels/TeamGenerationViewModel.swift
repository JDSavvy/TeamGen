import Foundation
import Observation
import SwiftUI

// MARK: - Team Generation State

enum TeamGenerationState: Equatable {
    case idle
    case loading
    case generating
    case success([TeamEntity])
    case error(TeamGenerationError)

    static func == (lhs: TeamGenerationState, rhs: TeamGenerationState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.generating, .generating):
            true
        case let (.success(lhsTeams), .success(rhsTeams)):
            lhsTeams == rhsTeams
        case let (.error(lhsError), .error(rhsError)):
            lhsError.localizedDescription == rhsError.localizedDescription
        default:
            false
        }
    }
}

// MARK: - Cache State Management

private struct CacheState {
    var lastPlayerLoadTime: Date = .distantPast
    var cachedPlayers: [PlayerEntity] = []
    var cacheVersion: Int = 0
    var isValid: Bool = false

    mutating func invalidate() {
        isValid = false
        cacheVersion += 1
    }

    mutating func update(with players: [PlayerEntity]) {
        cachedPlayers = players
        lastPlayerLoadTime = Date()
        isValid = true
        cacheVersion += 1
    }
}

// MARK: - Team Generation View Model

/// Modern ViewModel using pure @Observable for automatic state observation
@Observable
@MainActor
public final class TeamGenerationViewModel {
    // MARK: - Observable Properties

    private(set) var state: TeamGenerationState = .idle {
        didSet {
            validateState()
        }
    }

    private(set) var availablePlayers: [PlayerEntity] = []

    private(set) var selectedPlayers: [PlayerEntity] = []

    var teamCount: Int = 2

    var generationMode: TeamGenerationMode = .fair

    // Navigation state - only for one-time triggers
    var shouldNavigateToPlayers = false
    var shouldShowPlayerSelection = false

    // MARK: - Private Properties

    private var cacheState = CacheState()
    private let playerCacheValidityDuration: TimeInterval = 30.0 // 30 seconds cache

    // MARK: - Dependencies (injected via constructor)

    private let generateTeamsUseCase: GenerateTeamsUseCaseProtocol
    private let managePlayersUseCase: ManagePlayersUseCaseProtocol
    private let hapticService: HapticServiceProtocol

    // MARK: - Computed Properties

    var canGenerateTeams: Bool {
        selectedPlayers.count >= teamCount && teamCount >= 2 && state != .generating
    }

    var selectedPlayersCount: Int {
        selectedPlayers.count
    }

    /// Dynamic team count range based on selected players (minimum 2 players per team)
    var validTeamCountRange: ClosedRange<Int> {
        let maxTeams = max(2, selectedPlayers.count / 2)
        // Ensure minimum range is valid (at least 2 teams)
        guard maxTeams >= 2 else {
            return 2 ... 2 // Default to 2 teams when not enough players
        }
        return 2 ... maxTeams
    }

    /// Validated team count that automatically adjusts when player count changes (minimum 2 players per team)
    var validatedTeamCount: Int {
        let maxPossibleTeams = selectedPlayers.count / 2
        // If we don't have enough players for even 2 teams, return 2 (the generation will fail appropriately)
        guard maxPossibleTeams >= 2 else {
            return 2
        }
        return max(2, min(teamCount, maxPossibleTeams))
    }

    var generatedTeams: [TeamEntity] {
        if case let .success(teams) = state {
            return teams
        }
        return []
    }

    var isLoading: Bool {
        state == .loading || state == .generating
    }

    var errorMessage: String? {
        if case let .error(error) = state {
            return error.localizedDescription
        }
        return nil
    }

    var hasError: Bool {
        if case .error = state {
            return true
        }
        return false
    }

    var currentViewState: TeamGenerationState {
        state
    }

    var teams: [TeamEntity] {
        generatedTeams
    }

    // MARK: - Initialization

    public init(
        generateTeamsUseCase: GenerateTeamsUseCaseProtocol,
        managePlayersUseCase: ManagePlayersUseCaseProtocol,
        hapticService: HapticServiceProtocol
    ) {
        self.generateTeamsUseCase = generateTeamsUseCase
        self.managePlayersUseCase = managePlayersUseCase
        self.hapticService = hapticService
    }

    // MARK: - Public Methods

    /// Load available players for team generation with improved caching
    func loadPlayers() async {
        // Check cache validity with version control
        let timeSinceLastLoad = Date().timeIntervalSince(cacheState.lastPlayerLoadTime)
        if timeSinceLastLoad < playerCacheValidityDuration,
           cacheState.isValid,
           !cacheState.cachedPlayers.isEmpty
        {
            // Use cached data and update selected players
            availablePlayers = cacheState.cachedPlayers
            return
        }

        await performPlayerLoad()
    }

    /// Load selected players for team generation with forced refresh and proper state management
    func loadSelectedPlayers() async {
        // Invalidate cache to force fresh load
        cacheState.invalidate()
        await performPlayerLoad()
    }

    /// Refresh player data without affecting team generation state
    func refreshPlayerDataIfNeeded() async {
        // Only refresh if cache is invalid or too old, and preserve existing state
        let timeSinceLastLoad = Date().timeIntervalSince(cacheState.lastPlayerLoadTime)
        if timeSinceLastLoad > playerCacheValidityDuration || !cacheState.isValid {
            await performPlayerLoad()
        }
    }

    /// Generate teams with enhanced validation and error handling
    func generateTeams() async {
        guard canGenerateTeams else {
            await hapticService.error()
            return
        }

        state = .generating
        await hapticService.impact(.light)

        do {
            let teams = try await generateTeamsUseCase.execute(
                teamCount: validatedTeamCount,
                mode: generationMode
            )

            state = .success(teams)
            await hapticService.success()

            // Provide balance feedback
            let averageBalance = teams.map(\.balanceScore).reduce(0, +) / Double(teams.count)
            await hapticService.provideGenerationFeedback(balanceScore: averageBalance)

        } catch {
            let teamError = error as? TeamGenerationError ?? .generationFailed(error.localizedDescription)
            state = .error(teamError)
            await hapticService.error()
        }
    }

    /// Toggle player selection with optimistic UI updates
    func togglePlayerSelection(_ player: PlayerEntity) async {
        // Optimistic update for immediate UI feedback
        updatePlayerSelectionOptimistically(player)
        await hapticService.selection()

        do {
            try await managePlayersUseCase.togglePlayerSelection(id: player.id)
            // Invalidate cache to ensure consistency on next load
            cacheState.invalidate()
        } catch {
            // Revert optimistic update on failure
            updatePlayerSelectionOptimistically(player)
            await hapticService.error()
        }
    }

    /// Select all players with batch operations
    func selectAllPlayers() async {
        let unselectedPlayers = availablePlayers.filter { !$0.isSelected }
        guard !unselectedPlayers.isEmpty else { return }

        // Optimistic update
        availablePlayers = availablePlayers.map { player in
            var updatedPlayer = player
            updatedPlayer.isSelected = true
            return updatedPlayer
        }

        await hapticService.impact(.medium)

        do {
            // Batch operation for better performance
            for player in unselectedPlayers {
                try await managePlayersUseCase.togglePlayerSelection(id: player.id)
            }
            cacheState.invalidate()
        } catch {
            // Revert on failure
            await loadSelectedPlayers()
            await hapticService.error()
        }
    }

    /// Deselect all players with batch operations
    func deselectAllPlayers() async {
        let selectedPlayers = availablePlayers.filter(\.isSelected)
        guard !selectedPlayers.isEmpty else { return }

        // Optimistic update
        availablePlayers = availablePlayers.map { player in
            var updatedPlayer = player
            updatedPlayer.isSelected = false
            return updatedPlayer
        }

        await hapticService.impact(.medium)

        do {
            try await managePlayersUseCase.resetAllSelections()
            cacheState.invalidate()
        } catch {
            // Revert on failure
            await loadSelectedPlayers()
            await hapticService.error()
        }
    }

    /// Reset generation state
    func resetGeneration() {
        state = .idle
    }

    /// Update team count with validation and haptic feedback (minimum 2 players per team)
    func updateTeamCount(_ count: Int) async {
        let maxPossibleTeams = selectedPlayers.count / 2
        let validatedCount = max(2, min(count, maxPossibleTeams))
        teamCount = validatedCount
        validateTeamCount() // Manual call instead of didSet
        await hapticService.selection()
    }

    /// Update generation mode with haptic feedback
    func updateGenerationMode(_ mode: TeamGenerationMode) async {
        generationMode = mode
        await hapticService.selection()
    }

    /// Dismiss error state
    func dismissError() {
        if case .error = state {
            state = .idle
        }
    }

    // MARK: - Navigation Actions

    /// Navigate to players tab for player management
    func navigateToPlayers() {
        shouldNavigateToPlayers = true
    }

    /// Show player selection sheet
    func showPlayerSelection() {
        shouldShowPlayerSelection = true
    }

    /// Reset navigation flags
    func resetNavigationFlags() {
        shouldNavigateToPlayers = false
        shouldShowPlayerSelection = false
    }

    // MARK: - Helper Methods

    /// Get team summary for accessibility
    func teamSummary(for team: TeamEntity, index: Int) -> String {
        let playerNames = team.players.map(\.name).joined(separator: ", ")
        return "Team \(index + 1) (Avg: \(String(format: "%.1f", team.averageRank))): \(playerNames)"
    }

    // MARK: - Private Methods

    private func performPlayerLoad() async {
        // Preserve current state if teams are already generated
        let preservedState = state
        state = .loading

        do {
            let players = try await managePlayersUseCase.getAllPlayers()
            availablePlayers = players
            updateSelectedPlayers() // Manual call instead of didSet
            cacheState.update(with: players)

            // Only reset to idle if we don't have generated teams
            switch preservedState {
            case let .success(teams):
                // Keep the teams if they exist, just refresh the player data
                state = .success(teams)
            default:
                state = .idle
            }
        } catch {
            let teamError = error as? TeamGenerationError ?? .generationFailed(error.localizedDescription)
            state = .error(teamError)
            await hapticService.error()
        }
    }

    private func updateSelectedPlayers() {
        selectedPlayers = availablePlayers.filter(\.isSelected)
        adjustTeamCountIfNeeded() // Manual call instead of didSet
    }

    private func adjustTeamCountIfNeeded() {
        let maxPossibleTeams = selectedPlayers.count / 2
        if teamCount > maxPossibleTeams, selectedPlayers.count >= 2 {
            teamCount = min(teamCount, maxPossibleTeams)
            validateTeamCount() // Manual call instead of didSet
        }
    }

    private func validateTeamCount() {
        teamCount = max(2, teamCount)
    }

    private func validateState() {
        // Ensure state consistency
        switch state {
        case let .success(teams):
            if teams.isEmpty {
                state = .idle
            }
        case .error:
            // Error states are valid, no action needed
            break
        default:
            break
        }
    }

    private func updatePlayerSelectionOptimistically(_ player: PlayerEntity) {
        if let index = availablePlayers.firstIndex(where: { $0.id == player.id }) {
            availablePlayers[index].isSelected.toggle()
        }
    }
}

// MARK: - View Model Error

/// Custom error types for view model operations
enum ViewModelError: Error, LocalizedError {
    case insufficientPlayers
    case invalidTeamCount
    case generationFailed
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .insufficientPlayers:
            "Not enough players selected for team generation"
        case .invalidTeamCount:
            "Invalid team count specified"
        case .generationFailed:
            "Failed to generate balanced teams"
        case let .custom(message):
            message
        }
    }
}
