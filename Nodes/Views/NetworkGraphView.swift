import SwiftUI

struct NetworkGraphView: View {
    @EnvironmentObject private var networkState: NetworkState
    @State private var showingConnectionAlert = false
    @State private var commonInterest = ""
    @State private var tempConnectionEnd: CGPoint?
    @State private var draggedNode: StudentNode?
    @GestureState private var dragState = CGSize.zero
    @State private var viewSize: CGSize = .zero
    
    // Add this function to get a color based on node index
    private func nodeColor(for node: StudentNode) -> Color {
        let colors: [Color] = [
            .red, .orange, .yellow, .green, .blue, .indigo, .purple
        ]
        if let index = networkState.nodes.firstIndex(where: { $0.id == node.id }) {
            return colors[index % colors.count]
        }
        return .blue
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                // Connections
                ForEach(networkState.nodes) { node in
                    ForEach(node.connections) { connection in
                        if let toNode = networkState.nodes.first(where: { $0.id == connection.toNodeId }) {
                            ConnectionView(from: node, to: toNode, commonInterest: connection.commonInterest)
                                .opacity(node.isActive && toNode.isActive ? 1.0 : 0.3)
                        }
                    }
                }
                
                // Temporary connection line while drawing
                if networkState.isDrawingConnection,
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
                ForEach(networkState.nodes) { node in
                    NodeView(node: node, color: nodeColor(for: node))
                        .position(node.position)
                        .offset(draggedNode?.id == node.id ? dragState : .zero)
                        .scaleEffect(draggedNode?.id == node.id && dragState != .zero ? 1.1 : 1.0)
                        .gesture(
                            DragGesture()
                                .updating($dragState) { value, state, _ in
                                    draggedNode = node
                                    state = value.translation
                                }
                                .onEnded { value in
                                    if let index = networkState.nodes.firstIndex(where: { $0.id == node.id }) {
                                        let newPosition = CGPoint(
                                            x: min(max(node.position.x + value.translation.width, 30), geometry.size.width - 30),
                                            y: min(max(node.position.y + value.translation.height, 30), geometry.size.height - 30)
                                        )
                                        networkState.nodes[index].position = newPosition
                                    }
                                    draggedNode = nil
                                }
                        )
                        .onTapGesture {
                            handleNodeTap(node)
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: dragState)
                }
                
                // Path animation
                if networkState.isAnimatingPath {
                    ForEach(0..<networkState.currentPath.count - 1, id: \.self) { index in
                        let from = networkState.currentPath[index]
                        let to = networkState.currentPath[index + 1]
                        Path { path in
                            path.move(to: from.position)
                            path.addLine(to: to.position)
                        }
                        .stroke(Color.green, lineWidth: 3)
                        .opacity(0.7)
                    }
                }
            }
            .gesture(
                MagnificationGesture()
                    .onChanged { scale in
                        networkState.scale = scale
                    }
            )
            .onAppear {
                viewSize = geometry.size
            }
            .onChange(of: geometry.size) { newSize in
                viewSize = newSize
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

struct NodeView: View {
    let node: StudentNode
    let color: Color
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
            .shadow(radius: isDragging ? 8 : 4)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
    }
}

struct ConnectionView: View {
    let from: StudentNode
    let to: StudentNode
    let commonInterest: String
    
    var body: some View {
        Path { path in
            path.move(to: from.position)
            path.addLine(to: to.position)
        }
        .stroke(Color.blue, lineWidth: 2)
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