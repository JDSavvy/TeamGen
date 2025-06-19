import SwiftUI

// MARK: - Player View
/// Modern player management view using @Observable ViewModels
/// Features collapsible rows, intuitive editing, and clean navigation
/// NavigationStack and title handled at TabView level for proper isolation
struct PlayerView: View {
    @State private var viewModel: PlayerManagementViewModel?
    @Environment(\.dependencies) private var dependencies
    @State private var presentationState = PlayerPresentationState()
    @State private var isInitialized = false
    
    // MARK: - Player Details Display
    // Current: Expandable rows with tap-to-expand functionality
    // Alternative: Consider using NavigationLink to dedicated PlayerDetailView for better UX
    // This would provide more space for detailed information and editing capabilities
    @State private var expandedPlayerIDs = Set<UUID>()
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                PlayerContentView(
                    viewModel: viewModel,
                    presentationState: $presentationState,
                    expandedPlayerIDs: $expandedPlayerIDs
                )
                .onAppear {
                    Task {
                        await viewModel.loadPlayers()
                    }
                }
            } else {
                ProgressView("Initializing...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .searchable(
            text: Binding(
                get: { viewModel?.searchQuery ?? "" },
                set: { viewModel?.searchQuery = $0 }
            ),
            prompt: "Search by name..."
        )
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                // Sort control - only show when there are players to sort
                if let viewModel = viewModel, !viewModel.players.isEmpty {
                    Menu {
                        Picker("Sort by", selection: Binding(
                            get: { viewModel.sortOption },
                            set: { newValue in
                                viewModel.sortOption = newValue
                                Task { await viewModel.applySorting() }
                            }
                        )) {
                            ForEach(PlayerSortOption.allCases, id: \.self) { option in
                                Label(option.rawValue, systemImage: option.systemImage)
                                    .tag(option)
                            }
                        }
                        .pickerStyle(.inline)
                    } label: {
                        Image(systemName: DesignSystem.Symbols.sort)
                    }
                    .accessibilityLabel("Sort players")
                }
                
                Button {
                    presentationState.showingAddPlayer = true
                } label: {
                    Image(systemName: DesignSystem.Symbols.plus)
                }
                .accessibilityLabel("Add new player")
            }
        }
        .refreshable {
            if let viewModel = viewModel {
                await viewModel.loadPlayers()
            }
        }
        .task {
            await initializeViewIfNeeded()
        }
        .sheet(isPresented: $presentationState.showingAddPlayer) {
            PlayerFormView(mode: .add) {
                if let viewModel = viewModel {
                    // Add a small delay to ensure SwiftData save is committed
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                    await viewModel.loadPlayers()
                }
            }
        }
        .sheet(isPresented: $presentationState.showingEditPlayer) {
            if let player = presentationState.editingPlayer {
                PlayerFormView(mode: .edit(player)) {
                    if let viewModel = viewModel {
                        await viewModel.loadPlayers()
                    }
                    presentationState.editingPlayer = nil
                }
            }
        }
        .alert("Delete Player", isPresented: $presentationState.showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                presentationState.playerToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let player = presentationState.playerToDelete,
                   let viewModel = viewModel {
                    Task {
                        await viewModel.deletePlayer(player.id)
                        presentationState.playerToDelete = nil
                    }
                }
            }
        } message: {
            if let player = presentationState.playerToDelete {
                Text("Are you sure you want to delete \(player.name)? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func initializeViewIfNeeded() async {
        guard !isInitialized else { return }
        
        let initializedViewModel = PlayerManagementViewModel(
            managePlayersUseCase: dependencies.managePlayersUseCase,
            hapticService: dependencies.hapticService
        )
        
        viewModel = initializedViewModel
        await initializedViewModel.loadPlayers()
        isInitialized = true
    }
}



// MARK: - Player Content View
/// Separated content view to prevent navigation title conflicts
private struct PlayerContentView: View {
    let viewModel: PlayerManagementViewModel
    @Binding var presentationState: PlayerPresentationState
    @Binding var expandedPlayerIDs: Set<UUID>
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.primaryBackground
                .ignoresSafeArea()
            
            // Content
            Group {
                switch viewModel.currentViewState {
                case .loading:
                    LoadingStateView()
                case .loaded:
                    PlayerListContentView(
                        viewModel: viewModel,
                        presentationState: $presentationState,
                        expandedPlayerIDs: $expandedPlayerIDs
                    )
                case .empty:
                    // Show empty state through PlayerListContentView which handles it properly
                    PlayerListContentView(
                        viewModel: viewModel,
                        presentationState: $presentationState,
                        expandedPlayerIDs: $expandedPlayerIDs
                    )
                case .error:
                    ErrorStateView(viewModel: viewModel)
                default:
                    EmptyView()
                }
            }
        }
    }
    
    // MARK: - State Views
    
    @ViewBuilder
    private func LoadingStateView() -> some View {
        LoadingStateContent()
    }
    
    @ViewBuilder
    private func ErrorStateView(viewModel: PlayerManagementViewModel) -> some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                Image(systemName: "exclamationmark.triangle")
                    .font(DesignSystem.Typography.extraLargeDisplay)
                    .fontWeight(.light)
                    .foregroundColor(DesignSystem.Colors.error)
                
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text("Something Went Wrong")
                        .font(DesignSystem.Typography.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Text("Unable to load players. Please try again.")
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
            }
            
            Button {
                Task { await viewModel.loadPlayers() }
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(DesignSystem.Typography.body)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.primary)
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    Capsule()
                        .strokeBorder(DesignSystem.Colors.primary, lineWidth: 1.5)
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DesignSystem.Spacing.screenPadding)
    }
}

private struct LoadingStateContent: View {
    @State private var isRotating = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Modern loading indicator with subtle animation
            ZStack {
                Circle()
                    .stroke(DesignSystem.Colors.primary.opacity(DesignSystem.VisualConsistency.opacityLight), lineWidth: DesignSystem.VisualConsistency.borderBold)
                    .frame(width: DesignSystem.ComponentSize.loadingIndicatorStandard, height: DesignSystem.ComponentSize.loadingIndicatorStandard)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(DesignSystem.VisualConsistency.opacityLoading)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: DesignSystem.VisualConsistency.borderBold, lineCap: .round)
                    )
                    .frame(width: DesignSystem.ComponentSize.loadingIndicatorStandard, height: DesignSystem.ComponentSize.loadingIndicatorStandard)
                    .rotationEffect(.degrees(-90))
                    .rotationEffect(.degrees(isRotating ? 360 : 0))
                    .onAppear {
                        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                            isRotating = true
                        }
                    }
            }
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Loading Players")
                    .font(DesignSystem.Typography.largeControl)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                Text("Fetching your player roster")
                    .font(DesignSystem.Typography.mediumIcon)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DesignSystem.Spacing.xxxl)
    }
    
    // PlayerListContentView is now extracted to its own file
    
    // EmptySearchStateView is now extracted to PlayerListContentView.swift
}

// PlayerListHeader is now extracted to PlayerListContentView.swift

// RefinedPlayerRow is now extracted to RefinedPlayerRow.swift

// RefinedExpandedContent and RefinedSkillRow are now extracted to RefinedPlayerRow.swift

// PlayerPresentationState is now defined in States/PlayerPresentationState.swift





// MARK: - Supporting Components

// Action Button (reused from TeamView)
private struct ActionButton: View {
    let icon: String
    let style: ButtonStyle
    let action: () -> Void
    let accessibilityLabel: String
    
    enum ButtonStyle {
        case primary, secondary
        
        var foregroundColor: Color {
            switch self {
            case .primary: return DesignSystem.Colors.primary
            case .secondary: return DesignSystem.Colors.secondaryText
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .primary: return DesignSystem.Colors.primary.opacity(DesignSystem.VisualConsistency.opacitySkillBackground)
            case .secondary: return DesignSystem.Colors.tertiaryBackground
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(DesignSystem.Typography.mediumIcon)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: DesignSystem.ComponentSize.largeIcon, height: DesignSystem.ComponentSize.largeIcon)
                .background(
                    Circle()
                        .fill(style.foregroundColor)
                )
        }
        .accessibilityLabel(accessibilityLabel)
    }
}

// Sort Control Menu
private struct SortControlMenu: View {
    @Binding var selectedOption: PlayerSortOption
    let onChange: () async -> Void
    
    var body: some View {
        Menu {
            ForEach(PlayerSortOption.allCases) { option in
                Button {
                    selectedOption = option
                    Task { await onChange() }
                } label: {
                    HStack {
                        Image(systemName: option.systemImage)
                        Text(option.rawValue)
                        Spacer()
                        if selectedOption == option {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
        }
        .accessibilityLabel("Sort players")
        .accessibilityValue(selectedOption.rawValue)
        .accessibilityHint("Choose how to sort the player list")
    }
}

// Player Count Badge
private struct PlayerCountBadge: View {
    let count: Int
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "person.2")
                .font(.system(size: 12, weight: .medium))
            Text("\(count)")
                .font(DesignSystem.Typography.caption1)
                .fontWeight(.semibold)
        }
        .foregroundColor(DesignSystem.Colors.secondaryText)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(
            Capsule()
                .fill(DesignSystem.Colors.tertiaryBackground)
        )
        .accessibilityLabel("\(count) players")
    }
}

// MARK: - State-Specific Views

// Loading State
private struct LoadingPlayersState: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ProgressView()
                .controlSize(.large)
                .tint(DesignSystem.Colors.primary)
            
            Text("Loading players...")
                .font(DesignSystem.Typography.subheadline)
                .foregroundColor(DesignSystem.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xxxl)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading players")
    }
}



// Empty State
private struct EmptyPlayersState: View {
    let onAddPlayer: () -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 64, weight: .light))
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                    .accessibilityHidden(true)
                
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("No Players Yet")
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Add your first player to start creating balanced teams. You can add players with different skill levels to ensure fair team distribution.")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
            }
            
            VStack(spacing: DesignSystem.Spacing.md) {
                EnhancedButton.primary(
                    "Add Your First Player",
                    systemImage: "plus.circle.fill"
                ) {
                    onAddPlayer()
                }
                
                // Quick tips
                VStack(spacing: DesignSystem.Spacing.xs) {
                    HelpfulTip(
                        icon: "lightbulb.fill",
                        iconColor: DesignSystem.Colors.accent,
                        text: "Tip: Add at least 4 players for team generation"
                    )
                    
                    HelpfulTip(
                        icon: "star.fill",
                        iconColor: DesignSystem.Colors.warning,
                        text: "Rate skills from 1-10 for balanced teams"
                    )
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Tips for getting started")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xxxl)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("No players added yet")
        .accessibilityHint("Add your first player to start creating teams")
    }
}

// Error State
private struct ErrorPlayersState: View {
    let onRetry: () async -> Void
    let onAddPlayer: () -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            VStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "exclamationmark.triangle")
                    .font(DesignSystem.Typography.extraLargeDisplay)
                    .fontWeight(.light)
                    .foregroundColor(DesignSystem.Colors.error)
                
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text("Something Went Wrong")
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Text("Unable to load your players. Please check your connection and try again.")
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
            }
            
            HStack(spacing: DesignSystem.Spacing.md) {
                EnhancedButton.secondary("Try Again", systemImage: "arrow.clockwise") {
                    Task { await onRetry() }
                }
                
                EnhancedButton.primary("Add Player", systemImage: "plus") {
                    onAddPlayer()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xxxl)
        .background(DesignSystem.Colors.secondaryBackground)
        .cornerRadius(DesignSystem.CornerRadius.large)
    }
}

// MARK: - Helpful Tip Component
/// Refined tip component with better visual hierarchy
private struct HelpfulTip: View {
    let icon: String
    let iconColor: Color
    let text: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 20, height: 20)
                
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(iconColor)
            }
            
            Text(text)
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.secondaryText)
            
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(DesignSystem.Colors.tertiaryBackground.opacity(0.5))
        )
    }
}

// MARK: - Player Card Wrapper
/// Wrapper for the existing EnhancedPlayerCard with custom actions
private struct PlayerCardWithActions: View {
    let player: PlayerEntity
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        EnhancedPlayerCard(player: player)
    }
}

// MARK: - Enhanced Sheets



// MARK: - Form Components







// MARK: - Supporting Components (Reused)

private struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xxxs) {
            Text(value)
                .font(DesignSystem.Typography.callout)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            Text(title)
                .font(DesignSystem.Typography.caption2)
                .foregroundColor(DesignSystem.Colors.tertiaryText)
                .textCase(.uppercase)
        }
    
}
}