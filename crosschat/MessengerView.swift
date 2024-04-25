import SwiftUI

// View for outgoing message
struct OutgoingDoubleLineMessage: View {
    let message: MessagesStructure
    let outgoingBubble = Color(#colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1))
    let senderName = "Arafet"

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
    @State private var isEmojiPickerPresented = false // Add state for emoji picker
    
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
              //      EmojiButton() // Add EmojiButton here
                       // .foregroundColor(.gray)
                }
            }
            Image("incomingTail")
                .resizable()
                .frame(width: 10, height: 10)
                .padding(.leading, -5)
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
                        HStack {
                            if message.sender == "You" {
                                OutgoingDoubleLineMessage(message: message)
                            } else {
                                IncomingDoubleLineMessage(message: message)
                            }
                            if message.sender != "You" { // Only show EmojiButton for incoming messages
                                EmojiButton()
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                    }
                }
            }

            
            ComposeArea()
        }
        .padding(.bottom) // Add padding to ensure the ComposeArea is above the safe area
        .navigationBarBackButtonHidden(true) // Hide the automatic back button

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


