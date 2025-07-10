import Foundation

// MARK: - Player Repository Protocol

/// Defines the contract for player data access operations
public protocol PlayerRepositoryProtocol: Sendable {
    /// Fetches all players from the data store
    func fetchAll() async throws -> [PlayerEntity]

    /// Fetches a specific player by ID
    func fetch(id: UUID) async throws -> PlayerEntity?

    /// Saves a player to the data store
    func save(_ player: PlayerEntity) async throws

    /// Saves multiple players to the data store
    func saveAll(_ players: [PlayerEntity]) async throws

    /// Deletes a player by ID
    func delete(id: UUID) async throws

    /// Deletes multiple players by IDs
    func deleteAll(ids: [UUID]) async throws

    /// Fetches all selected players
    func fetchSelected() async throws -> [PlayerEntity]

    /// Updates player selection status
    func updateSelection(id: UUID, isSelected: Bool) async throws

    /// Resets all player selections
    func resetAllSelections() async throws

    /// Fetches players by minimum skill level
    func fetchByMinimumSkillLevel(_ minLevel: Double) async throws -> [PlayerEntity]

    /// Checks if any players exist
    func hasPlayers() async throws -> Bool

    /// Gets the count of all players
    func count() async throws -> Int
}

// Repository errors are now defined in UserFriendlyError.swift for better UX
