import Foundation
import MetricKit
import OSLog

// MARK: - Performance Monitoring Service Protocol
public protocol PerformanceMonitoringServiceProtocol: Sendable {
    func startMonitoring() async
    func stopMonitoring() async
    func logEvent(_ event: PerformanceEvent) async
    func recordMetric(_ metric: PerformanceMetric) async
}

// MARK: - Performance Event
public enum PerformanceEvent: Sendable {
    case appLaunch(duration: TimeInterval)
    case viewLoad(viewName: String, duration: TimeInterval)
    case dataLoad(operation: String, duration: TimeInterval)
    case teamGeneration(playerCount: Int, duration: TimeInterval)
    case userAction(action: String, duration: TimeInterval)
}

// MARK: - Performance Metric
public struct PerformanceMetric: Sendable {
    public let name: String
    public let value: Double
    public let unit: String
    public let timestamp: Date

    public init(name: String, value: Double, unit: String, timestamp: Date = Date()) {
        self.name = name
        self.value = value
        self.unit = unit
        self.timestamp = timestamp
    }
}

// MARK: - iOS Performance Monitoring Service
@MainActor
public final class iOSPerformanceMonitoringService: NSObject, PerformanceMonitoringServiceProtocol {
    private let logger = Logger(subsystem: "com.savvydev.TeamGen", category: "Performance")
    private var isMonitoring = false

    // MARK: - Performance Tracking
    private var eventStartTimes: [String: Date] = [:]

    public override init() {
        super.init()
    }

    // MARK: - Public Interface

    public func startMonitoring() async {
        guard !isMonitoring else { return }

        // Subscribe to MetricKit
        MXMetricManager.shared.add(self)
        isMonitoring = true

        logger.info("Performance monitoring started")

        // Start tracking app launch performance
        recordAppLaunchMetrics()
    }

    public func stopMonitoring() async {
        guard isMonitoring else { return }

        MXMetricManager.shared.remove(self)
        isMonitoring = false

        logger.info("Performance monitoring stopped")
    }

    public func logEvent(_ event: PerformanceEvent) async {
        switch event {
        case .appLaunch(let duration):
            logger.info("App launch completed in \(duration, privacy: .public)s")
            await recordMetric(PerformanceMetric(name: "app_launch_time", value: duration, unit: "seconds"))

        case .viewLoad(let viewName, let duration):
            logger.info("View '\(viewName, privacy: .public)' loaded in \(duration, privacy: .public)s")
            await recordMetric(PerformanceMetric(name: "view_load_time", value: duration, unit: "seconds"))

        case .dataLoad(let operation, let duration):
            logger.info("Data operation '\(operation, privacy: .public)' completed in \(duration, privacy: .public)s")
            await recordMetric(PerformanceMetric(name: "data_load_time", value: duration, unit: "seconds"))

        case .teamGeneration(let playerCount, let duration):
            logger.info("Team generation for \(playerCount, privacy: .public) players completed in \(duration, privacy: .public)s")
            await recordMetric(PerformanceMetric(name: "team_generation_time", value: duration, unit: "seconds"))

        case .userAction(let action, let duration):
            logger.info("User action '\(action, privacy: .public)' completed in \(duration, privacy: .public)s")
            await recordMetric(PerformanceMetric(name: "user_action_time", value: duration, unit: "seconds"))
        }
    }

    public func recordMetric(_ metric: PerformanceMetric) async {
        logger.info("📊 Metric: \(metric.name, privacy: .public) = \(metric.value, privacy: .public) \(metric.unit, privacy: .public)")

        // You could also send metrics to analytics services here
        // analyticsService.recordMetric(metric)
    }

    // MARK: - Performance Measurement Helpers

    public func startTimer(for event: String) {
        eventStartTimes[event] = Date()
    }

    public func endTimer(for event: String, category: String = "general") {
        guard let startTime = eventStartTimes.removeValue(forKey: event) else {
            logger.warning("No start time found for event: \(event, privacy: .public)")
            return
        }

        let duration = Date().timeIntervalSince(startTime)

        Task {
            switch category {
            case "view":
                await logEvent(.viewLoad(viewName: event, duration: duration))
            case "data":
                await logEvent(.dataLoad(operation: event, duration: duration))
            case "team_generation":
                if let playerCount = extractPlayerCount(from: event) {
                    await logEvent(.teamGeneration(playerCount: playerCount, duration: duration))
                }
            default:
                await logEvent(.userAction(action: event, duration: duration))
            }
        }
    }

    // MARK: - App Launch Metrics

    private func recordAppLaunchMetrics() {
        // Record app launch time from process start
        let processStartTime = ProcessInfo.processInfo.systemUptime

        // This is an approximation - for more accurate launch time measurement,
        // you'd need to set up measurement from app delegate
        Task {
            await recordMetric(PerformanceMetric(
                name: "process_uptime",
                value: processStartTime,
                unit: "seconds"
            ))
        }
    }

    // MARK: - Memory Usage Tracking

    public func recordMemoryUsage() async {
        var memoryInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &memoryInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            let memoryUsageMB = Double(memoryInfo.resident_size) / 1024 / 1024
            await recordMetric(PerformanceMetric(
                name: "memory_usage",
                value: memoryUsageMB,
                unit: "MB"
            ))
        }
    }

    // MARK: - Helper Methods

    private func extractPlayerCount(from event: String) -> Int? {
        // Extract player count from event string if it contains "players"
        let components = event.components(separatedBy: " ")
        for (index, component) in components.enumerated() {
            if component.lowercased().contains("player") && index > 0 {
                return Int(components[index - 1])
            }
        }
        return nil
    }
}

// MARK: - MetricKit Delegate
extension iOSPerformanceMonitoringService: MXMetricManagerSubscriber {

    nonisolated public func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            processMetricPayload(payload)
        }
    }

    nonisolated public func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            processDiagnosticPayload(payload)
        }
    }

    nonisolated private func processMetricPayload(_ payload: MXMetricPayload) {
        Task { @MainActor in
            logger.info("📈 Received MetricKit payload for timerange: \(payload.timeStampBegin, privacy: .public) - \(payload.timeStampEnd, privacy: .public)")
        }

        // Process app launch metrics
        if payload.applicationLaunchMetrics != nil {
            Task {
                await recordMetric(PerformanceMetric(
                    name: "app_launch_time_metrickit",
                    value: 1.0,
                    unit: "event_count"
                ))
            }
        }

        // Process app responsiveness metrics
        if payload.applicationResponsivenessMetrics != nil {
            Task {
                await recordMetric(PerformanceMetric(
                    name: "app_hang_time",
                    value: 1.0,
                    unit: "event_count"
                ))
            }
        }

        // Process memory metrics
        if let memoryMetrics = payload.memoryMetrics {
            Task {
                await recordMetric(PerformanceMetric(
                    name: "peak_memory_usage",
                    value: Double(memoryMetrics.peakMemoryUsage.value) / 1024 / 1024,
                    unit: "MB"
                ))
            }
        }

        // Process CPU metrics
        if let cpuMetrics = payload.cpuMetrics {
            Task {
                await recordMetric(PerformanceMetric(
                    name: "cpu_time",
                    value: cpuMetrics.cumulativeCPUTime.value,
                    unit: "seconds"
                ))
            }
        }
    }

    nonisolated private func processDiagnosticPayload(_ payload: MXDiagnosticPayload) {
        Task { @MainActor in
            logger.warning("🚨 Received diagnostic payload: \(payload.debugDescription, privacy: .public)")
        }

        // Process diagnostics using available properties
        if !payload.dictionaryRepresentation().isEmpty {
            Task {
                await recordMetric(PerformanceMetric(
                    name: "diagnostic_event",
                    value: 1.0,
                    unit: "count"
                ))
            }
        }
    }
}

// MARK: - Performance Monitoring Extensions

public extension PerformanceMonitoringServiceProtocol {

    /// Measures execution time of an async operation
    func measure<T>(_ operation: () async throws -> T, event: String, category: String = "general") async throws -> T {
        let startTime = Date()
        let result = try await operation()
        let duration = Date().timeIntervalSince(startTime)

        switch category {
        case "view":
            await logEvent(.viewLoad(viewName: event, duration: duration))
        case "data":
            await logEvent(.dataLoad(operation: event, duration: duration))
        case "team_generation":
            // Extract player count if available
            await logEvent(.userAction(action: event, duration: duration))
        default:
            await logEvent(.userAction(action: event, duration: duration))
        }

        return result
    }

    /// Measures execution time of a synchronous operation
    func measureSync<T>(_ operation: () throws -> T, event: String, category: String = "general") throws -> T {
        let startTime = Date()
        let result = try operation()
        let duration = Date().timeIntervalSince(startTime)

        Task {
            await logEvent(.userAction(action: event, duration: duration))
        }
        return result
    }
}

// MARK: - Mock Performance Monitoring Service

@MainActor
public final class MockPerformanceMonitoringService: PerformanceMonitoringServiceProtocol {
    public private(set) var events: [PerformanceEvent] = []
    public private(set) var metrics: [PerformanceMetric] = []
    public private(set) var isMonitoring = false

    public init() {}

    public func startMonitoring() async {
        isMonitoring = true
    }

    public func stopMonitoring() async {
        isMonitoring = false
    }

    public func logEvent(_ event: PerformanceEvent) async {
        events.append(event)
    }

    public func recordMetric(_ metric: PerformanceMetric) async {
        metrics.append(metric)
    }

    public func reset() {
        events.removeAll()
        metrics.removeAll()
    }
}