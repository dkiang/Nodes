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
Quick summary

Add nodes to the map, and build connections between them. Click Find Path to highlight the shortest path (using BFS) between two nodes. Double-tap any node to deactivate it. This illustrates the concept of fault tolerance within a network.

In the classroom, this is a great getting-to-know you activity.

Lesson Plan

Have your students fill out an index card with their name at the top.

Next, they should go around the room and talk to different people. The goal is to find one thing they have in common with that person e.g., they both: play soccer, or are the youngest in their family, or love vegetables, etc. (maybe the last one isn't too realistic, but you get the idea.)

As students hand in their index cards, you can build the network on this app. Click Add Student to add your students' names to the map (you can do this ahead of time.) You can tap two nodes in sequence to build a connection between them.

Now's the fun part: Play with passing messages from one student to another using the Find Path option! Some connections are easy: Susan can pass a note to Charlie at soccer practice, for example. In cases where there isn't a direct connection, other students (nodes) might have to act as intermediaries.

What happens if a student is sick that day? A message could still get through by rerouting through a different set oif studnets. This illustrates the fault-tolerant nature of the Internet: when one node goes down, the rest of the network still functions.

Note: Try to have some students with two or even one connection. If everyone has three connections, then the network is very robust—deactivating nodes will have little to no effect.

Questions to discuss

Network Structure & Society

How does the structure of this classroom network compare to social media platforms like Instagram or TikTok? What are the advantages and disadvantages of each design?
In our classroom network, some students might be "super-connectors" with many links while others have just one or two. How might this reflect real-world social dynamics? Is this fair?
If you could redesign the internet from scratch today, what would you do differently? Consider issues like privacy, misinformation, and equal access.
Real-World Applications

During natural disasters, cell towers and internet infrastructure often fail. How do emergency responders maintain communication? What backup systems exist?
Why might authoritarian governments try to control internet access by shutting down specific nodes or connections? How effective is this strategy given the internet's design?
When a major website like Instagram or YouTube goes down, why doesn't it affect other websites? How does this relate to our classroom network?
Ethics & Access

Not everyone has equal access to high-speed internet. How does this "digital divide" affect education, job opportunities, and social connections?
Should there be limits on how much control internet service providers have over traffic flow? What if they could slow down or block access to certain websites?
In our activity, deactivating nodes isolated some students. How might this relate to online censorship or social media bans?
Future Implications

As more devices become internet-connected (smart homes, self-driving cars, medical devices), how important does network fault tolerance become? What are the risks?
Could artificial intelligence help make networks more resilient, or could it create new vulnerabilities?
Historical context

The internet's fault-tolerant design was born out of Cold War fears in the 1960s. The U.S. military was worried about what would happen to communication systems if the country was attacked. Traditional phone and communication networks had a major weakness—they relied on central switching stations. If the main hub was destroyed, the entire network would go down.

To solve this problem, the Department of Defense funded research to create a communication network that could survive damage. In 1969, they launched ARPANET, which became the foundation of today's internet. This new network used a completely different approach called "packet-switching." Instead of sending messages through one central point, ARPANET broke information into small pieces called packets and sent them along many different routes through connected computers. If one path was blocked or destroyed, the packets would automatically find other ways to reach their destination—just like water flowing around rocks in a stream.

This created built-in backup systems throughout the network. No single computer or connection point could shut down the entire system. Today's internet still works the same way. When you send a text or watch a video, your data travels through multiple servers and routers, automatically finding new routes if any part of the network fails.

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
                        Text(.init(lessonContent))
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
        guard let url = URL(string: "https://raw.githubusercontent.com/dkiang/nodes-lesson-notes/main/lesson-notes.md") else {
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
