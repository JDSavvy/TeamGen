import Foundation
import SwiftUI

// MARK: - Player Presentation State

/// Manages presentation state for the PlayerManagement feature
/// Centralized state management following SwiftUI best practices
@Observable
@MainActor
final class PlayerPresentationState {
    // Sheet presentations
    var showingAddPlayer = false
    var showingEditPlayer = false

    // Alert presentations
    var showingDeleteConfirmation = false

    // Current player being edited or deleted
    var editingPlayer: PlayerEntity?
    var playerToDelete: PlayerEntity?

    // State management methods
    func presentAddPlayer() {
        showingAddPlayer = true
    }

    func presentEditPlayer(_ player: PlayerEntity) {
        editingPlayer = player
        showingEditPlayer = true
    }

    func presentDeleteConfirmation(for player: PlayerEntity) {
        playerToDelete = player
        showingDeleteConfirmation = true
    }

    func dismissAll() {
        showingAddPlayer = false
        showingEditPlayer = false
        showingDeleteConfirmation = false
        editingPlayer = nil
        playerToDelete = nil
    }
}
