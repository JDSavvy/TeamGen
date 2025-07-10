import Foundation
import SwiftUI
import Observation

// MARK: - Settings Management State
enum SettingsManagementState: Equatable {
    case idle
    case loading
    case loaded
    case saving
    case error(String)
}

// MARK: - Settings Management View Model
/// Modern ViewModel using @Observable for settings management
@Observable
@MainActor
public final class SettingsManagementViewModel {
    // MARK: - Observable Properties
    private(set) var currentState: SettingsManagementState = .idle
    var colorScheme: ColorSchemeOption = .system
    var selectedLanguage: SupportedLanguage = .english
    var highContrastEnabled: Bool = false

    // MARK: - Dependencies
    private let settingsRepository: SettingsRepositoryProtocol
    private let hapticService: HapticServiceProtocol
    private let colorSchemeService: any ColorSchemeServiceProtocol

    // MARK: - Computed Properties

    var isLoading: Bool {
        currentState == .loading || currentState == .saving
    }

    var errorMessage: String? {
        if case .error(let message) = currentState {
            return message
        }
        return nil
    }

    // MARK: - Initialization
    public init(
        settingsRepository: SettingsRepositoryProtocol,
        hapticService: HapticServiceProtocol,
        colorSchemeService: any ColorSchemeServiceProtocol
    ) {
        self.settingsRepository = settingsRepository
        self.hapticService = hapticService
        self.colorSchemeService = colorSchemeService
    }

    // MARK: - Public Methods

    /// Load current settings
    func loadSettings() async {
        currentState = .loading

        do {
            let settings = try await settingsRepository.getSettings()

            // Update local state with proper mapping
            colorScheme = settings.colorSchemePreference
            selectedLanguage = SupportedLanguage.from(appLanguage: settings.language)
            highContrastEnabled = settings.isHighContrastEnabled

            currentState = .loaded

        } catch {
            currentState = .error(error.localizedDescription)
            await hapticService.error()
        }
    }

    /// Update color scheme setting
    func updateColorScheme(_ newScheme: ColorSchemeOption) async {
        let previousScheme = colorScheme
        colorScheme = newScheme
        currentState = .saving

        do {
            // Update color scheme service
            await colorSchemeService.updateColorScheme(newScheme)

            // Save to repository
            var settings = try await settingsRepository.getSettings()
            settings.colorSchemePreference = newScheme
            try await settingsRepository.saveSettings(settings)

            currentState = .loaded
            await hapticService.selection()

        } catch {
            // Revert on error
            colorScheme = previousScheme
            currentState = .error("Failed to update color scheme")
            await hapticService.error()
        }
    }

    /// Update language setting
    func updateLanguage(_ newLanguage: SupportedLanguage) async {
        let previousLanguage = selectedLanguage
        selectedLanguage = newLanguage
        currentState = .saving

        do {
            var settings = try await settingsRepository.getSettings()
            settings.language = newLanguage.toAppLanguage()
            try await settingsRepository.saveSettings(settings)

            currentState = .loaded
            await hapticService.selection()

        } catch {
            // Revert on error
            selectedLanguage = previousLanguage
            currentState = .error("Failed to update language")
            await hapticService.error()
        }
    }

    /// Update high contrast setting
    func updateHighContrast(_ enabled: Bool) async {
        let previousValue = highContrastEnabled
        highContrastEnabled = enabled
        currentState = .saving

        do {
            var settings = try await settingsRepository.getSettings()
            settings.isHighContrastEnabled = enabled
            try await settingsRepository.saveSettings(settings)

            currentState = .loaded
            await hapticService.selection()

        } catch {
            // Revert on error
            highContrastEnabled = previousValue
            currentState = .error("Failed to update high contrast setting")
            await hapticService.error()
        }
    }

    /// Reset all settings to defaults
    func resetToDefaults() async {
        currentState = .saving

        do {
            let defaultSettings = AppSettings()
            try await settingsRepository.saveSettings(defaultSettings)

            // Update local state with proper mapping
            colorScheme = defaultSettings.colorSchemePreference
            selectedLanguage = SupportedLanguage.from(appLanguage: defaultSettings.language)
            highContrastEnabled = defaultSettings.isHighContrastEnabled

            currentState = .loaded
            await hapticService.impact(.medium)

        } catch {
            currentState = .error("Failed to reset settings")
            await hapticService.error()
        }
    }

    /// Clear error state
    func clearError() {
        if case .error = currentState {
            currentState = .loaded
        }
    }
}

// MARK: - Supporting Types

// Supported Languages
enum SupportedLanguage: String, CaseIterable, Identifiable {
    case english = "English"
    case german = "Deutsch"

    var id: String { self.rawValue }

    var displayName: String {
        return self.rawValue
    }

    var localeIdentifier: String {
        switch self {
        case .english: return "en"
        case .german: return "de"
        }
    }

    /// Convert from AppLanguage to SupportedLanguage
    static func from(appLanguage: AppLanguage) -> SupportedLanguage {
        switch appLanguage {
        case .english: return .english
        case .german: return .german
        }
    }

    /// Convert to AppLanguage
    func toAppLanguage() -> AppLanguage {
        switch self {
        case .english: return .english
        case .german: return .german
        }
    }
}