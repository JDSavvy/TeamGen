import Foundation

// MARK: - Team Generation Service Protocol
/// Defines the contract for team generation algorithms
public protocol TeamGenerationServiceProtocol: Sendable {
    /// Generates teams from the given players
    /// - Parameters:
    ///   - players: Array of players to distribute into teams
    ///   - count: Number of teams to create
    ///   - mode: Generation mode (fair or random)
    /// - Returns: Array of generated teams
    func generateTeams(
        from players: [PlayerEntity],
        count: Int,
        mode: TeamGenerationMode
    ) async throws -> [TeamEntity]
    
    /// Calculates balance scores for the given teams
    /// - Parameter teams: Teams to calculate balance for
    /// - Returns: Teams with updated balance scores
    func calculateBalanceScores(for teams: [TeamEntity]) -> [TeamEntity]
    
    /// Validates if team generation is possible
    /// - Parameters:
    ///   - playerCount: Number of available players
    ///   - teamCount: Desired number of teams
    /// - Returns: Validation result
    func validateGeneration(playerCount: Int, teamCount: Int) -> ValidationResult
}

// MARK: - Validation Result
public struct ValidationResult: Sendable {
    public let isValid: Bool
    public let error: TeamGenerationError?
    
    public init(isValid: Bool, error: TeamGenerationError?) {
        self.isValid = isValid
        self.error = error
    }
    
    public static var valid: ValidationResult {
        ValidationResult(isValid: true, error: nil)
    }
    
    public static func invalid(_ error: TeamGenerationError) -> ValidationResult {
        ValidationResult(isValid: false, error: error)
    }
}

// MARK: - Team Generation Errors
public enum TeamGenerationError: LocalizedError, Sendable {
    case insufficientPlayers(required: Int, available: Int)
    case invalidTeamCount(Int)
    case emptyPlayerList
    case generationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .insufficientPlayers(let required, let available):
            return "Need at least \(required) players, but only \(available) available"
        case .invalidTeamCount(let count):
            return "Invalid team count: \(count). Must be at least 2"
        case .emptyPlayerList:
            return "No players available for team generation"
        case .generationFailed(let reason):
            return "Team generation failed: \(reason)"
        }
    }
}

// MARK: - Team Balance Metrics
public struct TeamBalanceMetrics: Sendable {
    public let averageSkillDeviation: Double
    public let maxSkillDifference: Double
    public let balanceScore: Double // 0.0 to 1.0
    
    public var isWellBalanced: Bool {
        balanceScore >= 0.8
    }
    
    public var balanceDescription: String {
        switch balanceScore {
        case 0.9...1.0:
            return "Perfectly balanced"
        case 0.7..<0.9:
            return "Well balanced"
        case 0.5..<0.7:
            return "Moderately balanced"
        default:
            return "Poorly balanced"
        }
    }
} 