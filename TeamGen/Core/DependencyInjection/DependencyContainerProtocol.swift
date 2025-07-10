import Foundation
import SwiftUI

// MARK: - Dependency Container Protocol
/// Defines the contract for application-wide dependency injection
@MainActor
public protocol DependencyContainerProtocol {
    // Repositories
    var playerRepository: PlayerRepositoryProtocol { get }
    var settingsRepository: SettingsRepositoryProtocol { get }

    // Services
    var teamGenerationService: TeamGenerationServiceProtocol { get }
    var hapticService: HapticServiceProtocol { get }
    var colorSchemeService: any ColorSchemeServiceProtocol { get }

    // Core Services (modular architecture)
    var analyticsService: AnalyticsServiceProtocol { get }
    var networkService: NetworkServiceProtocol { get }

    // Use Cases
    var generateTeamsUseCase: GenerateTeamsUseCaseProtocol { get }
    var managePlayersUseCase: ManagePlayersUseCaseProtocol { get }

    // ViewModels (singletons for state persistence)
    var teamGenerationViewModel: TeamGenerationViewModel { get }
    var settingsManagementViewModel: SettingsManagementViewModel { get }
}

// MARK: - Color Scheme Service Protocol
/// Service for managing system-wide color scheme preferences and state
@MainActor
public protocol ColorSchemeServiceProtocol {
    /// Current effective color scheme (resolved from user preference and system setting)
    var effectiveColorScheme: ColorScheme? { get }

    /// User's color scheme preference
    var userPreference: ColorSchemeOption { get set }

    /// Whether high contrast is enabled
    var isHighContrastEnabled: Bool { get set }

    /// Whether reduce motion is enabled
    var isReduceMotionEnabled: Bool { get set }

    /// Load color scheme preferences from settings
    func loadPreferences() async

    /// Save color scheme preferences to settings
    func savePreferences() async

    /// Update color scheme preference
    func updateColorScheme(_ scheme: ColorSchemeOption) async

    /// Update high contrast setting
    func updateHighContrast(_ enabled: Bool) async

    /// Update reduce motion setting
    func updateReduceMotion(_ enabled: Bool) async
}

// MARK: - Settings Repository Protocol
public protocol SettingsRepositoryProtocol: Sendable {
    func getSettings() async throws -> AppSettings
    func saveSettings(_ settings: AppSettings) async throws
}

// MARK: - App Language
public enum AppLanguage: String, CaseIterable, Identifiable, Sendable, Codable {
    case english = "en"
    case german = "de"

    public var id: String { self.rawValue }

    public var displayName: String {
        switch self {
        case .english: return "English"
        case .german: return "Deutsch"
        }
    }
}

// MARK: - Color Scheme Options
public enum ColorSchemeOption: String, CaseIterable, Identifiable, Sendable, Codable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    public var id: String { self.rawValue }

    public var displayName: String {
        switch self {
        case .system: return "Automatic"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    public var systemColorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - App Settings
public struct AppSettings: Equatable, Sendable, Codable {
    public var isDarkModeEnabled: Bool
    public var language: AppLanguage
    public var defaultTeamCount: Int
    public var defaultGenerationMode: TeamGenerationMode
    public var colorSchemePreference: ColorSchemeOption
    public var isHighContrastEnabled: Bool
    public var isReduceMotionEnabled: Bool

    public init(
        isDarkModeEnabled: Bool = false,
        language: AppLanguage = .english,
        defaultTeamCount: Int = 2,
        defaultGenerationMode: TeamGenerationMode = .fair,
        colorSchemePreference: ColorSchemeOption = .system,
        isHighContrastEnabled: Bool = false,
        isReduceMotionEnabled: Bool = false
    ) {
        self.isDarkModeEnabled = isDarkModeEnabled
        self.language = language
        self.defaultTeamCount = defaultTeamCount
        self.defaultGenerationMode = defaultGenerationMode
        self.colorSchemePreference = colorSchemePreference
        self.isHighContrastEnabled = isHighContrastEnabled
        self.isReduceMotionEnabled = isReduceMotionEnabled
    }
}