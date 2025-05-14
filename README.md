# Class Network Visualization

An interactive iOS app that helps students visualize their social connections in the classroom. Students can create a network of connections based on shared interests, and explore how information flows through their social network.

## Features

- **Interactive Node Graph**
  - Drag and drop nodes to arrange the network
  - Rainbow-colored nodes for easy identification
  - Smooth animations and visual feedback
  - Pinch to zoom for better visibility

- **Connection Management**
  - Create connections between students by tapping nodes
  - Add shared interests to connections
  - Visualize active and inactive connections
  - Real-time updates to the network

- **Path Finding**
  - Find all possible paths between students
  - Animate path traversal
  - Deactivate nodes to see alternative routes
  - Visualize how information flows through the network

- **Data Persistence**
  - Save network data between app launches
  - Core Data integration for reliable storage
  - Maintain node positions and connections

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/Nodes.git
```

2. Open `Nodes.xcodeproj` in Xcode

3. Build and run the project (⌘R)

## Usage

1. **Adding Students**
   - Tap the "Add Student" button
   - Enter the student's name
   - The student will appear as a colored node in the network

2. **Creating Connections**
   - Tap a student node to start creating a connection
   - Tap another student node to complete the connection
   - Enter the shared interest when prompted

3. **Exploring the Network**
   - Drag nodes to rearrange the network
   - Use pinch gestures to zoom in/out
   - Tap the "Find Path" button to explore connections between students
   - Tap nodes to deactivate them and see alternative paths

## Architecture

The app is built using:
- SwiftUI for the user interface
- Core Data for persistence
- MVVM architecture pattern
- Observable state management

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Created for educational purposes to demonstrate network theory concepts
- Inspired by social network analysis and graph theory
- Built with SwiftUI and modern iOS development practices 