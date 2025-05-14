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
    
    // Path finding
    @Published var startNode: StudentNode?
    @Published var endNode: StudentNode?
    @Published var currentPath: [StudentNode] = []
    @Published var isAnimatingPath: Bool = false
    
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
            nodes = nodeEntities.compactMap { entity -> StudentNode? in
                guard let nodeEntity = entity as? NSManagedObject,
                      let id = nodeEntity.value(forKey: "id") as? UUID,
                      let name = nodeEntity.value(forKey: "name") as? String else {
                    return nil
                }
                
                let positionX = nodeEntity.value(forKey: "positionX") as? Double ?? 0.0
                let positionY = nodeEntity.value(forKey: "positionY") as? Double ?? 0.0
                let isActive = nodeEntity.value(forKey: "isActive") as? Bool ?? true
                
                let connections = (nodeEntity.value(forKey: "connections") as? Set<NSManagedObject>)?.compactMap { conn -> Connection? in
                    guard let connId = conn.value(forKey: "id") as? UUID,
                          let toNodeId = conn.value(forKey: "toNodeId") as? UUID,
                          let commonInterest = conn.value(forKey: "commonInterest") as? String else {
                        return nil
                    }
                    
                    return Connection(
                        id: connId,
                        fromNodeId: id,
                        toNodeId: toNodeId,
                        commonInterest: commonInterest
                    )
                } ?? []
                
                return StudentNode(
                    id: id,
                    name: name,
                    position: CGPoint(x: positionX, y: positionY),
                    isActive: isActive,
                    connections: connections
                )
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
        // Remove existing connection if any
        if let existingConnection = findConnection(from: from, to: to) {
            removeConnection(existingConnection, from: from, to: to)
        }
        
        let connection = Connection(fromNodeId: from.id, toNodeId: to.id, commonInterest: commonInterest)
        
        // Add to CoreData
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NodeEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", from.id as CVarArg)
        
        do {
            if let fromEntity = try viewContext.fetch(fetchRequest).first {
                let connectionEntity = NSEntityDescription.insertNewObject(forEntityName: "ConnectionEntity", into: viewContext)
                connectionEntity.setValue(connection.id, forKey: "id")
                connectionEntity.setValue(to.id, forKey: "toNodeId")
                connectionEntity.setValue(commonInterest, forKey: "commonInterest")
                connectionEntity.setValue(fromEntity, forKey: "fromNode")
                
                saveContext()
            }
        } catch {
            print("Error adding connection: \(error)")
        }
        
        if let fromIndex = nodes.firstIndex(where: { $0.id == from.id }) {
            nodes[fromIndex].connections.append(connection)
        }
        if let toIndex = nodes.firstIndex(where: { $0.id == to.id }) {
            nodes[toIndex].connections.append(Connection(fromNodeId: to.id, toNodeId: from.id, commonInterest: commonInterest))
        }
        pushUndoAction(.addConnection(connection, from: from.id, to: to.id))
    }
    
    func removeConnection(_ connection: Connection, from: StudentNode, to: StudentNode) {
        // Remove from CoreData
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ConnectionEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", connection.id as CVarArg)
        
        do {
            if let entity = try viewContext.fetch(fetchRequest).first {
                viewContext.delete(entity)
                saveContext()
            }
        } catch {
            print("Error removing connection: \(error)")
        }
        
        if let fromIndex = nodes.firstIndex(where: { $0.id == from.id }) {
            nodes[fromIndex].connections.removeAll { $0.id == connection.id }
        }
        if let toIndex = nodes.firstIndex(where: { $0.id == to.id }) {
            nodes[toIndex].connections.removeAll { $0.toNodeId == from.id }
        }
        pushUndoAction(.removeConnection(connection, from: from.id, to: to.id))
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
        }
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
    
    private func pushUndoAction(_ action: NetworkAction) {
        undoStack.append(action)
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
                nodes[index].position = oldPosition
            }
            
        case .toggleNodeActive(let id, let wasActive):
            if let index = nodes.firstIndex(where: { $0.id == id }) {
                nodes[index].isActive = wasActive
            }
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
