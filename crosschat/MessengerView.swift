import SwiftUI
import PhotosUI
// View for outgoing message
// View for outgoing message
// View for outgoing message
struct OutgoingDoubleLineMessage: View {
    let message: MessagesStructure
    let outgoingBubble = Color(#colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1))
    let senderName = "Arafet"

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
            if message.sender != "participant2" {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            if message.sender == "participant2" {
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

    var body: some View {
        HStack {
            if message.sender != "participant2" {
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
            if message.sender == "participant2" {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
        }
    }
}


struct MessengerView: View {
    let service = Service() // Create an instance of the Service class
    let senderName: String
    let conversationId: String
    @State private var messages: [MessagesStructure] = []
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                          // Add negative padding
                    }
                
                VStack(alignment: .leading) {
<<<<<<< Updated upstream
                    Text(senderName) // Dynamic sender name
=======
                    Text(senderName)
>>>>>>> Stashed changes
                        .font(.title)
                        .foregroundColor(.black)
                        .padding(.leading, 2) // Reduce padding between the online indicator and sender name
                }
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
                Text("Online")
                    .font(.caption)
<<<<<<< Updated upstream
                    .foregroundColor(.gray) // Adjust color as needed

                
                Spacer()
                
                Image(systemName: "video.fill") // Video call icon
                    .font(.title)
                    .foregroundColor(.blue)
                Image(systemName: "phone.fill") // Voice call icon
=======
                    .foregroundColor(.gray)
                Spacer()
                NavigationLink(destination: VideoCallView(currentUser: service.currentUser, conversationId: conversationId)) {
                    Image(systemName: "video.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
                Image(systemName: "phone.fill")
>>>>>>> Stashed changes
                    .font(.title)
                    .foregroundColor(.blue)
            }
            .padding()
            
<<<<<<< Updated upstream
            ScrollView {
                VStack(spacing: 1) {
                    ForEach(messages) { message in // Removed the $ sign
                        HStack {
                            if message.sender == "participant2" {
                                OutgoingDoubleLineMessage(message: message)
                            } else {
                                IncomingDoubleLineMessage(message: message)
                            }
                            if message.sender != "participant2" { // Only show EmojiButton for incoming messages
                                EmojiButton()
                                    .foregroundColor(.gray)
=======
            GeometryReader { geometry in
                ScrollViewReader { scrollView in
                    ScrollView {
                        VStack(spacing: 1) {
                            ForEach(messages.indices, id: \.self) { index in
                                HStack {
                                    if messages[index].sender == service.currentUser {
                                        OutgoingDoubleLineMessage(message: messages[index])
                                    } else {
                                        IncomingDoubleLineMessage(message: messages[index])
                                    }
                                    if messages[index].sender != service.currentUser {
                                        EmojiButton(conversationId: conversationId, messageId: messages[index].id, service: service)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .id(index)
                            }
                        }
                        .onChange(of: messages.count) { _ in
                            if messages.count > 0 {
                                withAnimation {
                                    scrollView.scrollTo(messages.count - 1, anchor: .bottom)
                                }
>>>>>>> Stashed changes
                            }
                        }
                    }
                }
            }
            
            ComposeArea()
        }
<<<<<<< Updated upstream
        .padding(.bottom) // Add padding to ensure the ComposeArea is above the safe area
       .navigationBarBackButtonHidden(true) // Hide the automatic back button
        
        .onAppear {
            // Fetch messages when the view appears
            service.fetchMessages(conversationId: conversationId) { json, error in
                if let error = error {
                    print("Error fetching messages: \(error)")
                    return
                }
=======
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
>>>>>>> Stashed changes

                if let json = json {
                    // Parse JSON and update messages array
                    if let messagesData = json["messages"] as? [[String: Any]] {
                        self.messages = messagesData.compactMap { messageData in
                            MessagesStructure(
                                sender: messageData["sender"] as? String ?? "",
                                content: messageData["content"] as? String ?? "",
                                timestamp: messageData["timestamp"] as? String ?? "",
                                emoji: messageData["emoji"] as? String
                            )
                        }
                    }
                }
            }
        }
    }
<<<<<<< Updated upstream
=======
    
    func onDisappear() {
        socketObject.socket.off("new_message_\(conversationId)")
    }
    
    func listenForMessages() {
        socketObject.listenForMessages(conversationId: conversationId) { newMessages in
            self.messages = newMessages
        }
    }
>>>>>>> Stashed changes
}

// Emoji button view
struct EmojiButton: View {
    @State private var isEmojiPickerPresented = false
    
    var body: some View {
        Button(action: {
            isEmojiPickerPresented.toggle()
        }) {
            Image(systemName: "smiley")
                .font(.title)
        }
        .overlay(
            EmojiPickerDialog(isPresented: $isEmojiPickerPresented)
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
    
    var emojis = ["😊", "😂", "😍", "👍", "👏", "❤️", "🔥", "🎉", "🤔"]
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) { // Decreased spacing
                    ForEach(emojis, id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: 20)) // Decreased font size
                            .onTapGesture {
                                // Handle emoji selection here if needed
                                isPresented.toggle()
                            }
                    }
                    .padding(5) // Decreased padding
                }
                .padding(10) // Increased padding around the ScrollView
            }
            .frame(height: 20) // Decreased height of ScrollView
        }
    }
}







import SwiftUI
import UIKit

struct ComposeArea: View {
    @State private var write: String = ""
    @State private var isRecording: Bool = false
    @State private var selectedButton: Int = 0 // 0 for camera, 1 for record
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            Picker(selection: $selectedButton, label: Text("")) {
                Image(systemName: "camera.fill").tag(0)
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .foregroundColor(.blue)
            .font(.title)

            if selectedButton == 0 {
                Button(action: {
                    // Show image picker
                    self.showImagePicker.toggle()
                }) {
                    Image(systemName: "camera.fill")
                        .font(.title)
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(selectedImage: self.$selectedImage, sourceType: .camera)
                }
            } else {
                Button(action: {
                    // Toggle the recording state
                    isRecording.toggle()
                    if isRecording {
                        // Start recording logic
                        // Example: startRecording()
                    } else {
                        // Stop recording logic
                        // Example: stopRecording()
                    }
                }) {
                    Image(systemName: "mic.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
            }

            TextField("Write a message", text: $write)
                .font(.headline)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .foregroundColor(.black)
                .background(RoundedRectangle(cornerRadius: 20).stroke(Color.blue, lineWidth: 1))

            Button(action: {
                // Perform action to send the message
                // Example: SendMessageFunction(message: write)
                write = "" // Clear the text field after sending
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 3)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1)) // Add a subtle background
        .cornerRadius(20)
        .shadow(radius: 5) // Add shadow for depth
    }
}

// Example startRecording and stopRecording functions
// Implement your own recording logic here
extension ComposeArea {
    func startRecording() {
        print("Recording started")
    }

    func stopRecording() {
        print("Recording stopped")
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImage: UIImage?

    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
