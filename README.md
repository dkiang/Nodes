# Nodes

A SwiftUI app for visualizing and managing student connections in a classroom network.

## Features

### Network Visualization
- Interactive node-based visualization of student connections
- Drag-and-drop interface for positioning nodes with improved smoothness
- Real-time connection visualization
- Rainbow-colored nodes for easy identification
- Black border highlighting for selected nodes in path finding mode
- Enhanced force touch sensitivity for better interaction
- Improved haptic feedback for better user experience

### Connection Management
- Create connections between students
- Specify common interests for connections
- Visual delete button for removing connections
- Automatic connection replacement
- Undo functionality for all operations
- Connection line visibility control
- Improved gesture handling for better touch response

### Path Finding
- Find paths between students
- Visual feedback for path finding mode
- Validation of node selection
- Animated path visualization
- Black border highlighting for selected nodes
- Prevention of invalid path selections
- Improved node selection and path display
- Enhanced interactive path finding
  - Node dragging enabled during path finding mode
  - Real-time shortest path calculation and updates
  - Automatic path re-routing when nodes become inactive
  - Dynamic path visualization that moves with dragged nodes
  - Immediate path updates when nodes are reactivated

### Data Management
- Persistent storage using CoreData
  - All data automatically saves between sessions
  - Efficient storage of nodes and connections
  - Automatic relationship management
- Data management tools
  - Clear all data option with confirmation
  - Undo functionality with persistent state
  - Menu-based toolbar for easy access
- Batch operations for efficient data handling

### User Interface
- Clean, minimal interface without navigation title
- Optimized Add Student experience
  - Immediate keyboard appearance
  - Automatic text field focus
  - Smooth sheet presentation
  - Responsive input handling
- Improved touch response and gesture handling
- Enhanced visual feedback for all interactions
- Smooth animations and transitions
- Intuitive controls and menu system

## Usage

### Adding Students
1. Tap the "Add Student" button
2. The keyboard appears immediately with the text field focused
3. Start typing the student's name
4. Tap "Add" to create the node
5. The node will appear at a random position
6. Drag to reposition as needed

### Creating Connections
1. Tap and hold a node to start drawing a connection
2. Drag to another node
3. Enter the common interest
4. The connection will be created with a visual line

### Finding Paths
1. Enter path finding mode using the "Find Path" button
2. Select a start node (will be highlighted with a black border)
3. Select an end node (will be highlighted with a black border)
4. The shortest available path will be shown with a green highlighted line
5. Drag any node - the path visualization moves with the nodes
6. Double-tap nodes to activate/deactivate them
   - Path automatically re-routes around inactive nodes
   - Path updates to shorter routes when nodes are reactivated
7. Exit path finding mode to return to normal operation

### Managing Data
- Use the menu (ellipsis) in the toolbar to access:
  - Clear All Data (with confirmation)
  - Undo (when available)
  - Find Path mode toggle
- All changes are automatically saved
- Data persists between app sessions

## Technical Details

### Data Model
- Uses CoreData for persistent storage
- Efficient relationship management
- Automatic cascade deletion
- Batch operations support

### State Management
- Centralized state management with NetworkState
- Persistent undo stack
- Automatic data synchronization
- Efficient batch operations

### UI Components
- Custom node and connection views
- Interactive gesture handling
- Smooth animations
- Responsive layout
- Accessible controls

## Requirements
- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation
1. Clone the repository
2. Open the project in Xcode
3. Build and run on your device or simulator

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- SwiftUI for the modern UI framework
- Core Data for persistence
- Graph algorithms for path finding 