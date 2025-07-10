import Foundation
import OSLog

// MARK: - Simple Performance Service Protocol
public protocol SimplePerformanceServiceProtocol: Sendable {
    func logAppLaunch(duration: TimeInterval) async
    func logTeamGeneration(playerCount: Int, duration: TimeInterval) async
    func logUserAction(_ action: String, duration: TimeInterval) async
}

// MARK: - Simple Performance Service Implementation
@MainActor
public final class SimplePerformanceService: SimplePerformanceServiceProtocol {
    
    // MARK: - Properties
    private let logger = Logger(subsystem: "com.savvydev.TeamGen", category: "Performance")
    
    // MARK: - Initialization
    public init() {}
    
    // MARK: - Public Methods
    public func logAppLaunch(duration: TimeInterval) async {
        logger.info("App launched in \(duration, privacy: .public)ms")
    }
    
    public func logTeamGeneration(playerCount: Int, duration: TimeInterval) async {
        logger.info("Generated teams for \(playerCount) players in \(duration, privacy: .public)ms")
    }
    
    public func logUserAction(_ action: String, duration: TimeInterval) async {
        logger.debug("User action '\(action)' completed in \(duration, privacy: .public)ms")
    }
}

// MARK: - Mock Implementation
public final class MockSimplePerformanceService: SimplePerformanceServiceProtocol {
    
    public var loggedEvents: [(action: String, duration: TimeInterval)] = []
    
    public init() {}
    
    public func logAppLaunch(duration: TimeInterval) async {
        loggedEvents.append(("app_launch", duration))
    }
    
    public func logTeamGeneration(playerCount: Int, duration: TimeInterval) async {
        loggedEvents.append(("team_generation_\(playerCount)", duration))
    }
    
    public func logUserAction(_ action: String, duration: TimeInterval) async {
        loggedEvents.append((action, duration))
    }
}