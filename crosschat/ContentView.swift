import SwiftUI

struct User: Identifiable {
    let id = UUID()
    let name: String
    let status: String
}

struct Conversation: Identifiable {
    let id = UUID()
    let user: User
    let lastMessage: String
    let timestamp: Date
}

struct ContentView: View {
    @State private var searchText = ""
    @State private var conversations: [Conversation] = [
        Conversation(user: User(name: "Alice", status: "Online"), lastMessage: "Hello!", timestamp: Date()),
        Conversation(user: User(name: "Bob", status: "Offline"), lastMessage: "Hi there!", timestamp: Date()),
        Conversation(user: User(name: "Charlie", status: "Online"), lastMessage: "Hey!", timestamp: Date()),
        // Add more conversations as needed
    ]
    @State private var conversationToDelete: Conversation? = nil
    @State private var showingDeleteAlert = false
    
    var filteredConversations: [Conversation] {
        if searchText.isEmpty {
            return conversations
        } else {
            return conversations.filter { $0.user.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(users) { user in
                            NavigationLink(destination: ConversationDetailView(user: user)) {
                                UserView(user: user)
                                    .padding(.horizontal, 10)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                
                Divider()
                
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(filteredConversations) { conversation in
                            ConversationView(conversation: conversation, onDelete: { self.setConversationToDelete(conversation) })
                                .gesture(
                                    DragGesture()
                                        .onEnded { value in
                                            if value.translation.width < -50 {
                                                // Swiped left
                                                self.setConversationToDelete(conversation)
                                            }
                                        }
                                )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("CrossChat")
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Conversation"),
                    message: Text("Are you sure you want to delete this conversation?"),
                    primaryButton: .cancel(),
                    secondaryButton: .destructive(Text("Delete")) {
                        if let conversation = conversationToDelete {
                            self.deleteConversation(conversation)
                        }
                    }
                )
            }
        }
    }
    
    private let users = [
        User(name: "Alice", status: "Online"),
        User(name: "Bob", status: "Offline"),
        User(name: "Charlie", status: "Online"),
        // Add more users as needed
    ]
    
    private func setConversationToDelete(_ conversation: Conversation) {
        self.conversationToDelete = conversation
        self.showingDeleteAlert = true
    }
    
    private func deleteConversation(_ conversation: Conversation) {
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations.remove(at: index)
        }
    }
}

struct UserView: View {
    let user: User

    var body: some View {
        VStack {
            Circle()
                .fill(user.status == "Online" ? Color.green : Color.gray)
                .frame(width: 50, height: 50)
            Text(user.name)
        }
    }
}

struct ConversationView: View {
    let conversation: Conversation
    let onDelete: () -> Void // No need to pass conversation here

    var body: some View {
        VStack(alignment: .leading) {
            Text(conversation.user.name)
                .font(.headline)
            Text(conversation.lastMessage)
                .foregroundColor(.gray)
            Text("\(conversation.timestamp)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 5)
        .contextMenu {
            Button(action: {
                onDelete()
            }) {
                Text("Delete")
                Image(systemName: "trash")
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(7)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(.systemGray2))
                        .padding(.trailing, 10)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ConversationDetailView: View {
    let user: User

    var body: some View {
        Text("Conversation with \(user.name)")
            .navigationTitle(user.name)
    }
}
