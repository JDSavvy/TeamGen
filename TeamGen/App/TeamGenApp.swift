//
//  TeamGenApp.swift
//  TeamGen
//
//  Created by Jorge Savvidis on 22.05.2025.
//

import SwiftUI
import SwiftData
import OSLog

@main
struct TeamGenApp: App {
    var body: some Scene {
        WindowGroup {
            ContentBootstrapper()
        }
        .modelContainer(createModelContainer())
    }
    
    // MARK: - Safe Model Container Creation
    private func createModelContainer() -> ModelContainer {
        do {
            return try ModelContainer(for: SchemaV3.PlayerV3.self, migrationPlan: PlayerMigrationPlan.self)
        } catch {
            // Log the error for debugging but provide a fallback
            Logger(subsystem: "com.teamgen.app", category: "ModelContainer")
                .fault("Failed to create ModelContainer: \(error.localizedDescription)")
            
            // Create a minimal fallback container
            do {
                return try ModelContainer(for: SchemaV3.PlayerV3.self)
            } catch {
                // If even the fallback fails, this is a critical error
                fatalError("Unable to create any ModelContainer: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Modern Content Bootstrapper
struct ContentBootstrapper: View {
    @Environment(\.modelContext) private var modelContext
    @State private var dependencyContainer: DependencyContainerProtocol?
    @State private var isInitialized = false
    @State private var initializationError: Error?
    
    var body: some View {
        Group {
            if let error = initializationError {
                ErrorView(error: error) {
                    Task { @MainActor in
                        await initializeDependencies()
                    }
                }
            } else if let container = dependencyContainer, isInitialized {
                MainTabView()
                    .environment(\.dependencies, container)
                    .colorSchemeAware()
                    .smoothColorTransitions()
            } else {
                LoadingView()
            }
        }
        .task { @MainActor in
            await initializeDependencies()
        }
    }
    
    @MainActor
    private func initializeDependencies() async {
        let logger = Logger(subsystem: "com.teamgen.app", category: "Initialization")
        logger.info("Initializing dependencies with modern SwiftData integration")
        
        // Create dependency container with SwiftData context
        let container = LiveDependencyContainer(modelContext: modelContext)
        
        self.dependencyContainer = container
        self.isInitialized = true
        self.initializationError = nil
        
        logger.info("Dependencies initialized successfully")
    }
}

// MARK: - Loading View
private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.accentColor)
            
            Text("Setting up TeamGen...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Error View
private struct ErrorView: View {
    let error: Error
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(DesignSystem.Typography.splashScreen)
                .foregroundColor(.orange)
            
            Text("Initialization Error")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .padding()
    }
}
