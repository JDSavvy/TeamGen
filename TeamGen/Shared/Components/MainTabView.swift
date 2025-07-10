import Observation
import SwiftUI

struct MainTabView: View {
    @Environment(\.colorScheme) var systemColorScheme
    @Environment(\.dependencies) var dependencies
    @State private var selectedTab = 0
    @State private var isInitialized = false
    @State private var lastImpactTime: Date = .distantPast

    private let impactCooldown: TimeInterval = 0.1 // Prevent rapid haptic feedback

    init() {
        configureTabBarAppearance()
    }

    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient
                .ignoresSafeArea()

            // Individual NavigationStacks for each tab to prevent toolbar cross-contamination
            TabView(selection: $selectedTab) {
                // Teams Tab
                NavigationStack {
                    TeamViewContent(selectedTab: $selectedTab)
                }
                .tabItem {
                    Label(
                        "Teams",
                        systemImage: selectedTab == 0 ? DesignSystem.Symbols.personGroupFill : DesignSystem.Symbols
                            .personGroup
                    )
                }
                .tag(0)

                // Players Tab - Isolated NavigationStack
                NavigationStack {
                    PlayerViewContent()
                }
                .tabItem {
                    Label(
                        "Players",
                        systemImage: selectedTab == 1 ? DesignSystem.Symbols.personStackFill : DesignSystem.Symbols
                            .personStack
                    )
                }
                .tag(1)

                // Settings Tab
                NavigationStack {
                    SettingsViewContent()
                }
                .tabItem {
                    Label(
                        "Settings",
                        systemImage: selectedTab == 2 ? DesignSystem.Symbols.gearFill : DesignSystem.Symbols.gear
                    )
                }
                .tag(2)
            }
            .onChange(of: selectedTab) { oldValue, newValue in
                handleTabChange(from: oldValue, to: newValue)
            }
            .preferredColorScheme(dependencies.colorSchemeService.effectiveColorScheme)
        }
        .task {
            await initializeView()
        }
        .onChange(of: systemColorScheme) { _, newScheme in
            updateTabBarStyle(for: newScheme)
        }
        .onChange(of: dependencies.colorSchemeService.effectiveColorScheme) { _, newScheme in
            updateTabBarStyle(for: newScheme ?? systemColorScheme)
        }
    }

    // MARK: - Background Gradient

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                DesignSystem.Colors.primaryBackground,
                DesignSystem.Colors.secondaryBackground.opacity(0.3),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Configuration Methods

    private func configureTabBarAppearance() {
        // Configure modern tab bar appearance following Apple's latest HIG
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()

        // Background styling
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)

        // Item styling - consistent with Apple's design language
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
        ]

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
        ]

        // Compact appearance (iPhone landscape)
        appearance.compactInlineLayoutAppearance = appearance.stackedLayoutAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

        // Additional styling following Apple's elevation guidelines
        UITabBar.appearance().layer.shadowColor = UIColor.black.cgColor
        UITabBar.appearance().layer.shadowOffset = CGSize(width: 0, height: -2)
        UITabBar.appearance().layer.shadowRadius = 8
        UITabBar.appearance().layer.shadowOpacity = 0.1
    }

    // MARK: - Event Handlers

    private func handleTabChange(from oldTab: Int, to newTab: Int) {
        // Haptic feedback with cooldown following Apple's guidelines
        let now = Date()
        if now.timeIntervalSince(lastImpactTime) > impactCooldown {
            Task { @MainActor in
                await dependencies.hapticService.selection()
            }
            lastImpactTime = now
        }

        // Analytics tracking
        trackTabChange(from: oldTab, to: newTab)
    }

    private func trackTabChange(from _: Int, to _: Int) {
        // Analytics tracking following Apple's privacy guidelines
        // Tab change logged for analytics
    }

    private func tabName(for index: Int) -> String {
        switch index {
        case 0: "Teams"
        case 1: "Players"
        case 2: "Settings"
        default: "Unknown"
        }
    }

    // MARK: - Initialization & State Management

    private func initializeView() async {
        if !isInitialized {
            await loadColorScheme()
            updateTabBarStyle(for: dependencies.colorSchemeService.effectiveColorScheme ?? systemColorScheme)
            isInitialized = true
        }
    }

    private func loadColorScheme() async {
        await dependencies.colorSchemeService.loadPreferences()
    }

    private func updateTabBarStyle(for _: ColorScheme) {
        // Implementation of updateTabBarStyle method
    }
}

// MARK: - Content Views (NavigationStack-free)

/// Content views without NavigationStack to prevent nesting issues

private struct TeamViewContent: View {
    @Binding var selectedTab: Int

    var body: some View {
        TeamView(selectedTab: $selectedTab)
            .navigationTitle("Teams")
            .navigationBarTitleDisplayMode(.large)
    }
}

private struct PlayerViewContent: View {
    var body: some View {
        PlayerView()
            .navigationTitle("Players")
            .navigationBarTitleDisplayMode(.large)
    }
}

private struct SettingsViewContent: View {
    var body: some View {
        SettingsView()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Preview

#if DEBUG
    struct MainTabView_Previews: PreviewProvider {
        static var previews: some View {
            MainTabView()
        }
    }
#endif
