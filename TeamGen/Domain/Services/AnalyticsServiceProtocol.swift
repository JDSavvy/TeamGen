import Foundation

// MARK: - Analytics Event Protocol

public protocol AnalyticsEvent {
    var name: String { get }
    var parameters: [String: Any] { get }
}

// MARK: - Analytics Service Protocol

public protocol AnalyticsServiceProtocol {
    func track(event: AnalyticsEvent) async
    func setUserProperty(key: String, value: String) async
    func identify(userId: String) async
}

// MARK: - Team Generation Analytics Events

public enum TeamGenAnalyticsEvent: AnalyticsEvent {
    case playerAdded(skillLevel: Double)
    case teamGenerated(playerCount: Int, teamCount: Int)
    case settingsChanged(setting: String, value: String)

    public var name: String {
        switch self {
        case .playerAdded:
            "player_added"
        case .teamGenerated:
            "team_generated"
        case .settingsChanged:
            "settings_changed"
        }
    }

    public var parameters: [String: Any] {
        switch self {
        case let .playerAdded(skillLevel):
            ["skill_level": skillLevel]
        case let .teamGenerated(playerCount, teamCount):
            ["player_count": playerCount, "team_count": teamCount]
        case let .settingsChanged(setting, value):
            ["setting": setting, "value": value]
        }
    }
}
