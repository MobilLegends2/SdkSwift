import SwiftUI

struct User: Identifiable {
    let id = UUID()
    let name: String
    let status: String
}

struct Conversation: Identifiable {
    let id : String
    let participantName: String
    let lastMessage: String
    let timestamp: Date
}

struct ContentView: View {
    @State private var searchText = ""
    @State private var senderN = ""
    @State private var conversations: [Conversation] = []
    @State private var conversationToDelete: Conversation? = nil
    @State private var showingDeleteAlert = false
    @State private var destinationView: AnyView? = nil
    @State private var navigateToMessengerView: Bool? = false
    @State private var selectedConversationId: String? = nil // Define selectedConversationId here

    let service = Service() // Create an instance of the Service class
    
    var filteredConversations: [Conversation] {
        if searchText.isEmpty {
            return conversations
        } else {
            return conversations.filter { $0.participantName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(users) { user in
                            UserView(user: user)
                                .padding(.horizontal, 10)
                                .onTapGesture {
                                    // Log when the user is pressed
                                    print("User \(user.name) pressed")
                                    
                                    // Call createOrGetConversation to create or retrieve conversation ID
                                    service.createOrGetConversation(clickedUserId: user.name) { conversationId, error in
                                        if let error = error {
                                            print("Error creating/getting conversation: \(error)")
                                            return
                                        }
                                        if let conversationId = conversationId {
                                            // Log the obtained conversation ID
                                            print("Obtained conversation ID for \(user.name): \(conversationId)")
                                            
                                            // Now, trigger navigation to MessengerView with the obtained conversation ID
                                            DispatchQueue.main.async {
                                                self.selectedConversationId = conversationId
                                                self.navigateToMessengerView = true
                                                self.senderN = user.name
                                            }
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.vertical)
                    .background(
                        NavigationLink(
                            destination: MessengerView(senderName: senderN ?? "", conversationId: selectedConversationId ?? ""),
                            tag: true,
                            selection: $navigateToMessengerView
                        ) {
                            EmptyView()
                        }
                        .hidden()
                    )
                }




                Divider()
                
                List {
                    ForEach(filteredConversations) { conversation in
                        NavigationLink(destination: MessengerView(senderName: conversation.participantName, conversationId:conversation.id)) {
                            ConversationRow(conversation: conversation)
                        }
                        .swipeActions {
                            Button(action: {
                                self.setConversationToDelete(conversation)
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("CrossChat")
            .navigationBarBackButtonHidden(true)
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
            .onAppear {
                // Fetch conversations when the view appears
                service.fetchConversations(currentUser: service.currentUser) { json, error in
                    if let error = error {
                        print("Error fetching conversations: \(error)")
                        return
                    }

                    if let conversationsData = json {
                        self.conversations = conversationsData.compactMap { conversationData in
                            let participants = conversationData["participants"] as? [String] ?? ["", ""]
                            let participantName = participants.first(where: { $0 != service.currentUser }) ?? ""
                            let convId = conversationData["_id"] as? String ?? "" // Get the conversation ID

                            print(participants)
                            print(participantName)

                            return Conversation(
                                id:convId ,
                                participantName: participantName,
                                lastMessage: (conversationData["messages"] as? [[String: Any]])?.last?["content"] as? String ?? "",
                                timestamp: Date() // You can parse the timestamp here
                            )
                        }
                    }

                }
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

struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(conversation.participantName)
                    .font(.headline)
                Text(conversation.lastMessage)
                    .foregroundColor(.gray)
                Text("\(conversation.timestamp)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 5)
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
            .navigationBarHidden(true)
    }
}
