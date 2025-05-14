import SwiftUI

// MARK: - Connection Views
struct ConnectionLineView: View {
    let from: StudentNode
    let to: StudentNode
    let commonInterest: String
    let opacity: Double
    
    var body: some View {
        Path { path in
            path.move(to: from.position)
            path.addLine(to: to.position)
        }
        .stroke(Color.blue, lineWidth: 2)
        .opacity(opacity)
        .overlay(
            Text(commonInterest)
                .font(.caption2)
                .foregroundColor(.secondary)
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
                opacity: getConnectionOpacity(from: node, to: toNode)
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
        }
    }
}

// MARK: - Node Views
struct NodeView: View {
    let node: StudentNode
    let color: Color
    let isSelected: Bool
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
                    .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 3)
            )
            .shadow(radius: isDragging ? 8 : 4)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
    }
}

struct NetworkNodesView: View {
    let nodes: [StudentNode]
    let nodeColor: (StudentNode) -> Color
    let draggedNode: StudentNode?
    let dragState: CGSize
    let pathFindingStartNode: StudentNode?
    let pathFindingEndNode: StudentNode?
    let onNodeTap: (StudentNode) -> Void
    let onNodeDrag: (StudentNode, CGSize) -> Void
    
    private func isNodeSelected(_ node: StudentNode) -> Bool {
        node.id == pathFindingStartNode?.id || node.id == pathFindingEndNode?.id
    }
    
    private func getNodeScale(_ node: StudentNode) -> CGFloat {
        draggedNode?.id == node.id && dragState != .zero ? 1.1 : 1.0
    }
    
    var body: some View {
        ForEach(nodes) { node in
            NodeView(
                node: node,
                color: nodeColor(node),
                isSelected: isNodeSelected(node)
            )
            .position(node.position)
            .offset(draggedNode?.id == node.id ? dragState : .zero)
            .scaleEffect(getNodeScale(node))
            .gesture(
                DragGesture()
                    .updating(.init(get: { dragState }, set: { _ in })) { value, state, _ in
                        onNodeDrag(node, value.translation)
                    }
            )
            .onTapGesture {
                onNodeTap(node)
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: dragState)
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
        !networkState.isPathFindingMode && networkState.isDrawingConnection
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
                    dragState: dragState
                )
                
                // Path visualization
                if let start = pathFindingStartNode, let end = pathFindingEndNode {
                    PathVisualizationView(path: currentPath)
                }
                
                // Temporary connection line
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
                    onNodeTap: handleNodeTap,
                    onNodeDrag: { node, translation in
                        draggedNode = node
                        if let index = networkState.nodes.firstIndex(where: { $0.id == node.id }) {
                            let newPosition = CGPoint(
                                x: min(max(node.position.x + translation.width, 30), geometry.size.width - 30),
                                y: min(max(node.position.y + translation.height, 30), geometry.size.height - 30)
                            )
                            networkState.nodes[index].position = newPosition
                        }
                        draggedNode = nil
                    }
                )
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
        if pathFindingStartNode == nil {
            pathFindingStartNode = node
        } else if pathFindingEndNode == nil && node.id != pathFindingStartNode?.id {
            pathFindingEndNode = node
            if let start = pathFindingStartNode {
                let paths = networkState.findPaths(from: start, to: node)
                if let shortestPath = paths.first {
                    currentPath = shortestPath
                }
            }
        } else {
            pathFindingStartNode = node
            pathFindingEndNode = nil
            currentPath = []
        }
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
        }
    }
} 
