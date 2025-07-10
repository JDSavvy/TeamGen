import Foundation
import SwiftUI

// MARK: - User-Friendly Error Translation Layer

/// User-friendly error representation for better UX
public struct UserFriendlyError: Error, Equatable {
    public let title: String
    public let message: String
    public let recoveryActions: [RecoveryAction]
    public let severity: Severity

    public enum Severity: String, CaseIterable {
        case info
        case warning
        case error
        case critical

        public var icon: String {
            switch self {
            case .info: "info.circle"
            case .warning: "exclamationmark.triangle"
            case .error: "exclamationmark.circle"
            case .critical: "xmark.circle"
            }
        }

        public var color: Color {
            switch self {
            case .info: .blue
            case .warning: .orange
            case .error: .red
            case .critical: .red
            }
        }
    }

    public struct RecoveryAction: Equatable {
        public let id: String
        public let title: String
        public let isDestructive: Bool
        public let action: () async -> Void

        public init(id: String, title: String, isDestructive: Bool = false, action: @escaping () async -> Void) {
            self.id = id
            self.title = title
            self.isDestructive = isDestructive
            self.action = action
        }

        public static func == (lhs: RecoveryAction, rhs: RecoveryAction) -> Bool {
            lhs.id == rhs.id && lhs.title == rhs.title && lhs.isDestructive == rhs.isDestructive
        }
    }

    public init(title: String, message: String, recoveryActions: [RecoveryAction] = [], severity: Severity = .error) {
        self.title = title
        self.message = message
        self.recoveryActions = recoveryActions
        self.severity = severity
    }
}

// MARK: - Repository Error Translation

public extension UserFriendlyError {
    static func fromRepositoryError(_ error: Error) -> UserFriendlyError {
        if let repositoryError = error as? RepositoryError {
            return fromRepositoryError(repositoryError)
        }

        return UserFriendlyError(
            title: "Unexpected Error",
            message: "Something went wrong. Please try again.",
            recoveryActions: [.retry, .contactSupport],
            severity: .error
        )
    }

    private static func fromRepositoryError(_ error: RepositoryError) -> UserFriendlyError {
        switch error {
        case .notFound:
            UserFriendlyError(
                title: "Player Not Found",
                message: "The player you're looking for no longer exists.",
                recoveryActions: [.refreshData, .goBack],
                severity: .warning
            )

        case .saveFailed:
            UserFriendlyError(
                title: "Save Failed",
                message: "Your changes couldn't be saved. Please check your connection and try again.",
                recoveryActions: [.retry, .saveOffline],
                severity: .error
            )

        case .deleteFailed:
            UserFriendlyError(
                title: "Delete Failed",
                message: "The player couldn't be deleted. Please try again.",
                recoveryActions: [.retry, .cancel],
                severity: .error
            )

        case .fetchFailed:
            UserFriendlyError(
                title: "Loading Failed",
                message: "Unable to load your data. Please check your connection.",
                recoveryActions: [.retry, .viewOfflineData],
                severity: .error
            )

        case let .validationFailed(reason):
            UserFriendlyError(
                title: "Validation Error",
                message: reason.isEmpty ? "Please check your input and try again." : reason,
                recoveryActions: [.editInput, .cancel],
                severity: .warning
            )

        case .duplicateEntry:
            UserFriendlyError(
                title: "Duplicate Entry",
                message: "A player with this name already exists.",
                recoveryActions: [.editInput, .replaceDuplicate, .cancel],
                severity: .warning
            )

        case .storageLimit:
            UserFriendlyError(
                title: "Storage Limit Reached",
                message: "You've reached the maximum number of players. Please delete some players to continue.",
                recoveryActions: [.manageStorage, .upgrade, .cancel],
                severity: .error
            )

        case .unauthorized:
            UserFriendlyError(
                title: "Access Denied",
                message: "You don't have permission to perform this action.",
                recoveryActions: [.signIn, .contactSupport],
                severity: .error
            )
        }
    }
}

// MARK: - Team Generation Error Translation

public extension UserFriendlyError {
    static func fromTeamGenerationError(_ error: TeamGenerationError) -> UserFriendlyError {
        switch error {
        case let .insufficientPlayers(required, available):
            UserFriendlyError(
                title: "Not Enough Players",
                message: "You need at least \(required) players but only have \(available) selected.",
                recoveryActions: [.addMorePlayers, .selectMorePlayers, .adjustTeamCount],
                severity: .warning
            )

        case let .invalidTeamCount(count):
            UserFriendlyError(
                title: "Invalid Team Count",
                message: "Invalid team count: \(count). Please select a valid number of teams (between 2 and 10).",
                recoveryActions: [.adjustTeamCount],
                severity: .warning
            )

        case .emptyPlayerList:
            UserFriendlyError(
                title: "No Players Available",
                message: "You need to add some players before generating teams.",
                recoveryActions: [.addMorePlayers],
                severity: .warning
            )

        case let .generationFailed(reason):
            UserFriendlyError(
                title: "Team Generation Failed",
                message: reason.isEmpty ? "Unable to generate balanced teams. Please try again." : reason,
                recoveryActions: [.retry, .tryDifferentMode, .adjustParameters],
                severity: .error
            )
        }
    }
}

// MARK: - Common Recovery Actions

public extension UserFriendlyError.RecoveryAction {
    static let retry = UserFriendlyError.RecoveryAction(
        id: "retry",
        title: "Try Again"
    ) {}

    static let cancel = UserFriendlyError.RecoveryAction(
        id: "cancel",
        title: "Cancel"
    ) {}

    static let goBack = UserFriendlyError.RecoveryAction(
        id: "goBack",
        title: "Go Back"
    ) {}

    static let refreshData = UserFriendlyError.RecoveryAction(
        id: "refreshData",
        title: "Refresh Data"
    ) {}

    static let saveOffline = UserFriendlyError.RecoveryAction(
        id: "saveOffline",
        title: "Save Offline"
    ) {}

    static let viewOfflineData = UserFriendlyError.RecoveryAction(
        id: "viewOfflineData",
        title: "View Offline Data"
    ) {}

    static let editInput = UserFriendlyError.RecoveryAction(
        id: "editInput",
        title: "Edit Input"
    ) {}

    static let replaceDuplicate = UserFriendlyError.RecoveryAction(
        id: "replaceDuplicate",
        title: "Replace Existing",
        isDestructive: true
    ) {}

    static let manageStorage = UserFriendlyError.RecoveryAction(
        id: "manageStorage",
        title: "Manage Storage"
    ) {}

    static let upgrade = UserFriendlyError.RecoveryAction(
        id: "upgrade",
        title: "Upgrade"
    ) {}

    static let signIn = UserFriendlyError.RecoveryAction(
        id: "signIn",
        title: "Sign In"
    ) {}

    static let contactSupport = UserFriendlyError.RecoveryAction(
        id: "contactSupport",
        title: "Contact Support"
    ) {}

    static let addMorePlayers = UserFriendlyError.RecoveryAction(
        id: "addMorePlayers",
        title: "Add More Players"
    ) {}

    static let selectMorePlayers = UserFriendlyError.RecoveryAction(
        id: "selectMorePlayers",
        title: "Select More Players"
    ) {}

    static let adjustTeamCount = UserFriendlyError.RecoveryAction(
        id: "adjustTeamCount",
        title: "Adjust Team Count"
    ) {}

    static let tryDifferentMode = UserFriendlyError.RecoveryAction(
        id: "tryDifferentMode",
        title: "Try Different Mode"
    ) {}

    static let adjustParameters = UserFriendlyError.RecoveryAction(
        id: "adjustParameters",
        title: "Adjust Parameters"
    ) {}

    static let useCurrentResult = UserFriendlyError.RecoveryAction(
        id: "useCurrentResult",
        title: "Use Current Result"
    ) {}

    static let simplifyBalancing = UserFriendlyError.RecoveryAction(
        id: "simplifyBalancing",
        title: "Simplify Balancing"
    ) {}
}

// MARK: - Repository Error Enum

public enum RepositoryError: Error, LocalizedError {
    case notFound
    case saveFailed(Error)
    case deleteFailed(Error)
    case fetchFailed(Error)
    case validationFailed(String)
    case duplicateEntry
    case storageLimit
    case unauthorized

    public var errorDescription: String? {
        switch self {
        case .notFound:
            "The requested item was not found."
        case let .saveFailed(error):
            "Failed to save: \(error.localizedDescription)"
        case let .deleteFailed(error):
            "Failed to delete: \(error.localizedDescription)"
        case let .fetchFailed(error):
            "Failed to fetch data: \(error.localizedDescription)"
        case let .validationFailed(reason):
            "Validation failed: \(reason)"
        case .duplicateEntry:
            "A duplicate entry already exists."
        case .storageLimit:
            "Storage limit exceeded."
        case .unauthorized:
            "Access denied."
        }
    }
}

// TeamGenerationError is defined in TeamGenerationServiceProtocol.swift
