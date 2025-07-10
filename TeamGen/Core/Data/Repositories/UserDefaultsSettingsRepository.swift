import Foundation

// MARK: - UserDefaults Settings Repository

/// Concrete implementation of SettingsRepositoryProtocol using UserDefaults
public final class UserDefaultsSettingsRepository: SettingsRepositoryProtocol, @unchecked Sendable {
    private let userDefaults: UserDefaults

    // Keys for UserDefaults
    private enum Keys {
        static let isDarkModeEnabled = "isDarkModeEnabled"
        static let language = "appLanguage"
        static let defaultTeamCount = "defaultTeamCount"
        static let defaultGenerationMode = "defaultGenerationMode"
        static let colorSchemePreference = "colorSchemePreference"
        static let isHighContrastEnabled = "isHighContrastEnabled"
        static let isReduceMotionEnabled = "isReduceMotionEnabled"
    }

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func getSettings() async throws -> AppSettings {
        AppSettings(
            isDarkModeEnabled: userDefaults.bool(forKey: Keys.isDarkModeEnabled),
            language: getLanguage(),
            defaultTeamCount: getDefaultTeamCount(),
            defaultGenerationMode: getDefaultGenerationMode(),
            colorSchemePreference: getColorSchemePreference(),
            isHighContrastEnabled: userDefaults.bool(forKey: Keys.isHighContrastEnabled),
            isReduceMotionEnabled: userDefaults.bool(forKey: Keys.isReduceMotionEnabled)
        )
    }

    public func saveSettings(_ settings: AppSettings) async throws {
        userDefaults.set(settings.isDarkModeEnabled, forKey: Keys.isDarkModeEnabled)
        userDefaults.set(settings.language.rawValue, forKey: Keys.language)
        userDefaults.set(settings.defaultTeamCount, forKey: Keys.defaultTeamCount)
        userDefaults.set(settings.defaultGenerationMode.rawValue, forKey: Keys.defaultGenerationMode)
        userDefaults.set(settings.colorSchemePreference.rawValue, forKey: Keys.colorSchemePreference)
        userDefaults.set(settings.isHighContrastEnabled, forKey: Keys.isHighContrastEnabled)
        userDefaults.set(settings.isReduceMotionEnabled, forKey: Keys.isReduceMotionEnabled)

        // Apply language change
        UserDefaults.standard.set([settings.language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

    // MARK: - Private Helpers

    private func getLanguage() -> AppLanguage {
        if let languageCode = userDefaults.string(forKey: Keys.language),
           let language = AppLanguage(rawValue: languageCode)
        {
            return language
        }
        return .english
    }

    private func getDefaultTeamCount() -> Int {
        let count = userDefaults.integer(forKey: Keys.defaultTeamCount)
        return count != 0 ? count : 2 // swiftlint:disable:this empty_count
    }

    private func getDefaultGenerationMode() -> TeamGenerationMode {
        if let modeString = userDefaults.string(forKey: Keys.defaultGenerationMode),
           let mode = TeamGenerationMode(rawValue: modeString)
        {
            return mode
        }
        return .fair
    }

    private func getColorSchemePreference() -> ColorSchemeOption {
        if let preferenceString = userDefaults.string(forKey: Keys.colorSchemePreference),
           let preference = ColorSchemeOption(rawValue: preferenceString)
        {
            return preference
        }
        return .system
    }
}
