import XCTest
@testable import TeamGen

@MainActor
final class ManagePlayersUseCaseTests: XCTestCase {
    private var useCase: ManagePlayersUseCase!
    private var mockRepository: MockPlayerRepository!

    override func setUpWithError() throws {
        mockRepository = MockPlayerRepository()
        useCase = ManagePlayersUseCase(playerRepository: mockRepository)
    }

    override func tearDownWithError() throws {
        useCase = nil
        mockRepository = nil
    }

    // MARK: - Add Player Tests

    func testAddPlayer_ValidData_Success() async throws {
        // Given
        let playerName = "John Doe"
        let skills = PlayerSkills(technical: 8, agility: 7, endurance: 6, teamwork: 9)

        // When
        let result = try await useCase.addPlayer(name: playerName, skills: skills)

        // Then
        XCTAssertEqual(result.name, playerName)
        XCTAssertEqual(result.skills.technical, 8)
        XCTAssertEqual(result.skills.agility, 7)
        XCTAssertEqual(result.skills.endurance, 6)
        XCTAssertEqual(result.skills.teamwork, 9)
        XCTAssertFalse(result.isSelected)

        // Verify repository was called
        XCTAssertEqual(mockRepository.saveCallCount, 1)
    }

    func testAddPlayer_EmptyName_ThrowsError() async {
        // Given
        let playerName = ""
        let skills = PlayerSkills(technical: 8, agility: 7, endurance: 6, teamwork: 9)

        // When/Then
        do {
            _ = try await useCase.addPlayer(name: playerName, skills: skills)
            XCTFail("Expected ValidationError to be thrown")
        } catch let error as ValidationError {
            XCTAssertEqual(error, ValidationError.invalidPlayerName)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testAddPlayer_WhitespaceOnlyName_ThrowsError() async {
        // Given
        let playerName = "   \n\t  "
        let skills = PlayerSkills(technical: 8, agility: 7, endurance: 6, teamwork: 9)

        // When/Then
        do {
            _ = try await useCase.addPlayer(name: playerName, skills: skills)
            XCTFail("Expected ValidationError to be thrown")
        } catch let error as ValidationError {
            XCTAssertEqual(error, ValidationError.invalidPlayerName)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Update Player Tests

    func testUpdatePlayer_ValidData_Success() async throws {
        // Given
        let player = PlayerEntity(
            name: "Jane Smith",
            skills: PlayerSkills(technical: 7, agility: 8, endurance: 7, teamwork: 8)
        )

        // When
        try await useCase.updatePlayer(player)

        // Then
        XCTAssertEqual(mockRepository.saveCallCount, 1)
    }

    func testUpdatePlayer_InvalidSkillValues_ThrowsError() async {
        // Given
        let player = PlayerEntity(
            name: "Invalid Player",
            skills: PlayerSkills(technical: 11, agility: 0, endurance: 5, teamwork: 15) // Invalid values
        )

        // When/Then
        do {
            try await useCase.updatePlayer(player)
            XCTFail("Expected ValidationError to be thrown")
        } catch is ValidationError {
            // Expected
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Delete Player Tests

    func testDeletePlayer_ExistingPlayer_Success() async throws {
        // Given
        let playerId = UUID()
        let player = PlayerEntity(
            id: playerId,
            name: "Test Player",
            skills: PlayerSkills(technical: 5, agility: 5, endurance: 5, teamwork: 5)
        )
        mockRepository.mockPlayer = player

        // When
        try await useCase.deletePlayer(id: playerId)

        // Then
        XCTAssertEqual(mockRepository.deleteCallCount, 1)
    }

    func testDeletePlayer_NonexistentPlayer_ThrowsError() async {
        // Given
        let playerId = UUID()
        mockRepository.mockPlayer = nil // No player found

        // When/Then
        do {
            try await useCase.deletePlayer(id: playerId)
            XCTFail("Expected RepositoryError to be thrown")
        } catch let error as RepositoryError {
            if case .notFound = error {
                // Expected - player not found
            } else {
                XCTFail("Expected notFound error")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Toggle Selection Tests

    func testTogglePlayerSelection_ExistingPlayer_Success() async throws {
        // Given
        let playerId = UUID()
        let player = PlayerEntity(
            id: playerId,
            name: "Test Player",
            skills: PlayerSkills(technical: 5, agility: 5, endurance: 5, teamwork: 5),
            isSelected: false
        )
        mockRepository.mockPlayer = player

        // When
        try await useCase.togglePlayerSelection(id: playerId)

        // Then
        XCTAssertEqual(mockRepository.updateSelectionCallCount, 1)
        XCTAssertEqual(mockRepository.lastSelectionUpdate?.playerId, playerId)
        XCTAssertEqual(mockRepository.lastSelectionUpdate?.isSelected, true) // Should toggle to true
    }

    // MARK: - Get Players Tests

    func testGetAllPlayers_Success() async throws {
        // Given
        let players = [
            PlayerEntity(name: "Player 1", skills: PlayerSkills(technical: 5, agility: 5, endurance: 5, teamwork: 5)),
            PlayerEntity(name: "Player 2", skills: PlayerSkills(technical: 7, agility: 6, endurance: 8, teamwork: 7)),
        ]
        mockRepository.mockPlayers = players

        // When
        let result = try await useCase.getAllPlayers()

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "Player 1")
        XCTAssertEqual(result[1].name, "Player 2")
    }

    func testGetSelectedPlayers_Success() async throws {
        // Given
        let selectedPlayers = [
            PlayerEntity(
                name: "Selected Player 1",
                skills: PlayerSkills(technical: 5, agility: 5, endurance: 5, teamwork: 5),
                isSelected: true
            ),
            PlayerEntity(
                name: "Selected Player 2",
                skills: PlayerSkills(technical: 7, agility: 6, endurance: 8, teamwork: 7),
                isSelected: true
            ),
        ]
        mockRepository.mockSelectedPlayers = selectedPlayers

        // When
        let result = try await useCase.getSelectedPlayers()

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy(\.isSelected))
    }

    // MARK: - Reset Selections Tests

    func testResetAllSelections_Success() async throws {
        // When
        try await useCase.resetAllSelections()

        // Then
        XCTAssertEqual(mockRepository.resetAllSelectionsCallCount, 1)
    }
}

// MARK: - Mock Player Repository

private class MockPlayerRepository: PlayerRepositoryProtocol {
    var mockPlayers: [PlayerEntity] = []
    var mockSelectedPlayers: [PlayerEntity] = []
    var mockPlayer: PlayerEntity?

    var saveCallCount = 0
    var deleteCallCount = 0
    var updateSelectionCallCount = 0
    var resetAllSelectionsCallCount = 0

    var lastSelectionUpdate: (playerId: UUID, isSelected: Bool)?

    func save(_: PlayerEntity) async throws {
        saveCallCount += 1
    }

    func saveAll(_ players: [PlayerEntity]) async throws {
        saveCallCount += players.count
    }

    func fetch(id _: UUID) async throws -> PlayerEntity? {
        mockPlayer
    }

    func fetchAll() async throws -> [PlayerEntity] {
        mockPlayers
    }

    func fetchSelected() async throws -> [PlayerEntity] {
        mockSelectedPlayers
    }

    func delete(id _: UUID) async throws {
        deleteCallCount += 1
        if mockPlayer == nil {
            throw RepositoryError.notFound
        }
    }

    func deleteAll(ids: [UUID]) async throws {
        deleteCallCount += ids.count
    }

    func updateSelection(id: UUID, isSelected: Bool) async throws {
        updateSelectionCallCount += 1
        lastSelectionUpdate = (id, isSelected)

        if mockPlayer == nil {
            throw RepositoryError.notFound
        }
    }

    func resetAllSelections() async throws {
        resetAllSelectionsCallCount += 1
    }

    func fetchByMinimumSkillLevel(_ minLevel: Double) async throws -> [PlayerEntity] {
        mockPlayers.filter { $0.skills.overall >= minLevel }
    }

    func hasPlayers() async throws -> Bool {
        !mockPlayers.isEmpty
    }

    func count() async throws -> Int {
        mockPlayers.count
    }
}
