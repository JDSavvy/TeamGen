import SwiftData
import XCTest
@testable import TeamGen

@MainActor
final class SwiftDataPlayerRepositoryTests: XCTestCase {
    private var repository: SwiftDataPlayerRepository!
    private var modelContext: ModelContext!
    private var modelContainer: ModelContainer!

    override func setUpWithError() throws {
        // Create in-memory container for testing
        let schema = Schema([SchemaV3.PlayerV3.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        modelContext = ModelContext(modelContainer)
        repository = SwiftDataPlayerRepository(modelContext: modelContext)
    }

    override func tearDownWithError() throws {
        repository = nil
        modelContext = nil
        modelContainer = nil
    }

    // MARK: - Save Tests

    func testSave_NewPlayer_Success() async throws {
        // Given
        let player = createTestPlayer(name: "John Doe")

        // When
        try await repository.save(player)

        // Then
        let savedPlayer = try await repository.fetch(id: player.id)
        XCTAssertNotNil(savedPlayer)
        XCTAssertEqual(savedPlayer?.name, "John Doe")
        XCTAssertEqual(savedPlayer?.id, player.id)
    }

    func testSave_UpdateExistingPlayer_Success() async throws {
        // Given
        let originalPlayer = createTestPlayer(name: "Original Name")
        try await repository.save(originalPlayer)

        // Update player
        let updatedPlayer = PlayerEntity(
            id: originalPlayer.id,
            name: "Updated Name",
            skills: originalPlayer.skills,
            statistics: originalPlayer.statistics,
            isSelected: true
        )

        // When
        try await repository.save(updatedPlayer)

        // Then
        let savedPlayer = try await repository.fetch(id: originalPlayer.id)
        XCTAssertNotNil(savedPlayer)
        XCTAssertEqual(savedPlayer?.name, "Updated Name")
        XCTAssertTrue(savedPlayer?.isSelected ?? false)
    }

    func testSaveAll_MultiplePlayers_Success() async throws {
        // Given
        let players = [
            createTestPlayer(name: "Player 1"),
            createTestPlayer(name: "Player 2"),
            createTestPlayer(name: "Player 3"),
        ]

        // When
        try await repository.saveAll(players)

        // Then
        let allPlayers = try await repository.fetchAll()
        XCTAssertEqual(allPlayers.count, 3)

        let playerNames = Set(allPlayers.map(\.name))
        XCTAssertTrue(playerNames.contains("Player 1"))
        XCTAssertTrue(playerNames.contains("Player 2"))
        XCTAssertTrue(playerNames.contains("Player 3"))
    }

    // MARK: - Fetch Tests

    func testFetch_ExistingPlayer_Success() async throws {
        // Given
        let player = createTestPlayer(name: "Test Player")
        try await repository.save(player)

        // When
        let fetchedPlayer = try await repository.fetch(id: player.id)

        // Then
        XCTAssertNotNil(fetchedPlayer)
        XCTAssertEqual(fetchedPlayer?.id, player.id)
        XCTAssertEqual(fetchedPlayer?.name, "Test Player")
    }

    func testFetch_NonexistentPlayer_ReturnsNil() async throws {
        // Given
        let nonexistentId = UUID()

        // When
        let fetchedPlayer = try await repository.fetch(id: nonexistentId)

        // Then
        XCTAssertNil(fetchedPlayer)
    }

    func testFetchAll_MultiplePlayers_Success() async throws {
        // Given
        let players = [
            createTestPlayer(name: "Alpha"),
            createTestPlayer(name: "Beta"),
            createTestPlayer(name: "Charlie"),
        ]
        try await repository.saveAll(players)

        // When
        let fetchedPlayers = try await repository.fetchAll()

        // Then
        XCTAssertEqual(fetchedPlayers.count, 3)

        // Should be sorted by name
        let names = fetchedPlayers.map(\.name)
        XCTAssertEqual(names, ["Alpha", "Beta", "Charlie"])
    }

    func testFetchAll_EmptyRepository_ReturnsEmpty() async throws {
        // When
        let fetchedPlayers = try await repository.fetchAll()

        // Then
        XCTAssertEqual(fetchedPlayers.count, 0)
    }

    func testFetchSelected_SelectedPlayers_Success() async throws {
        // Given
        let selectedPlayer1 = createTestPlayer(name: "Selected 1", isSelected: true)
        let selectedPlayer2 = createTestPlayer(name: "Selected 2", isSelected: true)
        let unselectedPlayer = createTestPlayer(name: "Unselected", isSelected: false)

        try await repository.saveAll([selectedPlayer1, selectedPlayer2, unselectedPlayer])

        // When
        let selectedPlayers = try await repository.fetchSelected()

        // Then
        XCTAssertEqual(selectedPlayers.count, 2)
        XCTAssertTrue(selectedPlayers.allSatisfy(\.isSelected))

        let selectedNames = Set(selectedPlayers.map(\.name))
        XCTAssertTrue(selectedNames.contains("Selected 1"))
        XCTAssertTrue(selectedNames.contains("Selected 2"))
        XCTAssertFalse(selectedNames.contains("Unselected"))
    }

    func testFetchByMinimumSkillLevel_FilteredResults_Success() async throws {
        // Given
        let lowSkillPlayer = createTestPlayer(name: "Low Skill", technical: 2, agility: 2, endurance: 2,
                                              teamwork: 2) // Overall: 2.0
        let highSkillPlayer = createTestPlayer(name: "High Skill", technical: 8, agility: 8, endurance: 8,
                                               teamwork: 8) // Overall: 8.0
        let mediumSkillPlayer = createTestPlayer(
            name: "Medium Skill",
            technical: 5,
            agility: 5,
            endurance: 5,
            teamwork: 5
        ) // Overall: 5.0

        try await repository.saveAll([lowSkillPlayer, highSkillPlayer, mediumSkillPlayer])

        // When
        let filteredPlayers = try await repository.fetchByMinimumSkillLevel(6.0)

        // Then
        XCTAssertEqual(filteredPlayers.count, 1)
        XCTAssertEqual(filteredPlayers.first?.name, "High Skill")
    }

    // MARK: - Delete Tests

    func testDelete_ExistingPlayer_Success() async throws {
        // Given
        let player = createTestPlayer(name: "To Delete")
        try await repository.save(player)

        // Verify player exists
        let existingPlayer = try await repository.fetch(id: player.id)
        XCTAssertNotNil(existingPlayer)

        // When
        try await repository.delete(id: player.id)

        // Then
        let deletedPlayer = try await repository.fetch(id: player.id)
        XCTAssertNil(deletedPlayer)
    }

    func testDelete_NonexistentPlayer_ThrowsError() async {
        // Given
        let nonexistentId = UUID()

        // When/Then
        do {
            try await repository.delete(id: nonexistentId)
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

    func testDeleteAll_MultiplePlayers_Success() async throws {
        // Given
        let players = [
            createTestPlayer(name: "Player 1"),
            createTestPlayer(name: "Player 2"),
            createTestPlayer(name: "Player 3"),
            createTestPlayer(name: "Player 4"),
        ]
        try await repository.saveAll(players)

        let idsToDelete = [players[0].id, players[2].id] // Delete players 1 and 3

        // When
        try await repository.deleteAll(ids: idsToDelete)

        // Then
        let remainingPlayers = try await repository.fetchAll()
        XCTAssertEqual(remainingPlayers.count, 2)

        let remainingNames = Set(remainingPlayers.map(\.name))
        XCTAssertTrue(remainingNames.contains("Player 2"))
        XCTAssertTrue(remainingNames.contains("Player 4"))
        XCTAssertFalse(remainingNames.contains("Player 1"))
        XCTAssertFalse(remainingNames.contains("Player 3"))
    }

    // MARK: - Selection Management Tests

    func testUpdateSelection_ExistingPlayer_Success() async throws {
        // Given
        let player = createTestPlayer(name: "Test Player", isSelected: false)
        try await repository.save(player)

        // When
        try await repository.updateSelection(id: player.id, isSelected: true)

        // Then
        let updatedPlayer = try await repository.fetch(id: player.id)
        XCTAssertNotNil(updatedPlayer)
        XCTAssertTrue(updatedPlayer?.isSelected ?? false)
    }

    func testUpdateSelection_NonexistentPlayer_ThrowsError() async {
        // Given
        let nonexistentId = UUID()

        // When/Then
        do {
            try await repository.updateSelection(id: nonexistentId, isSelected: true)
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

    func testResetAllSelections_Success() async throws {
        // Given
        let selectedPlayers = [
            createTestPlayer(name: "Selected 1", isSelected: true),
            createTestPlayer(name: "Selected 2", isSelected: true),
            createTestPlayer(name: "Unselected", isSelected: false),
        ]
        try await repository.saveAll(selectedPlayers)

        // When
        try await repository.resetAllSelections()

        // Then
        let allPlayers = try await repository.fetchAll()
        XCTAssertTrue(allPlayers.allSatisfy { !$0.isSelected })

        let fetchedSelectedPlayers = try await repository.fetchSelected()
        XCTAssertEqual(fetchedSelectedPlayers.count, 0)
    }

    // MARK: - Utility Tests

    func testHasPlayers_WithPlayers_ReturnsTrue() async throws {
        // Given
        let player = createTestPlayer(name: "Test Player")
        try await repository.save(player)

        // When
        let hasPlayers = try await repository.hasPlayers()

        // Then
        XCTAssertTrue(hasPlayers)
    }

    func testHasPlayers_EmptyRepository_ReturnsFalse() async throws {
        // When
        let hasPlayers = try await repository.hasPlayers()

        // Then
        XCTAssertFalse(hasPlayers)
    }

    func testCount_WithPlayers_ReturnsCorrectCount() async throws {
        // Given
        let players = [
            createTestPlayer(name: "Player 1"),
            createTestPlayer(name: "Player 2"),
            createTestPlayer(name: "Player 3"),
        ]
        try await repository.saveAll(players)

        // When
        let count = try await repository.count()

        // Then
        XCTAssertEqual(count, 3)
    }

    func testCount_EmptyRepository_ReturnsZero() async throws {
        // When
        let count = try await repository.count()

        // Then
        XCTAssertEqual(count, 0)
    }

    // MARK: - Performance Tests

    func testFetchAll_LargeDataset_PerformanceTest() async throws {
        // Given
        let largePlayerSet = (0 ..< 100).map { index in
            createTestPlayer(name: "Player \(index)")
        }
        try await repository.saveAll(largePlayerSet)

        // When/Then
        measure {
            Task {
                _ = try await repository.fetchAll()
            }
        }
    }

    // MARK: - Helper Methods

    private func createTestPlayer(
        name: String,
        technical: Int = 5,
        agility: Int = 5,
        endurance: Int = 5,
        teamwork: Int = 5,
        isSelected: Bool = false
    ) -> PlayerEntity {
        let skills = PlayerSkills(technical: technical, agility: agility, endurance: endurance, teamwork: teamwork)
        return PlayerEntity(name: name, skills: skills, isSelected: isSelected)
    }
}
