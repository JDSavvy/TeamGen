import XCTest
@testable import TeamGen

@MainActor
final class GenerateTeamsUseCaseTests: XCTestCase {
    private var useCase: GenerateTeamsUseCase!
    private var mockPlayerRepository: MockPlayerRepository!
    private var mockTeamGenerationService: MockTeamGenerationService!

    override func setUpWithError() throws {
        mockPlayerRepository = MockPlayerRepository()
        mockTeamGenerationService = MockTeamGenerationService()
        useCase = GenerateTeamsUseCase(
            playerRepository: mockPlayerRepository,
            teamGenerationService: mockTeamGenerationService
        )
    }

    override func tearDownWithError() throws {
        useCase = nil
        mockPlayerRepository = nil
        mockTeamGenerationService = nil
    }

    // MARK: - Generate Teams Tests

    func testGenerateTeams_ValidInput_Success() async throws {
        // Given
        let players = createTestPlayers(count: 6)
        mockPlayerRepository.mockSelectedPlayers = players

        let expectedTeams = [
            TeamEntity(players: Array(players[0 ..< 3])),
            TeamEntity(players: Array(players[3 ..< 6]))
        ]
        mockTeamGenerationService.mockTeams = expectedTeams

        // When
        let result = try await useCase.execute(teamCount: 2, mode: .fair)

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].players.count, 3)
        XCTAssertEqual(result[1].players.count, 3)

        // Verify service was called with correct parameters
        XCTAssertEqual(mockTeamGenerationService.lastGenerateCall?.teamCount, 2)
        XCTAssertEqual(mockTeamGenerationService.lastGenerateCall?.mode, .fair)
        XCTAssertEqual(mockTeamGenerationService.lastGenerateCall?.players.count, 6)
    }

    func testGenerateTeams_NoSelectedPlayers_ThrowsError() async {
        // Given
        mockPlayerRepository.mockSelectedPlayers = []

        // When/Then
        do {
            _ = try await useCase.execute(teamCount: 2, mode: .fair)
            XCTFail("Expected TeamGenerationError to be thrown")
        } catch let error as TeamGenerationError {
            if case .emptyPlayerList = error {
                // Expected
            } else {
                XCTFail("Expected emptyPlayerList error")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testGenerateTeams_InsufficientPlayers_ThrowsError() async {
        // Given
        let players = createTestPlayers(count: 2)
        mockPlayerRepository.mockSelectedPlayers = players

        // When/Then
        do {
            _ = try await useCase.execute(teamCount: 3, mode: .fair)
            XCTFail("Expected TeamGenerationError to be thrown")
        } catch let error as TeamGenerationError {
            if case let .insufficientPlayers(required, available) = error {
                XCTAssertEqual(required, 3)
                XCTAssertEqual(available, 2)
            } else {
                XCTFail("Expected insufficientPlayers error")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testGenerateTeams_InvalidTeamCount_ThrowsError() async {
        // Given
        let players = createTestPlayers(count: 6)
        mockPlayerRepository.mockSelectedPlayers = players

        // When/Then
        do {
            _ = try await useCase.execute(teamCount: 0, mode: .fair)
            XCTFail("Expected TeamGenerationError to be thrown")
        } catch let error as TeamGenerationError {
            if case .invalidTeamCount = error {
                // Expected
            } else {
                XCTFail("Expected invalidTeamCount error")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Validate Generation Tests

    func testValidateGeneration_ValidInput_Success() async throws {
        // Given
        let players = createTestPlayers(count: 8)
        mockPlayerRepository.mockSelectedPlayers = players

        // When
        let result = try await useCase.validateTeamGeneration(teamCount: 2, mode: .fair)

        // Then
        XCTAssertTrue(result.isValid)
    }

    func testValidateGeneration_InsufficientPlayers_ReturnsInvalid() async throws {
        // Given
        let players = createTestPlayers(count: 2)
        mockPlayerRepository.mockSelectedPlayers = players

        // When
        let result = try await useCase.validateTeamGeneration(teamCount: 4, mode: .fair)

        // Then
        XCTAssertFalse(result.isValid)
    }

    // MARK: - Get Selected Players Count Tests

    func testGetSelectedPlayersCount_Success() async throws {
        // Given
        let players = createTestPlayers(count: 5)
        mockPlayerRepository.mockSelectedPlayers = players

        // When
        let preview = try await useCase.previewTeamDistribution(teamCount: 2)
        let count = preview.playersPerTeam.reduce(0, +)

        // Then
        XCTAssertEqual(count, 5)
    }

    func testGetSelectedPlayersCount_NoPlayers_ReturnsZero() async throws {
        // Given
        mockPlayerRepository.mockSelectedPlayers = []

        // When & Then
        do {
            _ = try await useCase.previewTeamDistribution(teamCount: 2)
            XCTFail("Expected TeamGenerationError to be thrown")
        } catch TeamGenerationError.emptyPlayerList {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Helper Methods

    private func createTestPlayers(count: Int) -> [PlayerEntity] {
        (0 ..< count).map { index in
            PlayerEntity(
                name: "Player \(index + 1)",
                skills: PlayerSkills(
                    technical: 5 + (index % 3),
                    agility: 4 + (index % 4),
                    endurance: 6 + (index % 2),
                    teamwork: 5 + (index % 3)
                ),
                isSelected: true
            )
        }
    }
}

// MARK: - Mock Team Generation Service

private class MockTeamGenerationService: TeamGenerationServiceProtocol {
    var mockTeams: [TeamEntity] = []
    var lastGenerateCall: (players: [PlayerEntity], teamCount: Int, mode: TeamGenerationMode)?

    func generateTeams(from players: [PlayerEntity], count: Int,
                       mode: TeamGenerationMode) async throws -> [TeamEntity] {
        lastGenerateCall = (players, count, mode)

        // Basic validation
        guard !count.isZero else { // swiftlint:disable:this empty_count
            throw TeamGenerationError.invalidTeamCount(count)
        }

        guard !players.isEmpty else {
            throw TeamGenerationError.emptyPlayerList
        }

        guard players.count >= count else {
            throw TeamGenerationError.insufficientPlayers(required: count, available: players.count)
        }

        return mockTeams
    }

    func calculateBalanceScores(for teams: [TeamEntity]) -> [TeamEntity] {
        teams.map { team in
            var updatedTeam = team
            updatedTeam.calculateMetrics()
            return updatedTeam
        }
    }

    func validateGeneration(playerCount: Int, teamCount: Int) -> ValidationResult {
        if teamCount <= 0 {
            return ValidationResult.invalid(.invalidTeamCount(teamCount))
        }

        if playerCount == 0 {
            return ValidationResult.invalid(.emptyPlayerList)
        }

        if playerCount < teamCount {
            return ValidationResult.invalid(.insufficientPlayers(required: teamCount, available: playerCount))
        }

        return .valid
    }

}

// MARK: - Mock Player Repository

private class MockPlayerRepository: PlayerRepositoryProtocol {
    var mockSelectedPlayers: [PlayerEntity] = []
    var mockPlayers: [PlayerEntity] = []

    func fetchAll() async throws -> [PlayerEntity] {
        return mockPlayers
    }

    func fetch(id: UUID) async throws -> PlayerEntity? {
        return mockPlayers.first { $0.id == id }
    }

    func save(_ player: PlayerEntity) async throws {
        if let index = mockPlayers.firstIndex(where: { $0.id == player.id }) {
            mockPlayers[index] = player
        } else {
            mockPlayers.append(player)
        }
    }

    func saveAll(_ players: [PlayerEntity]) async throws {
        for player in players {
            try await save(player)
        }
    }

    func delete(id: UUID) async throws {
        mockPlayers.removeAll { $0.id == id }
        mockSelectedPlayers.removeAll { $0.id == id }
    }

    func deleteAll(ids: [UUID]) async throws {
        for id in ids {
            try await delete(id: id)
        }
    }

    func fetchSelected() async throws -> [PlayerEntity] {
        return mockSelectedPlayers
    }

    func updateSelection(id: UUID, isSelected: Bool) async throws {
        if let index = mockPlayers.firstIndex(where: { $0.id == id }) {
            mockPlayers[index].isSelected = isSelected
            if isSelected {
                if !mockSelectedPlayers.contains(where: { $0.id == id }) {
                    mockSelectedPlayers.append(mockPlayers[index])
                }
            } else {
                mockSelectedPlayers.removeAll { $0.id == id }
            }
        }
    }

    func resetAllSelections() async throws {
        mockSelectedPlayers.removeAll()
        for i in mockPlayers.indices {
            mockPlayers[i].isSelected = false
        }
    }

    func fetchByMinimumSkillLevel(_ minLevel: Double) async throws -> [PlayerEntity] {
        return mockPlayers.filter { $0.skills.overall >= minLevel }
    }

    func hasPlayers() async throws -> Bool {
        return !mockPlayers.isEmpty
    }

    func count() async throws -> Int {
        return mockPlayers.count
    }
}
