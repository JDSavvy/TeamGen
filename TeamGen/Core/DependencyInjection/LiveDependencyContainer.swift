import Foundation
import SwiftData
import SwiftUI

/// Production implementation of the dependency container with proper lazy initialization
@MainActor
public final class LiveDependencyContainer: DependencyContainerProtocol {
    // MARK: - Properties

    private let modelContext: ModelContext

    // MARK: - Initialization

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Lazy Dependencies

    public lazy var playerRepository: PlayerRepositoryProtocol = SwiftDataPlayerRepository(modelContext: modelContext)

    public lazy var settingsRepository: SettingsRepositoryProtocol = UserDefaultsSettingsRepository()

    public lazy var hapticService: HapticServiceProtocol = IOSHapticService()

    public lazy var teamGenerationService: TeamGenerationServiceProtocol = TeamGenerationService()

    public lazy var colorSchemeService: any ColorSchemeServiceProtocol = ColorSchemeService(
        settingsRepository: settingsRepository,
        hapticService: hapticService
    )

    public lazy var analyticsService: AnalyticsServiceProtocol = IOSAnalyticsService()

    public lazy var performanceService: SimplePerformanceServiceProtocol = SimplePerformanceService()

    public lazy var networkService: NetworkServiceProtocol = IOSNetworkService()

    public lazy var generateTeamsUseCase: GenerateTeamsUseCaseProtocol = GenerateTeamsUseCase(
        playerRepository: playerRepository,
        teamGenerationService: teamGenerationService
    )

    public lazy var managePlayersUseCase: ManagePlayersUseCaseProtocol = ManagePlayersUseCase(
        playerRepository: playerRepository
    )

    public lazy var teamGenerationViewModel: TeamGenerationViewModel = .init(
        generateTeamsUseCase: generateTeamsUseCase,
        managePlayersUseCase: managePlayersUseCase,
        hapticService: hapticService
    )

    public lazy var settingsManagementViewModel: SettingsManagementViewModel = .init(
        settingsRepository: settingsRepository,
        hapticService: hapticService,
        colorSchemeService: colorSchemeService
    )

    // MARK: - Lifecycle Management

    public func clearScopedInstances() {
        // Clear any scoped instances if needed
    }
}

// MARK: - SwiftUI Environment Integration

public struct DependencyContainerKey: @preconcurrency EnvironmentKey {
    @MainActor
    public static let defaultValue: DependencyContainerProtocol = MockDependencyContainer()
}

public extension EnvironmentValues {
    var dependencies: DependencyContainerProtocol {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}

// MARK: - Mock Container for Previews

@MainActor
public final class MockDependencyContainer: DependencyContainerProtocol {
    private var singletonInstances: [String: Any] = [:]

    public var playerRepository: PlayerRepositoryProtocol {
        getSingleton { MockPlayerRepository() }
    }

    public var settingsRepository: SettingsRepositoryProtocol {
        getSingleton { MockSettingsRepository() }
    }

    public var teamGenerationService: TeamGenerationServiceProtocol {
        getSingleton { MockTeamGenerationService() }
    }

    public var hapticService: HapticServiceProtocol {
        getSingleton { MockHapticService() }
    }

    public var colorSchemeService: any ColorSchemeServiceProtocol {
        getSingleton { MockColorSchemeService() }
    }

    public var analyticsService: AnalyticsServiceProtocol {
        getSingleton { MockAnalyticsService() }
    }

    public var networkService: NetworkServiceProtocol {
        getSingleton { MockNetworkService() }
    }

    public var performanceService: SimplePerformanceServiceProtocol {
        getSingleton { MockPerformanceService() }
    }

    public var generateTeamsUseCase: GenerateTeamsUseCaseProtocol {
        GenerateTeamsUseCase(
            playerRepository: playerRepository,
            teamGenerationService: teamGenerationService
        )
    }

    public var managePlayersUseCase: ManagePlayersUseCaseProtocol {
        ManagePlayersUseCase(playerRepository: playerRepository)
    }

    public var teamGenerationViewModel: TeamGenerationViewModel {
        getSingleton {
            TeamGenerationViewModel(
                generateTeamsUseCase: generateTeamsUseCase,
                managePlayersUseCase: managePlayersUseCase,
                hapticService: hapticService
            )
        }
    }

    public var settingsManagementViewModel: SettingsManagementViewModel {
        getSingleton {
            SettingsManagementViewModel(
                settingsRepository: settingsRepository,
                hapticService: hapticService,
                colorSchemeService: colorSchemeService
            )
        }
    }

    public init() {}

    public func clearScopedInstances() {
        // Clear any scoped instances if needed
    }

    private func getSingleton<T>(_ factory: () -> T) -> T {
        let key = String(describing: T.self)
        if let instance = singletonInstances[key] as? T {
            return instance
        }
        let newInstance = factory()
        singletonInstances[key] = newInstance
        return newInstance
    }
}

// MARK: - Mock Implementations

@MainActor
public final class MockPlayerRepository: PlayerRepositoryProtocol {
    private var players: [PlayerEntity] = []

    public init() {
        // Initialize with sample data
        players = [
            PlayerEntity(
                id: UUID(),
                name: "John Doe",
                skills: PlayerSkills(technical: 8, agility: 7, endurance: 6, teamwork: 9),
                isSelected: false
            ),
            PlayerEntity(
                id: UUID(),
                name: "Jane Smith",
                skills: PlayerSkills(technical: 7, agility: 8, endurance: 7, teamwork: 8),
                isSelected: true
            ),
        ]
    }

    public func save(_ player: PlayerEntity) async throws {
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index] = player
        } else {
            players.append(player)
        }
    }

    public func saveAll(_ players: [PlayerEntity]) async throws {
        for player in players {
            try await save(player)
        }
    }

    public func fetch(id: UUID) async throws -> PlayerEntity? {
        players.first { $0.id == id }
    }

    public func fetchAll() async throws -> [PlayerEntity] {
        players
    }

    public func fetchSelected() async throws -> [PlayerEntity] {
        players.filter(\.isSelected)
    }

    public func delete(id: UUID) async throws {
        players.removeAll { $0.id == id }
    }

    public func deleteAll(ids: [UUID]) async throws {
        players.removeAll { ids.contains($0.id) }
    }

    public func updateSelection(id: UUID, isSelected: Bool) async throws {
        if let index = players.firstIndex(where: { $0.id == id }) {
            players[index].isSelected = isSelected
        }
    }

    public func resetAllSelections() async throws {
        for index in players.indices {
            players[index].isSelected = false
        }
    }

    public func fetchByMinimumSkillLevel(_ minLevel: Double) async throws -> [PlayerEntity] {
        players.filter { $0.skills.overall >= minLevel }
    }

    public func hasPlayers() async throws -> Bool {
        !players.isEmpty
    }

    public func count() async throws -> Int {
        players.count
    }
}

@MainActor
public final class MockSettingsRepository: SettingsRepositoryProtocol {
    private var settings = AppSettings()

    public func getSettings() async throws -> AppSettings {
        settings
    }

    public func saveSettings(_ settings: AppSettings) async throws {
        self.settings = settings
    }
}

@MainActor
public final class MockTeamGenerationService: TeamGenerationServiceProtocol {
    public func generateTeams(from players: [PlayerEntity], count: Int,
                              mode _: TeamGenerationMode) async throws -> [TeamEntity]
    {
        // Mock implementation - create balanced teams
        let playersPerTeam = players.count / count
        var teams: [TeamEntity] = []

        for i in 0 ..< count {
            let startIndex = i * playersPerTeam
            let endIndex = min(startIndex + playersPerTeam, players.count)
            let teamPlayers = Array(players[startIndex ..< endIndex])

            let team = TeamEntity(
                id: UUID(),
                players: teamPlayers
            )
            teams.append(team)
        }

        return teams
    }

    public nonisolated func calculateBalanceScores(for teams: [TeamEntity]) -> [TeamEntity] {
        teams // Mock implementation
    }

    public nonisolated func validateGeneration(playerCount: Int, teamCount: Int) -> ValidationResult {
        if playerCount >= teamCount {
            .valid
        } else {
            .invalid(.insufficientPlayers(required: teamCount, available: playerCount))
        }
    }
}

@MainActor
public final class MockHapticService: HapticServiceProtocol {
    public func impact(_: HapticIntensity) async {
        // Mock implementation
    }

    public func selection() async {
        // Mock implementation
    }

    public func notification(_: HapticNotificationType) async {
        // Mock implementation
    }

    public func success() async {
        // Mock implementation
    }

    public func error() async {
        // Mock implementation
    }

    public func warning() async {
        // Mock implementation
    }

    public func provideGenerationFeedback(balanceScore _: Double) async {
        // Mock implementation
    }
}

@MainActor
public final class MockColorSchemeService: ColorSchemeServiceProtocol {
    public var effectiveColorScheme: ColorScheme?
    public var userPreference: ColorSchemeOption = .system
    public var isHighContrastEnabled: Bool = false
    public var isReduceMotionEnabled: Bool = false

    public func loadPreferences() async {
        // Mock implementation
    }

    public func savePreferences() async {
        // Mock implementation
    }

    public func updateColorScheme(_ scheme: ColorSchemeOption) async {
        userPreference = scheme
    }

    public func updateHighContrast(_ enabled: Bool) async {
        isHighContrastEnabled = enabled
    }

    public func updateReduceMotion(_ enabled: Bool) async {
        isReduceMotionEnabled = enabled
    }
}

@MainActor
public final class MockAnalyticsService: AnalyticsServiceProtocol {
    public func track(event _: AnalyticsEvent) async {
        // Mock implementation
    }

    public func setUserProperty(key _: String, value _: String) async {
        // Mock implementation
    }

    public func identify(userId _: String) async {
        // Mock implementation
    }
}

@MainActor
public final class MockNetworkService: NetworkServiceProtocol {
    public func request<T: Codable>(_: NetworkRequest, responseType _: T.Type) async throws -> T {
        throw NetworkError.invalidURL
    }

    public func request(_: NetworkRequest) async throws -> Data {
        throw NetworkError.invalidURL
    }
}

@MainActor
public final class MockPerformanceService: SimplePerformanceServiceProtocol {
    public func logAppLaunch(duration _: TimeInterval) async {
        // Mock implementation
    }

    public func logTeamGeneration(playerCount _: Int, duration _: TimeInterval) async {
        // Mock implementation
    }

    public func logUserAction(_: String, duration _: TimeInterval) async {
        // Mock implementation
    }
}
