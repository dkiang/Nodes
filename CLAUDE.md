# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Building and Running
- **Build**: Use Xcode to build the project (`Cmd+B`)
- **Run**: Use Xcode to run on simulator or device (`Cmd+R`)
- **Clean**: `Product > Clean Build Folder` in Xcode

### Testing
- **Run Tests**: `Cmd+U` in Xcode
- **Unit Tests**: Located in `NodesTests/NodesTests.swift`
- **UI Tests**: Located in `NodesUITests/`

## Architecture Overview

### Core Components
- **SwiftUI + CoreData**: Modern iOS app using SwiftUI for UI and CoreData for persistence
- **MVVM Pattern**: Uses `@StateObject` and `@ObservableObject` for state management
- **Centralized State**: `NetworkState` class manages all app state and business logic

### Data Layer
- **CoreData Entities**: 
  - `NodeEntity`: Stores student nodes with position, name, and active state
  - `ConnectionEntity`: Stores bidirectional connections between nodes with common interests
- **Persistence**: `PersistenceController` handles CoreData stack setup and operations
- **Models**: `StudentNode` and `Connection` structs provide Swift-friendly interfaces

### State Management
- **NetworkState**: Central state manager handling:
  - Node and connection management
  - Path finding algorithms (BFS/DFS)
  - Undo/redo functionality
  - UI state (modals, selection modes, drag operations)
  - CoreData synchronization

### UI Architecture
- **ContentView**: Main container with navigation and control panel
- **NetworkGraphView**: Interactive graph visualization
- **AddStudentView**: Modal sheet for adding new students
- Custom views for connections, path visualization, and animations

### Key Features
- **Interactive Node Graph**: Drag-and-drop positioning with smooth animations
- **Bidirectional Connections**: All connections are automatically created in both directions
- **Path Finding**: BFS algorithm to find shortest paths between nodes
- **Undo System**: Comprehensive undo functionality for all operations
- **Node Selection**: Multi-select mode for batch operations
- **Data Persistence**: Automatic saving to CoreData with efficient loading

### Important Patterns
- **Gesture Handling**: Complex gesture recognition for drag, tap, and long-press operations
- **View Size Tracking**: Handles modal presentation and screen rotation
- **Batch Operations**: Efficient CoreData operations for performance
- **Debugging**: Extensive debug logging for connection and path finding operations

## File Structure
- `Nodes/`: Main app target
  - `NodesApp.swift`: App entry point
  - `ContentView.swift`: Main UI container
  - `Persistence.swift`: CoreData stack
  - `Models/NetworkModels.swift`: Data models and state management
  - `Views/NetworkGraphView.swift`: Graph visualization
  - `Nodes.xcdatamodeld/`: CoreData model
- `NodesTests/`: Unit tests
- `NodesUITests/`: UI automation tests

## Development Notes
- **iOS Target**: iOS 15.0+
- **Swift Version**: 5.5+
- **Xcode Version**: 13.0+
- **Dependencies**: None (uses only system frameworks)