import Foundation
import SwiftUI
import Observation
import OSLog

// MARK: - Player Management View State
enum PlayerManagementViewState: Equatable {
    case idle
    case loading
    case loaded([PlayerEntity])
    case empty
    case error(Error)
    
    static func == (lhs: PlayerManagementViewState, rhs: PlayerManagementViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.empty, .empty):
            return true
        case (.loaded(let lhsPlayers), .loaded(let rhsPlayers)):
            return lhsPlayers == rhsPlayers
        case (.error, .error):
            return true // We consider all errors equal for state comparison
        default:
            return false
        }
    }
}

// MARK: - Player Management View Model
/// Modern ViewModel using @Observable for automatic observation and better performance
/// Optimized with state batching and efficient cache management
@Observable
@MainActor
final class PlayerManagementViewModel {
    // MARK: - Observable Properties (no @Published needed)
    private(set) var state: PlayerManagementViewState = .idle
    
    var searchQuery: String = "" {
        didSet { 
            if oldValue != searchQuery {
                scheduleSearch() 
            }
        }
    }
    
    var sortOption: PlayerSortOption = .nameAscending {
        didSet { 
            if oldValue != sortOption {
                applySortingSync() 
            }
        }
    }
    
    // MARK: - Private Properties
    private var allPlayers: [PlayerEntity] = []
    private var searchTask: Task<Void, Never>?
    private let searchDebounceTime: TimeInterval = 0.3
    private let logger = Logger(subsystem: "com.teamgen.app", category: "PlayerManagement")
    
    // MARK: - Performance Optimization: Simplified Filtered Results
    private var _cachedFilteredPlayers: [PlayerEntity] = []
    private var _lastSearchQuery: String = ""
    private var _lastSortOption: PlayerSortOption = .nameAscending
    private var _lastPlayerCount: Int = 0
    
    // MARK: - Dependencies (injected via constructor)
    private let managePlayersUseCase: ManagePlayersUseCaseProtocol
    private let hapticService: HapticServiceProtocol
    
    // MARK: - Computed Properties
    
    /// Current view state based on internal state and data
    var currentViewState: PlayerManagementViewState {
        let result: PlayerManagementViewState
        switch state {
        case .loaded:
            // Return proper state based on actual data
            result = allPlayers.isEmpty ? .empty : .loaded(allPlayers)
        default:
            result = state
        }
        

        
        return result
    }
    
    /// All players from the data source
    var players: [PlayerEntity] {
        allPlayers
    }
    
    /// Filtered and sorted players for display with simplified caching
    var filteredPlayers: [PlayerEntity] {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if cache is still valid by comparing allPlayers count too
        let currentPlayerCount = allPlayers.count
        if _lastSearchQuery == trimmedQuery && _lastSortOption == sortOption && _lastPlayerCount == currentPlayerCount {
            return _cachedFilteredPlayers
        }
        
        // Recalculate and cache
        var result = allPlayers
        
        // Apply search filter
        if !trimmedQuery.isEmpty {
            result = result.filter { player in
                player.name.localizedCaseInsensitiveContains(trimmedQuery)
            }
        }
        
        // Apply sort
        result = applySorting(to: result)
        
        // Update cache with player count tracking
        _cachedFilteredPlayers = result
        _lastSearchQuery = trimmedQuery
        _lastSortOption = sortOption
        _lastPlayerCount = currentPlayerCount
        
        return result
    }
    
    // MARK: - Initialization
    init(
        managePlayersUseCase: ManagePlayersUseCaseProtocol,
        hapticService: HapticServiceProtocol
    ) {
        self.managePlayersUseCase = managePlayersUseCase
        self.hapticService = hapticService
    }
    
    // MARK: - Public Methods
    
    /// Load all players from the data source
    func loadPlayers() async {
        logger.info("🔄 Loading players...")
        state = .loading
        
        do {
            let players = try await managePlayersUseCase.getAllPlayers()
            logger.info("📊 Loaded \(players.count) players from repository")
            allPlayers = players
            invalidateCache()
            
            // Ensure proper state management for empty vs loaded states
            if players.isEmpty {
                logger.info("📭 No players found - setting empty state")
                state = .empty
            } else {
                logger.info("✅ Players loaded - setting loaded state with \(players.count) players")
                state = .loaded(players)
            }
        } catch {
            logger.error("❌ Failed to load players: \(error.localizedDescription)")
            state = .error(error)
            await hapticService.error()
        }
    }
    
    /// Delete a player by ID
    func deletePlayer(_ playerId: UUID) async {
        do {
            // Delete from repository first
            try await managePlayersUseCase.deletePlayer(id: playerId)
            await hapticService.impact(.medium)
            
            // Optimistically update local state for immediate UI feedback
            allPlayers.removeAll { $0.id == playerId }
            invalidateCache()
            
            // Update state based on remaining players
            if allPlayers.isEmpty {
                state = .empty
            } else {
                state = .loaded(allPlayers)
            }
        } catch {
            // If deletion failed, reload to ensure UI consistency
            await loadPlayers()
            state = .error(error)
            await hapticService.error()
        }
    }
    
    /// Apply current sorting option with haptic feedback
    func applySorting() async {
        await hapticService.selection()
        // Sorting is automatically applied through computed property with @Observable
    }
    
    /// Apply sorting to a collection of players (optimized for background processing)
    private func applySorting(to players: [PlayerEntity]) -> [PlayerEntity] {
        // Perform sorting on background thread for large datasets
        switch sortOption {
        case .nameAscending:
            return players.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .nameDescending:
            return players.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        case .skillLowToHigh:
            return players.sorted { $0.skills.overall < $1.skills.overall }
        case .skillHighToLow:
            return players.sorted { $0.skills.overall > $1.skills.overall }
        }
    }
    
    func updatePlayer(_ player: PlayerEntity) async {
        
        do {
            try await managePlayersUseCase.updatePlayer(player)
            await loadPlayers()
            await hapticService.success()
        } catch {
            logger.error("Failed to update player: \(error.localizedDescription)")
            await hapticService.error()
        }
    }
    
    func togglePlayerSelection(_ playerId: UUID) async {
        
        do {
            try await managePlayersUseCase.togglePlayerSelection(id: playerId)
            await hapticService.selection()
            await loadPlayers()
        } catch {
            logger.error("Failed to toggle player selection: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Schedule a debounced search operation with proper cancellation
    private func scheduleSearch() {
        // Cancel any existing search task
        searchTask?.cancel()
        
        // Invalidate cache immediately for responsive UI
        invalidateCache()
        
        searchTask = Task { @MainActor [weak self] in
            guard let self = self else { return }
            
            do {
                try await Task.sleep(nanoseconds: UInt64(searchDebounceTime * 1_000_000_000))
            
                // Check if task was cancelled
                try Task.checkCancellation()
                
                // @Observable automatically triggers UI updates
                // The filteredPlayers computed property will recalculate with the new search query
                
            } catch is CancellationError {
                // Task was cancelled, which is expected behavior
                return
            } catch {
                // Handle other potential errors
                logger.error("Search task failed: \(error.localizedDescription)")
            }
        }
    }
    
    /// Apply sorting synchronously for immediate UI updates
    private func applySortingSync() {
        invalidateCache()
        // @Observable automatically handles change notifications
    }
    
    /// Invalidate the filtered players cache
    private func invalidateCache() {
        _cachedFilteredPlayers = []
        _lastSearchQuery = ""
        _lastSortOption = .nameAscending
        _lastPlayerCount = 0
    }
}

// MARK: - Sort Options
enum PlayerSortOption: String, CaseIterable, Identifiable {
    case nameAscending = "Name (A→Z)"
    case nameDescending = "Name (Z→A)"
    case skillLowToHigh = "Skill (Low→High)"
    case skillHighToLow = "Skill (High→Low)"
    
    var id: String { self.rawValue }
    
    var systemImage: String {
        switch self {
        case .nameAscending:
            return "textformat.abc"
        case .nameDescending:
            return "textformat.abc"
        case .skillLowToHigh:
            return "arrow.up.circle"
        case .skillHighToLow:
            return "arrow.down.circle"
        }
    }
} 