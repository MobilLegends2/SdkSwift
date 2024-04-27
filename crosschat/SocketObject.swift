//
//  SocketObject.swift
//  crosschat
//
//  Created by arafetksiksi on 27/4/2024.
//

import SwiftUI
import SocketIO

class SocketObject: ObservableObject {
    static var shared = SocketObject()
    let ipAddress = "http://172.18.23.21:9090"

    var manager: SocketManager!
    var socket: SocketIOClient!
    var status: String!
    
    init() {
        self.manager = SocketManager(socketURL: URL(string:ipAddress)!, config: [.log(false), .compress])
        self.socket = self.manager.defaultSocket
        
        socket.on(clientEvent: .connect) { (data,ack) in
                print("Socket connected")
        }
        socket.on(clientEvent: .disconnect) { (data,ack) in
                print("Socket disconnected")
        }  
        socket.onAny{ (event) in
            let responseObj = JSONUtility.getJson(objects: event.items!)
            print("----------- %@\n\n", event.event, event.items as Any)
            print("----------- %@\n items %@", event.event, responseObj as Any)
        }
        socket.on("UpdateSocket") { (object, ack) in
            print("Socket response UpdateSocket : %@", object)
            
            if (object.count > 0) {
                if let responseObj = object[0] as? NSDictionary {
                    if responseObj.value(forKey: self.status) as? String ?? "" == "1" {
                        print("succes status")
                    }else{
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
            break
    case .connecting:
        print("\n\n ---------- Connecting ... --------------/n/n", event)
        self.socket.once(clientEvent: .connect) {(object, ack) in
            self.socket.emit(event, items)
            print("\n\n---------ConnectOnce-----\n\n", event)
        }
        break
    case.disconnected:
        print("\n\n ---------- Disconnected --------------/n/n", event)
        break
    default:
        break
        }
    }
    func updateSocket(){
        
    }
    func joinConversation(conversationId: String) {
        switch self.socket.status {
        case .connected:
            socket.emit("join_conversation", conversationId)
        case .connecting:
            // If the socket is still connecting, wait for it to connect and then emit the event
            print("Socket is still connecting...")
            self.socket.once(clientEvent: .connect) { [weak self] _, _ in
                guard let self = self else { return }
                self.socket.emit("join_conversation", conversationId)
            }
        case .disconnected:
            // If the socket is disconnected, handle the situation accordingly
            print("Socket is disconnected.")
        default:
            break
        }
    }

    func sendMessage(conversationId: String, message: String, sender: String) {
        let messageData: [String: Any] = [
            "sender": sender,
            "conversation": conversationId,
            "content": message
        ]
        socket.emit("new_message_\(conversationId)", messageData)
    }

    
    func listenForMessages(conversationId: String, completion: @escaping (String) -> Void) {
        socket.on("new_message_\(conversationId)") { (data, ack) in
            if let message = data.first as? String {
                completion(message)
            }
        }
    }
}


