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
            if message.type == "attachment" {
                // Display the image fetched from the attachment URL
                AsyncImage(url: URL(string: message.content)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 300, height: 200) // Adjust size as needed
                            .clipped()
                    case .failure:
                        // Placeholder or error handling image
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 300, height: 200) // Adjust size as needed
                            .clipped()
                    case .empty:
                        // Placeholder or loading indicator
                        ProgressView()
                    @unknown default:
                        // Placeholder or error handling image
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 300, height: 200) // Adjust size as needed
                            .clipped()
                    }
                }
                .frame(width: 300, height: 200) // Adjust size as needed
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                // Display text message
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
            }
            Image("outgoingTail")
                .resizable()
                .frame(width: 10, height: 10)
                .padding(.trailing, -5)
            if message.sender != service.currentUser {
                Image(message.sender)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 3)
            }
            if message.sender == service.currentUser {
                Image(service.currentUser)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 3)
            }
        }
    }
}

struct IncomingDoubleLineMessage: View {
    let message: MessagesStructure
    let incomingBubble = Color.gray
    let service = Service()
    
    var body: some View {
        HStack {
            if message.sender != service.currentUser {
                Image(message.sender)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 3)
            }
            VStack(alignment: .leading) {
                if message.type == "attachment" {
                    // Display the image fetched from the attachment URL
                    AsyncImage(url: URL(string: message.content)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 300, height: 200) // Adjust size as needed
                                .clipped()
                        case .failure:
                            // Placeholder or error handling image
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 300, height: 200) // Adjust size as needed
                                .clipped()
                        case .empty:
                            // Placeholder or loading indicator
                            ProgressView()
                        @unknown default:
                            // Placeholder or error handling image
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 300, height: 200) // Adjust size as needed
                                .clipped()
                        }
                    }
                    .frame(width: 300, height: 200) // Adjust size as needed
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    // Display text message
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
                        Text(message.emoji ?? "" )
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
            }
            Image("incomingTail")
                .resizable()
                .frame(width: 10, height: 10)
                .padding(.leading, -5)
            if message.sender == service.currentUser {
                Image(service.currentUser)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 3)
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
                Image(senderName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 3)
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
            onAppear()
          }
        .onDisappear{
            onDisappear()
        }
    }
    
    
    func onAppear() {
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
                            type: messageData["type"] as? String ?? "",
                            emoji: (messageData["emojis"] as? [String])?.first ?? ""
                        )
                    }
                }
            }
        }
        listenForMessages()
        socketObject.joinConversation(conversationId: conversationId)
    }
    
    // Remove the listener when the view disappears
    func onDisappear() {
        socketObject.socket.off("new_message_\(conversationId)")
    }
    
    func listenForMessages() {
        socketObject.listenForMessages(conversationId: conversationId) { newMessages in
            // Update the messages array with the newly received messages
            self.messages = newMessages
        }
    }
 }
 


// Emoji button view
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
            }
            .frame(width: 200, height: 30) // Adjust size as needed
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .opacity(isEmojiPickerPresented ? 1 : 0) // Show only when isEmojiPickerPresented is true
        )
        .onChange(of: selectedEmoji) { emoji in
            if !emoji.isEmpty {
                service.addReaction(messageId: self.messageId, reaction: emoji) // Add reaction using the service
                
                
            }
        }
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
    @State private var isSendingMessage = false // Track whether a message is being sent
    @StateObject private var socketObject = SocketObject.shared
    @State private var selectedFile: URL? = nil // Track the selected file
    @State private var isFilePickerPresented = false // Track whether the file picker is presented
    
    let conversationId: String // Conversation ID
    let currentUserId: String // Current user ID

    var body: some View {
        HStack {
            Button(action: {
                isFilePickerPresented = true // Show the file picker when the button is pressed
            }) {
                Image(systemName: "camera.fill")
                    .font(.title)
            }
            .fileImporter(isPresented: $isFilePickerPresented, allowedContentTypes: [.image]) { result in
                do {
                    let selectedURL = try result.get()
                    self.selectedFile = selectedURL
                    // Call the sendAttachment function when a file is selected
                    sendAttachment()
                } catch {
                    print("Error selecting file: \(error.localizedDescription)")
                }
            }

            
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
                sendMessage()
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.title)
            }
            .disabled(isSendingMessage) // Disable button while a message is being sent
        }
        .foregroundColor(Color(.systemGray))
        .padding()
    }
    
    private func sendMessage() {
        guard !write.isEmpty && !isSendingMessage else { return } // Ensure message is not empty and not already sending
        
        // Update state to indicate that a message is being sent
        isSendingMessage = true
        
        // Send the message
        socketObject.sendMessage(conversationId: conversationId, message: write, sender: currentUserId, type: "text")
        
        // Reset state after message is sent
        isSendingMessage = false
        write = "" // Clear the text field after sending the message
    }
    private func sendAttachment() {
        guard let selectedFile = selectedFile else {
            // Handle case when no file is selected
            return
        }

        // Update state to indicate that an attachment is being sent
        isSendingMessage = true

        // Call the service to upload the attachment
        let service = Service() // Create an instance of the Service class
        service.sendAttachment(conversationId: conversationId, fileURL: selectedFile) { (attachmentURL: String?, error: Error?) in
            if let error = error {
                // Handle the error
                print("Error sending attachment: \(error.localizedDescription)")
                // Reset state
                DispatchQueue.main.async {
                    self.isSendingMessage = false
                }
                return
            }

            if let attachmentURL = attachmentURL {
                // Send the message with the attachment URL
                self.socketObject.sendMessage(conversationId: self.conversationId, message: attachmentURL, sender: self.currentUserId, type: "attachment")

                // Reset state
                DispatchQueue.main.async {
                    self.isSendingMessage = false
                    self.selectedFile = nil // Clear the selected file
                }
            }
        }
    }

}




