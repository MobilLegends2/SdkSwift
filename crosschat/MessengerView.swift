import SwiftUI

// View for outgoing message
struct OutgoingDoubleLineMessage: View {
    let message: MessagesStructure
    let outgoingBubble = Color(#colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1))
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
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
            if message.sender == "You" {
                EmojiButton()
                    .foregroundColor(.blue)
            }
        }
    }
}

// View for incoming message
struct IncomingDoubleLineMessage: View {
    let message: MessagesStructure
    let incomingBubble = Color.gray

    var body: some View {
        HStack {
            if message.sender != "You" {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            VStack {
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
                }
            }
            Image("incomingTail")
                .resizable()
                .frame(width: 10, height: 10)
                .padding(.leading, -5)
        }
    }
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
        .sheet(isPresented: $isEmojiPickerPresented) {
            EmojiPickerView(isPresented: $isEmojiPickerPresented)
        }
    }
}

// Emoji picker view
struct EmojiPickerView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Text("Emoji Picker")
                .font(.title)
                .padding()
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                    ForEach(["😊", "😂", "😍", "👍", "👏", "❤️", "🔥", "🎉", "🤔"], id: \.self) { emoji in
                        Button(action: {
                            // Handle emoji selection here
                            print("Selected emoji: \(emoji)")
                            isPresented = false
                        }) {
                            Text(emoji)
                                .font(.largeTitle)
                        }
                        .padding(5)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
}

struct MessengerView: View {
    let senderName: String
    @State private var messages: [MessagesStructure] = MessageData

    var body: some View {
        VStack {
                   HStack {
                       VStack(alignment: .leading) {
                           Text(senderName) // Dynamic sender name
                               .font(.title)
                               .foregroundColor(.black)
                               .padding(.leading, 8) // Add some padding between the online indicator and sender name
                       }
                       Circle()
                           .fill(Color.green)
                           .frame(width: 10, height: 10)
                       Text("Online")
                           .font(.caption)
                           .foregroundColor(.gray) // Adjust color as needed

                       
                       Spacer()
                       
                       Image(systemName: "video.fill") // Video call icon
                           .font(.title)
                           .foregroundColor(.blue)
                       Image(systemName: "phone.fill") // Voice call icon
                           .font(.title)
                           .foregroundColor(.blue)
                   }
                   .padding()
            
            ScrollView {
                VStack(spacing: 8) {
                    ForEach($messages) { $message in
                        if message.sender == "You" { // Assuming "You" are sending the messages
                            OutgoingDoubleLineMessage(message: message)
                        } else {
                            IncomingDoubleLineMessage(message: message)
                        }
                    }
                }
                .padding()
            }
            
            ComposeArea()
        }
        .padding(.bottom) // Add padding to ensure the ComposeArea is above the safe area
        .navigationBarBackButtonHidden(true) // Hide the automatic back button

    }
}
struct ComposeArea: View {
    @State private var write: String = ""
    
    var body: some View {
        HStack {
            Image(systemName: "camera.fill")
                .font(.title)
            Image("store")
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
        }
        .foregroundColor(Color(.systemGray))
        .padding()
    }
}


