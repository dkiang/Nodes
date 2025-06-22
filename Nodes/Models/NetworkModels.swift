import Foundation
import CoreData
import SwiftUI

// MARK: - Student Node Model
struct StudentNode: Identifiable, Equatable {
    let id: UUID
    var name: String
    var position: CGPoint
    var isActive: Bool
    var connections: [Connection]
    
    init(id: UUID = UUID(), name: String, position: CGPoint = .zero, isActive: Bool = true, connections: [Connection] = []) {
        self.id = id
        self.name = name
        self.position = position
        self.isActive = isActive
        self.connections = connections
    }
    
    static func == (lhs: StudentNode, rhs: StudentNode) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.position == rhs.position &&
        lhs.isActive == rhs.isActive &&
        lhs.connections == rhs.connections
    }
}

// MARK: - Connection Model
struct Connection: Identifiable, Equatable {
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
    
    static func == (lhs: Connection, rhs: Connection) -> Bool {
        lhs.id == rhs.id &&
        lhs.fromNodeId == rhs.fromNodeId &&
        lhs.toNodeId == rhs.toNodeId &&
        lhs.commonInterest == rhs.commonInterest
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
    @Published var showClearDataAlert: Bool = false
    @Published var isSelectionMode: Bool = false
    @Published var selectedNodes: Set<UUID> = []
    
    // View size tracking
    @Published var currentViewSize: CGSize = .zero
    @Published var lastViewSize: CGSize = .zero
    @Published var isShowingModal: Bool = false
    
    // Path finding
    @Published var startNode: StudentNode?
    @Published var endNode: StudentNode?
    @Published var currentPath: [StudentNode] = []
    @Published var isAnimatingPath: Bool = false
    
    // Drag tracking
    private var dragStartPositions: [UUID: CGPoint] = [:]
    
    // Undo stack
    private var undoStack: [NetworkAction] = []
    var canUndo: Bool { !undoStack.isEmpty }
    
    // CoreData
    private let viewContext: NSManagedObjectContext
    
    enum NetworkAction {
        case addNode(StudentNode)
        case removeNode(UUID)
        case addConnection(Connection, from: UUID, to: UUID)
        case removeConnection(Connection, from: UUID, to: UUID)
        case updateNodePosition(UUID, oldPosition: CGPoint, newPosition: CGPoint)
        case toggleNodeActive(UUID, wasActive: Bool)
    }
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        loadNodes()
    }
    
    private func loadNodes() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NodeEntity")
        
        do {
            let nodeEntities = try viewContext.fetch(fetchRequest)
            print("DEBUG: Loading \(nodeEntities.count) nodes from CoreData")
            
            nodes = nodeEntities.compactMap { entity -> StudentNode? in
                guard let nodeEntity = entity as? NSManagedObject,
                      let id = nodeEntity.value(forKey: "id") as? UUID,
                      let name = nodeEntity.value(forKey: "name") as? String else {
                    print("DEBUG: Failed to load node - missing required attributes")
                    return nil
                }
                
                let positionX = nodeEntity.value(forKey: "positionX") as? Double ?? 0.0
                let positionY = nodeEntity.value(forKey: "positionY") as? Double ?? 0.0
                let isActive = nodeEntity.value(forKey: "isActive") as? Bool ?? true
                
                let connections = (nodeEntity.value(forKey: "connections") as? Set<NSManagedObject>)?.compactMap { conn -> Connection? in
                    guard let connId = conn.value(forKey: "id") as? UUID,
                          let toNodeId = conn.value(forKey: "toNodeId") as? UUID,
                          let commonInterest = conn.value(forKey: "commonInterest") as? String else {
                        print("DEBUG: Failed to load connection - missing required attributes")
                        return nil
                    }
                    
                    return Connection(
                        id: connId,
                        fromNodeId: id,
                        toNodeId: toNodeId,
                        commonInterest: commonInterest
                    )
                } ?? []
                
                print("DEBUG: Loaded node \(name) with \(connections.count) connections")
                for conn in connections {
                    print("DEBUG:   - Connection to \(conn.toNodeId) with interest: \(conn.commonInterest)")
                }
                
                return StudentNode(
                    id: id,
                    name: name,
                    position: CGPoint(x: positionX, y: positionY),
                    isActive: isActive,
                    connections: connections
                )
            }
            
            // Verify connections are bidirectional
            for node in nodes {
                for connection in node.connections {
                    if let targetNode = nodes.first(where: { $0.id == connection.toNodeId }) {
                        let hasReverseConnection = targetNode.connections.contains { $0.toNodeId == node.id }
                        if !hasReverseConnection {
                            print("DEBUG: Warning - Connection from \(node.name) to \(targetNode.name) is not bidirectional")
                        }
                    }
                }
            }
            
        } catch {
            print("Error loading nodes: \(error)")
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func clearAllData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NodeEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
            nodes.removeAll()
            selectedNode = nil
            connectionStartNode = nil
            startNode = nil
            endNode = nil
            currentPath.removeAll()
            undoStack.removeAll()
        } catch {
            print("Error clearing data: \(error)")
        }
    }
    
    func addNode(name: String, at position: CGPoint) {
        let newNode = StudentNode(name: name, position: position)
        
        // Create CoreData entity
        let entity = NSEntityDescription.insertNewObject(forEntityName: "NodeEntity", into: viewContext)
        entity.setValue(newNode.id, forKey: "id")
        entity.setValue(newNode.name, forKey: "name")
        entity.setValue(position.x, forKey: "positionX")
        entity.setValue(position.y, forKey: "positionY")
        entity.setValue(newNode.isActive, forKey: "isActive")
        
        saveContext()
        nodes.append(newNode)
        pushUndoAction(.addNode(newNode))
    }
    
    func removeNode(_ node: StudentNode) {
        if let index = nodes.firstIndex(where: { $0.id == node.id }) {
            // Store all connections before removing
            let connections = nodes[index].connections
            for connection in connections {
                if let toNode = nodes.first(where: { $0.id == connection.toNodeId }) {
                    pushUndoAction(.removeConnection(connection, from: node.id, to: toNode.id))
                }
            }
            
            // Remove from CoreData
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NodeEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", node.id as CVarArg)
            
            do {
                let results = try viewContext.fetch(fetchRequest)
                if let entity = results.first {
                    viewContext.delete(entity)
                    saveContext()
                }
            } catch {
                print("Error removing node: \(error)")
            }
            
            pushUndoAction(.removeNode(node.id))
            nodes.remove(at: index)
        }
    }
    
    func addConnection(from: StudentNode, to: StudentNode, commonInterest: String) {
        print("DEBUG: Adding connection from \(from.name) to \(to.name) with interest: \(commonInterest)")
        
        // Remove existing connections if any
        if let existingConnection = findConnection(from: from, to: to) {
            print("DEBUG: Removing existing connection before adding new one")
            removeConnection(existingConnection, from: from, to: to)
        }
        if let existingReverseConnection = findConnection(from: to, to: from) {
            print("DEBUG: Removing existing reverse connection before adding new one")
            removeConnection(existingReverseConnection, from: to, to: from)
        }
        
        let connection = Connection(fromNodeId: from.id, toNodeId: to.id, commonInterest: commonInterest)
        let reverseConnection = Connection(fromNodeId: to.id, toNodeId: from.id, commonInterest: commonInterest)
        
        // Add to CoreData for both directions
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NodeEntity")
        
        do {
            // Get both node entities
            fetchRequest.predicate = NSPredicate(format: "id == %@ OR id == %@", from.id as CVarArg, to.id as CVarArg)
            let nodeEntities = try viewContext.fetch(fetchRequest)
            
            guard let fromEntity = nodeEntities.first(where: { ($0.value(forKey: "id") as? UUID) == from.id }),
                  let toEntity = nodeEntities.first(where: { ($0.value(forKey: "id") as? UUID) == to.id }) else {
                print("DEBUG: Error - Could not find both node entities in CoreData")
                return
            }
            
            // Create forward connection
            let forwardConnectionEntity = NSEntityDescription.insertNewObject(forEntityName: "ConnectionEntity", into: viewContext)
            forwardConnectionEntity.setValue(connection.id, forKey: "id")
            forwardConnectionEntity.setValue(to.id, forKey: "toNodeId")
            forwardConnectionEntity.setValue(commonInterest, forKey: "commonInterest")
            forwardConnectionEntity.setValue(fromEntity, forKey: "fromNode")
            
            // Create reverse connection
            let reverseConnectionEntity = NSEntityDescription.insertNewObject(forEntityName: "ConnectionEntity", into: viewContext)
            reverseConnectionEntity.setValue(reverseConnection.id, forKey: "id")
            reverseConnectionEntity.setValue(from.id, forKey: "toNodeId")
            reverseConnectionEntity.setValue(commonInterest, forKey: "commonInterest")
            reverseConnectionEntity.setValue(toEntity, forKey: "fromNode")
            
            saveContext()
            print("DEBUG: Successfully saved bidirectional connections to CoreData")
        } catch {
            print("Error adding connections: \(error)")
            return
        }
        
        // Update in-memory nodes
        if let fromIndex = nodes.firstIndex(where: { $0.id == from.id }) {
            nodes[fromIndex].connections.append(connection)
            print("DEBUG: Added connection to \(from.name)'s connections list")
        }
        if let toIndex = nodes.firstIndex(where: { $0.id == to.id }) {
            nodes[toIndex].connections.append(reverseConnection)
            print("DEBUG: Added reverse connection to \(to.name)'s connections list")
        }
        
        // Push both connections to undo stack
        pushUndoAction(.addConnection(connection, from: from.id, to: to.id))
        pushUndoAction(.addConnection(reverseConnection, from: to.id, to: from.id))
    }
    
    func removeConnection(_ connection: Connection, from: StudentNode, to: StudentNode) {
        print("DEBUG: Removing connection from \(from.name) to \(to.name)")
        
        // Remove both directions from CoreData
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ConnectionEntity")
        fetchRequest.predicate = NSPredicate(format: "(id == %@) OR (fromNode.id == %@ AND toNodeId == %@)",
                                           connection.id as CVarArg,
                                           to.id as CVarArg,
                                           from.id as CVarArg)
        
        do {
            let connections = try viewContext.fetch(fetchRequest)
            for entity in connections {
                viewContext.delete(entity)
            }
            saveContext()
            print("DEBUG: Successfully removed bidirectional connections from CoreData")
        } catch {
            print("Error removing connections: \(error)")
        }
        
        // Remove from in-memory nodes
        if let fromIndex = nodes.firstIndex(where: { $0.id == from.id }) {
            nodes[fromIndex].connections.removeAll { $0.id == connection.id }
            print("DEBUG: Removed connection from \(from.name)'s connections list")
        }
        if let toIndex = nodes.firstIndex(where: { $0.id == to.id }) {
            nodes[toIndex].connections.removeAll { $0.toNodeId == from.id }
            print("DEBUG: Removed reverse connection from \(to.name)'s connections list")
        }
        
        // Push both removals to undo stack
        pushUndoAction(.removeConnection(connection, from: from.id, to: to.id))
        if let reverseConnection = findConnection(from: to, to: from) {
            pushUndoAction(.removeConnection(reverseConnection, from: to.id, to: from.id))
        }
    }
    
    private func findConnection(from: StudentNode, to: StudentNode) -> Connection? {
        nodes.first { $0.id == from.id }?.connections.first { $0.toNodeId == to.id }
    }
    
    func toggleNodeActive(_ node: StudentNode) {
        if let index = nodes.firstIndex(where: { $0.id == node.id }) {
            let wasActive = nodes[index].isActive
            
            // Update CoreData
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NodeEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", node.id as CVarArg)
            
            do {
                if let entity = try viewContext.fetch(fetchRequest).first {
                    entity.setValue(!wasActive, forKey: "isActive")
                    saveContext()
                }
            } catch {
                print("Error toggling node active state: \(error)")
            }
            
            nodes[index].isActive.toggle()
            pushUndoAction(.toggleNodeActive(node.id, wasActive: wasActive))
            
            // Check if we need to re-route an active path
            recheckActivePath()
        }
    }
    
    func startNodeDrag(_ node: StudentNode) {
        dragStartPositions[node.id] = node.position
    }
    
    func updateNodePosition(_ node: StudentNode, newPosition: CGPoint) {
        if let index = nodes.firstIndex(where: { $0.id == node.id }) {
            let oldPosition = nodes[index].position
            
            // Update CoreData
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NodeEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", node.id as CVarArg)
            
            do {
                if let entity = try viewContext.fetch(fetchRequest).first {
                    entity.setValue(newPosition.x, forKey: "positionX")
                    entity.setValue(newPosition.y, forKey: "positionY")
                    saveContext()
                }
            } catch {
                print("Error updating node position: \(error)")
            }
            
            nodes[index].position = newPosition
            pushUndoAction(.updateNodePosition(node.id, oldPosition: oldPosition, newPosition: newPosition))
        }
    }
    
    func endNodeDrag(_ node: StudentNode) {
        // Only process drag end if we have a start position
        guard let startPosition = dragStartPositions[node.id] else { return }
        
        // If the node was actually moved (not just clicked), push the undo action
        if startPosition != node.position {
            pushUndoAction(.updateNodePosition(node.id, oldPosition: startPosition, newPosition: node.position))
        }
        
        // Clear the start position
        dragStartPositions.removeValue(forKey: node.id)
    }
    
    private func pushUndoAction(_ action: NetworkAction) {
        // If the last action was a node position update for the same node,
        // replace it instead of adding a new one
        if case .updateNodePosition(let id, let oldPosition, _) = action,
           case .updateNodePosition(let lastId, _, let lastNewPosition) = undoStack.last,
           id == lastId {
            undoStack[undoStack.count - 1] = .updateNodePosition(id, oldPosition: oldPosition, newPosition: lastNewPosition)
        } else {
            undoStack.append(action)
        }
    }
    
    func undo() {
        guard let action = undoStack.popLast() else { return }
        
        switch action {
        case .addNode(let node):
            if let index = nodes.firstIndex(where: { $0.id == node.id }) {
                nodes.remove(at: index)
            }
            
        case .removeNode(let id):
            // Note: This is a simplified version. In a real app, you'd want to restore the node with all its connections
            if let node = nodes.first(where: { $0.id == id }) {
                nodes.append(node)
            }
            
        case .addConnection(let connection, let fromId, let toId):
            if let fromIndex = nodes.firstIndex(where: { $0.id == fromId }) {
                nodes[fromIndex].connections.removeAll { $0.id == connection.id }
            }
            if let toIndex = nodes.firstIndex(where: { $0.id == toId }) {
                nodes[toIndex].connections.removeAll { $0.toNodeId == fromId }
            }
            
        case .removeConnection(let connection, let fromId, let toId):
            if let fromIndex = nodes.firstIndex(where: { $0.id == fromId }) {
                nodes[fromIndex].connections.append(connection)
            }
            if let toIndex = nodes.firstIndex(where: { $0.id == toId }) {
                nodes[toIndex].connections.append(Connection(fromNodeId: toId, toNodeId: fromId, commonInterest: connection.commonInterest))
            }
            
        case .updateNodePosition(let id, let oldPosition, _):
            if let index = nodes.firstIndex(where: { $0.id == id }) {
                // Update CoreData
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NodeEntity")
                fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                
                do {
                    if let entity = try viewContext.fetch(fetchRequest).first {
                        entity.setValue(oldPosition.x, forKey: "positionX")
                        entity.setValue(oldPosition.y, forKey: "positionY")
                        saveContext()
                    }
                } catch {
                    print("Error undoing node position: \(error)")
                }
                
                nodes[index].position = oldPosition
            }
            
        case .toggleNodeActive(let id, let wasActive):
            if let index = nodes.firstIndex(where: { $0.id == id }) {
                nodes[index].isActive = wasActive
            }
        }
    }
    
    func findPaths(from start: StudentNode, to end: StudentNode) -> [[StudentNode]] {
        print("DEBUG: Finding paths from \(start.name) to \(end.name)")
        print("DEBUG: Start node connections: \(start.connections.map { "\($0.toNodeId)" })")
        print("DEBUG: End node connections: \(end.connections.map { "\($0.toNodeId)" })")
        
        var paths: [[StudentNode]] = []
        var visited = Set<UUID>()
        var queue: [(node: StudentNode, path: [StudentNode])] = [(start, [start])]
        var foundShortestPath = false
        
        while !queue.isEmpty && !foundShortestPath {
            let (current, path) = queue.removeFirst()
            print("DEBUG: BFS visiting \(current.name), current path: \(path.map { $0.name })")
            
            if current.id == end.id {
                print("DEBUG: Found shortest path to \(end.name): \(path.map { $0.name })")
                paths.append(path)
                foundShortestPath = true
                continue
            }
            
            visited.insert(current.id)
            
            // Get all unvisited neighbors
            let neighbors = current.connections.compactMap { connection -> StudentNode? in
                guard let nextNode = nodes.first(where: { $0.id == connection.toNodeId }),
                      nextNode.isActive,
                      !visited.contains(nextNode.id) else {
                    return nil
                }
                return nextNode
            }
            
            // Add all neighbors to the queue
            for neighbor in neighbors {
                print("DEBUG: Adding neighbor \(neighbor.name) to queue")
                queue.append((neighbor, path + [neighbor]))
            }
        }
        
        // If we found a path, return it. Otherwise, try DFS to find any path
        if !paths.isEmpty {
            print("DEBUG: Found shortest path with length \(paths[0].count)")
            return paths
        }
        
        print("DEBUG: No path found with BFS, trying DFS...")
        // Fallback to DFS to find any path if BFS didn't find one
        visited.removeAll()
        
        func dfs(current: StudentNode, path: [StudentNode]) {
            if current.id == end.id {
                print("DEBUG: Found path with DFS: \(path.map { $0.name })")
                paths.append(path)
                return
            }
            
            visited.insert(current.id)
            
            for connection in current.connections {
                guard let nextNode = nodes.first(where: { $0.id == connection.toNodeId }) else {
                    print("DEBUG: Warning - connection to \(connection.toNodeId) points to non-existent node")
                    continue
                }
                
                guard nextNode.isActive else {
                    print("DEBUG: Skipping inactive node \(nextNode.name)")
                    continue
                }
                
                guard !visited.contains(nextNode.id) else {
                    print("DEBUG: Skipping already visited node \(nextNode.name)")
                    continue
                }
                
                print("DEBUG: Following connection to \(nextNode.name)")
                dfs(current: nextNode, path: path + [nextNode])
            }
            
            visited.remove(current.id)
        }
        
        dfs(current: start, path: [start])
        print("DEBUG: Found \(paths.count) paths from \(start.name) to \(end.name)")
        return paths
    }
    
    func toggleSelectionMode() {
        isSelectionMode.toggle()
        if !isSelectionMode {
            selectedNodes.removeAll()
        }
    }
    
    func toggleNodeSelection(_ node: StudentNode) {
        if selectedNodes.contains(node.id) {
            selectedNodes.remove(node.id)
        } else {
            selectedNodes.insert(node.id)
        }
    }
    
    func deactivateSelectedNodes() {
        for nodeId in selectedNodes {
            if let node = nodes.first(where: { $0.id == nodeId }) {
                toggleNodeActive(node)
            }
        }
        selectedNodes.removeAll()
        isSelectionMode = false
    }
    
    func activateSelectedNodes() {
        for nodeId in selectedNodes {
            if let node = nodes.first(where: { $0.id == nodeId }) {
                if !node.isActive {
                    toggleNodeActive(node)
                }
            }
        }
        selectedNodes.removeAll()
        isSelectionMode = false
    }
    
    private func recheckActivePath() {
        // Only re-route if we're in path finding mode and have both start and end nodes
        guard isPathFindingMode,
              let start = startNode,
              let end = endNode else { return }
        
        // Always recalculate to ensure we have the shortest path
        let newPaths = findPaths(from: start, to: end)
        if !newPaths.isEmpty {
            let newPath = newPaths[0]
            // Only update if the path has actually changed
            if newPath.map({ $0.id }) != currentPath.map({ $0.id }) {
                currentPath = newPath
                print("DEBUG: Path updated to shortest route: \(currentPath.map { $0.name }.joined(separator: " -> "))")
            }
        } else {
            // No valid path exists, clear the path
            if !currentPath.isEmpty {
                currentPath = []
                print("DEBUG: No valid path exists")
            }
        }
    }
} 
