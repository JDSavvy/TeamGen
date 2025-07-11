import Foundation
import SwiftUI

// MARK: - App Constants

enum AppConstants {
    // MARK: - App Information

    enum App {
        static let name = "TeamGen"
        static let version = "1.0.0"
        static let bundleIdentifier = "com.teamgen.app"
    }

    // MARK: - UI Constants

    enum UserInterface {
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 4
        static let animationDuration: Double = 0.3
        static let hapticFeedbackIntensity: Float = 0.7

        // Spacing constants (flattened to avoid nesting)
        static let spacingXS: CGFloat = 4
        static let spacingSM: CGFloat = 8
        static let spacingMD: CGFloat = 16
        static let spacingLG: CGFloat = 24
        static let spacingXL: CGFloat = 32

        // Font size constants (flattened to avoid nesting)
        static let fontSizeCaption: CGFloat = 12
        static let fontSizeBody: CGFloat = 16
        static let fontSizeTitle: CGFloat = 20
        static let fontSizeLargeTitle: CGFloat = 28
    }

    // MARK: - Player Constants

    enum Player {
        static let minSkillLevel = 1
        static let maxSkillLevel = 10
        static let defaultSkillLevel = 5
        static let maxNameLength = 50
        static let minNameLength = 2
    }

    // MARK: - Team Generation Constants

    enum TeamGeneration {
        static let minTeamCount = 2
        static let maxTeamCount = 10
        static let defaultTeamCount = 2
        static let minPlayersPerTeam = 1
        static let maxPlayersForBalancing = 100
    }

    // MARK: - Performance Constants

    enum Performance {
        static let searchDebounceTime: TimeInterval = 0.3
        static let animationDebounceTime: TimeInterval = 0.1
        static let maxConcurrentOperations = 3
    }

    // MARK: - Storage Constants

    enum Storage {
        static let userDefaultsPrefix = "TeamGen_"
        static let swiftDataModelName = "TeamGenModel"
        static let maxStorageSize: Int64 = 100_000_000 // 100MB
    }

    // MARK: - Accessibility Constants

    enum Accessibility {
        static let minimumTapTargetSize: CGFloat = 44
        static let preferredContentSizeCategory = ContentSizeCategory.large
        static let voiceOverDelay: TimeInterval = 0.5
    }

    // MARK: - Logging Constants

    enum Logging {
        static let subsystem = "com.teamgen.app"

        enum Category {
            static let ui = "UI"
            static let data = "Data"
            static let network = "Network"
            static let analytics = "Analytics"
            static let performance = "Performance"
        }
    }
}
