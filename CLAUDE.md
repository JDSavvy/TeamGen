# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) and the @claude GitHub bot when working with code in this repository.

## @claude GitHub Bot Integration

You can mention @claude in any GitHub issue or PR comment to get AI assistance with:
- Code review and suggestions
- Bug fixes and implementation 
- Test creation and debugging
- Architecture guidance
- Performance optimization
- Feature implementation

### Example Usage:
```
@claude Can you help implement the missing test for PlayerEntity.validateSkills()?
@claude Review this PR for performance issues and suggest optimizations
@claude Create a comprehensive test suite for the TeamGenerationService
```

## Build Commands

This is an iOS project using Xcode with comprehensive testing and code quality tools. Use the build script for automated workflows:

```bash
# Automated build script (recommended)
./scripts/build.sh full          # Complete pipeline (build, lint, test, docs)
./scripts/build.sh ci            # CI/CD simulation (faster, no UI tests)
./scripts/build.sh build         # Build only
./scripts/build.sh test          # Build and test
./scripts/build.sh lint          # Code quality checks only

# Manual Xcode commands
# Build the project
xcodebuild -project TeamGen.xcodeproj -scheme TeamGen -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Run tests
xcodebuild test -project TeamGen.xcodeproj -scheme TeamGen -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Run specific test suite
xcodebuild test -project TeamGen.xcodeproj -scheme TeamGen -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:TeamGenTests

# Run UI tests
xcodebuild test -project TeamGen.xcodeproj -scheme TeamGen -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:TeamGenUITests

# Code quality checks
swiftlint lint --reporter xcode
swiftformat --lint .

# Generate documentation
xcodebuild docbuild -project TeamGen.xcodeproj -scheme TeamGen -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Archive for App Store
xcodebuild -project TeamGen.xcodeproj -scheme TeamGen archive -archivePath TeamGen.xcarchive
```

### Code Quality Tools

Install required tools:
```bash
# Install SwiftLint
brew install swiftlint

# Install SwiftFormat  
brew install swiftformat
```

Run quality checks:
```bash
# Lint code
swiftlint

# Format code
swiftformat .

# Check formatting without applying changes
swiftformat --lint .
```

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
- **MetricKit**: Performance monitoring and diagnostics
- **Swift-DocC**: API documentation generation

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

### Development Infrastructure ✅

This project includes:
- ✅ Comprehensive unit test suite (`TeamGenTests/`)
- ✅ UI test automation (`TeamGenUITests/`)
- ✅ SwiftLint configuration (`.swiftlint.yml`)
- ✅ SwiftFormat configuration (`.swiftformat`)
- ✅ GitHub Actions CI/CD pipeline (`.github/workflows/ios.yml`)
- ✅ Swift-DocC documentation (`TeamGen.docc/`)
- ✅ Performance monitoring (MetricKit integration)
- ✅ Code coverage reporting

### Testing Infrastructure

**Test Coverage:**
- Domain layer business logic (90%+ target)
- Repository implementations
- ViewModel state management
- UI automation for critical flows
- Performance benchmarking

**Running Tests:**
```bash
# All tests
xcodebuild test -project TeamGen.xcodeproj -scheme TeamGen -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Unit tests only
xcodebuild test -project TeamGen.xcodeproj -scheme TeamGen -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:TeamGenTests

# UI tests only  
xcodebuild test -project TeamGen.xcodeproj -scheme TeamGen -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:TeamGenUITests
```

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

## @claude Bot Guidelines

### When Implementing Features:
1. **Follow Clean Architecture**: Domain → Core → Features → Shared
2. **Use Modern Patterns**: @Observable ViewModels, async/await, proper error handling
3. **Include Tests**: Always create corresponding tests for new features
4. **Maintain Quality**: Ensure SwiftLint compliance and proper documentation
5. **Consider Accessibility**: VoiceOver support, Dynamic Type, high contrast

### Code Style Preferences:
- Use `@Observable` instead of `@ObservableObject` for ViewModels
- Prefer protocol-based dependency injection
- Use structured error handling with domain-specific errors
- Follow Apple's Swift API Design Guidelines
- Include comprehensive inline documentation

### Test Implementation Requirements:
- Domain layer: 90%+ coverage target
- Use mock objects for external dependencies
- Test both success and failure scenarios
- Include performance tests for critical algorithms
- UI tests for core user journeys

### Current Priority Issues:
1. **Test Implementation**: Fix compilation errors in test files
2. **Core Features**: Complete missing implementations
3. **Performance**: Profile and optimize critical paths
4. **Accessibility**: Full VoiceOver and Dynamic Type support

### File Organization:
```
TeamGen/
├── Domain/           # Pure business logic (entities, use cases, protocols)
├── Core/            # Infrastructure (repositories, services, DI, persistence)
├── Features/        # Presentation layer (MVVM with @Observable)
└── Shared/          # Common components, design system, utilities
```

### When Creating PRs:
- Include detailed description of changes
- Add tests for new functionality
- Update documentation if needed
- Ensure CI/CD pipeline passes
- Follow conventional commit format