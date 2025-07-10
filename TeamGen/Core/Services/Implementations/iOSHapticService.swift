import UIKit

// MARK: - iOS Haptic Service

/// Concrete implementation of haptic feedback for iOS
public final class IOSHapticService: HapticServiceProtocol, @unchecked Sendable {
    // Feedback generators
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()

    public init() {
        // Prepare generators for immediate use on main thread
        Task { @MainActor in
            impactLight.prepare()
            impactMedium.prepare()
            impactHeavy.prepare()
            selectionFeedback.prepare()
            notificationFeedback.prepare()
        }
    }

    public func selection() async {
        await MainActor.run {
            selectionFeedback.selectionChanged()
        }
    }

    public func impact(_ intensity: HapticIntensity) async {
        await MainActor.run {
            switch intensity {
            case .light:
                impactLight.impactOccurred()
            case .medium:
                impactMedium.impactOccurred()
            case .heavy:
                impactHeavy.impactOccurred()
            }
        }
    }

    public func notification(_ type: HapticNotificationType) async {
        await MainActor.run {
            switch type {
            case .success:
                notificationFeedback.notificationOccurred(.success)
            case .warning:
                notificationFeedback.notificationOccurred(.warning)
            case .error:
                notificationFeedback.notificationOccurred(.error)
            }
        }
    }

    public func success() async {
        await notification(.success)
    }

    public func error() async {
        await notification(.error)
    }

    public func warning() async {
        await notification(.warning)
    }

    public func provideGenerationFeedback(balanceScore: Double) async {
        switch balanceScore {
        case 0.9 ... 1.0:
            await success()
        case 0.7 ..< 0.9:
            await impact(.medium)
        case 0.5 ..< 0.7:
            await impact(.light)
        default:
            await warning()
        }
    }
}
