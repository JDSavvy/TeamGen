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
            return "player_added"
        case .teamGenerated:
            return "team_generated"
        case .settingsChanged:
            return "settings_changed"
        }
    }
    
    public var parameters: [String: Any] {
        switch self {
        case .playerAdded(let skillLevel):
            return ["skill_level": skillLevel]
        case .teamGenerated(let playerCount, let teamCount):
            return ["player_count": playerCount, "team_count": teamCount]
        case .settingsChanged(let setting, let value):
            return ["setting": setting, "value": value]
        }
    }
} 