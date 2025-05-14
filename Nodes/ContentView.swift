//
//  ContentView.swift
//  Nodes
//
//  Created by Douglas Kiang on 5/13/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var networkState = NetworkState()
    @State private var showingAddStudent = false
    @State private var newStudentName = ""
    @State private var isPathFindingMode = false
    @State private var showingPathAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                NetworkGraphView()
                    .environmentObject(networkState)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Control Panel
                VStack(spacing: 12) {
                    HStack {
                        Button(action: { showingAddStudent = true }) {
                            Label("Add Student", systemImage: "person.badge.plus")
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: { isPathFindingMode.toggle() }) {
                            Label(isPathFindingMode ? "Cancel Path" : "Find Path", systemImage: "arrow.triangle.branch")
                        }
                        .buttonStyle(.bordered)
                        .tint(isPathFindingMode ? .red : .blue)
                    }
                    
                    if isPathFindingMode {
                        Text("Select start and end nodes to find paths")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("Class Network")
            .sheet(isPresented: $showingAddStudent) {
                NavigationView {
                    Form {
                        Section(header: Text("New Student")) {
                            TextField("Student Name", text: $newStudentName)
                        }
                    }
                    .navigationTitle("Add Student")
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            showingAddStudent = false
                            newStudentName = ""
                        },
                        trailing: Button("Add") {
                            if !newStudentName.isEmpty {
                                // Add node at a random position within the view
                                let randomX = CGFloat.random(in: 100...300)
                                let randomY = CGFloat.random(in: 100...300)
                                networkState.addNode(name: newStudentName, at: CGPoint(x: randomX, y: randomY))
                                newStudentName = ""
                                showingAddStudent = false
                            }
                        }
                        .disabled(newStudentName.isEmpty)
                    )
                }
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
