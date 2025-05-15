//
//  ContentView.swift
//  Nodes
//
//  Created by Douglas Kiang on 5/13/25.
//

import SwiftUI
import CoreData
import UIKit

// Add this at the top of the file, before ContentView
struct KeyboardFocusModifier: ViewModifier {
    @FocusState.Binding var isFocused: Bool
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                DispatchQueue.main.async {
                    isFocused = true
                }
            }
    }
}

extension View {
    func forceKeyboardFocus(isFocused: FocusState<Bool>.Binding) -> some View {
        self.modifier(KeyboardFocusModifier(isFocused: isFocused))
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var networkState: NetworkState
    @State private var showingAddStudent = false
    @State private var newStudentName = ""
    @State private var showingPathAlert = false
    @FocusState private var isStudentNameFocused: Bool

    init() {
        let context = PersistenceController.shared.container.viewContext
        _networkState = StateObject(wrappedValue: NetworkState(context: context))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                NetworkGraphView()
                    .environmentObject(networkState)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onChange(of: showingAddStudent) { isShowing in
                        networkState.isShowingModal = isShowing
                        if isShowing {
                            networkState.lastViewSize = networkState.currentViewSize
                        }
                    }
                
                // Control Panel
                VStack(spacing: 12) {
                    HStack {
                        Button(action: {
                            newStudentName = "" // Reset the name
                            showingAddStudent = true
                        }) {
                            Label("Add Student", systemImage: "person.badge.plus")
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: { networkState.isPathFindingMode.toggle() }) {
                            Label(networkState.isPathFindingMode ? "Cancel Path" : "Find Path", systemImage: "arrow.triangle.branch")
                        }
                        .buttonStyle(.bordered)
                        .tint(networkState.isPathFindingMode ? .red : .blue)
                    }
                    
                    if networkState.isPathFindingMode {
                        Text("Select start and end nodes to find paths")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("")
            .sheet(isPresented: $showingAddStudent) {
                AddStudentView(
                    isPresented: $showingAddStudent,
                    newStudentName: $newStudentName,
                    networkState: networkState,
                    onAdd: { name in
                        let randomX = CGFloat.random(in: 100...300)
                        let randomY = CGFloat.random(in: 100...300)
                        networkState.addNode(name: name, at: CGPoint(x: randomX, y: randomY))
                    }
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        if networkState.canUndo {
                            Button(action: {
                                networkState.undo()
                            }) {
                                Image(systemName: "arrow.uturn.backward")
                            }
                        }
                        
                        Menu {
                            if networkState.isSelectionMode {
                                Button(action: {
                                    networkState.deactivateSelectedNodes()
                                    updatePathAfterNodeDeactivation()
                                }) {
                                    Label("Deactivate Selected", systemImage: "circle.slash")
                                }
                                .disabled(networkState.selectedNodes.isEmpty)
                                
                                Button(action: {
                                    networkState.activateSelectedNodes()
                                    updatePathAfterNodeActivation()
                                }) {
                                    Label("Activate Selected", systemImage: "circle")
                                }
                                .disabled(networkState.selectedNodes.isEmpty)
                                
                                Button(action: {
                                    networkState.toggleSelectionMode()
                                }) {
                                    Label("Cancel Selection", systemImage: "xmark.circle")
                                }
                            } else {
                                Button(action: {
                                    networkState.toggleSelectionMode()
                                }) {
                                    Label("Select Nodes", systemImage: "checkmark.circle")
                                }
                            }
                            
                            Button(action: {
                                networkState.showClearDataAlert = true
                            }) {
                                Label("Clear All Data", systemImage: "trash")
                            }
                            
                            Button(action: {
                                networkState.isPathFindingMode.toggle()
                            }) {
                                Label(networkState.isPathFindingMode ? "Exit Find Path" : "Find Path", 
                                      systemImage: networkState.isPathFindingMode ? "xmark.circle" : "arrow.triangle.branch")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .alert("Clear All Data", isPresented: $networkState.showClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    networkState.clearAllData()
                }
            } message: {
                Text("Are you sure you want to clear all nodes and connections? This action cannot be undone.")
            }
        }
    }

    private func updatePathAfterNodeDeactivation() {
        guard networkState.isPathFindingMode,
              let start = networkState.startNode,
              let end = networkState.endNode else { return }
        
        // Check if either start or end node is now inactive
        if !start.isActive || !end.isActive {
            // Clear the path if either node is inactive
            networkState.currentPath = []
            return
        }
        
        // Try to find a new path that avoids inactive nodes
        let paths = networkState.findPaths(from: start, to: end)
        if let newPath = paths.first {
            networkState.currentPath = newPath
        } else {
            // No valid path found, clear the current path
            networkState.currentPath = []
        }
    }
    
    private func updatePathAfterNodeActivation() {
        guard networkState.isPathFindingMode,
              let start = networkState.startNode,
              let end = networkState.endNode else { return }
        
        // Try to find a path now that some nodes are active
        let paths = networkState.findPaths(from: start, to: end)
        if let newPath = paths.first {
            networkState.currentPath = newPath
        }
    }
}

struct AddStudentView: View {
    @Binding var isPresented: Bool
    @Binding var newStudentName: String
    let networkState: NetworkState
    @FocusState private var isFocused: Bool
    let onAdd: (String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Student")) {
                    TextField("Student Name", text: $newStudentName)
                        .focused($isFocused)
                        .submitLabel(.done)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("Add Student")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                    networkState.isShowingModal = false
                    newStudentName = ""
                },
                trailing: Button("Add") {
                    if !newStudentName.isEmpty {
                        onAdd(newStudentName)
                        newStudentName = ""
                        isPresented = false
                        networkState.isShowingModal = false
                    }
                }
                .disabled(newStudentName.isEmpty)
            )
            .onAppear {
                // Set focus after a very short delay to ensure the view is ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFocused = true
                }
            }
        }
        .interactiveDismissDisabled()
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
