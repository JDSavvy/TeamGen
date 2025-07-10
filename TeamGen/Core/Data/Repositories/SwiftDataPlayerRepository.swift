import Foundation
import SwiftData

// MARK: - SwiftData Player Repository

/// Concrete implementation of PlayerRepositoryProtocol using SwiftData
@MainActor
public final class SwiftDataPlayerRepository: PlayerRepositoryProtocol {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func fetchAll() async throws -> [PlayerEntity] {
        // Optimize fetch with sorting at database level
        var descriptor = FetchDescriptor<SchemaV3.PlayerV3>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        descriptor.fetchLimit = 1000 // Reasonable limit for performance

        let players = try modelContext.fetch(descriptor)
        let entities = players.map { $0.toEntity() }
        return entities
    }

    public func fetch(id: UUID) async throws -> PlayerEntity? {
        // Use more efficient predicate
        var descriptor = FetchDescriptor<SchemaV3.PlayerV3>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        let players = try modelContext.fetch(descriptor)
        return players.first?.toEntity()
    }

    public func save(_ player: PlayerEntity) async throws {
        // Optimize with single fetch for existence check
        let playerId = player.id
        var descriptor = FetchDescriptor<SchemaV3.PlayerV3>(
            predicate: #Predicate { $0.id == playerId }
        )
        descriptor.fetchLimit = 1

        let existingPlayers = try modelContext.fetch(descriptor)

        if let existingPlayer = existingPlayers.first {
            // Update existing player
            existingPlayer.updateFromEntity(player)
        } else {
            // Insert new player
            let newPlayer = SchemaV3.PlayerV3.from(player)
            modelContext.insert(newPlayer)
        }

        try modelContext.save()
    }

    public func saveAll(_ players: [PlayerEntity]) async throws {
        // Optimize batch operations by fetching all existing players at once
        let playerIds = players.map(\.id)
        let descriptor = FetchDescriptor<SchemaV3.PlayerV3>(
            predicate: #Predicate { playerIds.contains($0.id) }
        )
        let existingPlayers = try modelContext.fetch(descriptor)
        let existingPlayerDict = Dictionary(uniqueKeysWithValues: existingPlayers.map { ($0.id, $0) })

        // Process all players in batch
        for player in players {
            if let existingPlayer = existingPlayerDict[player.id] {
                existingPlayer.updateFromEntity(player)
            } else {
                let newPlayer = SchemaV3.PlayerV3.from(player)
                modelContext.insert(newPlayer)
            }
        }

        try modelContext.save()
    }

    public func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<SchemaV3.PlayerV3>(
            predicate: #Predicate { $0.id == id }
        )
        let players = try modelContext.fetch(descriptor)

        guard let player = players.first else {
            throw RepositoryError.notFound
        }

        modelContext.delete(player)
        try modelContext.save()
    }

    public func deleteAll(ids: [UUID]) async throws {
        // Optimize batch deletion by fetching all players at once
        let descriptor = FetchDescriptor<SchemaV3.PlayerV3>(
            predicate: #Predicate { ids.contains($0.id) }
        )
        let playersToDelete = try modelContext.fetch(descriptor)

        // Delete all players in batch
        for player in playersToDelete {
            modelContext.delete(player)
        }

        try modelContext.save()
    }

    public func fetchSelected() async throws -> [PlayerEntity] {
        let descriptor = FetchDescriptor<SchemaV3.PlayerV3>(
            predicate: #Predicate { $0.isSelected }
        )
        let players = try modelContext.fetch(descriptor)
        return players.map { $0.toEntity() }
    }

    public func updateSelection(id: UUID, isSelected: Bool) async throws {
        let descriptor = FetchDescriptor<SchemaV3.PlayerV3>(
            predicate: #Predicate { $0.id == id }
        )
        let players = try modelContext.fetch(descriptor)

        guard let player = players.first else {
            throw RepositoryError.notFound
        }

        player.isSelected = isSelected
        try modelContext.save()
    }

    public func resetAllSelections() async throws {
        let descriptor = FetchDescriptor<SchemaV3.PlayerV3>()
        let players = try modelContext.fetch(descriptor)

        for player in players {
            player.isSelected = false
        }

        try modelContext.save()
    }

    public func fetchByMinimumSkillLevel(_ minLevel: Double) async throws -> [PlayerEntity] {
        let descriptor = FetchDescriptor<SchemaV3.PlayerV3>()
        let allPlayers = try modelContext.fetch(descriptor)
        return allPlayers
            .filter { $0.overallRank >= minLevel }
            .map { $0.toEntity() }
    }

    public func hasPlayers() async throws -> Bool {
        var descriptor = FetchDescriptor<SchemaV3.PlayerV3>()
        descriptor.fetchLimit = 1
        let result = try modelContext.fetch(descriptor)
        return !result.isEmpty
    }

    public func count() async throws -> Int {
        let descriptor = FetchDescriptor<SchemaV3.PlayerV3>()
        let players = try modelContext.fetch(descriptor)
        return players.count
    }
}

// RepositoryError is defined in PlayerRepositoryProtocol.swift

// Model mapping extensions are defined in SchemaMigration.swift
