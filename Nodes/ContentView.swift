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
                    onAdd: { name in
                        let randomX = CGFloat.random(in: 100...300)
                        let randomY = CGFloat.random(in: 100...300)
                        networkState.addNode(name: name, at: CGPoint(x: randomX, y: randomY))
                    }
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            networkState.showClearDataAlert = true
                        }) {
                            Label("Clear All Data", systemImage: "trash")
                        }
                        
                        if networkState.canUndo {
                            Button(action: {
                                networkState.undo()
                            }) {
                                Label("Undo", systemImage: "arrow.uturn.backward")
                            }
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
}

struct AddStudentView: View {
    @Binding var isPresented: Bool
    @Binding var newStudentName: String
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
                    newStudentName = ""
                },
                trailing: Button("Add") {
                    if !newStudentName.isEmpty {
                        onAdd(newStudentName)
                        newStudentName = ""
                        isPresented = false
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
