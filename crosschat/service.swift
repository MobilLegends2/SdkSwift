//
//  service.swift
//  crosschat
//
//  Created by arafetksiksi on 25/4/2024.
//

import Foundation

class Service {
    let ipAddress = "172.18.23.21:9090"
    let conversationId = "10.0.2.2"
    let currentUser = "participant2"
    func fetchMessages(conversationId: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        let url = URL(string: "http://\(ipAddress)/conversations/\(conversationId)/messages")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(json, nil)
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    func sendMessage(conversationId: String, message: String, type: String) {
        let url = URL(string: "http://\(ipAddress)/conversations/\(conversationId)/messages")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let parameters: [String: Any] = [
            "sender": currentUser,
            "content": message,
            "conversation": conversationId,
            "type": type
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("Error sending message: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            print("Message sent successfully")
        }.resume()
    }
    func fetchConversations(currentUser: String, completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        let url = URL(string: "http://\(ipAddress)/conversation/\(currentUser)")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    completion(jsonResponse, nil)
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    func createOrGetConversation(clickedUserId: String,  completion: @escaping (String?, Error?) -> Void) {
        let url = URL(string: "http://\(ipAddress)/conversation/\(currentUser)/\(clickedUserId)")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let conversationId = jsonResponse["_id"] as? String {
                    completion(conversationId, nil)
                    
                } else {
                    completion(nil, NSError(domain: "ServiceError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create or get conversation"]))
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }

}
