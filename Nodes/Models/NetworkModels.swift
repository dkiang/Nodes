import Foundation
import CoreData
import SwiftUI

// MARK: - Student Node Model
struct StudentNode: Identifiable, Codable {
    let id: UUID
    var name: String
    var position: CGPoint
    var isActive: Bool
    var connections: [Connection]
    
    init(id: UUID = UUID(), name: String, position: CGPoint = .zero, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.position = position
        self.isActive = isActive
        self.connections = []
    }
}

// MARK: - Connection Model
struct Connection: Identifiable, Codable {
    let id: UUID
    let fromNodeId: UUID
    let toNodeId: UUID
    var commonInterest: String
    
    init(id: UUID = UUID(), fromNodeId: UUID, toNodeId: UUID, commonInterest: String) {
        self.id = id
        self.fromNodeId = fromNodeId
        self.toNodeId = toNodeId
        self.commonInterest = commonInterest
    }
}

// MARK: - Network State
class NetworkState: ObservableObject {
    @Published var nodes: [StudentNode] = []
    @Published var selectedNode: StudentNode?
    @Published var isDrawingConnection: Bool = false
    @Published var connectionStartNode: StudentNode?
    @Published var scale: CGFloat = 1.0
    @Published var offset: CGSize = .zero
    @Published var isPathFindingMode: Bool = false
    
    // Path finding
    @Published var startNode: StudentNode?
    @Published var endNode: StudentNode?
    @Published var currentPath: [StudentNode] = []
    @Published var isAnimatingPath: Bool = false
    
    func addNode(name: String, at position: CGPoint) {
        let newNode = StudentNode(name: name, position: position)
        nodes.append(newNode)
        // TODO: Sync with backend
    }
    
    func addConnection(from: StudentNode, to: StudentNode, commonInterest: String) {
        let connection = Connection(fromNodeId: from.id, toNodeId: to.id, commonInterest: commonInterest)
        if let fromIndex = nodes.firstIndex(where: { $0.id == from.id }) {
            nodes[fromIndex].connections.append(connection)
        }
        if let toIndex = nodes.firstIndex(where: { $0.id == to.id }) {
            nodes[toIndex].connections.append(Connection(fromNodeId: to.id, toNodeId: from.id, commonInterest: commonInterest))
        }
        // TODO: Sync with backend
    }
    
    func toggleNodeActive(_ node: StudentNode) {
        if let index = nodes.firstIndex(where: { $0.id == node.id }) {
            nodes[index].isActive.toggle()
            // TODO: Sync with backend
        }
    }
    
    func findPaths(from start: StudentNode, to end: StudentNode) -> [[StudentNode]] {
        var paths: [[StudentNode]] = []
        var visited = Set<UUID>()
        
        func dfs(current: StudentNode, path: [StudentNode]) {
            if current.id == end.id {
                paths.append(path)
                return
            }
            
            visited.insert(current.id)
            
            for connection in current.connections {
                guard let nextNode = nodes.first(where: { $0.id == connection.toNodeId }),
                      nextNode.isActive,
                      !visited.contains(nextNode.id) else { continue }
                
                dfs(current: nextNode, path: path + [nextNode])
            }
            
            visited.remove(current.id)
        }
        
        dfs(current: start, path: [start])
        return paths
    }
} 