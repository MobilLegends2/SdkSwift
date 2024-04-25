//
//  MessagesDataModel.swift
//  MessagesDataModel
//
//  Created by Amos Gyamfi from Stream on 15/12/2021.
//

import Foundation

// Data structure
struct MessagesStructure: Identifiable {
    var id = UUID()
    var unreadIndicator: String
    var avatar: String
    var sender: String
    var content: String
    var timestamp: String
}

// Data storage
let MessageData = [

    MessagesStructure(unreadIndicator: "", avatar: "martin", sender: "You", content: "I don't know why people are so anti pineapple pizza. I kind of like it.", timestamp: "12:40 AM"),
    MessagesStructure(unreadIndicator: "", avatar: "jeroen", sender: "Zach Friedman", content: "(Sad fact: you cannot search for a gif of the word “gif”, just gives you gifs.)", timestamp: "11:00 AM"),
    MessagesStructure(unreadIndicator: "", avatar: "carla", sender: "You", content: "There's no way you'll be able to jump your motorcycle over that bus.", timestamp: "10:36 AM"),
    MessagesStructure(unreadIndicator: "", avatar: "zain", sender: "Dee McRobie", content: "Tabs make way more sense than spaces. Convince me I'm wrong. LOL.", timestamp: "9:59 AM"),
  
]
