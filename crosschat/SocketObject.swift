import SwiftUI
import SocketIO

class SocketObject: ObservableObject {
    static var shared = SocketObject()
    let ipAddress = "http://192.168.78.249:9090"
    let service = Service()
    var manager: SocketManager!
    var socket: SocketIOClient!
    var status: String!

    init() {
        self.manager = SocketManager(socketURL: URL(string: ipAddress)!, config: [.log(false), .compress])
        self.socket = self.manager.defaultSocket

        socket.on(clientEvent: .connect) { (data, ack) in
            print("Socket connected")
        }
        socket.on(clientEvent: .disconnect) { (data, ack) in
            print("Socket disconnected")
        }
        socket.onAny { (event) in
            let responseObj = JSONUtility.getJson(objects: event.items!)
            print("----------- %@\n\n", event.event, event.items as Any)
            print("----------- %@\n items %@", event.event, responseObj as Any)
        }
        socket.on("UpdateSocket") { (object, ack) in
            print("Socket response UpdateSocket : %@", object)

            if (object.count > 0) {
                if let responseObj = object[0] as? NSDictionary {
                    if responseObj.value(forKey: self.status) as? String ?? "" == "1" {
                        print("success status")
                    } else {
                        print("fail status")
                    }
                }
            }
        }
        socket.connect(timeoutAfter: 0) {
            print("--------------%d", self.socket.status)
        }
        socket.connect()
    }

    func emit(event: String, with items: NSArray) {
        switch self.socket.status {
        case .connected:
            self.socket.emit(event, items)
        case .connecting:
            print("\n\n ---------- Connecting ... --------------/n/n", event)
            self.socket.once(clientEvent: .connect) { (object, ack) in
                self.socket.emit(event, items)
                print("\n\n---------ConnectOnce-----\n\n", event)
            }
        case .disconnected:
            print("\n\n ---------- Disconnected --------------/n/n", event)
        default:
            break
        }
    }

    func joinConversation(conversationId: String) {
        switch self.socket.status {
        case .connected:
            socket.emit("join_conversation", conversationId)
        case .connecting:
            print("Socket is still connecting...")
            self.socket.once(clientEvent: .connect) { [weak self] _, _ in
                guard let self = self else { return }
                self.socket.emit("join_conversation", conversationId)
            }
        case .disconnected:
            print("Socket is disconnected.")
        default:
            break
        }
    }

    func sendMessage(conversationId: String, message: String, sender: String, type: String) {
        let messageData: [String: Any] = [
            "sender": sender,
            "conversation": conversationId,
            "content": message,
            "type": type
        ]
        socket.emit("new_message_\(conversationId)", messageData)
    }

    func listenForMessages(conversationId: String, completion: @escaping ([MessagesStructure]) -> Void) {
        socket.on("new_message_\(conversationId)") { [weak self] (data, ack) in
            guard let self = self else { return }

            print("New message received:", data)

            self.service.fetchMessages(conversationId: conversationId) { json, error in
                if let error = error {
                    print("Error fetching messages: \(error)")
                    return
                }

                if let json = json {
                    if let messagesData = json["messages"] as? [[String: Any]] {
                        let messages = messagesData.compactMap { messageData in
                            MessagesStructure(
                                id: messageData["_id"] as? String ?? "",
                                sender: messageData["sender"] as? String ?? "",
                                content: messageData["content"] as? String ?? "",
                                timestamp: messageData["timestamp"] as? String ?? "",
                                type: messageData["type"] as? String ?? "",
                                emoji: (messageData["emojis"] as? [String])?.first ?? ""
                            )
                        }
                        DispatchQueue.main.async {
                            completion(messages)
                        }
                    }
                }
            }
        }
    }
}
