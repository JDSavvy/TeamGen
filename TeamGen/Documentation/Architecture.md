# TeamGen Architecture Documentation

## Overview
TeamGen follows **Clean Architecture** principles with modern **MVVM (Model-View-ViewModel)** patterns, aligned with the latest SwiftUI and Apple development best practices for iOS 18+.

## Architecture Layers

### 1. **Domain Layer** (`Domain/`) - Pure Business Logic
- **Entities**: Core business models (PlayerEntity, TeamEntity)
- **Use Cases**: Business logic orchestration and rules
- **Repository Protocols**: Data access contracts
- **Service Protocols**: Domain service interfaces

```
Domain/
├── Entities/               # Core business entities
│   ├── PlayerEntity.swift
│   └── TeamEntity.swift
├── UseCases/              # Business logic orchestration
├── Repositories/          # Data access protocols
└── Services/              # Domain service protocols
```

### 2. **Core Layer** (`Core/`) - Infrastructure & Implementation
- **Data**: Repository implementations and data access
- **Services**: Service implementations (Analytics, Haptics, etc.)
- **Dependency Injection**: Protocol-based container pattern
- **Persistence**: SwiftData integration
- **Networking**: API communication layer

```
Core/
├── Data/
│   └── Repositories/       # Repository implementations
├── Services/
│   └── Implementations/    # Service implementations
├── DependencyInjection/   # DI container
├── Persistence/           # SwiftData configuration
└── Networking/            # Network layer
```

### 3. **Features Layer** (`Features/`) - Presentation
- **Feature-Based Organization**: Each feature is self-contained with its own Views, ViewModels, and Components
- **Modern SwiftUI**: Using `@Observable` ViewModels with automatic state observation
- **Dependency Injection**: Environment-based DI for clean testability

```
Features/
├── PlayerManagement/
│   ├── ViewModels/        # Feature-specific ViewModels
│   ├── Views/            # SwiftUI Views and States
│   └── Components/       # Reusable UI components
├── TeamGeneration/
└── Settings/
```

### 4. **Shared Layer** (`Shared/`) - Common Utilities
- **Components**: Reusable UI components
- **Design System**: Consistent styling and theming
- **Extensions**: Utility extensions
- **Constants**: App-wide constants

## Key Architectural Decisions

### 1. **@Observable ViewModels**
```swift
@Observable
@MainActor
final class PlayerManagementViewModel {
    private(set) var state: PlayerManagementState = .idle
    // Automatic state observation - no @Published needed
}
```

**Benefits:**
- Automatic UI updates without manual observation
- Better performance than @ObservableObject
- Simplified state management

### 2. **Clean Architecture Layers**
Following the dependency rule: Domain ← Core ← Features ← Shared
- ✅ **Good**: `Domain/Entities/PlayerEntity.swift` (pure business logic)
- ✅ **Good**: `Core/Data/Repositories/SwiftDataPlayerRepository.swift` (implementation)
- ✅ **Good**: `Features/PlayerManagement/ViewModels/PlayerManagementViewModel.swift` (presentation)
- ❌ **Bad**: `ViewModels/PlayerManagementViewModel.swift` (breaks feature isolation)

### 3. **Protocol-Based Dependency Injection**
```swift
@MainActor
protocol DependencyContainerProtocol {
    var playerRepository: PlayerRepositoryProtocol { get }
    var hapticService: HapticServiceProtocol { get }
    // ...
}
```

### 4. **Modern State Management**
```swift
// View-local state
@State private var presentationState = PlayerPresentationState()

// Environment dependencies
@Environment(\.dependencies) private var dependencies

// No @StateObject/@ObservedObject needed with @Observable
```

### 5. **Clean View Separation**
- **Large Views Split**: 1000+ line views broken into focused components
- **Single Responsibility**: Each view has one clear purpose
- **Composition**: Complex UIs built from smaller, reusable components

## SwiftUI Best Practices Implemented

### 1. **Modern Property Wrappers**
- `@State` for local UI state
- `@Environment` for dependency injection
- `@Observable` for ViewModels (replaces @ObservableObject)

### 2. **Navigation Patterns**
```swift
NavigationStack {
    // Content
}
.sheet(isPresented: $showingForm) {
    PlayerFormView(mode: .add) { /* completion */ }
}
```

### 3. **Performance Optimizations**
- Lazy initialization of ViewModels
- Efficient state observation
- Minimal view rebuilds through focused state

### 4. **Error Handling**
```swift
enum PlayerManagementState: Equatable {
    case idle, loading, loaded([PlayerEntity])
    case error(String)
}
```

### 5. **Accessibility**
- VoiceOver support throughout
- Dynamic Type support
- High contrast mode compatibility

## Testing Strategy

### 1. **Unit Tests**
- ViewModels with mock dependencies
- Use Cases with mock repositories
- Domain logic validation

### 2. **Integration Tests**
- Repository implementations
- End-to-end feature flows

### 3. **UI Tests**
- Critical user journeys
- Accessibility validation

## Migration from Legacy Patterns

### ✅ **Modernized**
- `@ObservableObject` → `@Observable`
- Central ViewModels folder → Feature-specific ViewModels
- Massive view files → Focused, composed views
- Manual state observation → Automatic with @Observable

### 🚫 **Deprecated Patterns Avoided**
- `@StateObject` for dependency-injected ViewModels
- `@ObservedObject` when @Observable is available
- Centralized ViewModels breaking feature isolation
- Monolithic view files

## Performance Considerations

1. **Lazy Loading**: ViewModels initialized only when needed
2. **State Optimization**: Minimal observable properties
3. **View Composition**: Small, focused views for better diffing
4. **Memory Management**: Proper cleanup in ViewModels

## Future Enhancements

1. **Swift Concurrency**: Full async/await adoption
2. **SwiftData Optimizations**: Advanced queries and relationships
3. **Modularization**: Potential SPM package extraction
4. **Testing**: Increase coverage with modernized architecture 