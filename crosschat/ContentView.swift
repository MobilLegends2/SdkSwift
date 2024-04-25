//
//  ContentView.swift
//  crosschat
//
//  Created by arafetksiksi on 25/4/2024.
//

import SwiftUI
import CoreData


struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                NavigationLink(destination: MessengerView(senderName: "Arafet")) {
                    Text("Chats")
                        .font(.title)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                Spacer()
            }
            .navigationBarTitle("Home")
        }
    }
}


