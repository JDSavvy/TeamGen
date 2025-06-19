import XCTest
@testable import TeamGen

final class PlayerEntityTests: XCTestCase {
    
    // MARK: - PlayerEntity Tests
    
    func testPlayerEntity_Initialization_Success() {
        // Given
        let skills = PlayerSkills(technical: 8, agility: 7, endurance: 6, teamwork: 9)
        let statistics = PlayerStatistics(gamesPlayed: 5, teamsJoined: 3)
        
        // When
        let player = PlayerEntity(
            name: "John Doe",
            skills: skills,
            statistics: statistics,
            isSelected: true
        )
        
        // Then
        XCTAssertEqual(player.name, "John Doe")
        XCTAssertEqual(player.skills.technical, 8)
        XCTAssertEqual(player.skills.agility, 7)
        XCTAssertEqual(player.skills.endurance, 6)
        XCTAssertEqual(player.skills.teamwork, 9)
        XCTAssertEqual(player.statistics.gamesPlayed, 5)
        XCTAssertEqual(player.statistics.teamsJoined, 3)
        XCTAssertTrue(player.isSelected)
        XCTAssertNotNil(player.id)
    }
    
    func testPlayerEntity_DefaultValues_Success() {
        // Given
        let skills = PlayerSkills(technical: 5, agility: 5, endurance: 5, teamwork: 5)
        
        // When
        let player = PlayerEntity(name: "Jane Doe", skills: skills)
        
        // Then
        XCTAssertEqual(player.name, "Jane Doe")
        XCTAssertEqual(player.statistics.gamesPlayed, 0)
        XCTAssertEqual(player.statistics.teamsJoined, 0)
        XCTAssertNil(player.statistics.lastPlayed)
        XCTAssertFalse(player.isSelected)
    }
    
    // MARK: - PlayerSkills Tests
    
    func testPlayerSkills_ValidValues_Success() {
        // Given/When
        let skills = PlayerSkills(technical: 8, agility: 7, endurance: 6, teamwork: 9)
        
        // Then
        XCTAssertEqual(skills.technical, 8)
        XCTAssertEqual(skills.agility, 7)
        XCTAssertEqual(skills.endurance, 6)
        XCTAssertEqual(skills.teamwork, 9)
        XCTAssertEqual(skills.overall, 7.5) // (8+7+6+9)/4 = 7.5
    }
    
    func testPlayerSkills_OverallCalculation_Accuracy() {
        // Given/When
        let skills = PlayerSkills(technical: 10, agility: 1, endurance: 5, teamwork: 8)
        
        // Then
        XCTAssertEqual(skills.overall, 6.0) // (10+1+5+8)/4 = 6.0
    }
    
    func testPlayerSkills_ClampingValues_BelowMinimum() {
        // Given/When
        let skills = PlayerSkills(technical: -5, agility: 0, endurance: -10, teamwork: 15)
        
        // Then
        XCTAssertEqual(skills.technical, 1) // Clamped to minimum
        XCTAssertEqual(skills.agility, 1) // Clamped to minimum
        XCTAssertEqual(skills.endurance, 1) // Clamped to minimum
        XCTAssertEqual(skills.teamwork, 10) // Clamped to maximum
    }
    
    func testPlayerSkills_ClampingValues_AboveMaximum() {
        // Given/When
        let skills = PlayerSkills(technical: 15, agility: 20, endurance: 11, teamwork: 12)
        
        // Then
        XCTAssertEqual(skills.technical, 10) // Clamped to maximum
        XCTAssertEqual(skills.agility, 10) // Clamped to maximum
        XCTAssertEqual(skills.endurance, 10) // Clamped to maximum
        XCTAssertEqual(skills.teamwork, 10) // Clamped to maximum
    }
    
    // MARK: - PlayerStatistics Tests
    
    func testPlayerStatistics_DefaultInitialization_Success() {
        // Given/When
        let statistics = PlayerStatistics()
        
        // Then
        XCTAssertEqual(statistics.gamesPlayed, 0)
        XCTAssertEqual(statistics.teamsJoined, 0)
        XCTAssertNil(statistics.lastPlayed)
    }
    
    func testPlayerStatistics_CustomInitialization_Success() {
        // Given
        let lastPlayedDate = Date()
        
        // When
        let statistics = PlayerStatistics(
            gamesPlayed: 10,
            teamsJoined: 5,
            lastPlayed: lastPlayedDate
        )
        
        // Then
        XCTAssertEqual(statistics.gamesPlayed, 10)
        XCTAssertEqual(statistics.teamsJoined, 5)
        XCTAssertEqual(statistics.lastPlayed, lastPlayedDate)
    }
    
    // MARK: - SkillLevel Tests
    
    func testSkillLevel_FromOverallRank_BeginnerRange() {
        // Given/When
        let skillLevel1 = SkillLevel(from: 1.0)
        let skillLevel2 = SkillLevel(from: 1.9)
        
        // Then
        XCTAssertEqual(skillLevel1, .beginner)
        XCTAssertEqual(skillLevel2, .beginner)
    }
    
    func testSkillLevel_FromOverallRank_NoviceRange() {
        // Given/When
        let skillLevel1 = SkillLevel(from: 2.0)
        let skillLevel2 = SkillLevel(from: 3.9)
        
        // Then
        XCTAssertEqual(skillLevel1, .novice)
        XCTAssertEqual(skillLevel2, .novice)
    }
    
    func testSkillLevel_FromOverallRank_IntermediateRange() {
        // Given/When
        let skillLevel1 = SkillLevel(from: 4.0)
        let skillLevel2 = SkillLevel(from: 5.9)
        
        // Then
        XCTAssertEqual(skillLevel1, .intermediate)
        XCTAssertEqual(skillLevel2, .intermediate)
    }
    
    func testSkillLevel_FromOverallRank_AdvancedRange() {
        // Given/When
        let skillLevel1 = SkillLevel(from: 6.0)
        let skillLevel2 = SkillLevel(from: 7.9)
        
        // Then
        XCTAssertEqual(skillLevel1, .advanced)
        XCTAssertEqual(skillLevel2, .advanced)
    }
    
    func testSkillLevel_FromOverallRank_ExpertRange() {
        // Given/When
        let skillLevel1 = SkillLevel(from: 8.0)
        let skillLevel2 = SkillLevel(from: 10.0)
        
        // Then
        XCTAssertEqual(skillLevel1, .expert)
        XCTAssertEqual(skillLevel2, .expert)
    }
    
    func testSkillLevel_ColorMapping_AllLevels() {
        // Given/When/Then
        XCTAssertEqual(SkillLevel.beginner.color, "red")
        XCTAssertEqual(SkillLevel.novice.color, "orange")
        XCTAssertEqual(SkillLevel.intermediate.color, "yellow")
        XCTAssertEqual(SkillLevel.advanced.color, "green")
        XCTAssertEqual(SkillLevel.expert.color, "blue")
    }
    
    func testSkillLevel_DisplayNames_AllLevels() {
        // Given/When/Then
        XCTAssertEqual(SkillLevel.beginner.displayName, "Beginner")
        XCTAssertEqual(SkillLevel.novice.displayName, "Novice")
        XCTAssertEqual(SkillLevel.intermediate.displayName, "Intermediate")
        XCTAssertEqual(SkillLevel.advanced.displayName, "Advanced")
        XCTAssertEqual(SkillLevel.expert.displayName, "Expert")
    }
    
    func testSkillLevel_AccessibilityDescription_AllLevels() {
        // Given/When/Then
        XCTAssertTrue(SkillLevel.beginner.accessibilityDescription.contains("Beginner level"))
        XCTAssertTrue(SkillLevel.novice.accessibilityDescription.contains("Novice level"))
        XCTAssertTrue(SkillLevel.intermediate.accessibilityDescription.contains("Intermediate level"))
        XCTAssertTrue(SkillLevel.advanced.accessibilityDescription.contains("Advanced level"))
        XCTAssertTrue(SkillLevel.expert.accessibilityDescription.contains("Expert level"))
    }
    
    // MARK: - Equatable Tests
    
    func testPlayerEntity_Equatable_SameId() {
        // Given
        let id = UUID()
        let skills = PlayerSkills(technical: 5, agility: 5, endurance: 5, teamwork: 5)
        
        let player1 = PlayerEntity(id: id, name: "Player 1", skills: skills)
        let player2 = PlayerEntity(id: id, name: "Player 2", skills: skills) // Different name, same ID
        
        // When/Then
        XCTAssertEqual(player1, player2) // Should be equal based on ID
    }
    
    func testPlayerEntity_Equatable_DifferentId() {
        // Given
        let skills = PlayerSkills(technical: 5, agility: 5, endurance: 5, teamwork: 5)
        
        let player1 = PlayerEntity(name: "Same Name", skills: skills)
        let player2 = PlayerEntity(name: "Same Name", skills: skills) // Same name, different ID
        
        // When/Then
        XCTAssertNotEqual(player1, player2) // Should not be equal due to different IDs
    }
    
    func testPlayerSkills_Equatable_SameValues() {
        // Given
        let skills1 = PlayerSkills(technical: 8, agility: 7, endurance: 6, teamwork: 9)
        let skills2 = PlayerSkills(technical: 8, agility: 7, endurance: 6, teamwork: 9)
        
        // When/Then
        XCTAssertEqual(skills1, skills2)
    }
    
    func testPlayerSkills_Equatable_DifferentValues() {
        // Given
        let skills1 = PlayerSkills(technical: 8, agility: 7, endurance: 6, teamwork: 9)
        let skills2 = PlayerSkills(technical: 8, agility: 7, endurance: 6, teamwork: 8)
        
        // When/Then
        XCTAssertNotEqual(skills1, skills2)
    }
}