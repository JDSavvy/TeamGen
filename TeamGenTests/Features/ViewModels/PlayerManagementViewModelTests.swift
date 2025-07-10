import XCTest
@testable import TeamGen

@MainActor
final class PlayerManagementViewModelTests: XCTestCase {
    private var viewModel: PlayerManagementViewModel!
    private var mockManagePlayersUseCase: MockManagePlayersUseCase!
    private var mockHapticService: MockHapticService!

    override func setUpWithError() throws {
        mockManagePlayersUseCase = MockManagePlayersUseCase()
        mockHapticService = MockHapticService()

        viewModel = PlayerManagementViewModel(
            managePlayersUseCase: mockManagePlayersUseCase,
            hapticService: mockHapticService
        )
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockManagePlayersUseCase = nil
        mockHapticService = nil
    }

    // MARK: - Initialization Tests

    func testViewModel_Initialization_CorrectInitialState() {
        // Then
        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertEqual(viewModel.players.count, 0)
        XCTAssertEqual(viewModel.selectedPlayersCount, 0)
        XCTAssertFalse(viewModel.hasPlayers)
        XCTAssertFalse(viewModel.hasSelectedPlayers)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    // MARK: - Load Players Tests

    func testLoadPlayers_Success_UpdatesStateAndPlayers() async {
        // Given
        let mockPlayers = [
            createTestPlayer(name: "Player 1"),
            createTestPlayer(name: "Player 2", isSelected: true),
        ]
        mockManagePlayersUseCase.mockPlayers = mockPlayers

        // When
        await viewModel.loadPlayers()

        // Then
        XCTAssertEqual(viewModel.state, .loaded(mockPlayers))
        XCTAssertEqual(viewModel.players.count, 2)
        XCTAssertEqual(viewModel.selectedPlayersCount, 1)
        XCTAssertTrue(viewModel.hasPlayers)
        XCTAssertTrue(viewModel.hasSelectedPlayers)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadPlayers_EmptyResult_UpdatesStateToEmpty() async {
        // Given
        mockManagePlayersUseCase.mockPlayers = []

        // When
        await viewModel.loadPlayers()

        // Then
        XCTAssertEqual(viewModel.state, .empty)
        XCTAssertEqual(viewModel.players.count, 0)
        XCTAssertFalse(viewModel.hasPlayers)
        XCTAssertFalse(viewModel.hasSelectedPlayers)
    }

    func testLoadPlayers_Error_UpdatesStateToError() async {
        // Given
        mockManagePlayersUseCase.shouldThrowError = true

        // When
        await viewModel.loadPlayers()

        // Then
        if case let .error(errorMessage) = viewModel.state {
            XCTAssertFalse(errorMessage.isEmpty)
        } else {
            XCTFail("Expected error state")
        }
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testLoadPlayers_LoadingState_SetsLoadingCorrectly() async {
        // Given
        mockManagePlayersUseCase.delayDuration = 0.1 // Add delay to observe loading state

        // When
        let loadTask = Task {
            await viewModel.loadPlayers()
        }

        // Check loading state immediately
        XCTAssertEqual(viewModel.state, .loading)
        XCTAssertTrue(viewModel.isLoading)

        // Wait for completion
        await loadTask.value

        // Then
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Add Player Tests

    func testAddPlayer_ValidData_Success() async {
        // Given
        let playerName = "New Player"
        let skills = PlayerSkills(technical: 8, agility: 7, endurance: 6, teamwork: 9)
        let newPlayer = PlayerEntity(name: playerName, skills: skills)

        mockManagePlayersUseCase.mockAddedPlayer = newPlayer
        mockManagePlayersUseCase.mockPlayers = [newPlayer]

        // When
        await viewModel.addPlayer(name: playerName, skills: skills)

        // Then
        XCTAssertEqual(mockManagePlayersUseCase.addPlayerCallCount, 1)
        XCTAssertEqual(mockManagePlayersUseCase.lastAddedPlayerName, playerName)
        XCTAssertEqual(mockHapticService.successCallCount, 1)

        // Should reload players after adding
        XCTAssertEqual(viewModel.players.count, 1)
        XCTAssertEqual(viewModel.players.first?.name, playerName)
    }

    func testAddPlayer_InvalidData_ShowsError() async {
        // Given
        mockManagePlayersUseCase.shouldThrowError = true

        // When
        await viewModel.addPlayer(name: "", skills: PlayerSkills(technical: 5, agility: 5, endurance: 5, teamwork: 5))

        // Then
        XCTAssertEqual(mockHapticService.errorCallCount, 1)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    // MARK: - Update Player Tests

    func testUpdatePlayer_Success() async {
        // Given
        let originalPlayer = createTestPlayer(name: "Original Name")
        let updatedPlayer = PlayerEntity(
            id: originalPlayer.id,
            name: "Updated Name",
            skills: originalPlayer.skills,
            statistics: originalPlayer.statistics,
            isSelected: originalPlayer.isSelected
        )

        mockManagePlayersUseCase.mockPlayers = [updatedPlayer]

        // When
        await viewModel.updatePlayer(updatedPlayer)

        // Then
        XCTAssertEqual(mockManagePlayersUseCase.updatePlayerCallCount, 1)
        XCTAssertEqual(mockHapticService.successCallCount, 1)
    }

    func testUpdatePlayer_Error_ShowsError() async {
        // Given
        let player = createTestPlayer(name: "Test Player")
        mockManagePlayersUseCase.shouldThrowError = true

        // When
        await viewModel.updatePlayer(player)

        // Then
        XCTAssertEqual(mockHapticService.errorCallCount, 1)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    // MARK: - Delete Player Tests

    func testDeletePlayer_Success() async {
        // Given
        let player = createTestPlayer(name: "To Delete")
        mockManagePlayersUseCase.mockPlayers = [] // Empty after deletion

        // When
        await viewModel.deletePlayer(id: player.id)

        // Then
        XCTAssertEqual(mockManagePlayersUseCase.deletePlayerCallCount, 1)
        XCTAssertEqual(mockManagePlayersUseCase.lastDeletedPlayerId, player.id)
        XCTAssertEqual(mockHapticService.successCallCount, 1)
    }

    func testDeletePlayer_Error_ShowsError() async {
        // Given
        let playerId = UUID()
        mockManagePlayersUseCase.shouldThrowError = true

        // When
        await viewModel.deletePlayer(id: playerId)

        // Then
        XCTAssertEqual(mockHapticService.errorCallCount, 1)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    // MARK: - Toggle Selection Tests

    func testTogglePlayerSelection_Success() async {
        // Given
        let player = createTestPlayer(name: "Test Player", isSelected: false)
        let toggledPlayer = PlayerEntity(
            id: player.id,
            name: player.name,
            skills: player.skills,
            statistics: player.statistics,
            isSelected: true
        )

        mockManagePlayersUseCase.mockPlayers = [toggledPlayer]

        // When
        await viewModel.togglePlayerSelection(id: player.id)

        // Then
        XCTAssertEqual(mockManagePlayersUseCase.togglePlayerSelectionCallCount, 1)
        XCTAssertEqual(mockManagePlayersUseCase.lastToggledPlayerId, player.id)
        XCTAssertEqual(mockHapticService.selectionCallCount, 1)
    }

    func testTogglePlayerSelection_Error_ShowsError() async {
        // Given
        let playerId = UUID()
        mockManagePlayersUseCase.shouldThrowError = true

        // When
        await viewModel.togglePlayerSelection(id: playerId)

        // Then
        XCTAssertEqual(mockHapticService.errorCallCount, 1)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    // MARK: - Reset All Selections Tests

    func testResetAllSelections_Success() async {
        // Given
        let players = [
            createTestPlayer(name: "Player 1", isSelected: true),
            createTestPlayer(name: "Player 2", isSelected: true),
        ]
        let unselectedPlayers = players.map { player in
            PlayerEntity(
                id: player.id,
                name: player.name,
                skills: player.skills,
                statistics: player.statistics,
                isSelected: false
            )
        }

        mockManagePlayersUseCase.mockPlayers = unselectedPlayers

        // When
        await viewModel.resetAllSelections()

        // Then
        XCTAssertEqual(mockManagePlayersUseCase.resetAllSelectionsCallCount, 1)
        XCTAssertEqual(mockHapticService.impactCallCount, 1)
    }

    func testResetAllSelections_Error_ShowsError() async {
        // Given
        mockManagePlayersUseCase.shouldThrowError = true

        // When
        await viewModel.resetAllSelections()

        // Then
        XCTAssertEqual(mockHapticService.errorCallCount, 1)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    // MARK: - Search and Filter Tests

    func testSearchPlayers_FiltersByName() async {
        // Given
        let players = [
            createTestPlayer(name: "John Doe"),
            createTestPlayer(name: "Jane Smith"),
            createTestPlayer(name: "Bob Johnson"),
        ]
        mockManagePlayersUseCase.mockPlayers = players
        await viewModel.loadPlayers()

        // When
        viewModel.searchQuery = "John"

        // Then
        let filteredPlayers = viewModel.filteredPlayers
        XCTAssertEqual(filteredPlayers.count, 2) // John Doe and Bob Johnson
        XCTAssertTrue(filteredPlayers.contains { $0.name == "John Doe" })
        XCTAssertTrue(filteredPlayers.contains { $0.name == "Bob Johnson" })
    }

    func testSearchPlayers_EmptyQuery_ReturnsAllPlayers() async {
        // Given
        let players = [
            createTestPlayer(name: "Player 1"),
            createTestPlayer(name: "Player 2"),
        ]
        mockManagePlayersUseCase.mockPlayers = players
        await viewModel.loadPlayers()

        // When
        viewModel.searchQuery = ""

        // Then
        let filteredPlayers = viewModel.filteredPlayers
        XCTAssertEqual(filteredPlayers.count, 2)
    }

    // MARK: - Error Handling Tests

    func testDismissError_ClearsErrorState() async {
        // Given
        mockManagePlayersUseCase.shouldThrowError = true
        await viewModel.loadPlayers() // This should set error state

        XCTAssertNotNil(viewModel.errorMessage)

        // When
        viewModel.dismissError()

        // Then
        XCTAssertNil(viewModel.errorMessage)
    }

    // MARK: - Computed Properties Tests

    func testSelectedPlayersCount_CalculatesCorrectly() async {
        // Given
        let players = [
            createTestPlayer(name: "Selected 1", isSelected: true),
            createTestPlayer(name: "Selected 2", isSelected: true),
            createTestPlayer(name: "Unselected", isSelected: false),
        ]
        mockManagePlayersUseCase.mockPlayers = players
        await viewModel.loadPlayers()

        // Then
        XCTAssertEqual(viewModel.selectedPlayersCount, 2)
    }

    func testHasSelectedPlayers_ReturnsTrueWhenPlayersSelected() async {
        // Given
        let players = [createTestPlayer(name: "Selected", isSelected: true)]
        mockManagePlayersUseCase.mockPlayers = players
        await viewModel.loadPlayers()

        // Then
        XCTAssertTrue(viewModel.hasSelectedPlayers)
    }

    func testHasSelectedPlayers_ReturnsFalseWhenNoPlayersSelected() async {
        // Given
        let players = [createTestPlayer(name: "Unselected", isSelected: false)]
        mockManagePlayersUseCase.mockPlayers = players
        await viewModel.loadPlayers()

        // Then
        XCTAssertFalse(viewModel.hasSelectedPlayers)
    }

    // MARK: - Helper Methods

    private func createTestPlayer(name: String, isSelected: Bool = false) -> PlayerEntity {
        let skills = PlayerSkills(technical: 5, agility: 5, endurance: 5, teamwork: 5)
        return PlayerEntity(name: name, skills: skills, isSelected: isSelected)
    }
}

// MARK: - Mock Use Case

private class MockManagePlayersUseCase: ManagePlayersUseCaseProtocol {
    var mockPlayers: [PlayerEntity] = []
    var mockAddedPlayer: PlayerEntity?
    var shouldThrowError = false
    var delayDuration: TimeInterval = 0

    // Call tracking
    var addPlayerCallCount = 0
    var updatePlayerCallCount = 0
    var deletePlayerCallCount = 0
    var togglePlayerSelectionCallCount = 0
    var resetAllSelectionsCallCount = 0

    var lastAddedPlayerName: String?
    var lastDeletedPlayerId: UUID?
    var lastToggledPlayerId: UUID?

    func addPlayer(name: String, skills: PlayerSkills) async throws -> PlayerEntity {
        addPlayerCallCount += 1
        lastAddedPlayerName = name

        if delayDuration > 0 {
            try await Task.sleep(nanoseconds: UInt64(delayDuration * 1_000_000_000))
        }

        if shouldThrowError {
            throw ValidationError.invalidPlayerName
        }

        return mockAddedPlayer ?? PlayerEntity(name: name, skills: skills)
    }

    func updatePlayer(_: PlayerEntity) async throws {
        updatePlayerCallCount += 1

        if shouldThrowError {
            throw ValidationError.invalidPlayerName
        }
    }

    func deletePlayer(id: UUID) async throws {
        deletePlayerCallCount += 1
        lastDeletedPlayerId = id

        if shouldThrowError {
            throw RepositoryError.notFound(id: id)
        }
    }

    func togglePlayerSelection(id: UUID) async throws {
        togglePlayerSelectionCallCount += 1
        lastToggledPlayerId = id

        if shouldThrowError {
            throw RepositoryError.notFound(id: id)
        }
    }

    func updatePlayerSelection(id: UUID, isSelected _: Bool) async throws {
        if shouldThrowError {
            throw RepositoryError.notFound(id: id)
        }
    }

    func resetAllSelections() async throws {
        resetAllSelectionsCallCount += 1

        if shouldThrowError {
            throw RepositoryError.operationFailed("Failed to reset selections")
        }
    }

    func getAllPlayers() async throws -> [PlayerEntity] {
        if delayDuration > 0 {
            try await Task.sleep(nanoseconds: UInt64(delayDuration * 1_000_000_000))
        }

        if shouldThrowError {
            throw RepositoryError.operationFailed("Failed to fetch players")
        }

        return mockPlayers
    }

    func getSelectedPlayers() async throws -> [PlayerEntity] {
        if shouldThrowError {
            throw RepositoryError.operationFailed("Failed to fetch selected players")
        }

        return mockPlayers.filter(\.isSelected)
    }
}

// MARK: - Mock Haptic Service

private class MockHapticService: HapticServiceProtocol {
    var impactCallCount = 0
    var selectionCallCount = 0
    var successCallCount = 0
    var errorCallCount = 0

    func impact(_: HapticIntensity) async {
        impactCallCount += 1
    }

    func selection() async {
        selectionCallCount += 1
    }

    func notification(_: HapticNotificationType) async {
        // Handle different notification types if needed
    }

    func success() async {
        successCallCount += 1
    }

    func error() async {
        errorCallCount += 1
    }

    func warning() async {
        // Handle warning if needed
    }

    func provideGenerationFeedback(balanceScore _: Double) async {
        // Handle generation feedback if needed
    }
}
