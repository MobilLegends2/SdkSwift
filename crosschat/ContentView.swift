import SwiftUI

struct ContentView: View {
    static var currentUser = "participant2"
    
    @State private var isChatsViewPresented = false // State to track if ChatsView is presented
    
    var body: some View {
        VStack {
            Button(action: {
                isChatsViewPresented = true // Set isChatsViewPresented to true to present ChatsView
            }) {
                Text("Chats")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .fullScreenCover(isPresented: $isChatsViewPresented) { // Present ChatsView when isChatsViewPresented is true
                ChatsView(users: users, currentUser: ContentView.currentUser, apiKey: "123456789")
                    .navigationBarBackButtonHidden(true) // Hide the navigation back button in ChatsView
            }
            Spacer()
        }
        .navigationTitle("Home")
    }
}

private let users = [
    User(name: "Alice", status: "Online", image: "Alice"),
    User(name: "Bob", status: "Offline", image: "Bob"),
    User(name: "Charlie", status: "Online", image: "Charlie"),
    // Add more users as needed
]
