import Foundation

// MARK: - Domain Entity (Framework Agnostic)
/// Pure domain model representing a player without any framework dependencies
public struct PlayerEntity: Equatable, Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var skills: PlayerSkills
    public var statistics: PlayerStatistics
    public var isSelected: Bool
    
    public init(
        id: UUID = UUID(),
        name: String,
        skills: PlayerSkills,
        statistics: PlayerStatistics = PlayerStatistics(),
        isSelected: Bool = false
    ) {
        self.id = id
        self.name = name
        self.skills = skills
        self.statistics = statistics
        self.isSelected = isSelected
    }
}

// MARK: - Value Objects
public struct PlayerSkills: Equatable, Sendable {
    public let technical: Int
    public let agility: Int
    public let endurance: Int
    public let teamwork: Int
    
    public var overall: Double {
        Double(technical + agility + endurance + teamwork) / 4.0
    }
    
    public init(technical: Int, agility: Int, endurance: Int, teamwork: Int) {
        self.technical = min(max(technical, 1), 10)
        self.agility = min(max(agility, 1), 10)
        self.endurance = min(max(endurance, 1), 10)
        self.teamwork = min(max(teamwork, 1), 10)
    }
    

}

public struct PlayerStatistics: Equatable, Sendable {
    public var gamesPlayed: Int
    public var teamsJoined: Int
    public var lastPlayed: Date?
    
    public init(
        gamesPlayed: Int = 0,
        teamsJoined: Int = 0,
        lastPlayed: Date? = nil
    ) {
        self.gamesPlayed = gamesPlayed
        self.teamsJoined = teamsJoined
        self.lastPlayed = lastPlayed
    }
}

// MARK: - Skill Level Classification
public enum SkillLevel: String, CaseIterable, Sendable {
    case beginner = "Beginner"
    case novice = "Novice"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    public init(from overallRank: Double) {
        switch overallRank {
        case 0..<2:
            self = .beginner
        case 2..<4:
            self = .novice
        case 4..<6:
            self = .intermediate
        case 6..<8:
            self = .advanced
        default:
            self = .expert
        }
    }
    
    public var color: String {
        switch self {
        case .beginner: return "red"
        case .novice: return "orange"
        case .intermediate: return "yellow"
        case .advanced: return "green"
        case .expert: return "blue"
        }
    }
    
    // MARK: - Display Properties
    var displayName: String {
        switch self {
        case .beginner:
            return "Beginner"
        case .novice:
            return "Novice"
        case .intermediate:
            return "Intermediate"
        case .advanced:
            return "Advanced"
        case .expert:
            return "Expert"
        }
    }
    
    /// Detailed accessibility description for VoiceOver users
    var accessibilityDescription: String {
        switch self {
        case .beginner:
            return "Beginner level, represented by a triangle shape"
        case .novice:
            return "Novice level, represented by a diamond shape"
        case .intermediate:
            return "Intermediate level, represented by a circle shape"
        case .advanced:
            return "Advanced level, represented by a square shape"
        case .expert:
            return "Expert level, represented by a star shape"
        }
    }
    
    /// Short accessibility hint for skill level
    var accessibilityHint: String {
        switch self {
        case .beginner:
            return "Low skill level"
        case .novice:
            return "Below average skill level"
        case .intermediate:
            return "Average skill level"
        case .advanced:
            return "Above average skill level"
        case .expert:
            return "High skill level"
        }
    }
}

 