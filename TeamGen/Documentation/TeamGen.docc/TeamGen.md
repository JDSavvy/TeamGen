# ``TeamGen``

TeamGen is a modern iOS application for creating balanced teams from groups of players with sophisticated skill-based algorithms.

## Overview

TeamGen implements Clean Architecture principles with modern SwiftUI patterns to deliver a professional-grade team generation experience. The app features player management, advanced team generation algorithms, and comprehensive accessibility support.

### Key Features

- **Player Management**: Add, edit, and organize players with multi-dimensional skill ratings
- **Intelligent Team Generation**: Advanced algorithms for creating balanced teams
- **Modern UI**: SwiftUI-based interface with iOS 18 design patterns
- **Accessibility First**: Comprehensive VoiceOver and accessibility support
- **Data Persistence**: SwiftData integration with schema migration support

## Architecture

TeamGen follows Clean Architecture principles with clear separation between layers:

### Domain Layer
Pure business logic without framework dependencies:
- ``PlayerEntity`` - Core player model with skills and statistics
- ``TeamEntity`` - Team model with balance calculations and validation
- ``ManagePlayersUseCase`` - Player management business logic
- ``GenerateTeamsUseCase`` - Team generation orchestration

### Core Layer  
Infrastructure and implementation details:
- ``SwiftDataPlayerRepository`` - Data persistence implementation
- ``TeamGenerationService`` - Team creation algorithms
- ``iOSHapticService`` - Haptic feedback implementation
- ``LiveDependencyContainer`` - Dependency injection container

### Features Layer
SwiftUI presentation layer with @Observable ViewModels:
- ``PlayerManagementViewModel`` - Player management state
- ``TeamGenerationViewModel`` - Team generation coordination
- Modern SwiftUI views with accessibility support

### Shared Layer
Common components and design system:
- ``DesignSystem`` - Comprehensive design system
- ``EnhancedButton`` - Reusable button components
- Extensions and utilities

## Getting Started

### Adding Players

1. Navigate to the Players tab
2. Tap the "Add Player" button
3. Enter player name and adjust skill ratings
4. Save to add to your player roster

### Generating Teams

1. Select players from your roster
2. Navigate to the Teams tab  
3. Adjust team count and generation mode
4. Tap "Generate Teams" for balanced results

### Customization

Use the Settings tab to customize:
- Color scheme preferences
- Language settings
- Accessibility options

## Technical Requirements

- **iOS**: 18.4+ (cutting-edge iOS features)
- **Swift**: 5.9+
- **Architecture**: Clean Architecture with MVVM
- **UI Framework**: SwiftUI with @Observable pattern
- **Data**: SwiftData with migration support

## Topics

### Essential Types
- ``PlayerEntity``
- ``TeamEntity``
- ``PlayerSkills``
- ``TeamStrengthLevel``

### Business Logic
- ``ManagePlayersUseCase``
- ``GenerateTeamsUseCase``
- ``TeamGenerationService``

### Data Management
- ``PlayerRepositoryProtocol``
- ``SwiftDataPlayerRepository``
- ``SchemaMigration``

### User Interface
- ``PlayerManagementViewModel``
- ``TeamGenerationViewModel``
- ``DesignSystem``

### Services
- ``HapticServiceProtocol``
- ``AnalyticsServiceProtocol``
- ``ColorSchemeService``