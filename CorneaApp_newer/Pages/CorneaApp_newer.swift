//
//  CorneaApp_newerApp.swift
//  CorneaApp_newer
//
//  Created by Yoshiyuki Kitaguchi on 2021/12/13.
//

import SwiftUI

@main
struct CorneaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
