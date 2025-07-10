import XCTest
@testable import TeamGen

final class TeamEntityTests: XCTestCase {
    // MARK: - TeamEntity Initialization Tests

    func testTeamEntity_InitializationWithPlayers_Success() {
        // Given
        let players = createTestPlayers(count: 3)

        // When
        var team = TeamEntity(players: players)

        // Then
        XCTAssertEqual(team.players.count, 3)
        XCTAssertEqual(team.totalPlayers, 3)
        XCTAssertNotNil(team.id)
        XCTAssertEqual(team.averageRank, 0.0) // Should be calculated

        // Trigger metric calculation
        team.calculateMetrics()
        XCTAssertGreaterThan(team.averageRank, 0.0)
    }

    func testTeamEntity_EmptyTeam_Success() {
        // Given/When
        var team = TeamEntity(players: [])

        // Then
        XCTAssertEqual(team.players.count, 0)
        XCTAssertEqual(team.totalPlayers, 0)
        XCTAssertEqual(team.averageRank, 0.0)

        // Test metric calculation with empty team
        team.calculateMetrics()
        XCTAssertEqual(team.averageRank, 0.0)
        XCTAssertEqual(team.strengthLevel, .weak)
    }

    // MARK: - Metric Calculation Tests

    func testTeamEntity_CalculateMetrics_Success() {
        // Given
        let players = [
            createPlayer(name: "Player 1", technical: 8, agility: 7, endurance: 6, teamwork: 9), // Overall: 7.5
            createPlayer(name: "Player 2", technical: 6, agility: 8, endurance: 7, teamwork: 7), // Overall: 7.0
            createPlayer(name: "Player 3", technical: 9, agility: 6, endurance: 8, teamwork: 8), // Overall: 7.75
        ]
        var team = TeamEntity(players: players)

        // When
        team.calculateMetrics()

        // Then
        let expectedAverage = (7.5 + 7.0 + 7.75) / 3.0 // ≈ 7.42
        XCTAssertEqual(team.averageRank, expectedAverage, accuracy: 0.01)
        XCTAssertEqual(team.strengthLevel, TeamStrengthLevel(from: expectedAverage))
    }

    func testTeamEntity_SkillVariance_Calculation() {
        // Given
        let players = [
            createPlayer(name: "Player 1", technical: 10, agility: 10, endurance: 10, teamwork: 10), // Overall: 10.0
            createPlayer(name: "Player 2", technical: 1, agility: 1, endurance: 1, teamwork: 1), // Overall: 1.0
            createPlayer(name: "Player 3", technical: 5, agility: 5, endurance: 5, teamwork: 7), // Overall: 5.5
        ]
        let team = TeamEntity(players: players)

        // When
        let variance = team.skillVariance
        let standardDeviation = team.skillStandardDeviation

        // Then
        XCTAssertGreaterThan(variance, 0) // Should have significant variance
        XCTAssertGreaterThan(standardDeviation, 0) // Should have significant standard deviation
        XCTAssertEqual(standardDeviation, sqrt(variance), accuracy: 0.001)
    }

    func testTeamEntity_SkillRange_Calculation() {
        // Given
        let players = [
            createPlayer(name: "Player 1", technical: 10, agility: 10, endurance: 10, teamwork: 10), // Overall: 10.0
            createPlayer(name: "Player 2", technical: 3, agility: 3, endurance: 3, teamwork: 3), // Overall: 3.0
            createPlayer(name: "Player 3", technical: 7, agility: 7, endurance: 7, teamwork: 7), // Overall: 7.0
        ]
        let team = TeamEntity(players: players)

        // When
        let minSkill = team.minSkillLevel
        let maxSkill = team.maxSkillLevel
        let skillRange = team.skillRange

        // Then
        XCTAssertEqual(minSkill, 3.0)
        XCTAssertEqual(maxSkill, 10.0)
        XCTAssertEqual(skillRange, 7.0)
    }

    // MARK: - Skill Breakdown Tests

    func testTeamEntity_SkillBreakdown_Calculation() {
        // Given
        let players = [
            createPlayer(name: "Player 1", technical: 8, agility: 6, endurance: 7, teamwork: 9),
            createPlayer(name: "Player 2", technical: 6, agility: 8, endurance: 5, teamwork: 7),
        ]
        let team = TeamEntity(players: players)

        // When
        let breakdown = team.skillBreakdown

        // Then
        XCTAssertEqual(breakdown.technical, 7.0, accuracy: 0.01) // (8+6)/2 = 7.0
        XCTAssertEqual(breakdown.agility, 7.0, accuracy: 0.01) // (6+8)/2 = 7.0
        XCTAssertEqual(breakdown.endurance, 6.0, accuracy: 0.01) // (7+5)/2 = 6.0
        XCTAssertEqual(breakdown.teamwork, 8.0, accuracy: 0.01) // (9+7)/2 = 8.0
    }

    func testTeamEntity_SkillBreakdown_EmptyTeam() {
        // Given
        let team = TeamEntity(players: [])

        // When
        let breakdown = team.skillBreakdown

        // Then
        XCTAssertEqual(breakdown.technical, 0.0)
        XCTAssertEqual(breakdown.agility, 0.0)
        XCTAssertEqual(breakdown.endurance, 0.0)
        XCTAssertEqual(breakdown.teamwork, 0.0)
    }

    // MARK: - Team Composition Tests

    func testTeamEntity_CompositionAnalysis_MixedSkills() {
        // Given
        let players = [
            createPlayer(name: "Beginner", technical: 1, agility: 1, endurance: 1, teamwork: 1),
            // Overall: 1.0 (Beginner)
            createPlayer(name: "Novice", technical: 3, agility: 3, endurance: 3, teamwork: 3), // Overall: 3.0 (Novice)
            createPlayer(name: "Intermediate", technical: 5, agility: 5, endurance: 5, teamwork: 5),
            // Overall: 5.0 (Intermediate)
            createPlayer(name: "Advanced", technical: 7, agility: 7, endurance: 7, teamwork: 7),
            // Overall: 7.0 (Advanced)
            createPlayer(name: "Expert", technical: 9, agility: 9, endurance: 9, teamwork: 9), // Overall: 9.0 (Expert)
        ]
        let team = TeamEntity(players: players)

        // When
        let composition = team.compositionAnalysis

        // Then
        XCTAssertEqual(composition.beginners, 1)
        XCTAssertEqual(composition.novices, 1)
        XCTAssertEqual(composition.intermediates, 1)
        XCTAssertEqual(composition.advanced, 1)
        XCTAssertEqual(composition.experts, 1)
        XCTAssertEqual(composition.total, 5)
    }

    // MARK: - Team Validation Tests

    func testTeamEntity_ValidateComposition_ValidTeam() {
        // Given
        let players = createTestPlayers(count: 4)
        let team = TeamEntity(players: players)

        // When
        let validation = team.validateComposition()

        // Then
        XCTAssertTrue(validation.isValid)
        XCTAssertTrue(validation.issues.isEmpty)
    }

    func testTeamEntity_ValidateComposition_EmptyTeam() {
        // Given
        let team = TeamEntity(players: [])

        // When
        let validation = team.validateComposition()

        // Then
        XCTAssertFalse(validation.isValid)
        XCTAssertTrue(validation.issues.contains { issue in
            if case .emptyTeam = issue { return true }
            return false
        })
    }

    func testTeamEntity_ValidateComposition_SinglePlayer() {
        // Given
        let players = createTestPlayers(count: 1)
        let team = TeamEntity(players: players)

        // When
        let validation = team.validateComposition()

        // Then
        XCTAssertTrue(validation.isValid) // Single player is valid, but has warnings
        XCTAssertTrue(validation.warnings.contains { warning in
            if case .singlePlayer = warning { return true }
            return false
        })
    }

    func testTeamEntity_ValidateComposition_LargeSkillGap() {
        // Given
        let players = [
            createPlayer(name: "Beginner", technical: 1, agility: 1, endurance: 1, teamwork: 1), // Overall: 1.0
            createPlayer(name: "Expert", technical: 10, agility: 10, endurance: 10, teamwork: 10), // Overall: 10.0
        ]
        let team = TeamEntity(players: players)

        // When
        let validation = team.validateComposition()

        // Then
        XCTAssertTrue(validation.isValid) // Valid but has warnings
        let hasLargeSkillGapWarning = validation.warnings.contains { warning in
            if case .largeSkillGap = warning { return true }
            return false
        }
        XCTAssertTrue(hasLargeSkillGapWarning)
    }

    // MARK: - Team Management Tests

    func testTeamEntity_AddPlayer_Success() throws {
        // Given
        var team = TeamEntity(players: [])
        let newPlayer = createPlayer(name: "New Player", technical: 5, agility: 5, endurance: 5, teamwork: 5)

        // When
        try team.addPlayer(newPlayer)

        // Then
        XCTAssertEqual(team.players.count, 1)
        XCTAssertEqual(team.players.first?.id, newPlayer.id)
        XCTAssertGreaterThan(team.averageRank, 0) // Metrics should be updated
    }

    func testTeamEntity_AddPlayer_DuplicatePlayer_ThrowsError() {
        // Given
        let player = createPlayer(name: "Player", technical: 5, agility: 5, endurance: 5, teamwork: 5)
        var team = TeamEntity(players: [player])

        // When/Then
        XCTAssertThrowsError(try team.addPlayer(player)) { error in
            XCTAssertTrue(error is TeamValidationError)
            if case let .playerAlreadyInTeam(name) = error as? TeamValidationError {
                XCTAssertEqual(name, "Player")
            }
        }
    }

    func testTeamEntity_RemovePlayer_Success() throws {
        // Given
        let player1 = createPlayer(name: "Player 1", technical: 5, agility: 5, endurance: 5, teamwork: 5)
        let player2 = createPlayer(name: "Player 2", technical: 6, agility: 6, endurance: 6, teamwork: 6)
        var team = TeamEntity(players: [player1, player2])

        // When
        try team.removePlayer(withId: player1.id)

        // Then
        XCTAssertEqual(team.players.count, 1)
        XCTAssertEqual(team.players.first?.id, player2.id)
    }

    func testTeamEntity_RemovePlayer_NonexistentPlayer_ThrowsError() {
        // Given
        let player = createPlayer(name: "Player", technical: 5, agility: 5, endurance: 5, teamwork: 5)
        var team = TeamEntity(players: [player])
        let nonexistentId = UUID()

        // When/Then
        XCTAssertThrowsError(try team.removePlayer(withId: nonexistentId)) { error in
            XCTAssertTrue(error is TeamValidationError)
            if case .playerNotFound = error as? TeamValidationError {
                // Expected
            } else {
                XCTFail("Expected playerNotFound error")
            }
        }
    }

    // MARK: - Team Comparison Tests

    func testTeamEntity_CompareBalance_WellBalanced() {
        // Given
        let players1 = createTestPlayers(count: 3, baseSkill: 7)
        let players2 = createTestPlayers(count: 3, baseSkill: 7)
        var team1 = TeamEntity(players: players1)
        var team2 = TeamEntity(players: players2)

        team1.calculateMetrics()
        team2.calculateMetrics()

        // When
        let comparison = team1.compareBalance(with: team2)

        // Then
        XCTAssertLessThan(comparison.skillDifference, 1.0)
        XCTAssertTrue(comparison.isWellBalanced)
        XCTAssertNotEqual(comparison.recommendation, .rebalanceNeeded)
    }

    func testTeamEntity_CompareBalance_Unbalanced() {
        // Given
        let lowSkillPlayers = createTestPlayers(count: 3, baseSkill: 3)
        let highSkillPlayers = createTestPlayers(count: 3, baseSkill: 9)
        var team1 = TeamEntity(players: lowSkillPlayers)
        var team2 = TeamEntity(players: highSkillPlayers)

        team1.calculateMetrics()
        team2.calculateMetrics()

        // When
        let comparison = team1.compareBalance(with: team2)

        // Then
        XCTAssertGreaterThan(comparison.skillDifference, 2.0)
        XCTAssertFalse(comparison.isWellBalanced)
        XCTAssertEqual(comparison.recommendation, .rebalanceNeeded)
    }

    // MARK: - TeamStrengthLevel Tests

    func testTeamStrengthLevel_FromAverageRank_AllLevels() {
        // Given/When/Then
        XCTAssertEqual(TeamStrengthLevel(from: 2.0), .weak)
        XCTAssertEqual(TeamStrengthLevel(from: 5.0), .average)
        XCTAssertEqual(TeamStrengthLevel(from: 7.0), .strong)
        XCTAssertEqual(TeamStrengthLevel(from: 9.0), .elite)
    }

    func testTeamStrengthLevel_DisplayNames() {
        // Given/When/Then
        XCTAssertEqual(TeamStrengthLevel.weak.displayName, "Developing")
        XCTAssertEqual(TeamStrengthLevel.average.displayName, "Balanced")
        XCTAssertEqual(TeamStrengthLevel.strong.displayName, "Strong")
        XCTAssertEqual(TeamStrengthLevel.elite.displayName, "Elite")
    }

    // MARK: - BalanceQuality Tests

    func testBalanceQuality_DisplayNames() {
        // Given/When/Then
        XCTAssertEqual(BalanceQuality.excellent.displayName, "Excellent")
        XCTAssertEqual(BalanceQuality.good.displayName, "Good")
        XCTAssertEqual(BalanceQuality.fair.displayName, "Fair")
        XCTAssertEqual(BalanceQuality.poor.displayName, "Poor")
        XCTAssertEqual(BalanceQuality.veryPoor.displayName, "Very Poor")
    }

    // MARK: - Helper Methods

    private func createTestPlayers(count: Int, baseSkill: Int = 5) -> [PlayerEntity] {
        (0 ..< count).map { index in
            createPlayer(
                name: "Player \(index + 1)",
                technical: baseSkill + (index % 3),
                agility: baseSkill + (index % 2),
                endurance: baseSkill + (index % 4),
                teamwork: baseSkill + (index % 3)
            )
        }
    }

    private func createPlayer(name: String, technical: Int, agility: Int, endurance: Int,
                              teamwork: Int) -> PlayerEntity
    {
        let skills = PlayerSkills(technical: technical, agility: agility, endurance: endurance, teamwork: teamwork)
        return PlayerEntity(name: name, skills: skills)
    }
}
