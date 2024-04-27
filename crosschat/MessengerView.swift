import SwiftUI
// View for outgoing message
// View for outgoing message
// View for outgoing message
struct OutgoingDoubleLineMessage: View {
    let message: MessagesStructure
    let outgoingBubble = Color(#colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1))
    let senderName = "Arafet"
    let service = Service()
    var body: some View {
        HStack {
            VStack(alignment: .trailing) {
                Text(message.content)
                    .font(.body)
                    .padding(8)
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 16).fill(outgoingBubble))
                HStack {
                    Spacer()
                    Text(message.timestamp) // Display timestamp
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.trailing, 8) // Add some padding between the timestamp and the edge of the bubble
                }
            }
            Image("outgoingTail")
                .resizable()
                .frame(width: 10, height: 10)
                .padding(.trailing, -5)
            if message.sender != service.currentUser {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            if message.sender == service.currentUser {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
        }
    }
}


// View for incoming message
// View for incoming message
struct IncomingDoubleLineMessage: View {
    let message: MessagesStructure
    let incomingBubble = Color.gray
    let service = Service()
    var body: some View {
        HStack {
            if message.sender != service.currentUser {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            VStack(alignment: .leading) {
                Text(message.content)
                    .font(.body)
                    .padding(8)
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 16).fill(incomingBubble))
                
                HStack {
                    Text(message.timestamp) // Display timestamp
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.trailing, 8) // Add some padding between the timestamp and the edge of the bubble
                    Spacer()
              //      EmojiButton() // Add EmojiButton here
                       // .foregroundColor(.gray)
                }
            }
            Image("incomingTail")
                .resizable()
                .frame(width: 10, height: 10)
                .padding(.leading, -5)
            if message.sender == service.currentUser {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
        }
    }
}




struct MessengerView: View {
    let service = Service()
    let senderName: String
    let conversationId: String
    @State private var messages: [MessagesStructure] = []
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var socketObject = SocketObject.shared

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .padding(.leading, -10)
                }
                
                VStack(alignment: .leading) {
                    Text(senderName)
                        .font(.title)
                        .foregroundColor(.black)
                        .padding(.leading, 2)
                }
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
                Text("Online")
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()
                
                Image(systemName: "video.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                Image(systemName: "phone.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 1) {
                    ForEach(messages.indices, id: \.self) { index in
                        HStack {
                            if messages[index].sender == service.currentUser {
                                OutgoingDoubleLineMessage(message: messages[index]) // Unwrap the binding
                            } else {
                                IncomingDoubleLineMessage(message: messages[index]) // Unwrap the binding
                            }
                            if messages[index].sender != service.currentUser {
                                EmojiButton(conversationId: conversationId, messageId: messages[index].id, service: service) // Pass necessary parameters
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                    }
                }
            }

            
            ComposeArea(conversationId: conversationId, currentUserId: service.currentUser)
        }
        .padding(.bottom)
        .navigationBarBackButtonHidden(true)
        
        .onAppear {
            socketObject.socket.connect()
            
            service.fetchMessages(conversationId: conversationId) { json, error in
                if let error = error {
                    print("Error fetching messages: \(error)")
                    return
                }

                if let json = json {
                    if let messagesData = json["messages"] as? [[String: Any]] {
                        self.messages = messagesData.compactMap { messageData in
                            MessagesStructure(
                                id:messageData["_id"] as? String ?? "",
                                sender: messageData["sender"] as? String ?? "",
                                content: messageData["content"] as? String ?? "",
                                timestamp: messageData["timestamp"] as? String ?? "",
                                emoji: messageData["emoji"] as? String
                            )
                        }
                    }
                }
            }
            socketObject.joinConversation(conversationId: conversationId)
        }
    }
}


// Emoji button view
struct EmojiButton: View {
    @State private var isEmojiPickerPresented = false
    @State private var selectedEmoji: String = "" // Add a state property to hold the selected emoji
    
    let conversationId: String
    let messageId: String
    let service: Service // Add a property for the Service
    
    var body: some View {
        Button(action: {
            isEmojiPickerPresented.toggle()
        }) {
            Image(systemName: "smiley")
                .font(.title)
        }
        .overlay(
            EmojiPickerDialog(isPresented: $isEmojiPickerPresented) { emoji in
                self.selectedEmoji = emoji // Set the selected emoji
                print(emoji)
                self.service.addReaction(conversationId: self.conversationId, messageId: self.messageId, reaction: emoji) // Add reaction using the service
            }
            .frame(width: 200, height: 30) // Adjust size as needed
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .opacity(isEmojiPickerPresented ? 1 : 0) // Show only when isEmojiPickerPresented is true
        )
    }
}

  



struct EmojiPickerDialog: View {
    @Binding var isPresented: Bool
    let onSelectEmoji: (String) -> Void // Closure to handle emoji selection
    
    var emojis = ["😊", "😂", "😍", "👍", "👏", "❤️", "🔥", "🎉", "🤔"]
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) { // Decreased spacing
                    ForEach(emojis, id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: 20)) // Decreased font size
                            .onTapGesture {
                                self.onSelectEmoji(emoji) // Call the closure to handle emoji selection
                                self.isPresented.toggle() // Close the emoji picker
                            }
                    }
                    .padding(5) // Decreased padding
                }
            }
            .padding(10) // Increased padding around the ScrollView
            .frame(height: 40) // Adjusted height of ScrollView
        }
    }
}



struct ComposeArea: View {
    @State private var write: String = ""
    @StateObject private var socketObject = SocketObject.shared
    
    let conversationId: String // Conversation ID
    let currentUserId: String // Current user ID

    var body: some View {
        HStack {
            Image(systemName: "camera.fill")
                .font(.title)
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .stroke()
                HStack{
                    TextField("Write a message", text: $write)
                        .font(.headline)
                    Spacer()
                    Image(systemName: "waveform.circle.fill")
                        .font(.title)
                }
                .padding(EdgeInsets(top: 3, leading: 8, bottom: 3, trailing: 3))
            }
            .frame(width: 249, height: 33)
            
            Button(action: {
                sendMessage() // Call the function to send the message
                write = "" // Clear the text field after sending the message
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.title)
            }
        }
        .foregroundColor(Color(.systemGray))
        .padding()
    }
    
    private func sendMessage() {
        guard !write.isEmpty else { return } // Ensure the message is not empty
        socketObject.sendMessage(conversationId: conversationId, message: write, sender: currentUserId) // Send the message
    }
}



