# Nodes

A SwiftUI application for creating and visualizing networks of nodes and their connections. Built with SwiftUI and CoreData for persistent storage.

## Features

### Node Management
- Create and delete nodes
- Drag nodes to position them
- Activate/deactivate nodes
- Undo/redo node movements and creation/deletion

### Connection Management
- Create bidirectional connections between nodes
- Specify common interests for connections
- Delete connections
- Connections are automatically saved and persisted
- Connections respect node activation state (dimmed when either node is inactive)

### Path Finding
- Toggle path finding mode to find connections between nodes
- Automatically finds the shortest path between selected nodes
- Visualizes the path with a thick green highlighted connection
- Disables node dragging while in path finding mode
- Intuitive node selection behavior:
  - First tap on any node sets it as the start node
  - Tapping the start node again resets both start and end nodes
  - Tapping the end node again only deselects the end node
  - Tapping a new node when only start is selected tries to set it as end node
  - Tapping a new node when both are selected makes it the new start node
- End nodes are only selectable if a valid path exists
- Clear visual feedback with black borders for selected nodes
- Thick green path visualization for better visibility

### Data Management
- Automatic saving of all changes
- Clear all data option with confirmation dialog
- Persistent storage using CoreData
- Undo/redo support for all operations

## Usage

### Creating and Managing Nodes
1. Tap the "+" button to create a new node
2. Enter the node's name
3. Drag nodes to position them
4. Double-tap a node to activate/deactivate it
5. Use the undo button to revert changes

### Creating Connections
1. Tap a node to start creating a connection
2. Tap another node to complete the connection
3. Enter the common interest for the connection
4. Connections are automatically bidirectional

### Path Finding
1. Toggle path finding mode using the "Find Path" button
2. Select a start node (will be highlighted with a black border)
3. Select an end node (will be highlighted with a black border)
   - If you tap the start node again, both selections will be cleared
   - If you tap the end node again, only the end node will be deselected
   - If you tap a new node when both are selected, it becomes the new start node
4. Available paths will be shown with thick green animated lines
5. Exit path finding mode to return to normal operation

### Data Management
- Use the menu to access additional options
- "Clear All Data" will remove all nodes and connections
- "Undo" will revert the last action
- All changes are automatically saved

## Technical Details

### Architecture
- Built with SwiftUI for the user interface
- Uses CoreData for persistent storage
- Implements BFS (Breadth-First Search) for path finding
- Supports bidirectional connections with proper persistence

### Data Model
- `StudentNode`: Represents a node in the network
  - Properties: id, name, position, isActive, connections
- `Connection`: Represents a connection between nodes
  - Properties: id, fromNodeId, toNodeId, commonInterest
- CoreData entities: NodeEntity and ConnectionEntity

### Path Finding
- Uses BFS algorithm to find the shortest path
- Considers node activation state
- Falls back to DFS if no path is found with BFS
- Visualizes the path with animated connections

## Requirements
- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation
1. Clone the repository
2. Open the project in Xcode
3. Build and run on your device or simulator

## Contributing
Feel free to submit issues and enhancement requests! 