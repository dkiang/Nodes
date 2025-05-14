//
//  Persistence.swift
//  Nodes
//
//  Created by Douglas Kiang on 5/13/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create some sample student nodes
        let names = ["Alice", "Bob", "Charlie", "Diana", "Eve"]
        for (index, name) in names.enumerated() {
            let node = StudentNodeEntity(context: viewContext)
            node.id = UUID()
            node.name = name
            node.positionX = Double(100 + index * 50)
            node.positionY = Double(100 + index * 50)
            node.isActive = true
        }
        
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
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Student Node Operations
    
    func saveStudentNode(_ node: StudentNode, context: NSManagedObjectContext) {
        let entity = StudentNodeEntity(context: context)
        entity.id = node.id
        entity.name = node.name
        entity.positionX = node.position.x
        entity.positionY = node.position.y
        entity.isActive = node.isActive
        
        do {
            try context.save()
        } catch {
            print("Error saving student node: \(error)")
        }
    }
    
    func saveConnection(from: StudentNode, to: StudentNode, commonInterest: String, context: NSManagedObjectContext) {
        guard let fromEntity = fetchStudentNodeEntity(with: from.id, context: context),
              let toEntity = fetchStudentNodeEntity(with: to.id, context: context) else {
            return
        }
        
        let connection = ConnectionEntity(context: context)
        connection.id = UUID()
        connection.commonInterest = commonInterest
        connection.fromNode = fromEntity
        connection.toNode = toEntity
        
        do {
            try context.save()
        } catch {
            print("Error saving connection: \(error)")
        }
    }
    
    func fetchStudentNodeEntity(with id: UUID, context: NSManagedObjectContext) -> StudentNodeEntity? {
        let request: NSFetchRequest<StudentNodeEntity> = StudentNodeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("Error fetching student node: \(error)")
            return nil
        }
    }
    
    func loadAllStudentNodes(context: NSManagedObjectContext) -> [StudentNode] {
        let request: NSFetchRequest<StudentNodeEntity> = StudentNodeEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                StudentNode(
                    id: entity.id ?? UUID(),
                    name: entity.name ?? "",
                    position: CGPoint(x: entity.positionX, y: entity.positionY),
                    isActive: entity.isActive
                )
            }
        } catch {
            print("Error loading student nodes: \(error)")
            return []
        }
    }
    
    func loadConnections(for node: StudentNode, context: NSManagedObjectContext) -> [Connection] {
        guard let entity = fetchStudentNodeEntity(with: node.id, context: context) else {
            return []
        }
        
        return (entity.connections?.allObjects as? [ConnectionEntity])?.compactMap { connectionEntity in
            guard let toNode = connectionEntity.toNode,
                  let toNodeId = toNode.id,
                  let commonInterest = connectionEntity.commonInterest else {
                return nil
            }
            
            return Connection(
                id: connectionEntity.id ?? UUID(),
                fromNodeId: node.id,
                toNodeId: toNodeId,
                commonInterest: commonInterest
            )
        } ?? []
    }
}
