# Nodes - Student Connection Visualization

A SwiftUI application for visualizing and managing connections between students based on common interests.

## Features

### Node Management
- Add students as nodes to the network
- Drag and drop nodes to position them
- Automatic node repositioning during device rotation
- Nodes maintain their positions during modal presentations
- Batch selection and activation/deactivation of nodes
- Visual feedback for selected nodes with checkmark indicators

### Connection Management
- Create bidirectional connections between students
- Specify common interests for each connection
- Visual representation of connections with interest labels
- Delete connections with a single tap
- Improved connection line visualization
- Automatic connection updates during node activation/deactivation

### Path Finding
- Toggle path finding mode to find connections between nodes
- Automatic finding of the shortest path between selected nodes
- Visualization of the path with a thick green highlighted connection
- Intuitive node selection behavior:
  - First tap sets the start node
  - Second tap on a different node sets the end node
  - Tapping the start node again clears both selections
  - Tapping the end node again only clears the end node
- Path updates automatically when nodes are activated/deactivated
- Disabled node dragging while in path finding mode

### User Interface
- Clean, modern interface with intuitive controls
- Responsive layout that adapts to device orientation
- Modal dialogs for adding students and connections
- Immediate keyboard focus for text input fields
- Toolbar menu with quick access to common actions
- Undo support for all operations
- Clear visual feedback for all interactions

### Node States
- Active/Inactive states for nodes
- Visual distinction between active and inactive nodes
- Greyed-out appearance for inactive nodes and their connections
- Batch activation/deactivation of selected nodes
- Automatic path updates when node states change

## Usage

### Adding Students
1. Tap the "Add Student" button
2. Enter the student's name
3. The student will appear as a node in the network
4. Drag the node to position it

### Creating Connections
1. Tap a node to start creating a connection
2. Tap another node to complete the connection
3. Enter the common interest in the dialog
4. A bidirectional connection will be created between the nodes

### Finding Paths
1. Tap the "Find Path" button to enter path finding mode
2. Tap a node to set it as the start node
3. Tap another node to set it as the end node
4. The shortest path between the nodes will be highlighted
5. Tap the start node again to clear the selection
6. Tap the end node again to clear only the end node

### Managing Node States
1. Tap "Select Nodes" in the toolbar menu
2. Tap nodes to select them
3. Use "Deactivate Selected" or "Activate Selected" to change their states
4. Tap "Cancel Selection" to exit selection mode

### Device Rotation
- Nodes automatically reposition to remain visible
- Connections and paths update smoothly
- Node positions are preserved during modal presentations
- Layout adapts to maintain usability in any orientation

## Technical Details

### Architecture
- SwiftUI-based user interface
- CoreData for persistent storage
- Observable state management
- Bidirectional connection model
- Efficient path finding algorithms (BFS with DFS fallback)

### Performance
- Optimized node repositioning
- Efficient connection management
- Smooth animations and transitions
- Responsive user interface
- Memory-efficient data structures

## Requirements
- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation
1. Clone the repository
2. Open the project in Xcode
3. Build and run on your device or simulator

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is licensed under the MIT License - see the LICENSE file for details. 