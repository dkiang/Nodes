# Changelog

## [Unreleased]

### Added
- CoreData integration for persistent storage of nodes and connections
- Undo functionality for node movements, connections, and node creation/deletion
- Clear data feature with confirmation dialog
- Path finding mode with shortest path visualization
- Debug logging for path finding and connection operations
- Automatic node repositioning on device rotation
- Node selection mode for managing multiple nodes
- Batch node activation/deactivation
- Visual feedback for selected nodes
- Node selection mode for batch activation/deactivation
- Visual feedback for selected nodes with checkmark indicators
- Improved keyboard focus handling for text input fields
- Modal state tracking to prevent unwanted node repositioning

### Changed
- Improved connection handling to ensure bidirectional connections are properly saved
- Updated path finding algorithm to use BFS (Breadth-First Search) for finding shortest paths
- Enhanced node dragging to track start positions for undo functionality
- Disabled node dragging in path finding mode
- Improved connection visualization with better opacity handling
- Updated connection management to replace existing connections
- Improved node highlighting system with black borders for path finding
- Enhanced path finding visual feedback
- Increased path visualization stroke width for better visibility
- Updated path finding node selection behavior:
  - Tapping start node again now resets both start and end nodes
  - Tapping end node again now only deselects the end node
  - Improved node selection logic for better user experience
- Enhanced toolbar menu with node selection options
- Improved node visual feedback with selection indicators
- Updated node interaction to support selection mode
- Improved connection management with bidirectional connections
- Enhanced node highlighting system with clearer visual states
- Updated toolbar menu with node selection options
- Improved path finding visual feedback with thicker stroke width
- Refined node selection behavior in path finding mode
- Optimized view size handling during modal presentations

### Fixed
- Fixed issue where connections were not being saved as bidirectional in CoreData
- Fixed path finding to always find the shortest path between nodes
- Fixed node selection in path finding mode to allow any node as start point
- Fixed connection persistence issues that caused some nodes to appear disconnected
- Fixed path finding node selection behavior to be more intuitive
- Fixed path visualization to be more visible with thicker strokes
- Fixed node positioning to maintain visibility during device rotation
- Fixed node repositioning during modal sheet presentation
- Fixed keyboard focus issues in connection and student input dialogs
- Fixed path finding node selection behavior
- Fixed visibility of path visualization
- Fixed node positions during device rotation
- Fixed connection line visualization
- Fixed modal presentation state management
- Fixed environment object handling in modal views

## [0.1.0] - 2024-03-XX

### Added
- Initial release
- Basic node creation and connection functionality
- Node dragging and positioning
- Connection creation with common interests
- Node activation/deactivation
- Basic path visualization 