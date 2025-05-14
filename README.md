# Class Network Visualization

An interactive iOS app for visualizing social connections among students in a class. The app allows users to create, manage, and explore relationships between students through an intuitive node-based interface.

## Features

- **Interactive Node Graph**
  - Create and manage student nodes with unique rainbow colors
  - Drag nodes to rearrange the network layout
  - Pinch-to-zoom and pan for easy navigation
  - Visual feedback for active/inactive nodes
  - Black border highlighting for selected nodes in path finding mode

- **Connection Management**
  - Create connections between students with shared interests
  - Automatic replacement of existing connections
  - Delete connections with a single tap
  - Visual labels showing common interests
  - Connection lines only appear after selecting both nodes

- **Path Finding**
  - Find the shortest path between any two students
  - Black border highlighting for start and end nodes
  - Animated path visualization with green highlight
  - Prevents selection of unreachable nodes
  - Clear visual feedback for selected nodes
  - Maintains node colors during path finding

- **Undo Support**
  - Undo any action (node creation, connection management, etc.)
  - Maintains a history of all changes
  - Easy access through the toolbar

- **Data Persistence**
  - Automatic saving of network state
  - Restore previous sessions
  - Maintains all connections and node positions

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository
2. Open `Nodes.xcodeproj` in Xcode
3. Build and run the project

## Usage

### Creating Nodes
- Tap the "+" button to add a new student node
- Enter the student's name
- The node will appear with a unique rainbow color

### Managing Connections
- Tap a node to select it
- Tap another node to create a connection
- Enter the common interest
- To delete a connection, tap the "x" button on the connection label

### Finding Paths
1. Tap the "Find Path" button
2. Select the starting node (highlighted with black border)
3. Select a reachable destination node (highlighted with black border)
4. The shortest path will be highlighted in green
5. Tap any node to start a new path search
6. Unreachable nodes cannot be selected as end points

### Undoing Actions
- Use the undo button in the toolbar to revert the last action
- Supports undoing:
  - Node creation/deletion
  - Connection creation/deletion
  - Node position changes
  - Node activation state changes

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: `StudentNode`, `Connection`, and `NetworkState`
- **Views**: SwiftUI views for the network graph and UI components
- **ViewModels**: `NetworkState` manages the app's state and business logic

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- SwiftUI for the modern UI framework
- Core Data for persistence
- Graph algorithms for path finding 