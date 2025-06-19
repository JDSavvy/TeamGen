# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

This is an iOS project using Xcode. Standard Xcode commands apply:

```bash
# Build the project
xcodebuild -project TeamGen.xcodeproj -scheme TeamGen -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Run tests (when test targets are added)
xcodebuild -project TeamGen.xcodeproj -scheme TeamGen -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test

# Build for device
xcodebuild -project TeamGen.xcodeproj -scheme TeamGen -destination 'generic/platform=iOS' build

# Archive for App Store
xcodebuild -project TeamGen.xcodeproj -scheme TeamGen archive -archivePath TeamGen.xcarchive
```

**Note**: This project currently has no test targets or linting setup. When making changes, build and run in Xcode/Simulator to verify functionality.

## Project Configuration

- **iOS Deployment Target**: 18.4 (cutting-edge, latest iOS)
- **Swift Version**: 5.0
- **Bundle ID**: com.savvydev.TeamGen
- **Development Team**: JV4QB7FYS7
- **Architecture**: iPhone-only (portrait orientation)

## Architecture Overview

TeamGen implements **Clean Architecture** with modern **SwiftUI + @Observable ViewModels**:

### Layer Structure
```
TeamGen/
├── Domain/           # Pure business logic (entities, use cases, protocols)
├── Core/            # Infrastructure (repositories, services, DI, persistence)
├── Features/        # Presentation layer (MVVM with @Observable)
├── Shared/          # Common components, design system, utilities
├── Resources/       # Assets, localization
└── App/            # Application entry point
```

### Key Patterns

**1. Dependency Injection**: Protocol-based DI container with live/mock implementations
- Live container: `LiveDependencyContainer` (production)
- Mock container: `MockDependencyContainer` (previews/testing)
- Environment integration: `@Environment(\.dependencies)`

**2. Modern SwiftUI State Management**:
- `@Observable` ViewModels (not `@ObservableObject`)
- `@State` for local UI state
- `@Environment` for dependency injection
- No `@StateObject` or `@ObservedObject` needed

**3. Feature-Based Organization**:
- Each feature has its own ViewModels, Views, and Components
- Self-contained modules for better maintainability
- Clear separation of concerns

**4. SwiftData Integration**:
- Modern persistence replacing Core Data
- Schema migration plan: `PlayerMigrationPlan`
- Repository pattern abstracting data access

### Core Technologies

- **SwiftUI**: Declarative UI framework
- **SwiftData**: Modern data persistence
- **@Observable**: Modern state observation (iOS 17+)
- **OSLog**: Structured logging
- **Combine**: Reactive programming patterns
- **Haptic Feedback**: Native iOS haptic services

## Development Guidelines

### When Adding New Features

1. **Follow Clean Architecture**: New features go in `Features/[FeatureName]/`
2. **Use @Observable ViewModels**: 
   ```swift
   @Observable
   @MainActor
   final class NewFeatureViewModel {
       private(set) var state: NewFeatureState = .idle
   }
   ```
3. **Implement Repository Pattern**: Create protocol in `Domain/Repositories/`, implement in `Core/Data/Repositories/`
4. **Update Dependency Container**: Add new dependencies to both live and mock containers
5. **Follow Design System**: Use `DesignSystem.swift` for consistent styling

### Code Style Conventions

- **Naming**: Follow Apple's Swift API Design Guidelines
- **ViewModels**: Always `@MainActor` and `@Observable`
- **Dependencies**: Inject via protocol, not concrete types
- **State Management**: Use clear state enums (`.idle`, `.loading`, `.loaded`, `.error`)
- **Error Handling**: Comprehensive validation with domain events

### Architecture Constraints

- **Domain Layer**: No SwiftUI/UIKit imports, pure business logic
- **Core Layer**: No SwiftUI imports, infrastructure only
- **Features Layer**: SwiftUI views and ViewModels only
- **Dependency Flow**: Domain ← Core ← Features ← Shared

### Missing Development Infrastructure

This project lacks:
- Unit test targets
- UI test targets
- SwiftLint configuration
- CI/CD pipeline
- Code coverage reporting

When setting up testing, create test targets and update this file with test commands.

## Key Files to Understand

- `TeamGen/App/TeamGenApp.swift`: App entry point with SwiftData setup
- `TeamGen/Core/DependencyInjection/LiveDependencyContainer.swift`: DI container
- `TeamGen/Documentation/Architecture.md`: Detailed architecture documentation
- `TeamGen/Shared/DesignSystem/DesignSystem.swift`: Design system constants
- `TeamGen/Shared/Constants/AppConstants.swift`: App-wide constants

## SwiftData Schema

Current schema version: `SchemaV3.PlayerV3`
- Migration plan: `PlayerMigrationPlan`
- Safe container creation with fallback handling
- Async/await patterns throughout data layer