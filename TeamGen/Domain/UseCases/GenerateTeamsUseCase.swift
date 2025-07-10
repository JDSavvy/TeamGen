import Foundation

// MARK: - Generate Teams Use Case Protocol

public protocol GenerateTeamsUseCaseProtocol {
    func execute(
        teamCount: Int,
        mode: TeamGenerationMode
    ) async throws -> [TeamEntity]

    func validateTeamGeneration(
        teamCount: Int,
        mode: TeamGenerationMode
    ) async throws -> TeamGenerationValidationResult

    func previewTeamDistribution(
        teamCount: Int
    ) async throws -> TeamDistributionPreview
}

// MARK: - Team Generation Validation Result

public struct TeamGenerationValidationResult: Sendable {
    public let isValid: Bool
    public let warnings: [TeamGenerationWarning]
    public let recommendations: [TeamGenerationRecommendation]
    public let estimatedBalance: Double

    public init(
        isValid: Bool,
        warnings: [TeamGenerationWarning] = [],
        recommendations: [TeamGenerationRecommendation] = [],
        estimatedBalance: Double = 0.0
    ) {
        self.isValid = isValid
        self.warnings = warnings
        self.recommendations = recommendations
        self.estimatedBalance = estimatedBalance
    }
}

// MARK: - Team Generation Warning

public enum TeamGenerationWarning: Sendable {
    case unevenPlayerDistribution(difference: Int)
    case significantSkillGap(maxDifference: Double)
    case smallTeamSize(playersPerTeam: Int)
    case largeTeamSize(playersPerTeam: Int)

    public var description: String {
        switch self {
        case let .unevenPlayerDistribution(difference):
            "Some teams will have \(difference) more player(s) than others"
        case let .significantSkillGap(maxDifference):
            "Large skill difference detected (up to \(String(format: "%.1f", maxDifference)) points)"
        case let .smallTeamSize(playersPerTeam):
            "Teams will be very small (\(playersPerTeam) player(s) each)"
        case let .largeTeamSize(playersPerTeam):
            "Teams will be very large (\(playersPerTeam)+ players each)"
        }
    }
}

// MARK: - Team Generation Recommendation

public enum TeamGenerationRecommendation: Sendable {
    case adjustTeamCount(suggested: Int, reason: String)
    case addMorePlayers(minimum: Int)
    case balanceSkillLevels
    case useFairMode
    case useRandomMode

    public var description: String {
        switch self {
        case let .adjustTeamCount(suggested, reason):
            "Consider \(suggested) teams: \(reason)"
        case let .addMorePlayers(minimum):
            "Add at least \(minimum) more players for better balance"
        case .balanceSkillLevels:
            "Consider adding players with different skill levels"
        case .useFairMode:
            "Use Fair mode for better skill balance"
        case .useRandomMode:
            "Use Random mode for variety"
        }
    }
}

// MARK: - Team Distribution Preview

public struct TeamDistributionPreview: Sendable {
    public let teamCount: Int
    public let playersPerTeam: [Int]
    public let estimatedBalance: Double
    public let skillDistribution: [Double]

    public init(
        teamCount: Int,
        playersPerTeam: [Int],
        estimatedBalance: Double,
        skillDistribution: [Double]
    ) {
        self.teamCount = teamCount
        self.playersPerTeam = playersPerTeam
        self.estimatedBalance = estimatedBalance
        self.skillDistribution = skillDistribution
    }
}

// MARK: - Domain Events

public protocol DomainEventPublisher {
    func publish(_ event: DomainEvent) async
}

public protocol DomainEvent: Sendable {
    var eventId: UUID { get }
    var timestamp: Date { get }
    var eventType: String { get }
}

public struct TeamGenerationStartedEvent: DomainEvent {
    public let eventId = UUID()
    public let timestamp = Date()
    public let eventType = "TeamGenerationStarted"
    public let playerCount: Int
    public let teamCount: Int
    public let mode: TeamGenerationMode

    public init(playerCount: Int, teamCount: Int, mode: TeamGenerationMode) {
        self.playerCount = playerCount
        self.teamCount = teamCount
        self.mode = mode
    }
}

public struct TeamGenerationCompletedEvent: DomainEvent {
    public let eventId = UUID()
    public let timestamp = Date()
    public let eventType = "TeamGenerationCompleted"
    public let teams: [TeamEntity]
    public let averageBalance: Double
    public let generationTime: TimeInterval

    public init(teams: [TeamEntity], averageBalance: Double, generationTime: TimeInterval) {
        self.teams = teams
        self.averageBalance = averageBalance
        self.generationTime = generationTime
    }
}

public struct TeamGenerationFailedEvent: DomainEvent {
    public let eventId = UUID()
    public let timestamp = Date()
    public let eventType = "TeamGenerationFailed"
    public let error: TeamGenerationError
    public let playerCount: Int
    public let teamCount: Int

    public init(error: TeamGenerationError, playerCount: Int, teamCount: Int) {
        self.error = error
        self.playerCount = playerCount
        self.teamCount = teamCount
    }
}

// MARK: - Generate Teams Use Case Implementation

public final class GenerateTeamsUseCase: GenerateTeamsUseCaseProtocol {
    private let playerRepository: PlayerRepositoryProtocol
    private let teamGenerationService: TeamGenerationServiceProtocol
    private let eventPublisher: DomainEventPublisher?

    // Business rules constants
    private let minPlayersPerTeam = 2
    private let maxPlayersPerTeam = 8
    private let optimalPlayersPerTeam = 4 ... 6
    private let significantSkillGapThreshold = 3.0

    public init(
        playerRepository: PlayerRepositoryProtocol,
        teamGenerationService: TeamGenerationServiceProtocol,
        eventPublisher: DomainEventPublisher? = nil
    ) {
        self.playerRepository = playerRepository
        self.teamGenerationService = teamGenerationService
        self.eventPublisher = eventPublisher
    }

    public func execute(
        teamCount: Int,
        mode: TeamGenerationMode
    ) async throws -> [TeamEntity] {
        let startTime = Date()

        // Comprehensive validation
        let validationResult = try await validateTeamGeneration(teamCount: teamCount, mode: mode)
        guard validationResult.isValid else {
            throw TeamGenerationError.generationFailed("Validation failed: Invalid configuration")
        }

        // Fetch selected players with business logic validation
        let selectedPlayers = try await fetchAndValidateSelectedPlayers()

        // Publish domain event
        await eventPublisher?.publish(TeamGenerationStartedEvent(
            playerCount: selectedPlayers.count,
            teamCount: teamCount,
            mode: mode
        ))

        do {
            // Generate teams with enhanced error handling
            let teams = try await generateTeamsWithRetry(
                players: selectedPlayers,
                teamCount: teamCount,
                mode: mode
            )

            // Calculate balance scores with business logic
            let balancedTeams = enhanceTeamsWithBusinessLogic(teams)

            // Update player statistics with domain logic
            try await updatePlayerStatisticsWithBusinessRules(for: selectedPlayers, teams: balancedTeams)

            // Calculate metrics for event
            let averageBalance = balancedTeams.map(\.balanceScore).reduce(0, +) / Double(balancedTeams.count)
            let generationTime = Date().timeIntervalSince(startTime)

            // Publish success event
            await eventPublisher?.publish(TeamGenerationCompletedEvent(
                teams: balancedTeams,
                averageBalance: averageBalance,
                generationTime: generationTime
            ))

            return balancedTeams

        } catch {
            // Publish failure event
            await eventPublisher?.publish(TeamGenerationFailedEvent(
                error: error as? TeamGenerationError ?? .generationFailed(error.localizedDescription),
                playerCount: selectedPlayers.count,
                teamCount: teamCount
            ))

            throw error
        }
    }

    public func validateTeamGeneration(
        teamCount: Int,
        mode: TeamGenerationMode
    ) async throws -> TeamGenerationValidationResult {
        // Basic validation
        guard teamCount >= 2 else {
            return TeamGenerationValidationResult(isValid: false)
        }

        let selectedPlayers = try await playerRepository.fetchSelected()

        guard !selectedPlayers.isEmpty else {
            return TeamGenerationValidationResult(isValid: false)
        }

        guard selectedPlayers.count >= teamCount else {
            return TeamGenerationValidationResult(isValid: false)
        }

        // Advanced business logic validation
        var warnings: [TeamGenerationWarning] = []
        var recommendations: [TeamGenerationRecommendation] = []

        // Check team size distribution
        let playersPerTeam = selectedPlayers.count / teamCount
        let remainder = selectedPlayers.count % teamCount

        if remainder > 0 {
            warnings.append(.unevenPlayerDistribution(difference: 1))
        }

        if playersPerTeam < minPlayersPerTeam {
            warnings.append(.smallTeamSize(playersPerTeam: playersPerTeam))
            recommendations.append(.adjustTeamCount(
                suggested: max(2, selectedPlayers.count / minPlayersPerTeam),
                reason: "Ensures minimum \(minPlayersPerTeam) players per team"
            ))
        }

        if playersPerTeam > maxPlayersPerTeam {
            warnings.append(.largeTeamSize(playersPerTeam: playersPerTeam))
            recommendations.append(.adjustTeamCount(
                suggested: (selectedPlayers.count + maxPlayersPerTeam - 1) / maxPlayersPerTeam,
                reason: "Keeps teams manageable (max \(maxPlayersPerTeam) players)"
            ))
        }

        // Check skill distribution
        let skillLevels = selectedPlayers.map(\.skills.overall)
        let minSkill = skillLevels.min() ?? 0
        let maxSkill = skillLevels.max() ?? 0
        let skillGap = maxSkill - minSkill

        if skillGap > significantSkillGapThreshold {
            warnings.append(.significantSkillGap(maxDifference: skillGap))
            if mode == .random {
                recommendations.append(.useFairMode)
            }
        }

        // Estimate balance score
        let estimatedBalance = estimateBalanceScore(
            players: selectedPlayers,
            teamCount: teamCount,
            mode: mode
        )

        // Check if more players would help
        if selectedPlayers.count < teamCount * optimalPlayersPerTeam.lowerBound {
            let suggestedMinimum = teamCount * optimalPlayersPerTeam.lowerBound - selectedPlayers.count
            recommendations.append(.addMorePlayers(minimum: suggestedMinimum))
        }

        return TeamGenerationValidationResult(
            isValid: true,
            warnings: warnings,
            recommendations: recommendations,
            estimatedBalance: estimatedBalance
        )
    }

    public func previewTeamDistribution(
        teamCount: Int
    ) async throws -> TeamDistributionPreview {
        let selectedPlayers = try await playerRepository.fetchSelected()

        guard !selectedPlayers.isEmpty else {
            throw TeamGenerationError.emptyPlayerList
        }

        guard teamCount >= 2 else {
            throw TeamGenerationError.invalidTeamCount(teamCount)
        }

        let basePlayersPerTeam = selectedPlayers.count / teamCount
        let remainder = selectedPlayers.count % teamCount

        var playersPerTeam: [Int] = []
        for i in 0 ..< teamCount {
            let extraPlayer = i < remainder ? 1 : 0
            playersPerTeam.append(basePlayersPerTeam + extraPlayer)
        }

        // Estimate skill distribution
        let sortedPlayers = selectedPlayers.sorted { $0.skills.overall > $1.skills.overall }
        var skillDistribution: [Double] = []

        var playerIndex = 0
        for teamSize in playersPerTeam {
            let teamPlayers = Array(sortedPlayers[playerIndex ..< min(playerIndex + teamSize, sortedPlayers.count)])
            let averageSkill = teamPlayers.isEmpty ? 0 : teamPlayers.map(\.skills.overall)
                .reduce(0, +) / Double(teamPlayers.count)
            skillDistribution.append(averageSkill)
            playerIndex += teamSize
        }

        let estimatedBalance = calculateEstimatedBalance(skillDistribution: skillDistribution)

        return TeamDistributionPreview(
            teamCount: teamCount,
            playersPerTeam: playersPerTeam,
            estimatedBalance: estimatedBalance,
            skillDistribution: skillDistribution
        )
    }

    // MARK: - Private Methods

    private func fetchAndValidateSelectedPlayers() async throws -> [PlayerEntity] {
        let selectedPlayers = try await playerRepository.fetchSelected()

        guard !selectedPlayers.isEmpty else {
            throw TeamGenerationError.emptyPlayerList
        }

        // Business rule: Validate player data integrity
        for player in selectedPlayers {
            guard !player.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw TeamGenerationError.generationFailed("Invalid player data: empty name")
            }

            guard player.skills.overall > 0, player.skills.overall <= 10 else {
                throw TeamGenerationError.generationFailed("Invalid player data: skill out of range")
            }
        }

        return selectedPlayers
    }

    private func generateTeamsWithRetry(
        players: [PlayerEntity],
        teamCount: Int,
        mode: TeamGenerationMode
    ) async throws -> [TeamEntity] {
        let maxRetries = 3
        var lastError: Error?

        for attempt in 1 ... maxRetries {
            do {
                let teams = try await teamGenerationService.generateTeams(
                    from: players,
                    count: teamCount,
                    mode: mode
                )

                // Validate generated teams
                try validateGeneratedTeams(teams, expectedCount: teamCount)

                return teams

            } catch {
                lastError = error

                // Only retry on specific errors
                if case TeamGenerationError.generationFailed = error, attempt < maxRetries {
                    // Brief delay before retry
                    try await Task.sleep(nanoseconds: 100_000_000) // 100ms
                    continue
                } else {
                    throw error
                }
            }
        }

        throw lastError ?? TeamGenerationError.generationFailed("Team generation failed after \(maxRetries) attempts")
    }

    private func validateGeneratedTeams(_ teams: [TeamEntity], expectedCount: Int) throws {
        guard teams.count == expectedCount else {
            throw TeamGenerationError.generationFailed("Generated \(teams.count) teams, expected \(expectedCount)")
        }

        for (index, team) in teams.enumerated() {
            guard !team.players.isEmpty else {
                throw TeamGenerationError.generationFailed("Team \(index + 1) is empty")
            }

            // Validate team metrics
            guard team.averageRank > 0 else {
                throw TeamGenerationError.generationFailed("Team \(index + 1) has invalid average rank")
            }
        }
    }

    private func enhanceTeamsWithBusinessLogic(_ teams: [TeamEntity]) -> [TeamEntity] {
        let enhancedTeams = teamGenerationService.calculateBalanceScores(for: teams)

        return enhancedTeams.map { team in
            var enhancedTeam = team

            // Apply business rules for team classification
            enhancedTeam.strengthLevel = TeamStrengthLevel(from: team.averageRank)

            // Ensure metrics are calculated
            enhancedTeam.calculateMetrics()

            return enhancedTeam
        }
    }

    private func updatePlayerStatisticsWithBusinessRules(
        for players: [PlayerEntity],
        teams: [TeamEntity]
    ) async throws {
        let updatedPlayers = players.map { player in
            var updatedPlayer = player

            // Business rule: Only update stats for players who were actually placed in teams
            let wasPlaced = teams.contains { team in
                team.players.contains { $0.id == player.id }
            }

            if wasPlaced {
                updatedPlayer.statistics.gamesPlayed += 1
                updatedPlayer.statistics.teamsJoined += 1
                updatedPlayer.statistics.lastPlayed = Date()
            }

            return updatedPlayer
        }

        try await playerRepository.saveAll(updatedPlayers)
    }

    private func estimateBalanceScore(
        players: [PlayerEntity],
        teamCount _: Int,
        mode: TeamGenerationMode
    ) -> Double {
        switch mode {
        case .fair:
            // For fair mode, estimate based on skill distribution
            let skillLevels = players.map(\.skills.overall)
            let averageSkill = skillLevels.reduce(0, +) / Double(skillLevels.count)
            let variance = skillLevels.map { pow($0 - averageSkill, 2) }.reduce(0, +) / Double(skillLevels.count)
            let standardDeviation = sqrt(variance)

            // Lower standard deviation = better potential balance
            return max(0.0, 1.0 - (standardDeviation / 5.0)) // Normalize to 0-1 scale

        case .random:
            // Random mode has unpredictable balance
            return 0.5 // Neutral estimate
        }
    }

    private func calculateEstimatedBalance(skillDistribution: [Double]) -> Double {
        guard skillDistribution.count > 1 else { return 1.0 }

        let averageSkill = skillDistribution.reduce(0, +) / Double(skillDistribution.count)
        let maxDeviation = skillDistribution.map { abs($0 - averageSkill) }.max() ?? 0.0

        return maxDeviation > 0 ? max(0.0, 1.0 - (maxDeviation / 5.0)) : 1.0
    }
}
