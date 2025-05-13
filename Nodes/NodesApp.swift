//
//  NodesApp.swift
//  Nodes
//
//  Created by Douglas Kiang on 5/13/25.
//

import SwiftUI

@main
struct NodesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
