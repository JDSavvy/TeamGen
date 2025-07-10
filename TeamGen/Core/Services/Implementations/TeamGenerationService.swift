import Foundation

// MARK: - Team Generation Service Implementation

/// Optimized team generation service for fair team distribution (max 99 players)
///
/// ## Core Features:
/// - **Balanced Team Sizes**: Ensures team sizes never differ by more than 1 player (e.g., 10 players → 4-3-3 teams)
/// - **Controlled Randomness**: Provides variation in team configurations while maintaining fairness
/// - **Skill-Based Balancing**: Uses enhanced snake draft (≤30 players) and skill-tier distribution (31-99 players)
/// - **Modern Swift Implementation**: Async/await, proper error handling, and Apple development standards
public final class TeamGenerationService: TeamGenerationServiceProtocol {
    // MARK: - Private Properties

    private let balanceThreshold: Double = 0.15 // 15% deviation threshold for balance
    private let maxOptimizationIterations: Int = 100

    public init() {}

    // MARK: - Public Methods

    public func generateTeams(
        from players: [PlayerEntity],
        count: Int,
        mode: TeamGenerationMode
    ) async throws -> [TeamEntity] {
        guard !players.isEmpty else {
            throw TeamGenerationError.emptyPlayerList
        }

        guard count >= 2 else {
            throw TeamGenerationError.invalidTeamCount(count)
        }

        guard players.count >= count else {
            throw TeamGenerationError.insufficientPlayers(required: count, available: players.count)
        }

        switch mode {
        case .fair:
            return await generateFairTeams(from: players, count: count)
        case .random:
            return generateRandomTeams(from: players, count: count)
        }
    }

    public func calculateBalanceScores(for teams: [TeamEntity]) -> [TeamEntity] {
        guard !teams.isEmpty else { return teams }

        let teamSkills = teams.map(\.averageRank)
        let averageSkill = teamSkills.reduce(0, +) / Double(teams.count)
        let maxDeviation = teamSkills.map { abs($0 - averageSkill) }.max() ?? 0.0

        return teams.map { team in
            var updatedTeam = team
            let deviation = abs(team.averageRank - averageSkill)

            // Calculate balance score with improved formula
            if maxDeviation > 0 {
                updatedTeam.balanceScore = max(0.0, 1.0 - (deviation / maxDeviation))
            } else {
                updatedTeam.balanceScore = 1.0 // Perfect balance
            }

            return updatedTeam
        }
    }

    public func validateGeneration(playerCount: Int, teamCount: Int) -> ValidationResult {
        if playerCount == 0 {
            return .invalid(.emptyPlayerList)
        }

        if teamCount < 2 {
            return .invalid(.invalidTeamCount(teamCount))
        }

        if playerCount < teamCount {
            return .invalid(.insufficientPlayers(required: teamCount, available: playerCount))
        }

        return .valid
    }

    // MARK: - Private Methods - Fair Team Generation

    /// Generates optimally balanced teams using efficient algorithms for ≤99 players
    /// Includes controlled randomness for variation while maintaining fairness
    private func generateFairTeams(from players: [PlayerEntity], count: Int) async -> [TeamEntity] {
        // For small datasets (≤30 players), use enhanced snake draft with controlled variation
        if players.count <= 30 {
            await generateSmallScaleFairTeams(from: players, count: count)
        } else {
            // For medium datasets (31-99 players), use skill-tier distribution with intelligent shuffling
            await generateMediumScaleFairTeams(from: players, count: count)
        }
    }

    /// Optimized algorithm for small datasets (≤30 players) with controlled variation
    private func generateSmallScaleFairTeams(from players: [PlayerEntity], count: Int) async -> [TeamEntity] {
        // Create skill-balanced groups with controlled randomness
        let skillGroupedPlayers = createSkillBalancedGroups(from: players)

        // Use enhanced snake draft with randomized starting configuration
        var teams = performEnhancedSnakeDraft(players: skillGroupedPlayers, teamCount: count)

        // Apply optimization with randomized starting points
        teams = await optimizeTeamBalance(teams: teams, maxIterations: 50)

        return teams.map { $0.toTeamEntity() }
    }

    /// Balanced algorithm for medium datasets (31-99 players) with intelligent variation
    private func generateMediumScaleFairTeams(from players: [PlayerEntity], count: Int) async -> [TeamEntity] {
        // Use skill-tier based distribution with controlled shuffling
        let tieredPlayers = createShuffledSkillTiers(from: players, tierCount: min(count * 2, 8))
        var teams = initializeTeams(count: count, totalPlayers: players.count)

        // Distribute players tier by tier with randomized team assignment order
        for tier in tieredPlayers {
            teams = distributeTierToTeams(tier: tier, teams: teams, useRandomizedAssignment: true)
            await Task.yield() // Maintain responsiveness
        }

        // Apply targeted optimization with multiple starting points
        teams = await optimizeTeamBalance(teams: teams, maxIterations: 75)

        return teams.map { $0.toTeamEntity() }
    }

    // MARK: - Core Algorithm Implementations with Controlled Randomness

    /// Creates skill-balanced groups with controlled randomness for equal-skill players
    private func createSkillBalancedGroups(from players: [PlayerEntity]) -> [PlayerEntity] {
        // Group players by skill level (0.2 intervals for fine-grained control)
        let skillGroups = Dictionary(grouping: players) { player in
            Int(player.skills.overall * 5) // Creates groups: 1.0-1.2, 1.2-1.4, etc.
        }

        // Sort groups by skill level and shuffle players within each group
        let balancedPlayers = skillGroups
            .sorted { $0.key > $1.key } // Highest skill first
            .flatMap { _, playersInGroup in
                // Maintain fairness by shuffling only within same skill level
                playersInGroup.shuffled()
            }

        return balancedPlayers
    }

    /// Enhanced snake draft with randomized starting team and balanced team sizes
    private func performEnhancedSnakeDraft(players: [PlayerEntity], teamCount: Int) -> [TeamBuilder] {
        // Calculate balanced team sizes (e.g., 10 players, 3 teams = [4,3,3])
        let (baseSize, largerTeams) = calculateBalancedTeamSizes(playerCount: players.count, teamCount: teamCount)

        let teamBuilders = (0 ..< teamCount).map { teamIndex in
            let capacity = teamIndex < largerTeams ? baseSize + 1 : baseSize
            return TeamBuilder(capacity: capacity + 1) // +1 for safety margin
        }

        // Introduce controlled variation: randomize starting team
        var currentTeam = Int.random(in: 0 ..< teamCount)
        var direction = Bool.random() ? 1 : -1 // Random initial direction
        var playersAssigned = 0

        for player in players {
            // Ensure we don't exceed team capacity for balanced distribution
            while teamBuilders[currentTeam].players.count >= teamBuilders[currentTeam].capacity - 1 {
                // Move to next available team
                currentTeam = findNextAvailableTeam(teams: teamBuilders, current: currentTeam, direction: &direction)
            }

            teamBuilders[currentTeam].addPlayer(player)
            playersAssigned += 1

            // Enhanced snake draft movement with proper boundary handling
            if direction == 1 {
                if currentTeam == teamCount - 1 {
                    direction = -1 // Reverse direction at end
                } else {
                    currentTeam += 1
                }
            } else {
                if currentTeam == 0 {
                    direction = 1 // Reverse direction at start
                } else {
                    currentTeam -= 1
                }
            }
        }

        return teamBuilders
    }

    /// Calculates balanced team sizes ensuring max difference of 1 player
    private func calculateBalancedTeamSizes(playerCount: Int, teamCount: Int) -> (baseSize: Int, largerTeams: Int) {
        let baseSize = playerCount / teamCount
        let remainder = playerCount % teamCount

        // `remainder` teams get `baseSize + 1` players
        // `teamCount - remainder` teams get `baseSize` players
        return (baseSize, remainder)
    }

    /// Finds the next available team that hasn't reached its capacity
    private func findNextAvailableTeam(teams: [TeamBuilder], current: Int, direction: inout Int) -> Int {
        var next = current
        let teamCount = teams.count

        // Try current direction first
        for _ in 0 ..< teamCount {
            if direction == 1 {
                next = (next + 1) % teamCount
            } else {
                next = (next - 1 + teamCount) % teamCount
            }

            if teams[next].players.count < teams[next].capacity - 1 {
                return next
            }
        }

        // If no team found in current direction, try the opposite
        direction *= -1
        next = current

        for _ in 0 ..< teamCount {
            if direction == 1 {
                next = (next + 1) % teamCount
            } else {
                next = (next - 1 + teamCount) % teamCount
            }

            if teams[next].players.count < teams[next].capacity - 1 {
                return next
            }
        }

        // Fallback: return current (should not happen with proper capacity calculation)
        return current
    }

    /// Creates skill tiers with intelligent shuffling for variation
    private func createShuffledSkillTiers(from players: [PlayerEntity], tierCount: Int) -> [[PlayerEntity]] {
        let sortedPlayers = players.sorted { $0.skills.overall > $1.skills.overall }
        let playersPerTier = max(1, players.count / tierCount)

        var tiers: [[PlayerEntity]] = []
        var currentIndex = 0

        for _ in 0 ..< tierCount {
            let endIndex = min(currentIndex + playersPerTier, players.count)
            if currentIndex < endIndex {
                let tierPlayers = Array(sortedPlayers[currentIndex ..< endIndex])
                // Shuffle players within each tier for variation while maintaining skill balance
                tiers.append(tierPlayers.shuffled())
                currentIndex = endIndex
            }
        }

        return tiers
    }

    /// Distributes a skill tier across teams with balanced team sizes and optional randomized assignment
    private func distributeTierToTeams(tier: [PlayerEntity], teams: [TeamBuilder],
                                       useRandomizedAssignment: Bool) -> [TeamBuilder] {
        let mutableTeams = teams // Already mutable through reference semantics

        if useRandomizedAssignment {
            // Create randomized team assignment order for variation, but respect capacity limits
            let teamIndices = Array(0 ..< teams.count).shuffled()

            for player in tier {
                // Find next available team with capacity
                let availableTeam = findNextTeamWithCapacity(teams: mutableTeams, preferredOrder: teamIndices)
                mutableTeams[availableTeam].addPlayer(player)
            }
        } else {
            // Standard round-robin distribution with capacity checking
            var teamIndex = 0

            for player in tier {
                // Find next available team starting from current index
                while mutableTeams[teamIndex].players.count >= mutableTeams[teamIndex].capacity - 1 {
                    teamIndex = (teamIndex + 1) % teams.count
                }

                mutableTeams[teamIndex].addPlayer(player)
                teamIndex = (teamIndex + 1) % teams.count
            }
        }

        return mutableTeams
    }

    /// Finds the next team with available capacity
    private func findNextTeamWithCapacity(teams: [TeamBuilder], preferredOrder: [Int]) -> Int {
        // First try preferred order
        for teamIndex in preferredOrder where teams[teamIndex].players.count < teams[teamIndex].capacity - 1 {
            return teamIndex
        }

        // Fallback: find any available team
        for (index, team) in teams.enumerated() where team.players.count < team.capacity - 1 {
            return index
        }

        // Emergency fallback: return team with minimum players
        return teams.indices.min { teams[$0].players.count < teams[$1].players.count } ?? 0
    }

    /// Initializes empty team builders with balanced capacities
    private func initializeTeams(count: Int, totalPlayers: Int = 0) -> [TeamBuilder] {
        if totalPlayers > 0 {
            let (baseSize, largerTeams) = calculateBalancedTeamSizes(playerCount: totalPlayers, teamCount: count)

            return (0 ..< count).map { teamIndex in
                let capacity = teamIndex < largerTeams ? baseSize + 1 : baseSize
                return TeamBuilder(capacity: capacity + 1) // +1 for safety margin
            }
        } else {
            // Fallback for when total players unknown
            return (0 ..< count).map { _ in TeamBuilder(capacity: 20) }
        }
    }

    /// Optimizes team balance through local improvements with randomized starting points
    private func optimizeTeamBalance(teams: [TeamBuilder], maxIterations: Int) async -> [TeamBuilder] {
        let mutableTeams = teams // Reference semantics handle mutability
        var iteration = 0

        // Use multiple optimization passes with different starting points for better results
        let optimizationPasses = min(3, maxIterations / 25)
        var bestTeams = mutableTeams
        var bestBalance = calculateTeamBalance(teams: mutableTeams)

        for _ in 0 ..< optimizationPasses {
            let currentTeams = mutableTeams
            var passIteration = 0
            var passImproved = true
            let passMaxIterations = maxIterations / optimizationPasses

            while passImproved, passIteration < passMaxIterations {
                passImproved = false
                let currentBalance = calculateTeamBalance(teams: currentTeams)

                // Randomize team pair order for variation in optimization
                let teamPairs = generateRandomizedTeamPairs(teamCount: currentTeams.count)

                for (i, j) in teamPairs where await trySwapPlayersForBalance(
                    between: currentTeams[i],
                    and: currentTeams[j],
                    currentBalance: currentBalance
                ) {
                    passImproved = true
                }

                passIteration += 1
                iteration += 1

                // Yield control periodically to maintain app responsiveness
                if iteration % 10 == 0 {
                    await Task.yield()
                }

                // Early termination if balance is good enough
                let newBalance = calculateTeamBalance(teams: currentTeams)
                if newBalance < balanceThreshold {
                    break
                }

                // Track best result across passes
                if newBalance < bestBalance {
                    bestBalance = newBalance
                    bestTeams = currentTeams.map { $0.copy() }
                }
            }
        }

        return bestTeams
    }

    /// Generates randomized team pairs for optimization variation
    private func generateRandomizedTeamPairs(teamCount: Int) -> [(Int, Int)] {
        var pairs: [(Int, Int)] = []

        for i in 0 ..< teamCount {
            for j in (i + 1) ..< teamCount {
                pairs.append((i, j))
            }
        }

        return pairs.shuffled()
    }

    /// Attempts to swap players between two teams to improve balance
    private func trySwapPlayersForBalance(
        between team1: TeamBuilder,
        and team2: TeamBuilder,
        currentBalance _: Double
    ) async -> Bool {
        guard !team1.players.isEmpty, !team2.players.isEmpty else { return false }

        let bestSwap = findBestPlayerSwap(team1: team1, team2: team2)

        if let (player1, player2) = bestSwap {
            // Perform temporary swap to test
            team1.removePlayer(player1)
            team1.addPlayer(player2)
            team2.removePlayer(player2)
            team2.addPlayer(player1)

            let newBalance = abs(team1.averageRank - team2.averageRank)
            let oldBalance = abs((team1.averageRank - player2.skills.overall + player1.skills.overall) -
                (team2.averageRank - player1.skills.overall + player2.skills.overall))

            if newBalance < oldBalance {
                return true // Keep the swap
            } else {
                // Revert the swap
                team1.removePlayer(player2)
                team1.addPlayer(player1)
                team2.removePlayer(player1)
                team2.addPlayer(player2)
                return false
            }
        }

        return false
    }

    /// Finds the best player swap between two teams
    private func findBestPlayerSwap(team1: TeamBuilder, team2: TeamBuilder) -> (PlayerEntity, PlayerEntity)? {
        var bestSwap: (PlayerEntity, PlayerEntity)?
        var bestBalanceImprovement = 0.0

        let currentDifference = abs(team1.averageRank - team2.averageRank)

        for player1 in team1.players {
            for player2 in team2.players {
                let newTeam1Average = (team1.totalRank - player1.skills.overall + player2.skills.overall) /
                    Double(team1.playerCount)
                let newTeam2Average = (team2.totalRank - player2.skills.overall + player1.skills.overall) /
                    Double(team2.playerCount)
                let newDifference = abs(newTeam1Average - newTeam2Average)

                let improvement = currentDifference - newDifference

                if improvement > bestBalanceImprovement {
                    bestBalanceImprovement = improvement
                    bestSwap = (player1, player2)
                }
            }
        }

        return bestSwap
    }

    /// Calculates overall team balance score (lower is better)
    private func calculateTeamBalance(teams: [TeamBuilder]) -> Double {
        guard teams.count > 1 else { return 0.0 }

        let averageRanks = teams.map(\.averageRank)
        let overall = averageRanks.reduce(0, +) / Double(averageRanks.count)
        let variance = averageRanks.map { pow($0 - overall, 2) }.reduce(0, +) / Double(averageRanks.count)

        return sqrt(variance)
    }

    /// Generates random teams for comparison/testing
    private func generateRandomTeams(from players: [PlayerEntity], count: Int) -> [TeamEntity] {
        let shuffledPlayers = players.shuffled()
        let teams = initializeTeams(count: count)

        for (index, player) in shuffledPlayers.enumerated() {
            let teamIndex = index % count
            teams[teamIndex].addPlayer(player)
        }

        return teams.map { $0.toTeamEntity() }
    }
}

// MARK: - TeamBuilder Implementation

/// Mutable team builder for algorithm processing
private final class TeamBuilder {
    private(set) var players: [PlayerEntity] = []
    private let _capacity: Int

    init(capacity: Int) {
        _capacity = capacity
    }

    var capacity: Int {
        _capacity
    }

    var playerCount: Int {
        players.count
    }

    var averageRank: Double {
        guard !players.isEmpty else { return 0.0 }
        return totalRank / Double(players.count)
    }

    var totalRank: Double {
        players.reduce(0) { $0 + $1.skills.overall }
    }

    func addPlayer(_ player: PlayerEntity) {
        guard players.count < _capacity else { return }
        players.append(player)
    }

    func removePlayer(_ player: PlayerEntity) {
        players.removeAll { $0.id == player.id }
    }

    func copy() -> TeamBuilder {
        let newBuilder = TeamBuilder(capacity: _capacity)
        newBuilder.players = players
        return newBuilder
    }

    func toTeamEntity() -> TeamEntity {
        var team = TeamEntity(players: players)
        team.calculateMetrics()
        return team
    }
}
