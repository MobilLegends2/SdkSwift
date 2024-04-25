//
//  crosschatApp.swift
//  crosschat
//
//  Created by arafetksiksi on 25/4/2024.
//

import SwiftUI

@main
struct crosschatApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
