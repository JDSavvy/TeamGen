import Foundation

// MARK: - Manage Players Use Case Protocol

public protocol ManagePlayersUseCaseProtocol {
    func addPlayer(name: String, skills: PlayerSkills) async throws -> PlayerEntity
    func updatePlayer(_ player: PlayerEntity) async throws
    func deletePlayer(id: UUID) async throws
    func togglePlayerSelection(id: UUID) async throws
    func updatePlayerSelection(id: UUID, isSelected: Bool) async throws
    func resetAllSelections() async throws
    func getAllPlayers() async throws -> [PlayerEntity]
    func getSelectedPlayers() async throws -> [PlayerEntity]
}

// MARK: - Manage Players Use Case Implementation

public final class ManagePlayersUseCase: ManagePlayersUseCaseProtocol {
    private let playerRepository: PlayerRepositoryProtocol

    public init(playerRepository: PlayerRepositoryProtocol) {
        self.playerRepository = playerRepository
    }

    public func addPlayer(name: String, skills: PlayerSkills) async throws -> PlayerEntity {
        // Validate player name
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw ValidationError.invalidPlayerName
        }

        // Create new player entity
        let player = PlayerEntity(
            name: trimmedName,
            skills: skills
        )

        // Save to repository
        try await playerRepository.save(player)

        return player
    }

    public func updatePlayer(_ player: PlayerEntity) async throws {
        // Validate player data
        try validatePlayer(player)

        // Save updated player
        try await playerRepository.save(player)
    }

    public func deletePlayer(id: UUID) async throws {
        // Verify player exists
        guard try await (playerRepository.fetch(id: id)) != nil else {
            throw RepositoryError.notFound
        }

        // Delete from repository
        try await playerRepository.delete(id: id)
    }

    public func togglePlayerSelection(id: UUID) async throws {
        // Fetch current player state
        guard let player = try await playerRepository.fetch(id: id) else {
            throw RepositoryError.notFound
        }

        // Toggle selection
        try await playerRepository.updateSelection(
            id: id,
            isSelected: !player.isSelected
        )
    }

    public func updatePlayerSelection(id: UUID, isSelected: Bool) async throws {
        // Verify player exists
        guard try await (playerRepository.fetch(id: id)) != nil else {
            throw RepositoryError.notFound
        }

        // Update selection
        try await playerRepository.updateSelection(
            id: id,
            isSelected: isSelected
        )
    }

    public func resetAllSelections() async throws {
        try await playerRepository.resetAllSelections()
    }

    public func getAllPlayers() async throws -> [PlayerEntity] {
        try await playerRepository.fetchAll()
    }

    public func getSelectedPlayers() async throws -> [PlayerEntity] {
        try await playerRepository.fetchSelected()
    }

    // MARK: - Validation

    private func validatePlayer(_ player: PlayerEntity) throws {
        // Validate name
        guard !player.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.invalidPlayerName
        }

        // Validate skills
        let skills = [player.skills.technical, player.skills.agility, player.skills.endurance, player.skills.teamwork]
        for skill in skills {
            guard (1 ... 10).contains(skill) else {
                throw ValidationError.invalidSkillValue(skill)
            }
        }
    }
}

// MARK: - Validation Errors

public enum ValidationError: LocalizedError, Equatable {
    case invalidPlayerName
    case invalidSkillValue(Int)
    case duplicatePlayerName(String)

    public var errorDescription: String? {
        switch self {
        case .invalidPlayerName:
            "Player name cannot be empty"
        case let .invalidSkillValue(value):
            "Skill value \(value) must be between 1 and 10"
        case let .duplicatePlayerName(name):
            "A player named '\(name)' already exists"
        }
    }
}
