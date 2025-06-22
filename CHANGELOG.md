# Changelog

All notable changes to the Class Network Visualization project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Rainbow-colored nodes for better visual distinction
- Connection deletion with visual delete button
- Undo functionality for all actions
- Automatic connection replacement when creating new connections
- Black border highlighting for selected nodes in path finding mode
- Path validation to prevent selection of unreachable nodes
- Animated path visualization
- Connection line visibility control
- State management for path finding mode
- Enhanced Find Path mode functionality
  - Node dragging enabled in path finding mode
  - Dynamic shortest path calculation and updates
  - Automatic path re-routing when nodes become inactive
  - Real-time path visualization that moves with dragged nodes
  - Shortest path optimization when nodes are reactivated
- Data persistence using CoreData
  - Automatic saving of nodes and connections
  - Data persists between app sessions
  - Efficient batch operations for data management
- Data management features
  - Clear all data option with confirmation dialog
  - Improved undo functionality with persistent state
  - Menu-based toolbar for data management actions
- CoreData model for nodes and connections
  - Efficient storage of node properties
  - Relationship management for connections
  - Automatic cascade deletion of related data
- Automatic text field focus when adding new students
- Improved force touch sensitivity for node interaction
- Enhanced haptic feedback system
- Dedicated AddStudentView component for better state management
- Immediate keyboard appearance when adding new students
- Educational lesson notes system
  - Comprehensive teaching materials and activities
  - Remote content update capability via GitHub
  - Professional markdown formatting for easy reading
- Simplified user interface design
  - Clean two-button control panel (Add Student and Find Path only)
  - Info button for accessing lesson notes and administrative functions
  - Streamlined toolbar with essential functions only

### Changed
- Updated connection management to replace existing connections
- Improved node highlighting system with black borders for path finding
- Enhanced path finding visual feedback
- Refactored state management for better undo support
- Updated README with new features and usage instructions
- Improved connection label visibility and interaction
- Modified path finding to maintain node colors
- Updated connection line appearance logic
- Enhanced Find Path mode behavior
  - Removed restrictions on node dragging during path finding
  - Improved path calculation to always show shortest available route
  - Updated path visualization to use real-time node positions during dragging
- Updated node and connection models to work with CoreData
- Improved data management UI with a more organized menu
- Enhanced toolbar with additional data management options
- Removed navigation title for cleaner interface
- Improved node dragging behavior and smoothness
- Enhanced gesture handling for better touch response
- Optimized Add Student sheet presentation and performance
- Improved keyboard handling and focus management
- Complete user interface redesign for educational use
  - Replaced complex menu system with simple info button
  - Moved Clear All Data function to lesson notes screen
  - Simplified control panel to focus on core functions
  - Removed selection mode functionality from main interface
- Enhanced lesson notes integration
  - Fallback to default content when remote content unavailable
  - Quick access through info button in toolbar
  - Consolidated administrative functions in notes view

### Fixed
- Connection persistence during node dragging
- Path finding mode node selection
- Connection label positioning
- State management for undo operations
- Visual feedback for selected nodes
- Connection line appearance timing
- Path finding node selection validation
- Node color consistency during path finding
- Path visualization positioning during node dragging
  - Fixed green highlighted path staying static when nodes are dragged
  - Ensured path lines move smoothly with dragged nodes
  - Synchronized path visualization with real-time node positions
- Data persistence between app launches
- Proper cleanup of related data when deleting nodes
- Consistent state management across app sessions
- Node spinning and disappearing issues during drag
- Force touch detection and response
- Scope issues with isDragging variable
- CGPoint distance method implementation
- HapticManager integration
- NetworkState scope management
- Keyboard focus and appearance in Add Student sheet
- Sheet presentation performance and responsiveness
- App startup performance issues
  - Eliminated 10+ second white screen at launch
  - Simplified CoreData initialization for faster loading
  - Removed complex async patterns that were blocking UI
  - Optimized synchronous data loading for immediate responsiveness

## [0.1.0] - 2024-05-13

### Added
- Initial project creation
- Basic SwiftUI structure
- Core Data model setup
- Student node management
- Connection creation between nodes
- Path finding algorithm
- Node deactivation
- Data persistence
- Rainbow-colored nodes
- Interactive dragging
- Pinch-to-zoom support

### Changed
- Improved node dragging behavior
- Enhanced visual feedback
- Optimized layout system
- Updated input handling

### Fixed
- Layout constraints
- Dragging behavior
- UI/UX improvements

## Versioning

We use [Semantic Versioning](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/yourusername/Nodes/tags).

## Release Notes

### Version 0.1.0
Initial release with core functionality:
- Node creation and management
- Connection creation and visualization
- Path finding between nodes
- Basic data persistence
- Interactive node manipulation
- Visual feedback system 