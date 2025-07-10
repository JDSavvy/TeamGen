import SwiftUI

// MARK: - Settings View

/// Modern settings view using @Observable ViewModels
/// Focuses on essential app configuration with clean, intuitive design
/// NavigationStack and title handled at TabView level for proper isolation
struct SettingsView: View {
    @State private var viewModel: SettingsManagementViewModel?
    @Environment(\.dependencies) private var dependencies
    @Environment(\.colorScheme) private var systemColorScheme

    var body: some View {
        Group {
            if let viewModel {
                Form {
                    appearanceSection(viewModel: viewModel)
                    languageSection(viewModel: viewModel)
                    aboutSection
                }
            } else {
                ProgressView("Loading Settings...")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await initializeViewIfNeeded()
        }
        .preferredColorScheme(dependencies.colorSchemeService.effectiveColorScheme)
    }

    private func appearanceSection(viewModel: SettingsManagementViewModel) -> some View {
        Section {
            // Color Scheme Picker
            HStack {
                Label("Appearance", systemImage: "circle.lefthalf.filled")
                    .foregroundColor(.primary)

                Spacer()

                Picker("Appearance", selection: Binding(
                    get: { viewModel.colorScheme },
                    set: { newValue in
                        viewModel.colorScheme = newValue
                        Task { await viewModel.updateColorScheme(newValue) }
                    }
                )) {
                    ForEach(ColorSchemeOption.allCases, id: \.self) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.menu)
            }

            // High Contrast Toggle
            HStack {
                Label("Increase Contrast", systemImage: "circle.grid.cross.fill")
                    .foregroundColor(.primary)

                Spacer()

                Toggle("", isOn: Binding(
                    get: { viewModel.highContrastEnabled },
                    set: { newValue in
                        viewModel.highContrastEnabled = newValue
                        Task { await viewModel.updateHighContrast(newValue) }
                    }
                ))
                .labelsHidden()
            }
        } header: {
            Text("Display & Brightness")
        } footer: {
            Text("Choose how TeamGen appears on your device. Automatic follows your system settings.")
        }
    }

    private func languageSection(viewModel: SettingsManagementViewModel) -> some View {
        Section {
            HStack {
                Label("Language", systemImage: "globe")
                    .foregroundColor(.primary)

                Spacer()

                Picker("Language", selection: Binding(
                    get: { viewModel.selectedLanguage },
                    set: { newValue in
                        viewModel.selectedLanguage = newValue
                        Task { await viewModel.updateLanguage(newValue) }
                    }
                )) {
                    ForEach(SupportedLanguage.allCases, id: \.self) { language in
                        Text(language.displayName).tag(language)
                    }
                }
                .pickerStyle(.menu)
            }
        } header: {
            Text("General")
        } footer: {
            Text("Select your preferred language for TeamGen. Some changes may require restarting the app.")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Label("Version", systemImage: "app.badge")
                    .foregroundColor(.primary)

                Spacer()

                Text(appVersion)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }

            HStack {
                Label("Developer", systemImage: "person.circle")
                    .foregroundColor(.primary)

                Spacer()

                Text("Jorge Savvidis")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
        } header: {
            Text("About TeamGen")
        } footer: {
            Text(
                """
                TeamGen helps create balanced teams for sports and recreational activities.
                Thank you for using our app!
                """
            )
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    // MARK: - Private Methods

    private func initializeViewIfNeeded() async {
        guard viewModel == nil else { return }

        let vm = SettingsManagementViewModel(
            settingsRepository: dependencies.settingsRepository,
            hapticService: dependencies.hapticService,
            colorSchemeService: dependencies.colorSchemeService
        )

        await vm.loadSettings()
        viewModel = vm
    }
}

// MARK: - Appearance Settings Section

/// Visual appearance settings following HIG guidelines
private struct AppearanceSettingsSection: View {
    @Bindable var viewModel: SettingsManagementViewModel

    var body: some View {
        SettingsSection(
            title: NSLocalizedString("Appearance", comment: "Appearance settings section title"),
            icon: "paintbrush.fill",
            iconColor: DesignSystem.Colors.accent
        ) {
            SettingsPickerRow(
                title: NSLocalizedString("Color Scheme", comment: "Color scheme setting title"),
                subtitle: NSLocalizedString("Choose your preferred theme", comment: "Color scheme setting subtitle"),
                selection: $viewModel.colorScheme,
                options: ColorSchemeOption.allCases,
                icon: "circle.lefthalf.filled",
                onSelectionChange: { await viewModel.updateColorScheme($0) }
            )

            SettingsToggleRow(
                title: NSLocalizedString("High Contrast", comment: "High contrast setting title"),
                subtitle: NSLocalizedString("Increase text and UI contrast", comment: "High contrast setting subtitle"),
                isOn: $viewModel.highContrastEnabled,
                icon: "circle.grid.cross.fill",
                onToggle: { await viewModel.updateHighContrast($0) }
            )
        }
    }
}

// MARK: - Localization Section

/// Language selection for app interface
private struct LocalizationSection: View {
    @Bindable var viewModel: SettingsManagementViewModel

    var body: some View {
        SettingsSection(
            title: NSLocalizedString("Language", comment: "Language settings section title"),
            icon: "globe",
            iconColor: DesignSystem.Colors.primary
        ) {
            SettingsPickerRow(
                title: NSLocalizedString("App Language", comment: "App language setting title"),
                subtitle: NSLocalizedString("Choose your preferred language", comment: "App language setting subtitle"),
                selection: $viewModel.selectedLanguage,
                options: SupportedLanguage.allCases,
                icon: "textformat.abc",
                onSelectionChange: { await viewModel.updateLanguage($0) }
            )
        }
    }
}

// MARK: - About Section

/// Essential app information and developer details
private struct AboutSection: View {
    var body: some View {
        SettingsSection(
            title: NSLocalizedString("About", comment: "About section title"),
            icon: "info.circle.fill",
            iconColor: DesignSystem.Colors.secondaryText
        ) {
            SettingsInfoRow(
                title: NSLocalizedString("App Version", comment: "App version info title"),
                subtitle: appVersion,
                icon: "app.badge",
                isInteractive: false
            )

            SettingsInfoRow(
                title: NSLocalizedString("Developer", comment: "Developer info title"),
                subtitle: NSLocalizedString("Jorge Savvidis", comment: "Developer name"),
                icon: "person.circle.fill",
                isInteractive: false
            )

            SettingsInfoRow(
                title: NSLocalizedString("GitHub", comment: "GitHub link title"),
                subtitle: NSLocalizedString("Coming soon", comment: "GitHub link placeholder"),
                icon: "link.circle.fill",
                isInteractive: false
            )
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

// MARK: - Settings Components

// Settings Section Container
private struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Section Header
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(DesignSystem.Typography.settingsIcon)
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(iconColor.opacity(DesignSystem.VisualConsistency.opacitySkillBackground))
                    )

                Text(title)
                    .font(DesignSystem.Typography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Spacer()
            }
            .accessibilityAddTraits(.isHeader)

            // Section Content
            EnhancedCard(style: .default, elevation: .low) {
                VStack(spacing: 0) {
                    content
                }
            }
        }
    }
}

// Settings Toggle Row
private struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let icon: String
    let onToggle: (Bool) async -> Void

    var body: some View {
        SettingsRowContainer(
            title: title,
            subtitle: subtitle,
            icon: icon
        ) {
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .onChange(of: isOn) { _, newValue in
                    Task {
                        await onToggle(newValue)
                    }
                }
        }
    }
}

// Settings Picker Row
private struct SettingsPickerRow<T: CaseIterable & Identifiable & RawRepresentable>: View where T.RawValue == String {
    let title: String
    let subtitle: String
    @Binding var selection: T
    let options: [T]
    let icon: String
    let onSelectionChange: (T) async -> Void

    var body: some View {
        SettingsRowContainer(
            title: title,
            subtitle: subtitle,
            icon: icon
        ) {
            Menu {
                ForEach(options) { option in
                    Button {
                        selection = option
                        Task {
                            await onSelectionChange(option)
                        }
                    } label: {
                        HStack {
                            Text(option.rawValue)
                            if selection == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Text(selection.rawValue)
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.primary)

                    Image(systemName: "chevron.down")
                        .font(DesignSystem.Typography.settingsDescription)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
    }
}

// Settings Info Row
private struct SettingsInfoRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let isInteractive: Bool
    let action: (() -> Void)?

    init(title: String, subtitle: String, icon: String, isInteractive: Bool = true, action: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isInteractive = isInteractive
        self.action = action
    }

    var body: some View {
        if isInteractive, let action {
            Button(action: action) {
                rowContent
            }
            .buttonStyle(.plain)
        } else {
            rowContent
        }
    }

    private var rowContent: some View {
        SettingsRowContainer(
            title: title,
            subtitle: subtitle,
            icon: icon
        ) {
            if isInteractive {
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Typography.settingsDescription)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }
        }
    }
}

// Settings Row Container
private struct SettingsRowContainer<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    var iconColor: Color = DesignSystem.Colors.secondaryText
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(DesignSystem.Typography.settingsIcon)
                .foregroundColor(iconColor)
                .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxxs) {
                Text(title)
                    .font(DesignSystem.Typography.body)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Text(subtitle)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .lineLimit(2)
            }

            Spacer()

            content
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .contentShape(Rectangle())
    }
}

// MARK: - Supporting Types
