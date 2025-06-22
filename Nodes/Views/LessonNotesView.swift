//
//  LessonNotesView.swift
//  Nodes
//
//  Created by Douglas Kiang on 6/22/25.
//

import SwiftUI
import Foundation

struct LessonNotesView: View {
    @Binding var isPresented: Bool
    @ObservedObject var networkState: NetworkState
    @State private var lessonContent: String = ""
    @State private var isLoading: Bool = true
    @State private var showingClearAlert: Bool = false
    
    private let defaultLessonContent = """
# Classroom Network Visualization - Lesson Notes

## Overview
This app helps visualize student connections and relationships in your classroom. Students are represented as colorful nodes, and their shared interests create connections between them.

## Getting Started
1. **Add Students**: Use the "Add Student" button to create nodes for each student
2. **Create Connections**: Long-press and drag between students to create connections
3. **Find Paths**: Use "Find Path" mode to explore how students are connected

## Teaching Objectives
- Understand social networks and relationships
- Explore graph theory concepts
- Visualize classroom dynamics
- Practice collaborative learning

## Activities
### Activity 1: Building the Network
- Have each student add themselves to the network
- Students interview classmates to find shared interests
- Create connections based on common hobbies, subjects, or activities

### Activity 2: Path Exploration
- Use Find Path mode to see how students are connected
- Discuss shortest paths vs. alternative routes
- Explore what happens when connections are removed

### Activity 3: Network Analysis
- Identify the most connected students
- Find students who bridge different groups
- Discuss the importance of inclusion and connection

## Discussion Questions
- What patterns do you see in our classroom network?
- How do connections help information spread?
- What happens when key connectors are absent?
- How can we strengthen our classroom community?

## Extensions
- Compare networks from different time periods
- Analyze connections by subject area
- Explore real-world network examples

## Assessment Ideas
- Students explain their role in the network
- Identify strategies to connect isolated students
- Predict network changes over time

---
*These notes can be updated remotely to reflect current lesson plans and activities.*
"""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if isLoading {
                        ProgressView("Loading lesson notes...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Text(lessonContent)
                            .font(.body)
                            .padding()
                    }
                    
                    Spacer()
                    
                    // Clear all data button at bottom
                    VStack(spacing: 8) {
                        Divider()
                        
                        Button(action: {
                            showingClearAlert = true
                        }) {
                            Label("Clear All Data", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
            .navigationTitle("Lesson Notes")
            .navigationBarItems(
                trailing: Button("Done") {
                    isPresented = false
                }
            )
            .onAppear {
                loadLessonNotes()
            }
            .alert("Clear All Data", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    networkState.clearAllData()
                    isPresented = false
                }
            } message: {
                Text("Are you sure you want to clear all nodes and connections? This action cannot be undone.")
            }
        }
    }
    
    private func loadLessonNotes() {
        isLoading = true
        
        // Try to load from remote source first, fall back to default
        loadRemoteLessonNotes { remoteContent in
            DispatchQueue.main.async {
                if let content = remoteContent {
                    self.lessonContent = content
                } else {
                    self.lessonContent = self.defaultLessonContent
                }
                self.isLoading = false
            }
        }
    }
    
    private func loadRemoteLessonNotes(completion: @escaping (String?) -> Void) {
        // Remote URL for lesson notes - can be updated by teachers
        guard let url = URL(string: "https://raw.githubusercontent.com/your-org/nodes-lesson-notes/main/lesson-notes.md") else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data,
               let content = String(data: data, encoding: .utf8),
               !content.isEmpty {
                completion(content)
            } else {
                completion(nil)
            }
        }
        
        task.resume()
        
        // Timeout after 3 seconds to avoid long waits
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            task.cancel()
            completion(nil)
        }
    }
}

struct LessonNotesView_Previews: PreviewProvider {
    static var previews: some View {
        LessonNotesView(
            isPresented: .constant(true),
            networkState: NetworkState(context: PersistenceController.preview.container.viewContext)
        )
    }
}