//
//  Persistence.swift
//  Nodes
//
//  Created by Douglas Kiang on 5/13/25.
//

import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample data for preview
        let node1 = NSEntityDescription.insertNewObject(forEntityName: "NodeEntity", into: viewContext) as! NodeEntity
        node1.id = UUID()
        node1.name = "Alice"
        node1.positionX = 100
        node1.positionY = 100
        node1.isActive = true
        
        let node2 = NSEntityDescription.insertNewObject(forEntityName: "NodeEntity", into: viewContext) as! NodeEntity
        node2.id = UUID()
        node2.name = "Bob"
        node2.positionX = 200
        node2.positionY = 200
        node2.isActive = true
        
        let connection = NSEntityDescription.insertNewObject(forEntityName: "ConnectionEntity", into: viewContext) as! ConnectionEntity
        connection.id = UUID()
        connection.commonInterest = "Math"
        connection.toNodeId = node2.id
        connection.fromNode = node1
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Nodes")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Node Operations
    
    func saveNode(_ node: StudentNode, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "NodeEntity", into: context) as! NodeEntity
        entity.id = node.id
        entity.name = node.name
        entity.positionX = node.position.x
        entity.positionY = node.position.y
        entity.isActive = node.isActive
        
        do {
            try context.save()
        } catch {
            print("Error saving node: \(error)")
        }
    }
    
    func saveConnection(from: StudentNode, to: StudentNode, commonInterest: String, context: NSManagedObjectContext) {
        guard let fromEntity = fetchNodeEntity(with: from.id, context: context) else {
            return
        }
        
        let connection = NSEntityDescription.insertNewObject(forEntityName: "ConnectionEntity", into: context) as! ConnectionEntity
        connection.id = UUID()
        connection.commonInterest = commonInterest
        connection.toNodeId = to.id
        connection.fromNode = fromEntity
        
        do {
            try context.save()
        } catch {
            print("Error saving connection: \(error)")
        }
    }
    
    func fetchNodeEntity(with id: UUID, context: NSManagedObjectContext) -> NodeEntity? {
        let request: NSFetchRequest<NodeEntity> = NodeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("Error fetching node: \(error)")
            return nil
        }
    }
    
    func loadAllNodes(context: NSManagedObjectContext) -> [StudentNode] {
        let request: NSFetchRequest<NodeEntity> = NodeEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                guard let id = entity.id,
                      let name = entity.name else { return nil }
                
                return StudentNode(
                    id: id,
                    name: name,
                    position: CGPoint(x: entity.positionX, y: entity.positionY),
                    isActive: entity.isActive
                )
            }
        } catch {
            print("Error loading nodes: \(error)")
            return []
        }
    }
    
    func loadConnections(for node: StudentNode, context: NSManagedObjectContext) -> [Connection] {
        guard let entity = fetchNodeEntity(with: node.id, context: context) else {
            return []
        }
        
        return (entity.connections?.allObjects as? [ConnectionEntity])?.compactMap { connectionEntity in
            guard let connId = connectionEntity.id,
                  let toNodeId = connectionEntity.toNodeId,
                  let commonInterest = connectionEntity.commonInterest else {
                return nil
            }
            
            return Connection(
                id: connId,
                fromNodeId: node.id,
                toNodeId: toNodeId,
                commonInterest: commonInterest
            )
        } ?? []
    }
}
