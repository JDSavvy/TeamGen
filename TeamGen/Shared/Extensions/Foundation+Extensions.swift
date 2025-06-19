import Foundation

// MARK: - String Extensions
extension String {
    /// Validates if string is a valid player name
    var isValidPlayerName: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= AppConstants.Player.minNameLength && 
               trimmed.count <= AppConstants.Player.maxNameLength &&
               !trimmed.isEmpty
    }
}

// MARK: - Array Extensions
extension Array {
    /// Safely accesses array element at index
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Double Extensions
extension Double {
    /// Formats double to specified decimal places
    func formatted(decimalPlaces: Int = 1) -> String {
        return String(format: "%.\(decimalPlaces)f", self)
    }
}

 