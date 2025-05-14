import SwiftUI

// MARK: - Connection Views
struct ConnectionLineView: View {
    let from: StudentNode
    let to: StudentNode
    let commonInterest: String
    let opacity: Double
    let onDelete: () -> Void
    
    var body: some View {
        Path { path in
            path.move(to: from.position)
            path.addLine(to: to.position)
        }
        .stroke(Color.blue, lineWidth: 2)
        .opacity(opacity)
        .overlay(
            HStack(spacing: 4) {
                Text(commonInterest)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption2)
                }
            }
            .padding(4)
            .background(Color(.systemBackground).opacity(0.8))
            .cornerRadius(8)
            .position(
                x: (from.position.x + to.position.x) / 2,
                y: (from.position.y + to.position.y) / 2 - 10
            )
        )
    }
}

struct NetworkConnectionsView: View {
    let nodes: [StudentNode]
    let draggedNode: StudentNode?
    let dragState: CGSize
    let onDeleteConnection: (Connection, StudentNode, StudentNode) -> Void
    
    private func getNodePosition(_ node: StudentNode, isDragged: Bool) -> CGPoint {
        if isDragged {
            return CGPoint(
                x: node.position.x + dragState.width,
                y: node.position.y + dragState.height
            )
        }
        return node.position
    }
    
    private func createNodeWithPosition(_ node: StudentNode, position: CGPoint) -> StudentNode {
        StudentNode(
            id: node.id,
            name: node.name,
            position: position,
            isActive: node.isActive
        )
    }
    
    private func getConnectionOpacity(from: StudentNode, to: StudentNode) -> Double {
        from.isActive && to.isActive ? 1.0 : 0.3
    }
    
    private func connectionView(for connection: Connection, from node: StudentNode) -> some View {
        guard let toNode = nodes.first(where: { $0.id == connection.toNodeId }) else {
            return AnyView(EmptyView())
        }
        
        let fromPosition = getNodePosition(node, isDragged: draggedNode?.id == node.id)
        let toPosition = getNodePosition(toNode, isDragged: draggedNode?.id == toNode.id)
        
        let fromNodeWithPosition = createNodeWithPosition(node, position: fromPosition)
        let toNodeWithPosition = createNodeWithPosition(toNode, position: toPosition)
        
        return AnyView(
            ConnectionLineView(
                from: fromNodeWithPosition,
                to: toNodeWithPosition,
                commonInterest: connection.commonInterest,
                opacity: getConnectionOpacity(from: node, to: toNode),
                onDelete: { onDeleteConnection(connection, node, toNode) }
            )
        )
    }
    
    var body: some View {
        ForEach(nodes) { node in
            ForEach(node.connections) { connection in
                connectionView(for: connection, from: node)
            }
        }
    }
}

// MARK: - Path Views
struct PathVisualizationView: View {
    let path: [StudentNode]
    
    var body: some View {
        ForEach(path.indices.dropLast(), id: \.self) { index in
            let from = path[index]
            let to = path[index + 1]
            Path { path in
                path.move(to: from.position)
                path.addLine(to: to.position)
            }
            .stroke(Color.green, lineWidth: 3)
            .opacity(0.7)
            .animation(.easeInOut(duration: 0.3), value: path)
        }
    }
}

// MARK: - Node Views
struct NodeView: View {
    let node: StudentNode
    let color: Color
    let isSelected: Bool
    let isStartNode: Bool
    let isEndNode: Bool
    @State private var isDragging = false
    
    var body: some View {
        Circle()
            .fill(node.isActive ? color : Color.gray)
            .frame(width: 60, height: 60)
            .overlay(
                Text(node.name)
                    .font(.caption)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(4)
            )
            .overlay(
                Circle()
                    .stroke(
                        isStartNode || isEndNode ? Color.black : 
                        isSelected ? Color.yellow : Color.clear,
                        lineWidth: 3
                    )
            )
            .shadow(radius: isDragging ? 8 : 4)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
    }
}

struct NodeGestureView: View {
    let node: StudentNode
    let color: Color
    let isDragged: Bool
    let dragState: CGSize
    let isStartNode: Bool
    let isEndNode: Bool
    let isPathFindingMode: Bool
    let onDragStart: (StudentNode) -> Void
    let onDrag: (StudentNode, CGSize) -> Void
    let onDragEnd: (StudentNode) -> Void
    let onTap: (StudentNode) -> Void
    @GestureState private var localDragState = CGSize.zero
    
    var body: some View {
        NodeView(
            node: node,
            color: color,
            isSelected: false,
            isStartNode: isStartNode,
            isEndNode: isEndNode
        )
        .offset(isDragged ? dragState : localDragState)
        .scaleEffect((isDragged && dragState != .zero) || localDragState != .zero ? 1.1 : 1.0)
        .gesture(
            DragGesture()
                .onChanged { _ in
                    if !isPathFindingMode && localDragState == .zero {
                        onDragStart(node)
                    }
                }
                .updating($localDragState) { value, state, _ in
                    if !isPathFindingMode {
                        state = value.translation
                        onDrag(node, value.translation)
                    }
                }
                .onEnded { _ in
                    if !isPathFindingMode {
                        onDragEnd(node)
                    }
                }
        )
        .onTapGesture {
            onTap(node)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: localDragState)
    }
}

struct NetworkNodesView: View {
    let nodes: [StudentNode]
    let nodeColor: (StudentNode) -> Color
    let draggedNode: StudentNode?
    let dragState: CGSize
    let pathFindingStartNode: StudentNode?
    let pathFindingEndNode: StudentNode?
    let isPathFindingMode: Bool
    let onNodeTap: (StudentNode) -> Void
    let onNodeDragStart: (StudentNode) -> Void
    let onNodeDrag: (StudentNode, CGSize) -> Void
    let onNodeDragEnd: (StudentNode) -> Void
    
    private func isNodeSelected(_ node: StudentNode) -> Bool {
        node.id == pathFindingStartNode?.id || node.id == pathFindingEndNode?.id
    }
    
    private func isNodeDragged(_ node: StudentNode) -> Bool {
        draggedNode?.id == node.id
    }
    
    private func nodeView(for node: StudentNode) -> some View {
        NodeGestureView(
            node: node,
            color: nodeColor(node),
            isDragged: isNodeDragged(node),
            dragState: dragState,
            isStartNode: node.id == pathFindingStartNode?.id,
            isEndNode: node.id == pathFindingEndNode?.id,
            isPathFindingMode: isPathFindingMode,
            onDragStart: onNodeDragStart,
            onDrag: onNodeDrag,
            onDragEnd: onNodeDragEnd,
            onTap: onNodeTap
        )
        .position(node.position)
    }
    
    var body: some View {
        ForEach(nodes) { node in
            nodeView(for: node)
        }
    }
}

// MARK: - Main View
struct NetworkGraphView: View {
    @EnvironmentObject private var networkState: NetworkState
    @State private var showingConnectionAlert = false
    @State private var commonInterest = ""
    @State private var tempConnectionEnd: CGPoint?
    @State private var draggedNode: StudentNode?
    @GestureState private var dragState = CGSize.zero
    @State private var viewSize: CGSize = .zero
    @State private var pathFindingStartNode: StudentNode?
    @State private var pathFindingEndNode: StudentNode?
    @State private var currentPath: [StudentNode] = []
    
    private func nodeColor(for node: StudentNode) -> Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple]
        if let index = networkState.nodes.firstIndex(where: { $0.id == node.id }) {
            return colors[index % colors.count]
        }
        return .blue
    }
    
    private var isDrawingTemporaryConnection: Bool {
        !networkState.isPathFindingMode && 
        networkState.isDrawingConnection && 
        networkState.connectionStartNode != nil && 
        tempConnectionEnd != nil
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                // Connections
                NetworkConnectionsView(
                    nodes: networkState.nodes,
                    draggedNode: draggedNode,
                    dragState: dragState,
                    onDeleteConnection: { connection, from, to in
                        networkState.removeConnection(connection, from: from, to: to)
                    }
                )
                
                // Path visualization
                if let start = pathFindingStartNode, let end = pathFindingEndNode {
                    PathVisualizationView(path: currentPath)
                }
                
                // Temporary connection line - only show when we have both start and end points
                if isDrawingTemporaryConnection,
                   let startNode = networkState.connectionStartNode,
                   let endPoint = tempConnectionEnd {
                    Path { path in
                        path.move(to: startNode.position)
                        path.addLine(to: endPoint)
                    }
                    .stroke(Color.blue, lineWidth: 2)
                    .opacity(0.5)
                }
                
                // Nodes
                NetworkNodesView(
                    nodes: networkState.nodes,
                    nodeColor: nodeColor,
                    draggedNode: draggedNode,
                    dragState: dragState,
                    pathFindingStartNode: pathFindingStartNode,
                    pathFindingEndNode: pathFindingEndNode,
                    isPathFindingMode: networkState.isPathFindingMode,
                    onNodeTap: handleNodeTap,
                    onNodeDragStart: { node in
                        networkState.startNodeDrag(node)
                    },
                    onNodeDrag: { node, translation in
                        draggedNode = node
                        if let index = networkState.nodes.firstIndex(where: { $0.id == node.id }) {
                            let newPosition = CGPoint(
                                x: min(max(node.position.x + translation.width, 30), geometry.size.width - 30),
                                y: min(max(node.position.y + translation.height, 30), geometry.size.height - 30)
                            )
                            networkState.updateNodePosition(node, newPosition: newPosition)
                        }
                    },
                    onNodeDragEnd: { node in
                        networkState.endNodeDrag(node)
                        draggedNode = nil
                    }
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { networkState.undo() }) {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    .disabled(!networkState.canUndo)
                }
            }
            .gesture(
                MagnificationGesture()
                    .onChanged { scale in
                        networkState.scale = scale
                    }
            )
            .onAppear { viewSize = geometry.size }
            .onChange(of: geometry.size) { viewSize = $0 }
            .onChange(of: networkState.isPathFindingMode) { newValue in
                if !newValue {
                    pathFindingStartNode = nil
                    pathFindingEndNode = nil
                    currentPath = []
                }
            }
        }
        .sheet(isPresented: $showingConnectionAlert) {
            NavigationView {
                Form {
                    Section(header: Text("Connection Details")) {
                        TextField("Common Interest", text: $commonInterest)
                    }
                }
                .navigationTitle("New Connection")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        networkState.isDrawingConnection = false
                        networkState.connectionStartNode = nil
                        commonInterest = ""
                        showingConnectionAlert = false
                    },
                    trailing: Button("Connect") {
                        if let startNode = networkState.connectionStartNode,
                           let endNode = networkState.nodes.first(where: { $0.position == tempConnectionEnd }) {
                            networkState.addConnection(from: startNode, to: endNode, commonInterest: commonInterest)
                        }
                        networkState.isDrawingConnection = false
                        networkState.connectionStartNode = nil
                        commonInterest = ""
                        showingConnectionAlert = false
                    }
                    .disabled(commonInterest.isEmpty)
                )
            }
        }
    }
    
    private func handleNodeTap(_ node: StudentNode) {
        if networkState.isPathFindingMode {
            handlePathFindingTap(node)
        } else {
            handleConnectionTap(node)
        }
    }
    
    private func handlePathFindingTap(_ node: StudentNode) {
        print("\n=== Path Finding Tap ===")
        print("Tapped node: \(node.name)")
        print("Current state - Start: \(pathFindingStartNode?.name ?? "none"), End: \(pathFindingEndNode?.name ?? "none")")
        
        // Format connections for display
        let connectionNames = node.connections.compactMap { conn -> String? in
            if let targetNode = networkState.nodes.first(where: { $0.id == conn.toNodeId }) {
                return targetNode.name
            }
            return nil
        }
        print("Node connections: \(connectionNames.joined(separator: ", "))")
        
        if pathFindingStartNode == nil {
            // First tap - set as start node
            print("\nSetting \(node.name) as start node")
            pathFindingStartNode = node
            networkState.startNode = node
            pathFindingEndNode = nil
            currentPath = []
            networkState.endNode = nil
            networkState.currentPath = []
        } else if node.id == pathFindingStartNode?.id {
            // Tapping start node again - reset
            print("\nTapped start node again, resetting selection")
            pathFindingStartNode = nil
            pathFindingEndNode = nil
            currentPath = []
            networkState.startNode = nil
            networkState.endNode = nil
            networkState.currentPath = []
        } else if pathFindingEndNode == nil {
            // Second tap - try to set as end node
            if let start = pathFindingStartNode {
                print("\nAttempting to find path from \(start.name) to \(node.name)")
                let paths = networkState.findPaths(from: start, to: node)
                if !paths.isEmpty {
                    // Valid path exists - set as end node
                    print("\nFound valid path:")
                    if let shortestPath = paths.first {
                        let pathString = shortestPath.map { $0.name }.joined(separator: " -> ")
                        print("Path: \(pathString)")
                        print("Path length: \(shortestPath.count) nodes")
                        currentPath = shortestPath
                        networkState.currentPath = shortestPath
                    }
                    pathFindingEndNode = node
                    networkState.endNode = node
                } else {
                    // No valid path - ignore the tap
                    print("\nNo valid path found from \(start.name) to \(node.name)")
                }
            }
        } else {
            // Already have both start and end - reset to new start
            print("\nResetting to new start node: \(node.name)")
            pathFindingStartNode = node
            pathFindingEndNode = nil
            currentPath = []
            networkState.startNode = node
            networkState.endNode = nil
            networkState.currentPath = []
        }
        print("=== End Path Finding Tap ===\n")
    }
    
    private func handleConnectionTap(_ node: StudentNode) {
        if networkState.isDrawingConnection {
            if let startNode = networkState.connectionStartNode, startNode.id != node.id {
                tempConnectionEnd = node.position
                showingConnectionAlert = true
            }
        } else {
            networkState.isDrawingConnection = true
            networkState.connectionStartNode = node
            tempConnectionEnd = nil // Reset the end point when starting a new connection
        }
    }
} 
