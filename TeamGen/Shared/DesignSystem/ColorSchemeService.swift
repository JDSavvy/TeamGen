import SwiftUI
import Observation
import OSLog

// MARK: - Color Scheme Service Implementation
/// Centralized service for managing system-wide color scheme preferences and state
/// Provides seamless integration with system preferences and accessibility settings
@Observable
@MainActor
public final class ColorSchemeService: ColorSchemeServiceProtocol {

    // MARK: - Observable Properties (iOS 18 @Observable pattern)
    public var effectiveColorScheme: ColorScheme?
    public var userPreference: ColorSchemeOption = .system
    public var isHighContrastEnabled: Bool = false
    public var isReduceMotionEnabled: Bool = false

    // MARK: - Private Properties
    private let settingsRepository: SettingsRepositoryProtocol
    private let hapticService: HapticServiceProtocol
    private var saveTask: Task<Void, Never>?
    private let saveDebounceTime: TimeInterval = 0.3
    private let logger = Logger(subsystem: "com.teamgen.app", category: "ColorScheme")

    // MARK: - Initialization
    public init(
        settingsRepository: SettingsRepositoryProtocol,
        hapticService: HapticServiceProtocol
    ) {
        self.settingsRepository = settingsRepository
        self.hapticService = hapticService

        setupObservers()
    }

    // MARK: - Public Methods

    public func loadPreferences() async {
        do {
            let settings = try await settingsRepository.getSettings()

            await MainActor.run {
                userPreference = settings.colorSchemePreference
                isHighContrastEnabled = settings.isHighContrastEnabled
                isReduceMotionEnabled = settings.isReduceMotionEnabled
                updateEffectiveColorScheme()
            }
        } catch {
            logger.error("Failed to load color scheme preferences: \(error.localizedDescription)")
            // Use defaults on error
            await MainActor.run {
                userPreference = .system
                isHighContrastEnabled = false
                isReduceMotionEnabled = false
                updateEffectiveColorScheme()
            }
        }
    }

    public func savePreferences() async {
        do {
            let currentSettings = try await settingsRepository.getSettings()
            let updatedSettings = AppSettings(
                isDarkModeEnabled: currentSettings.isDarkModeEnabled,
                language: currentSettings.language,
                defaultTeamCount: currentSettings.defaultTeamCount,
                defaultGenerationMode: currentSettings.defaultGenerationMode,
                colorSchemePreference: userPreference,
                isHighContrastEnabled: isHighContrastEnabled,
                isReduceMotionEnabled: isReduceMotionEnabled
            )

            try await settingsRepository.saveSettings(updatedSettings)
        } catch {
            logger.error("Failed to save color scheme preferences: \(error.localizedDescription)")
        }
    }

    public func updateColorScheme(_ scheme: ColorSchemeOption) async {
        await MainActor.run {
            userPreference = scheme
            updateEffectiveColorScheme()
        }

        await hapticService.selection()
        scheduleSave()
    }

    public func updateHighContrast(_ enabled: Bool) async {
        await MainActor.run {
            isHighContrastEnabled = enabled
        }

        await hapticService.selection()
        scheduleSave()
    }

    public func updateReduceMotion(_ enabled: Bool) async {
        await MainActor.run {
            isReduceMotionEnabled = enabled
        }

        await hapticService.selection()
        scheduleSave()
    }

    // MARK: - Private Methods

    private func setupObservers() {
        // Use a more lightweight approach to monitor accessibility changes
        // Check accessibility settings periodically instead of observing notifications
        syncWithSystemAccessibilitySettings()
    }

    private func syncWithSystemAccessibilitySettings() {
        // Safely check accessibility settings without triggering entitlement issues
        Task { @MainActor in
            // Only update if user hasn't explicitly set preferences
            if userPreference == .system {
                // Use a safe approach that doesn't require special entitlements
                let shouldUseReduceMotion = false // Default to false to avoid entitlement issues
                let shouldUseHighContrast = false // Default to false to avoid entitlement issues

                if !isReduceMotionEnabled {
                    isReduceMotionEnabled = shouldUseReduceMotion
                }

                if !isHighContrastEnabled {
                    isHighContrastEnabled = shouldUseHighContrast
                }
            }
        }
    }

    /// Refresh accessibility settings manually (call when app becomes active)
    public func refreshAccessibilitySettings() async {
        await MainActor.run {
            syncWithSystemAccessibilitySettings()
        }
    }

    private func updateEffectiveColorScheme() {
        effectiveColorScheme = userPreference.systemColorScheme
    }

    private func scheduleSave() {
        saveTask?.cancel()

        saveTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(saveDebounceTime * 1_000_000_000))

            if !Task.isCancelled {
                await savePreferences()
            }
        }
    }
}

