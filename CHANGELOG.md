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

### Changed
- Updated connection management to replace existing connections
- Improved node highlighting system with black borders for path finding
- Enhanced path finding visual feedback
- Refactored state management for better undo support
- Updated README with new features and usage instructions
- Improved connection label visibility and interaction
- Modified path finding to maintain node colors
- Updated connection line appearance logic

### Fixed
- Connection persistence during node dragging
- Path finding mode node selection
- Connection label positioning
- State management for undo operations
- Visual feedback for selected nodes
- Connection line appearance timing
- Path finding node selection validation
- Node color consistency during path finding

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