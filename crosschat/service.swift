//
//  service.swift
//  crosschat
//
//  Created by arafetksiksi on 25/4/2024.
//

import Foundation

class Service {
    let ipAddress = "192.168.231.138"
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
        request.setValue(ContentView.apiKey, forHTTPHeaderField: "X-Secret-Key")
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
        var request = URLRequest(url: url)
        request.setValue(ContentView.apiKey, forHTTPHeaderField: "X-Secret-Key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
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
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // or "POST" if you are creating a conversation
        request.setValue(ContentView.apiKey, forHTTPHeaderField: "X-Secret-Key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
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

    func addReaction( messageId: String, reaction: String) {
        let url = URL(string: "http://\(ipAddress)/message/\(messageId)/emoji")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(ContentView.apiKey, forHTTPHeaderField: "X-Secret-Key")
        let parameters: [String: Any] = [
            "emoji": reaction, // Ensure that the key is "emoji"
            "user": currentUser
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("Error adding reaction: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            print("Reaction added successfully")
        }.resume()
        
    }
    func deleteConversation(conversationId: String, completion: @escaping (Error?) -> Void) {
        let url = URL(string: "http://\(ipAddress)/conversations/\(conversationId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(ContentView.apiKey, forHTTPHeaderField: "X-Secret-Key")
        request.setValue("é", forHTTPHeaderField: "X-Secret-Key") // Add secret key to the headers
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }


    func sendAttachment(conversationId: String, fileURL: URL, completion: @escaping (String?, Error?) -> Void) {
        let url = URL(string: "http://\(ipAddress)/conversations/\(conversationId)/attachments")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(ContentView.apiKey, forHTTPHeaderField: "X-Secret-Key")
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let body = NSMutableData()

        // Add file data to the request body
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"attachment\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        body.append(try! Data(contentsOf: fileURL))
        body.append("\r\n".data(using: .utf8)!)

        // Final boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body as Data

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let url = json["url"] as? String {
                    completion(url, nil)
                } else {
                    completion(nil, NSError(domain: "ServiceError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to send attachment"]))
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }

}
