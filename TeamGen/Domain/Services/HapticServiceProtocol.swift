import Foundation

// MARK: - Haptic Service Protocol
/// Defines the contract for haptic feedback operations
public protocol HapticServiceProtocol: Sendable {
    /// Provides selection feedback
    func selection() async
    
    /// Provides impact feedback with specified intensity
    func impact(_ intensity: HapticIntensity) async
    
    /// Provides notification feedback
    func notification(_ type: HapticNotificationType) async
    
    /// Provides success feedback
    func success() async
    
    /// Provides error feedback
    func error() async
    
    /// Provides warning feedback
    func warning() async
    
    /// Provides custom haptic feedback based on team generation balance
    func provideGenerationFeedback(balanceScore: Double) async
}

// MARK: - Haptic Types
public enum HapticIntensity {
    case light
    case medium
    case heavy
}

public enum HapticNotificationType {
    case success
    case warning
    case error
} 