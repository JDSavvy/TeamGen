import Foundation

// MARK: - Team Strength Level
public enum TeamStrengthLevel: String, CaseIterable, Sendable {
    case weak = "weak"
    case average = "average"
    case strong = "strong"
    case elite = "elite"
    
    public init(from averageRank: Double) {
        switch averageRank {
        case 0..<4.0:
            self = .weak
        case 4.0..<6.0:
            self = .average
        case 6.0..<8.0:
            self = .strong
        default:
            self = .elite
        }
    }
    
    public var displayName: String {
        switch self {
        case .weak:
            return "Developing"
        case .average:
            return "Balanced"
        case .strong:
            return "Strong"
        case .elite:
            return "Elite"
        }
    }
    
    public var color: String {
        switch self {
        case .weak:
            return "orange"
        case .average:
            return "blue"
        case .strong:
            return "green"
        case .elite:
            return "purple"
        }
    }
    
    public var description: String {
        switch self {
        case .weak:
            return "Team with developing skills"
        case .average:
            return "Well-balanced team"
        case .strong:
            return "High-performing team"
        case .elite:
            return "Elite-level team"
        }
    }
}

// MARK: - Team Entity
/// Represents a generated team with players and calculated metrics
/// Follows domain-driven design principles with rich business logic
public struct TeamEntity: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var players: [PlayerEntity]
    public var averageRank: Double
    public var balanceScore: Double
    public var strengthLevel: TeamStrengthLevel
    public var createdAt: Date
    
    // Computed metrics
    public var totalPlayers: Int {
        players.count
    }
    
    public var skillVariance: Double {
        guard players.count > 1 else { return 0.0 }
        
        let skills = players.map(\.skills.overall)
        let mean = averageRank
        let variance = skills.map { pow($0 - mean, 2) }.reduce(0, +) / Double(skills.count)
        return variance
    }
    
    public var skillStandardDeviation: Double {
        sqrt(skillVariance)
    }
    
    public var minSkillLevel: Double {
        players.map(\.skills.overall).min() ?? 0.0
    }
    
    public var maxSkillLevel: Double {
        players.map(\.skills.overall).max() ?? 0.0
    }
    
    public var skillRange: Double {
        maxSkillLevel - minSkillLevel
    }
    
    // Skill category breakdown
    public var skillBreakdown: SkillBreakdown {
        guard !players.isEmpty else {
            return SkillBreakdown(technical: 0, agility: 0, endurance: 0, teamwork: 0)
        }
        
        let technical = players.map { Double($0.skills.technical) }.reduce(0, +) / Double(players.count)
        let agility = players.map { Double($0.skills.agility) }.reduce(0, +) / Double(players.count)
        let endurance = players.map { Double($0.skills.endurance) }.reduce(0, +) / Double(players.count)
        let teamwork = players.map { Double($0.skills.teamwork) }.reduce(0, +) / Double(players.count)
        
        return SkillBreakdown(
            technical: technical,
            agility: agility,
            endurance: endurance,
            teamwork: teamwork
        )
    }
    
    // Team composition analysis
    public var compositionAnalysis: TeamComposition {
        let skillLevels = players.map { PlayerSkillPresentation.skillLevel(from: $0.skills.overall) }
        
        let beginners = skillLevels.filter { $0 == .beginner }.count
        let novices = skillLevels.filter { $0 == .novice }.count
        let intermediates = skillLevels.filter { $0 == .intermediate }.count
        let advanced = skillLevels.filter { $0 == .advanced }.count
        let experts = skillLevels.filter { $0 == .expert }.count
        
        return TeamComposition(
            beginners: beginners,
            novices: novices,
            intermediates: intermediates,
            advanced: advanced,
            experts: experts
        )
    }
    
    // Team balance quality indicators
    public var balanceQuality: BalanceQuality {
        switch balanceScore {
        case 0.9...1.0:
            return .excellent
        case 0.8..<0.9:
            return .good
        case 0.6..<0.8:
            return .fair
        case 0.4..<0.6:
            return .poor
        default:
            return .veryPoor
        }
    }
    
    public init(players: [PlayerEntity]) {
        self.id = UUID()
        self.players = players
        self.averageRank = 0.0
        self.balanceScore = 0.0
        self.strengthLevel = .average
        self.createdAt = Date()
        
        // Calculate initial metrics
        calculateMetrics()
    }
    
    public init(
        id: UUID = UUID(),
        players: [PlayerEntity],
        averageRank: Double = 0.0,
        balanceScore: Double = 0.0,
        strengthLevel: TeamStrengthLevel = .average,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.players = players
        self.averageRank = averageRank
        self.balanceScore = balanceScore
        self.strengthLevel = strengthLevel
        self.createdAt = createdAt
    }
    
    // MARK: - Business Logic Methods
    
    /// Calculates all team metrics based on current players
    public mutating func calculateMetrics() {
        guard !players.isEmpty else {
            averageRank = 0.0
            strengthLevel = .weak
            return
        }
        
        // Calculate average rank
        let totalRank = players.map(\.skills.overall).reduce(0, +)
        averageRank = totalRank / Double(players.count)
        
        // Determine strength level
        strengthLevel = TeamStrengthLevel(from: averageRank)
    }
    
    /// Validates team composition according to business rules
    public func validateComposition() -> TeamValidationResult {
        var issues: [TeamValidationIssue] = []
        var warnings: [TeamValidationWarning] = []
        
        // Check minimum players
        if players.isEmpty {
            issues.append(.emptyTeam)
        } else if players.count == 1 {
            warnings.append(.singlePlayer)
        }
        
        // Check for duplicate players
        let uniquePlayerIds = Set(players.map(\.id))
        if uniquePlayerIds.count != players.count {
            issues.append(.duplicatePlayers)
        }
        
        // Check skill distribution
        if skillRange > 6.0 {
            warnings.append(.largeSkillGap(range: skillRange))
        }
        
        // Check for extreme imbalance
        if skillStandardDeviation > 2.5 {
            warnings.append(.highVariance(standardDeviation: skillStandardDeviation))
        }
        
        return TeamValidationResult(
            isValid: issues.isEmpty,
            issues: issues,
            warnings: warnings
        )
    }
    
    /// Adds a player to the team with validation
    public mutating func addPlayer(_ player: PlayerEntity) throws {
        // Validate player isn't already in team
        guard !players.contains(where: { $0.id == player.id }) else {
            throw TeamValidationError.playerAlreadyInTeam(player.name)
        }
        
        // Add player and recalculate metrics
        players.append(player)
        calculateMetrics()
    }
    
    /// Removes a player from the team
    public mutating func removePlayer(withId playerId: UUID) throws {
        guard let index = players.firstIndex(where: { $0.id == playerId }) else {
            throw TeamValidationError.playerNotFound
        }
        
        players.remove(at: index)
        calculateMetrics()
    }
    
    /// Gets team summary for display
    public func getSummary() -> TeamSummary {
        return TeamSummary(
            id: id,
            playerCount: totalPlayers,
            averageSkill: averageRank,
            strengthLevel: strengthLevel,
            balanceScore: balanceScore,
            balanceQuality: balanceQuality,
            skillRange: skillRange,
            createdAt: createdAt
        )
    }
    
    /// Compares this team with another for balance analysis
    public func compareBalance(with otherTeam: TeamEntity) -> TeamComparison {
        let skillDifference = abs(averageRank - otherTeam.averageRank)
        let balanceDifference = abs(balanceScore - otherTeam.balanceScore)
        
        return TeamComparison(
            skillDifference: skillDifference,
            balanceDifference: balanceDifference,
            isWellBalanced: skillDifference < 1.0,
            recommendation: skillDifference > 2.0 ? .rebalanceNeeded : .acceptable
        )
    }
    
    // MARK: - Equatable
    public static func == (lhs: TeamEntity, rhs: TeamEntity) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Supporting Types

public struct SkillBreakdown: Sendable {
    public let technical: Double
    public let agility: Double
    public let endurance: Double
    public let teamwork: Double
    
    public init(technical: Double, agility: Double, endurance: Double, teamwork: Double) {
        self.technical = technical
        self.agility = agility
        self.endurance = endurance
        self.teamwork = teamwork
    }
}

public struct TeamComposition: Sendable {
    public let beginners: Int
    public let novices: Int
    public let intermediates: Int
    public let advanced: Int
    public let experts: Int
    
    public var total: Int {
        beginners + novices + intermediates + advanced + experts
    }
    
    public init(beginners: Int, novices: Int, intermediates: Int, advanced: Int, experts: Int) {
        self.beginners = beginners
        self.novices = novices
        self.intermediates = intermediates
        self.advanced = advanced
        self.experts = experts
    }
}

public enum BalanceQuality: String, CaseIterable, Sendable {
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"
    case veryPoor = "very_poor"
    
    public var displayName: String {
        switch self {
        case .excellent:
            return "Excellent"
        case .good:
            return "Good"
        case .fair:
            return "Fair"
        case .poor:
            return "Poor"
        case .veryPoor:
            return "Very Poor"
        }
    }
    
    public var color: String {
        switch self {
        case .excellent:
            return "green"
        case .good:
            return "blue"
        case .fair:
            return "yellow"
        case .poor:
            return "orange"
        case .veryPoor:
            return "red"
        }
    }
}

// MARK: - Validation Types

public struct TeamValidationResult: Sendable {
    public let isValid: Bool
    public let issues: [TeamValidationIssue]
    public let warnings: [TeamValidationWarning]
    
    public init(isValid: Bool, issues: [TeamValidationIssue], warnings: [TeamValidationWarning]) {
        self.isValid = isValid
        self.issues = issues
        self.warnings = warnings
    }
}

public enum TeamValidationIssue: Sendable {
    case emptyTeam
    case duplicatePlayers
    
    public var description: String {
        switch self {
        case .emptyTeam:
            return "Team cannot be empty"
        case .duplicatePlayers:
            return "Team contains duplicate players"
        }
    }
}

public enum TeamValidationWarning: Sendable {
    case singlePlayer
    case largeSkillGap(range: Double)
    case highVariance(standardDeviation: Double)
    
    public var description: String {
        switch self {
        case .singlePlayer:
            return "Team has only one player"
        case .largeSkillGap(let range):
            return "Large skill gap in team (range: \(String(format: "%.1f", range)))"
        case .highVariance(let standardDeviation):
            return "High skill variance (σ: \(String(format: "%.1f", standardDeviation)))"
        }
    }
}

public enum TeamValidationError: Error, LocalizedError {
    case playerAlreadyInTeam(String)
    case playerNotFound
    case invalidTeamSize
    
    public var errorDescription: String? {
        switch self {
        case .playerAlreadyInTeam(let playerName):
            return "\(playerName) is already in this team"
        case .playerNotFound:
            return "Player not found in team"
        case .invalidTeamSize:
            return "Invalid team size"
        }
    }
}

// MARK: - Analysis Types

public struct TeamSummary: Sendable {
    public let id: UUID
    public let playerCount: Int
    public let averageSkill: Double
    public let strengthLevel: TeamStrengthLevel
    public let balanceScore: Double
    public let balanceQuality: BalanceQuality
    public let skillRange: Double
    public let createdAt: Date
    
    public init(
        id: UUID,
        playerCount: Int,
        averageSkill: Double,
        strengthLevel: TeamStrengthLevel,
        balanceScore: Double,
        balanceQuality: BalanceQuality,
        skillRange: Double,
        createdAt: Date
    ) {
        self.id = id
        self.playerCount = playerCount
        self.averageSkill = averageSkill
        self.strengthLevel = strengthLevel
        self.balanceScore = balanceScore
        self.balanceQuality = balanceQuality
        self.skillRange = skillRange
        self.createdAt = createdAt
    }
}

public struct TeamComparison: Sendable {
    public let skillDifference: Double
    public let balanceDifference: Double
    public let isWellBalanced: Bool
    public let recommendation: BalanceRecommendation
    
    public init(
        skillDifference: Double,
        balanceDifference: Double,
        isWellBalanced: Bool,
        recommendation: BalanceRecommendation
    ) {
        self.skillDifference = skillDifference
        self.balanceDifference = balanceDifference
        self.isWellBalanced = isWellBalanced
        self.recommendation = recommendation
    }
}

public enum BalanceRecommendation: Sendable {
    case excellent
    case acceptable
    case rebalanceNeeded
    
    public var description: String {
        switch self {
        case .excellent:
            return "Teams are excellently balanced"
        case .acceptable:
            return "Teams are acceptably balanced"
        case .rebalanceNeeded:
            return "Teams need rebalancing"
        }
    }
}

// MARK: - Team Generation Mode
public enum TeamGenerationMode: String, CaseIterable, Sendable, Codable {
    case fair = "Fair"
    case random = "Random"
    
    public var description: String {
        switch self {
        case .fair:
            return "Creates balanced teams based on player skills"
        case .random:
            return "Randomly distributes players across teams"
        }
    }
}

 