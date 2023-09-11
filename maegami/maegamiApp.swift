//
//  maegamiApp.swift
//  maegami
//
//  Created by sayakoakamatsu on 2023/06/11.
//

import SwiftUI

@main
struct maegamiApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TipsView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
